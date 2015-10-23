pro testrun, fmdi

DEFSYSV, '!AR_PATH', '/home/jack/IDL/Lib/smart_library/'
DEFSYSV, '!AR_PARAM', 'ar_param.txt'

t1=systim(/utc)

;Set up parameters---------------------------------->

;Read in the AR detection parameter file
fparam='./ar_param.txt'
params=ar_loadparam(fparam=fparam)

;Input magnetogram
fmdi= fmdi

;Output AR info CSV file
;fcsv=dpath+'smart_cutouts_metadata_alpha.txt'

;Run version of code (just to keep track of output CSV files)
;runvers='ALPHA.0'

;Cut-out size for AR zooms
;xycutsz=[600,600]
;determine from detection bounding box

;+/- Dynamic range for scaling the magnetograms 
magdisplay=1000


;Start detecting ARs-------------------------------->

;Read in a fits file (including WCS and full header)
thismap=ar_readmag(fmdi)
maporig=thismap

;filedate=anytim(file2time(fmdi),/vms)
fdate=time2file(thismap.time,/date)
fyyyy=strmid(fdate,0,4)

;Create AR mask (includes processing of MDI image -> read out into THISPROC)
thisarstr=ar_detect_core(thismap,/nosmart, /doprocess, mapproc=thisproc, params=params, status=status, cosmap=cosmap, limbmask=limbmask)

;Overwrite original data with processed
thismap=thisproc

;Get number of ARs in image
nar=max(thisarstr.data)

mask=ar_core2mask(thisarstr.data)

if max(mask) gt 0. then begin
pospropstr=ar_posprop(map=thismap, mask=mask, cosmap=cosmap, params=params)
endif else pospropstr=-1

loadct,0,/sil
plot_image,rot(magscl(thismap.data),-thismap.roll_angle)
setcolors,/sil,/sys
plots,pospropstr.xcenbnd,pospropstr.ycenbnd,ps=4,color=!red

print,'Computation time='
print,anytim(systim(/utc))-anytim(t1),'s'

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

for i=0,jkl do begin

	savepixelarray = [xpixelarray[i], ypixelarray[i]]

	print, fmdi, savepixelarray, justdate

	cd, '/home/jack/SSProject/Results/'

	openu, lun, "twoksevenresults.dat", /GET_LUN, /APPEND
	printf, lun, fmdi, xpixelarray[i], ypixelarray[i], justdate
	free_lun, lun
	
	cd, '/home/jack/SSProject/2015-10-5/2007Extract'

endfor

end
