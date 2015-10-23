pro weighcent, fmdi

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
;Create AR mask (includes processing of MDI image -> read out into THISPROC)
;----------------------------------------------------------;

thisarstr = ar_detect_core(thismap,/nosmart, /doprocess, mapproc=thisproc, params=params, status=status, cosmap=cosmap, limbmask=limbmask)

;----------------------------------------------------------;
;Overwrite original data with processed
;----------------------------------------------------------;
thismap = thisproc
nar = max(thisarstr.data)
mask = ar_core2mask(thisarstr.data)

if max(mask) gt 0. then begin
pospropstr=ar_posprop(map=thismap, mask=mask, cosmap=cosmap, params=params)
endif else pospropstr=-1

loadct,0,/sil
plot_image,rot(magscl(thismap.data),-thismap.roll_angle)
setcolors,/sil,/sys
plots,pospropstr.xcenbnd,pospropstr.ycenbnd,ps=4,color=!red
;x2jpeg, 'IdentifiedArs.jpg'

;print,'X,Y pixel positions of AR bounding box centers'
;print,[(pospropstr.xcenbnd),(pospropstr.ycenbnd)]

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

;---------------------------------------------------------------------------;
;Joy's Law Verification Work, started on 22nd of October
;---------------------------------------------------------------------------;

for i = 0, jkl do begin

savepixelarray = [xpixelarray[i], ypixelarray[i]]

imgsz = size(thisarstr.data,/dim)
;--------------------------------------------------------------------------;
;Determine bounding box in pixels
;--------------------------------------------------------------------------;

x1 = xpixelarray[i]-64
y1 = ypixelarray[i]-64
x2 = xpixelarray[i]+64
y2 = ypixelarray[i]+64
arbox = [x1, y1, x2, y2]

;--------------------------------------------------------------------------;
;Get geometric centroid and width of box
;--------------------------------------------------------------------------;
arxywidth = [arbox[2]-arbox[0], arbox[3]-arbox[1]]
arxycent = [arbox[0]+arxywidth[0]/2., arbox[1]+arxywidth[1]/2.]

;--------------------------------------------------------------------------;
;Convert to image coordinates (arcsecs) and make cutout image
;--------------------------------------------------------------------------;

hcarxywidth = arxywidth*thismap.dx
hcarxycent = (arxycent-imgsz/2.)*thismap.dx+[thismap.xc,thismap.yc]
narmap = map_cutout(thismap, xycen=hcarxycent, xwidth=hcarxywidth[0], $
yheight=hcarxywidth[1], auxdat1=thisarstr.data, outauxdat1=narmask, $
auxdat2=thisarmask, outauxdat2=narthismask, auxdat3=limbmask, $
outauxdat3=narlimb)

;--------------------------------------------------------------------------;
;Determine centroid of pixel with Flux gt 100 Gauss
;--------------------------------------------------------------------------;

mag = narmap.data
postmp = where(mag ge 150)
mask = mag*0.0
mask(postmp) = 1.0

cent = centroid(mag*mask)
xpos = [cent[0]]
ypos = [cent[1]]

;--------------------------------------------------------------------------;
;Determine centroid of pixel with Flux gt 100 Gauss
;--------------------------------------------------------------------------;
negtmp = where(mag le -150)
negmask = mag*0.0
negmask(negtmp) = 1.0

negcent = centroid(mag*negmask)
xneg = [negcent[0]]
yneg = [negcent[1]]

;--------------------------------------------------------------------------;
;Plot and Verify
;--------------------------------------------------------------------------;
window, 0
loadct, 0, /sil
plot_image, magscl(narmap.data)
setcolors, /sil, /sys
line = [[xpos, ypos], [xneg, yneg]]
plots, line, psym = 0, color = !blue, thick = 2
plots, xpos, ypos, ps=4, color=!red, thick = 2
plots, xneg, yneg, ps=4, color=!green, thick = 2

;--------------------------------------------------------------------------;
;Find the Tilt
;--------------------------------------------------------------------------;
tantilt = (ypos - yneg)/(xpos-xneg)
tilt = 180/!pi*atan(tantilt)
print, 'The tilt is', tilt

endfor

end
