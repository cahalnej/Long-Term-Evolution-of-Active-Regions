pro ar_track

cd, '/home/jack/SSProject/2015-10-5/2001Extract/'
filenames = file_search('*.fits')
num = 50
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
;---------------------------------------------------------------------------------------------------------;
;Individually store each AR
;---------------------------------------------------------------------------------------------------------;
	stri = string(i)
	stri = strtrim(i, 1)
	name = 'AR'+stri
	result = IDL_validname(name)
	savedStruc = create_struct(NAME=result, 'quickmap',quickmap.data,'areabnd', mag.areabnd, $
	'posareabnd', mag.posareabnd, 'negareabnd', mag.negareabnd, 'posarea', mag.posarea, 'negarea', $
	mag.negarea, 'totalarea', mag.totarea, 'bmax', mag.bmax, 'bmin', mag.bmin, 'totflx', mag.totflx, $
	'posflx', mag.posflx, 'negflx', mag.negflx)
	if execute('AR'+string(i,Format='(I3.3)')+$
	'=savedStruc') EQ 0 THEN $
	Print, 'We have a failure to execute!'

endfor

strucarr = [AR001, AR002, AR003, AR004, AR005, AR006, AR007, AR008, AR009, AR010]

create_features, thismap.data, coremask, features,  dx=params.yaftadx, min_size=params.yaftaminsize, peakthreshold=params.yaftapeakthresh

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
	print, 'AR ',printi,' should be observable in the next ' ,num2print, ' magnetograms.'
endfor

total=nar
numinput =  max(num2obs)-3
candxcores = xarcores
candycores = yarcores
candloc = locations
mark = 0
magtrack = 0
;---------------------------------------------------------------------------------------------------------;
;Identify the ARs in the next max(num2obs) magnetograms and track these hoes
;---------------------------------------------------------------------------------------------------------;

for i = 1, 2 do begin
	newnum=num+i
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
	secondnar = max(seccoremask)
	if i eq 1 then nararr = secondnar else nararr = [nararr, secondnar]
	secorgcoremask = seccoremask
	pospropstr=ar_posprop(map=thismap, mask=seccoremask, cosmap=cosmap, params=params, $
	outpos=outpos, outneg=outneg, /nosigned, status=posstatus, datafile=thisdatafile)
	nextxarcores = [pospropstr.xcenbnd] 
	nextyarcores = [pospropstr.ycenbnd]

;---------------------------------------------------------------------------------------------------------;
;Isolate ARs, get properties, and create structure and map arrays
;---------------------------------------------------------------------------------------------------------;
	for l = 1, secondnar do begin
		map = thismap
		imgsz=size(map.data,/dim)
		war =  where(seccoremask eq l)
		wnotar = where(seccoremask ne l)
		thisarmask = seccoremask
		thisarmask[wnotar] = 0
		thisarmask[war] = 1
		quickmap = map
		quickmap.data = map.data*thisarmask
		if mark eq 0 then begin 
		recutmaparr = quickmap 
		endif else begin
		recutmaparr = [recutmaparr, quickmap]
		endelse
		magpropstr=ar_magprop(map=quickmap, mask=thisarmask, cosmap=cosmap, params=params)
		if mark eq 0 then begin 
		remagproparr=magpropstr 
		endif else begin
		remagproparr = [remagproparr, magpropstr]
		endelse
		mark = mark+1
	endfor

;---------------------------------------------------------------------------------------------------------;
;Update locations and then identify ARs in the magnetogram
;---------------------------------------------------------------------------------------------------------;
	onto=candxcores+90
	nextlon = candloc[1,*]+17
	lats = candloc[0,*]
	monitor=0
	tracked=0
	if i gt 1 then prevnotables=notables

	for j = 0, n_elements(nextlon)-1 do begin
		wcs_convert_to_coord, wcs, coord, 'HG', nextlon[j], lats[j]
		result = finite(coord)
		source = j
		;if i gt 1 then source = prevnotables[0,j]
		if result[0] && result[1] ne 0 then begin
			pixel = wcs_get_pixel(wcs, [coord[0], coord[1]])
			if onto[j] lt 1024 then begin
				loniden = seccoremask[pixel[0],pixel[1]]
				pixiden = seccoremask[onto[j], candycores[j]]
				if (loniden gt 0) || (pixiden gt 0) then begin
					if tracked eq 0 then notables = [j,loniden,pixiden] $
					else notables = [[notables],[j,loniden,pixiden]]
					if pixiden gt 0 then begin
					relevantcore = [nextxarcores[pixiden-1], nextyarcores[pixiden-1]]
					poscoord = wcs_get_coord(wcs, [nextxarcores[pixiden-1], nextyarcores[pixiden-1]])
					endif else begin
					relevantcore = [nextxarcores[loniden-1], nextyarcores[loniden-1]]
					poscoord = wcs_get_coord(wcs, [nextxarcores[loniden-1], nextyarcores[loniden-1]])
					endelse
					wcs_convert_from_coord, wcs, poscoord, 'hg', lon, lat
					if tracked eq 0 then newloc = [lat, lon] else newloc = [[newloc],[lat,lon]]
					if tracked eq 0 then candcores = relevantcore else candcores = [[candcores],[relevantcore]]
					tracked=tracked+1				
				endif
			endif
			if monitor eq 0 then xpix = pixel[0] else xpix = [xpix,pixel[0]]
			if monitor eq 0 then ypix = pixel[1] else ypix = [ypix,pixel[1]]
			monitor=monitor+1
		endif	
	endfor

