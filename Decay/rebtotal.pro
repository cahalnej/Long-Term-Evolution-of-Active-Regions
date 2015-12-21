pro rebtotal, fmdi

DEFSYSV, '!AR_PATH', '/home/jack/IDL/Lib/smart_library/'
DEFSYSV, '!AR_PARAM', 'ar_param.txt'

t1=systim(/utc)

;----------------------------------------------------------;
;Set up parameters and input magnetogram
;----------------------------------------------------------;

fparam = './ar_param.txt'
params = ar_loadparam(fparam=fparam)
fmdi = fmdi

;----------------------------------------------------------;
;Dynamic range for scaling the magnetograms
;----------------------------------------------------------;

magdisplay = 1000

;----------------------------------------------------------;
;Read in a fits file (including WCS and full header)
;----------------------------------------------------------;

thismap = ar_readmag(fmdi)
maporig = thismap
fdate = time2file(thismap.time,/date)
fyyyy = strmid(fdate,0,4)

;----------------------------------------------------------;
;Create AR mask
;----------------------------------------------------------;

thisarstr = ar_detect_core(thismap,/nosmart, /doprocess, mapproc=thisproc, $
params=params, status=status, cosmap=cosmap, limbmask=limbmask)

;----------------------------------------------------------;
;Overwrite original data with processed
;----------------------------------------------------------;

thismap = thisproc
nar = max(thisarstr.data)
mask = ar_core2mask(thisarstr.data)

if max(mask) gt 0. then begin
pospropstr=ar_posprop(map=thismap, mask=mask, cosmap=cosmap, params=params)

;---------------------------------------------------------------------------;
;Additional code by Jack Cahalane on 14th October to get time of .fits file
;---------------------------------------------------------------------------;

getheader = readfits(fmdi, hdr)
T_OBS =  hdr[where(strmatch(hdr, 'T_OBS*', /FOLD_CASE) eq 1)]
justdate = STRMID(T_OBS, 11, 19)

;---------------------------------------------------------------------------;
;Further additional code by Jack Cahalane on 14th October
;---------------------------------------------------------------------------;

xpixelarray = (pospropstr.xcenbnd)
ypixelarray = (pospropstr.ycenbnd)

jkl = N_Elements(pospropstr.xcenbnd) - 1

;------------------------------------------------------------------------------;
;Make indexed core mask
;------------------------------------------------------------------------------;
coremask = ar_core2mask(thisarstr.data ,smartmask=coresmblob, $
coresmartmask=coresmblob_conn)

nar = max(coremask)

;------------------------------------------------------------------------------;
;For loop to analyse individual ARs
;------------------------------------------------------------------------------;

for i = 1, nar do begin

map = thismap
imgsz=size(map.data,/dim)
war =  where(coremask eq i)
wnotar = where(coremask ne i) 
thisarmask = coremask
thisarmask[wnotar] = 0
thisarmask[war] = 1
quickmap = map
quickmap.data = map.data*thisarmask

;------------------------------------------------------------------------------;
;Create cutout map
;------------------------------------------------------------------------------;

x1 = min(war mod imgsz[0])
y1 = min(war/imgsz[0])
x2 = max(war mod imgsz[0])
y2 = max(war/imgsz[0])

arbox = [x1, y1, x2, y2]
arxywidth = [arbox[2] - arbox[0], arbox[3] - arbox[1]]
arxycent = [arbox[0] + arxywidth[0]/2., arbox[1] + arxywidth[1]/2.]
hcarxywidth = arxywidth*map.dx
hcarxycent = (arxycent-imgsz/2.)*map.dx + [map.xc, map.yc]
narmap = map_cutout(quickmap, xycen = hcarxycent, xwidth = hcarxywidth[0], $
yheight = hcarxywidth[1], auxdat1 = thisarmask, outauxdat1 = narmask, $
auxdat2 = thisarmask, outauxdat2 = narthismask, auxdat3 = limbmask, $
outauxdat3 = narlimb)

;--------------------------------------------------------------------------;
;Determine centroid of pixel with Flux gt 500 Gauss
;--------------------------------------------------------------------------;

mag = narmap.data
area = n_elements(where(mag ne 0))
postmp = where(mag ge 500)
if postmp[0] gt 0 then begin
posnumber= n_elements(postmp)
mask = mag*0.0
mask(postmp) = 1.0
activeregion = mag*mask*narmask
posactive = activeregion
bpostotal = total(activeregion)

cent = centroid(activeregion)
xpos = [cent[0]]
ypos = [cent[1]]

;--------------------------------------------------------------------------;
;Determine the distance of each pixel from the centroid
;--------------------------------------------------------------------------;
height = n_elements(activeregion[0,*])
width = n_elements(activeregion[*,0])
distarr = activeregion*0
totalpos = where(activeregion[*,*] gt 0)
col = where(activeregion gt 0)/width
floatypos = float(where(activeregion gt 0))/width
row = long((floatypos - col)*width)
adj = row - cent[0]
opp = col - cent[1]
poldist = (opp^2 + adj^2)^0.5
sortposdist = poldist[sort(poldist)]
number = long(n_elements(sortposdist)*0.75)
criteria = sortposdist[number]

