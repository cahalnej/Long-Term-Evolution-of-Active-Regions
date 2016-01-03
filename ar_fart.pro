pro ar_fart

cd, '/home/jack/SSProject/2015-10-5/2001Extract/'
filenames = file_search('*.fits')
num = 0
nfile = N_Elements(filenames)-1
filename = filenames[num] 
;------------------------------------------------------------------------------;
;Set up parameters
;------------------------------------------------------------------------------;
t1=systim(/utc)
DEFSYSV, '!AR_PATH', '/home/jack/IDL/Lib/smart_library/'
DEFSYSV, '!AR_PARAM', 'ar_param.txt'
fparam = '/home/jack/IDL/Lib/smart_library/ar_param.txt'
params = ar_loadparam(fparam=fparam)

;------------------------------------------------------------------------------;
;Analyse First Magnetogram and Identify ARs
;------------------------------------------------------------------------------;
gethdr = readfits(filename, hdr)
thismap = ar_readmag(filename)
fdate = time2file(thismap.time,/date)
fyyyy = strmid(fdate,0,4)
thisarstr = ar_detect_core(thismap, /nosmart, /doprocess, mapproc=thisproc, $
params=params, status=corestatus, cosmap=cosmap, limbmask=limbmask, /nocosmic)
thismap = thisproc
mask = ar_core2mask(thisarstr.data)
coremask = ar_core2mask(thisarstr.data ,smartmask=coresmblob, $
coresmartmask=coresmblob_conn)
orgcoremask = coremask
nar = max(coremask)
pospropstr=ar_posprop(map=thismap, mask=coremask, cosmap=cosmap, params=params, $
outpos=outpos, outneg=outneg, /nosigned, status=posstatus, datafile=thisdatafile)
coremask = abs(coremask)
xarcores = [pospropstr.xcenbnd] 
yarcores = [pospropstr.ycenbnd]

;------------------------------------------------------------------------------;
;Analyse the Individual ARs in the first magnetogram
;------------------------------------------------------------------------------;

for i = 1, nar do begin
	source = i
	map = thismap
	imgsz=size(map.data,/dim)
	war =  where(coremask eq i)
	wnotar = where(coremask ne i) 
	thisarmask = coremask
	thisarmask[wnotar] = 0
	thisarmask[war] = 1
	quickmap = map
	quickmap.data = map.data*thisarmask
	if i eq 1 then cutmaparr = quickmap else cutmaparr = [cutmaparr, quickmap]
	magpropstr=ar_magprop(map=quickmap, mask=thisarmask, cosmap=cosmap, params=params)
	if i eq 1 then magproparr=magpropstr else magproparr = [magproparr, magpropstr]
	mag=magpropstr
endfor

;----------------------------------------------------------------------------------------------------------;
;For each AR compute how many more magnetograms it should appear in and then track it in those magnetograms
;----------------------------------------------------------------------------------------------------------;
for i = 1, nar do begin
	xcent=xarcores[i-1]
	ycent=yarcores[i-1]
	wcs = fitshead2wcs(hdr)
	poscoord = wcs_get_coord(wcs, [xcent, ycent])
	wcs_convert_from_coord, wcs, poscoord, 'hg', lon, lat
	longitude = string(lon)
	longitude = strtrim(longitude, 1)
	latitude = string(lat)
	latitude = strtrim(latitude, 1)
	;print, 'Longitude: ',longitude,' Latitude: ', latitude
	necessary = 90 - lon
	if i eq 1 then locations = [lat, lon] else locations = [[locations],[lat, lon]]
	number = necessary/18
	number = fix(number)
	printi = string(i,Format='(I3.3)')
	num2print = string(number)
	num2print = strtrim(num2print, 1)
	if i eq 1 then num2obs = number else num2obs = [num2obs, number]
	;print, 'AR ',printi,' should be observable in the next ' ,num2print, ' magnetograms.'
endfor