;---------------------------------------------------------------------------------------------------------;
;Housekeeping that has to be done beyond i=1
;---------------------------------------------------------------------------------------------------------;
if i gt 1 then begin
print, notables[]
endif

;---------------------------------------------------------------------------------------------------------;
;Make a quick auld movie of each tracked AR
;---------------------------------------------------------------------------------------------------------;
	orgtotal = total	
	newtotal = orgtotal + secondnar
	help, recutmaparr
	for m = 0, n_elements(notables[0,*])-1 do begin
		if i eq 1 then begin
			;if notables[1,m] ne 0 then begin
			;	loadct, 0
			;	plot_image, magscl(cutmaparr[notables[0,m]].data)
			;	wait, 1
			;;	plot_image, magscl(recutmaparr[notables[1,m]-1].data)
			;	wait, 1
			;endif else begin
			;	loadct, 0
			;	plot_image, magscl(cutmaparr[notables[0,m]].data)
			;	wait, 1
			;	plot_image, magscl(recutmaparr[notables[2,m]-1].data)
			;endelse
		endif else begin
			print, nararr[i-2], nararr[i-1]
			if notables[1,m] ne 0 then begin
				loadct, 0
				print, notables[0,m],'loniden'
				plot_image, magscl(recutmaparr[ notables[0,m]].data)
				wait, 1
				print, notables[0,m],'loniden'
				plot_image, magscl(recutmaparr[notables[1,m]-1+nararr[i-2]].data)
				pause
			endif else begin
				loadct, 0
				print, notables[0,m],'pixiden'
				plot_image, magscl(recutmaparr[notables[0,m]].data)
				wait, 1
				print, notables[2,m],'pixiden'
				plot_image, magscl(recutmaparr[notables[2,m]-1+nararr[i-2]].data)
				pause
			endelse
		endelse
	endfor
;---------------------------------------------------------------------------------------------------------;
;Compare some value from earlier, say totarea
;---------------------------------------------------------------------------------------------------------;
	for n = 0, n_elements(notables[0,*])-1 do begin
		print, notables[0,n], notables[1,n], notables[2,n]
		if notables[1,n] ne 0 then begin
			print, magproparr[notables[0,n]].totarea, remagproparr[notables[1,n]-1].totarea
			if magtrack eq 0 then begin
				magarr = [magproparr[notables[0,n]].totarea, remagproparr[notables[1,n]-1].totarea]
				magtrack = magtrack+1
			endif else begin
				magarr = [[magarr], [magproparr[notables[0,n]].totarea, remagproparr[notables[1,n]-1].totarea]]
			endelse
		endif else begin
			print, magproparr[notables[0,n]].totarea, remagproparr[notables[2,n]-1].totarea
			if magtrack eq 0 then begin
				magarr = [magproparr[notables[0,n]].totarea, remagproparr[notables[1,n]-1].totarea]
				magtrack = magtrack+1
			endif else begin
				magarr = [[magarr], [magproparr[notables[0,n]].totarea, remagproparr[notables[1,n]-1].totarea]]
			endelse			
		endelse
	endfor
;---------------------------------------------------------------------------------------------------------;
;Now for the housekeeping, making sure everything is alright
;---------------------------------------------------------------------------------------------------------;
	window, i
	loadct, 0
	plot_image, magscl(thismap.data)
	loadct, 13
	oplot, nextxarcores, nextyarcores, psym=4, color=255
	contour, seccoremask, level=0.5, c_colors=255, /over
	;contour, coremask, level=0.5, c_colors = 205, /over
	oplot, onto, candycores, psym = 1, color = 125
	oplot, xpix, ypix, psym = 1, color = 200
	candloc = newloc
	candxcores = candcores[0,*]
	candycores = candcores[1,*]
	;print, candloc, candxcores, candycores

endfor

cd, '/home/jack/SSProject/Track/'

end
