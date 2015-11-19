pro sporer, fmdi

filename = fmdi 
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
if max(mask) gt 0. then begin
pospropstr=ar_posprop(map=thismap, mask=coremask, cosmap=cosmap, params=params, $
outpos=outpos, outneg=outneg, /nosigned, status=posstatus, datafile=thisdatafile)
coremask = abs(coremask)
xarcores = [pospropstr.xcenbnd] 
yarcores = [pospropstr.ycenbnd]

;---------------------------------------------------------------------------;
;Additional code by Jack Cahalane on 14th October to get time of .fits file
;---------------------------------------------------------------------------;

getheader = readfits(fmdi, hdr)
T_OBS =  hdr[where(strmatch(hdr, 'T_OBS*', /FOLD_CASE) eq 1)]
justdate = STRMID(T_OBS, 11, 10)

;---------------------------------------------------------------------------;
;Further additional code by Jack Cahalane on 14th October
;---------------------------------------------------------------------------;


jkl = N_Elements(pospropstr.xcenbnd) - 1

for i=0,jkl do begin

	savepixelarray = [xarcores[i], yarcores[i]]

	print, fmdi, savepixelarray, justdate

	cd, '/home/jack/SSProject/Results/'

	openu, lun, "twoktenresults.dat", /GET_LUN, /APPEND
	printf, lun, fmdi, xarcores[i], yarcores[i], justdate
	free_lun, lun
	
	cd, '/home/jack/SSProject/2015-10-5/2010Extract'

endfor

endif else pospropstr=-1


end