total=nar
numinput =  max(num2obs)-3
candxcores = xarcores
candycores = yarcores
candloc = locations
mark = 0
magtrack = 0

;-----------------------------------------------------------------------------------------------------------;
;Create Arrays of the Next NumInput Magnetograms
;-----------------------------------------------------------------------------------------------------------;

for j = 1, max(num2obs) do begin
	newnum=num+j
	filename = filenames[newnum]
	gethdr = readfits(filename, hdr)
	wcs = fitshead2wcs(hdr)
	thismap = ar_readmag(filename)
	fdate = time2file(thismap.time,/date)
	fyyyy = strmid(fdate,0,4)
	thisarstr = ar_detect_core(thismap, /nosmart, /doprocess, mapproc=thisproc, $
	params=params, status=corestatus, cosmap=cosmap, limbmask=limbmask, /nocosmic)
	thismap = thisproc
	mask = ar_core2mask(thisarstr.data)
	seccoremask = ar_core2mask(thisarstr.data ,smartmask=coresmblob, $
	coresmartmask=coresmblob_conn)
	corestr=create_struct('j', j, 'data', seccoremask)
	secondnar = max(seccoremask)
	secorgcoremask = seccoremask
	pospropstr=ar_posprop(map=thismap, mask=seccoremask, cosmap=cosmap, params=params, $
	outpos=outpos, outneg=outneg, /nosigned, status=posstatus, datafile=thisdatafile)
	nextxarcores = [pospropstr.xcenbnd] 
	nextyarcores = [pospropstr.ycenbnd]
	if j eq 1 then maskmaparr=thisarstr else maskmaparr=[maskmaparr,thisarstr]
	if j eq 1 then magmaparr=thismap else magmaparr=[magmaparr,thismap]
	if j eq 1 then nararr = secondnar else nararr = [nararr, secondnar]
	if j eq 1 then posproparr=pospropstr else posproparr=[posproparr,pospropstr]
	if j eq 1 then coremaskarr = corestr else coremaskarr = [coremaskarr, corestr]
endfor

;-----------------------------------------------------------------------------------------------------------;
;Analyse each individual AR over the number of magnetograms it should appear in and plot the necessary
;properties
;-----------------------------------------------------------------------------------------------------------;

for i=0,nar-1 do begin
	total = 0
	fmditrack = 0
	run = num2obs[i]
	latitude = locations[0,i]
	longitude = locations[1,i]
	xcore = xarcores[i]
	ycore = yarcores[i]
	for j = 0, run-1 do begin
		monitor=0
		onto = xcore+90
		nextlon = longitude+17
		mask = coremaskarr[j].data
		wcs_convert_to_coord, wcs, coord, 'HG', nextlon, latitude
		result = finite(coord)
		if result[0] && result[1] ne 0 then begin
		if onto lt 1024 then begin
			pixel = wcs_get_pixel(wcs, [coord[0], coord[1]])
			loniden = mask[pixel[0],pixel[1]]
			pixiden = mask[onto, ycore]
			if (loniden gt 0) || (pixiden gt 0) then begin
				if loniden gt 0 then trackar = loniden-1
				if pixiden gt 0 then trackar = pixiden-1
				postnum = trackar+total