;--------------------------------------------------------------------------;
;Determine centroid of pixel with Flux lt -500 Gauss
;--------------------------------------------------------------------------;
negtmp = where(mag le -500)
negnumber = n_elements(negtmp)
if negtmp[0] gt 0 then begin

negmask = mag*0.0
negmask(negtmp) = 1.0
activeregion = mag*negmask*narmask
negactive = activeregion
bnegtotal=total(activeregion)

;loadct, 0
;plot_image, magscl(narmap.data)
;loadct, 13
;contour, negactive, /over, c_colors=125, c_thick=2
;contour, posactive, level=0.5, /over, color=255,c_thick=2
;oplot, row, col, psym=1, color=75
;oplot, xpos, ypos, psym = 4, color = 150

negcent = centroid(activeregion)
xneg = [negcent[0]]
yneg = [negcent[1]]

;-------------------------------------------------------------------------;
;Determine the distance of each pixel from negative centroid
;-------------------------------------------------------------------------;
height = n_elements(activeregion[0,*])
width = n_elements(activeregion[*,0])
totalpos = where(activeregion[*,*] lt 0)
col = where(activeregion lt 0)/width
floatypos = float(where(activeregion lt 0))/width
row = long((floatypos - col)*width)+1
adj = row - negcent[0]
opp = col - negcent[1]
negpoldist = (opp^2 + adj^2)^0.5
negsortposdist = negpoldist[sort(negpoldist)]
negnumber = long(n_elements(negsortposdist)*0.75)
negcriteria = negsortposdist[negnumber]

;loadct, 0
;plot_image, magscl(narmap.data)
;loadct, 13
;contour, negactive, /over, c_colors=125, c_thick=2
;contour, posactive, level=0.5, /over, color=255,c_thick=2
;oplot, row, col, psym=1, color=125
;oplot, xneg, yneg, psym = 4, color = 150

;-------------------------------------------------------------------------;
;Determine the percent of the AR occupied by high mag pixels
;-------------------------------------------------------------------------;
totalnum = negnumber + posnumber
totalnum = float(totalnum)
areapercent = (totalnum/area)*100

;-------------------------------------------------------------------------;
;Determine radius of perfect circle
;-------------------------------------------------------------------------;
poscircle = float(posnumber)
posradius = (poscircle/(!pi))^0.5
negcircle = float(negnumber)
negradius = (negcircle/(!pi))^0.5
poscomparison = criteria/posradius
negcomparison = negcriteria/negradius
;-------------------------------------------------------------------------;
;Print Information
;-------------------------------------------------------------------------;

;print, '75% of Positive Distribution:', string(criteria)
;print, '75% of Negative Distribution:', string(negcriteria)
;print, 'Area Percent:',string(areapercent), '%'
;print, 'Positive Radius:', string(posradius)
;print, 'Negative Radius:', string(negradius)
;print, 'Positive Comparison:', string(poscomparison)
;print, 'Negative Comparison:', string(negcomparison)

;-------------------------------------------------------------------------;
;Convert back and get coordinates of centroids
;-------------------------------------------------------------------------;

xpos = xpos + x1
ypos = ypos + y1
xneg = xneg + x1
yneg = yneg + y1

wcs = fitshead2wcs(hdr)
poscoord = wcs_get_coord(wcs, [xpos, ypos])
wcs_convert_from_coord, wcs, poscoord, 'hg', poslon, poslat
negcoord = wcs_get_coord(wcs, [xneg, yneg])
wcs_convert_from_coord, wcs, negcoord, 'hg', neglon, neglat
arcore = wcs_get_coord(wcs, [xpixelarray[i-1], ypixelarray[i-1]])
wcs_convert_from_coord, wcs, arcore, 'HG', longitude, latitude

if poslon gt neglon then begin
leadingnum = posnumber
trailingnum = negnumber
leadingb = bpostotal
trailingb = bnegtotal
endif else begin
leadingnum = negnumber
trailingnum = posnumber
trailingb = bpostotal
leadingb = bnegtotal
endelse

if abs(leadingb) gt abs(trailingb) then begin

cd, '/home/jack/SSProject/Results/'

openu, lun, "reredecaydata.dat", /GET_LUN, /APPEND
printf, lun, format='(%"%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%s")', justdate, longitude, latitude, leadingb, leadingnum, $
trailingb, trailingnum, areapercent, poscomparison, negcomparison, 'Leading'
free_lun, lun

cd, '/home/jack/SSProject/Track/'

endif else begin 

cd, '/home/jack/SSProject/Results/'

openu, lun, "reredecaydata.dat", /GET_LUN, /APPEND
printf, lun, format='(%"%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%s")', justdate, longitude, latitude, leadingb, leadingnum, $
trailingb, trailingnum, areapercent, poscomparison, negcomparison, 'Trailing'
free_lun, lun

cd, '/home/jack/SSProject/Track/'

endelse

endif
endif
endfor
endif else begin 
pospropstr=-1
endelse

print,'Computation time=', anytim(systim(/utc))-anytim(t1), 's'

end
