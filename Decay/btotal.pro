pro btotal, fmdi

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
justdate = STRMID(T_OBS, 11, 10)

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

;---------------------------------------------------------------------------;
;Joy's Law Verification Work, started on 22nd of October
;---------------------------------------------------------------------------;

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
postmp = where(mag ge 500)
if postmp[0] gt 0 then begin
posnumber= n_elements(postmp)
mask = mag*0.0
mask(postmp) = 1.0
activeregion = mag*mask*narmask
bpostotal = total(activeregion)

cent = centroid(activeregion)
xpos = [cent[0]]
ypos = [cent[1]]


;--------------------------------------------------------------------------;
;Determine centroid of pixel with Flux lt -500 Gauss
;--------------------------------------------------------------------------;
negtmp = where(mag le -500)
negnumber = n_elements(negtmp)
if negtmp[0] gt 0 then begin

negmask = mag*0.0
negmask(negtmp) = 1.0
activeregion = mag*negmask*narmask
bnegtotal=total(activeregion)

negcent = centroid(activeregion)
xneg = [negcent[0]]
yneg = [negcent[1]]

xpos = xpos + x1
ypos = ypos + y1
xneg = xneg + x1
yneg = yneg + y1

wcs = fitshead2wcs(hdr)
poscoord = wcs_get_coord(wcs, [xpos, ypos])
wcs_convert_from_coord, wcs, poscoord, 'hg', poslon, poslat
negcoord = wcs_get_coord(wcs, [xneg, yneg])
wcs_convert_from_coord, wcs, negcoord, 'hg', neglon, neglat

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

cd, '/home/jack/SSProject/Results/'

openu, lun, "btotal05.dat", /GET_LUN, /APPEND
printf, lun, format='(%"%s\t%f\t%f\t%f\t%f\t%f\t%f\t%s")', fmdi, leadingnum, $
trailingnum, bpostotal, bnegtotal, leadingb, trailingb, justdate
free_lun, lun

endif
endif
endfor
endif else begin 
pospropstr=-1
endelse


end