;-----------------------------------------------------------------------------------------------------------;
;Get MagProp of AR in magnetogram
;-----------------------------------------------------------------------------------------------------------;
				map = magmaparr[j]
				imgsz=size(map.data,/dim)
				war =  where(mask eq trackar+1)
				wnotar = where(mask ne trackar+1) 
				thisarmask = mask
				thisarmask[wnotar] = 0
				thisarmask[war] = 1
				quickmap = map
				quickmap.data = map.data*thisarmask
				magpropstr=ar_magprop(map=quickmap, mask=thisarmask, cosmap=cosmap, params=params)
				if fmditrack eq 0 then begin
					bmax = [magproparr[i].bmax, magpropstr.bmax]
					bmin = [magproparr[i].bmin, magpropstr.bmin]
					totflx = [magproparr[i].totflx, magpropstr.totflx]
					posflx = [magproparr[i].posflx, magpropstr.posflx]
					negflx = [magproparr[i].negflx, magpropstr.negflx]
					totarea = [magproparr[i].totarea, magpropstr.totarea]
					negarea = [magproparr[i].negarea, magpropstr.negarea]
					posarea = [magproparr[i].posarea, magpropstr.posarea]
					areabnd = [magproparr[i].areabnd, magpropstr.areabnd]
					posareabnd = [magproparr[i].posareabnd, magpropstr.posareabnd]
					negareabnd = [magproparr[i].negareabnd, magpropstr.negareabnd]
				endif else begin
					bmax = [bmax,magpropstr.bmax]
					bmin = [bmin,magpropstr.bmin]
					totflx = [totflx,magpropstr.totflx]
					posflx = [posflx,magpropstr.posflx]
					negflx = [negflx,magpropstr.negflx]
					totarea = [totarea,magpropstr.totarea]
					negarea = [negarea,magpropstr.negarea]
					posarea = [posarea,magpropstr.posarea]
					areabnd = [areabnd, magpropstr.areabnd]
					posareabnd = [posareabnd, magpropstr.posareabnd]
					negareabnd = [negareabnd, magpropstr.negareabnd]				
				endelse

;-----------------------------------------------------------------------------------------------------------;
;Get MagProp of AR in magnetogram
;-----------------------------------------------------------------------------------------------------------;
				mag = quickmap.data
				postmp = where(mag ge 500)
				if postmp[0] gt 0 then begin
				posnumber= n_elements(postmp)
				mask = mag*0.0
				mask(postmp) = 1.0
				activeregion = mag*mask
				bpostotal = total(activeregion)
				cent = centroid(activeregion)
				xpos = [cent[0]]
				ypos = [cent[1]]
				negtmp = where(mag le -500)
				if negtmp[0] gt 0 then begin
				negnumber = n_elements(negtmp)
				negmask = mag*0.0
				negmask(negtmp) = 1.0
				activeregion = mag*negmask
				bnegtotal=total(activeregion)
				negcent = centroid(activeregion)
				xneg = [negcent[0]]
				yneg = [negcent[1]]
				image = readfits(filenames[num+j+1], hdr)
				wcs = fitshead2wcs(hdr)
				poscoord = wcs_get_coord(wcs, [xpos, ypos])
				wcs_convert_from_coord, wcs, poscoord, 'hg', poslon, poslat
				negcoord = wcs_get_coord(wcs, [xneg, yneg])
				wcs_convert_from_coord, wcs, negcoord, 'hg', neglon, neglat
				if poslon gt neglon then begin
					leadingnum  = posnumber
					trailingnum = negnumber
					leadingb    = bpostotal
					trailingb   = bnegtotal
				endif else begin
					leadingnum  = negnumber
					trailingnum = posnumber
					trailingb   = bpostotal
					leadingb    = bnegtotal
				endelse
				if fmditrack eq 0 then begin
					leadingarr  = leadingnum
					trailingarr = trailingnum
					leadbarr    = leadingb
					trailbarr   = trailingb
				endif else begin
					leadingarr  = [leadingarr, leadingnum]
					trailingarr = [trailingarr, trailingnum]
					leadbarr    = [leadbarr, leadingb]
					trailbarr   = [trailbarr, trailingb]				
				endelse
				endif
				endif

;-----------------------------------------------------------------------------------------------------------;
;Plot this AR and locations
;-----------------------------------------------------------------------------------------------------------;
				window, 0
				loadct, 0
				plot_image, magscl(quickmap.data)
				loadct, 13
				onarr = [onto]
				yarr = [ycore]
				oplot, onarr, yarr, psym = 4 , color=150
				xcent=[pixel[0]]
				ycent=[pixel[1]]
				oplot, xcent, ycent, psym = 4, color = 255
				xcore = posproparr[postnum].xcenbnd
				poscoord = wcs_get_coord(wcs, [posproparr[postnum].xcenbnd,posproparr[postnum].ycenbnd])
				wcs_convert_from_coord, wcs, poscoord, 'hg', longitude, latitude
				wait, 1
				fmditrack=1
			endif else begin
			endelse
		endif
		endif
		total = total + nararr[j]
	endfor

;-----------------------------------------------------------------------------------------------------------;
;Plot the magnetic properties garnered
;-----------------------------------------------------------------------------------------------------------;
if n_elements(bmax) gt 3 then begin
	!p.multi = [0, 3, 2]
	window, i, xsize = 1500, ysize = 825
	loadct, 0
	plot, areabnd, color = 0, background = 255, xrange = [-0.5, n_elements(areabnd)-0.5], $
	xtitle = 'Days', ytitle = 'Area of Active Region', charsize = 1.5, $
	title = 'Area Bounded by Active Region'
	loadct, 13
	oplot, posareabnd, color = 255
	oplot, negareabnd, color = 125

	loadct, 0
	plot, totarea, color = 0, background = 255, xrange = [-0.5, n_elements(totarea)-0.5], $
	xtitle = 'Days since detection',  charsize = 1.5, $
	title = 'Positive and Negative Areas of the AR'
	loadct, 13
	oplot, posarea, color = 255
	oplot, negarea, color = 125
	
	loadct, 0
	plot, totflx, color = 0, background = 255, xrange = [-0.5, n_elements(totflx)-0.5], $
	xtitle = 'Days since detection', title = 'Flux in the AR',  charsize = 1.5, $
	ytitle = 'Magnetic Flux (Maxwells)'
	loadct, 13
	oplot, posflx, psym = 0, color = 255
	oplot, negflx, psym = 0, color = 125
	
	if max(bmax) gt max(abs(bmin)) then ymax = max(bmax) else ymax = max(abs(bmin))
	
	loadct, 0
	plot, bmax, color = 0, background = 255, xrange = [-0.5, n_elements(bmax)-0.5],$
	xtitle = 'Days since detection', ytitle = 'Magnetic Field (Gauss)',  yrange = [0, ymax], $
	title = 'Maximum and Minimum Magnetic Field Values',  charsize = 1.5
	loadct, 13
	oplot, bmax, psym = 0, color = 255
	oplot, abs(bmin), psym = 0, color = 125

	if max(leadingarr) gt max(trailingarr) then ymax = max(leadingarr) else  ymax = max(trailingarr)
	if min(leadingarr) gt min(trailingarr) then ymin = min(leadingarr) else  ymin = min(trailingarr)

	loadct, 0
	plot, leadingarr, color = 0, background = 255, yrange = [ymin, ymax]
	loadct, 13
	oplot, leadingarr, psym = 0, color = 170
	oplot, trailingarr, psym = 0, color = 80

	if max(abs(leadbarr)) gt max(abs(trailbarr)) then ymax = max(abs(leadbarr)) else  ymax = max(abs(trailbarr))
	if min(abs(leadbarr)) gt min(abs(trailbarr)) then ymin = min(abs(leadbarr)) else  ymin = min(abs(trailbarr))

	loadct, 0
	plot, abs(leadbarr), color = 0, background = 255, yrange = [ymin, ymax]
	loadct, 13
	oplot, abs(leadbarr), psym = 0, color = 170
	oplot, abs(trailbarr), psym = 0, color = 80	

	!P.MULTI = 0
endif
endfor

;-----------------------------------------------------------------------------------------------------------;
;And finish up there
;-----------------------------------------------------------------------------------------------------------;

print,'Computation time='
print,anytim(systim(/utc))-anytim(t1),'s'

cd, '/home/jack/SSProject/Track/'

end
