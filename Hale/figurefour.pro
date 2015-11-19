pro figurefour

;--------------------------------------------------------------------------------------------------;
;Jack Cahalane 26th October 2015
;A procedure to determine the polarity of the leading spot in an Active region and then plot the
;the results
;--------------------------------------------------------------------------------------------------;

DEVICE, SET_FONT='Helvetica', /TT_FONT
USERSYM, [-.5, .5], [-0, 0.5]


;--------------------------------------------------------------------------------------------------;
;Read the data outputted by Joy.pro
;--------------------------------------------------------------------------------------------------;
cd, '/home/jack/SSProject/Joy/'
readcol, 'editedjoy.dat', fmdi, poslat, poslon, neglat, neglon, tilt, justdate, format = 'A,D,D,D,D,D,A'

convday = strmid(justdate, 8, 2)
convmonth = strmid(justdate, 5, 2)
convyear = strmid(justdate, 0, 4)

;--------------------------------------------------------------------------------------------------;
;Set up the arrays where info will be stored
;--------------------------------------------------------------------------------------------------;

SHtrial = [neglat[0], neglon[0], convday[0], convmonth[0], convyear[0]]
NHtrial = [neglat[2], neglon[2], convday[2], convmonth[2], convyear[2]]
NHother = [neglat[57], neglon[57], convday[57], convmonth[57], convyear[57]]
SHother = [neglat[30], neglon[30], convday[30], convmonth[30], convyear[30]]

jkl = N_Elements(poslat)-1

;--------------------------------------------------------------------------------------------------;
;Determine whether the AR is NH or SH, and then which spot is leading
;--------------------------------------------------------------------------------------------------;

for i = 1, jkl do begin
	if poslat[i] && neglat[i] lt 0 then begin
		if neglon[i] gt poslon[i] then begin
			trial = [neglat[i], neglon[i], convday[i], convmonth[i], convyear[i]]
			SHtrial = [[SHtrial], [trial]]
		endif else begin
			othertrial = [[neglat[i], neglon[i], convday[i], convmonth[i], convyear[i]]]
			NHother = [[NHother], [othertrial]]
		endelse
	endif
	if poslat[i] && neglat[i] gt 0 then begin
		if poslon[i] gt neglon[i] then begin
			trial = [poslat[i], poslon[i], convday[i], convmonth[i], convyear[i]]
			NHtrial = [[NHtrial], [trial]]
		endif else begin
			SHothertrial = [[neglat[i], neglon[i], convday[i], convmonth[i], convyear[i]]]
			SHother = [[SHother], [SHothertrial]]
		endelse
	endif	
endfor

;--------------------------------------------------------------------------------------------------;
;Set up the arrays which will be used for plotting
;--------------------------------------------------------------------------------------------------;
nSHt = (n_elements(SHtrial)/5) - 1
nNHt = (n_elements(NHtrial)/5) - 1
nNHo = (n_elements(NHother)/5) - 1
nSHo = (n_elements(SHother)/5) - 1

SHlat = SHtrial[0,0]
SHlon = SHtrial[1,0]
SHday = SHtrial[2,0]
SHmonth = SHtrial[3,0]
SHyear = SHtrial[4,0]

for i = 1, nSHt do begin
	SHlat = [SHlat, SHtrial[0,i]]
	SHlon = [SHlon, SHtrial[1,i]]
	SHday   = [SHday, SHtrial[2,i]]
	SHmonth = [SHmonth, SHtrial[3,i]]
	SHyear  = [SHyear, SHtrial[4,i]]
endfor	

NHlat = NHtrial[0,0]
NHlon = NHtrial[1,0]
NHday = NHtrial[2,0]
NHmonth = NHtrial[3,0]
NHyear = NHtrial[4,0]

for i = 1, nNHt do begin
	NHlat = [NHlat, NHtrial[0,i]]
	NHlon = [NHlon, NHtrial[1,i]]
	NHday   = [NHday, NHtrial[2,i]]
	NHmonth = [NHmonth, NHtrial[3,i]]
	NHyear  = [NHyear, NHtrial[4,i]]
endfor

NHolat = NHother[0,0]
NHolon = NHother[1,0]
NHoday = NHother[2,0]
NHomonth = NHother[3,0]
NHoyear = NHother[4, 0]

for i = 1, nNHo do begin
	NHolat = [NHolat, NHother[0,i]]
	NHolon = [NHolon, NHother[1,i]]
	NHoday   = [NHoday, NHother[2,i]]
	NHomonth = [NHomonth, NHother[3,i]]
	NHoyear  = [NHoyear, NHother[4,i]]
endfor

SHolat = SHother[0,0]
SHolon = SHother[1,0]
SHoday = SHother[2,0]
SHomonth = SHother[3,0]
SHoyear = SHother[4, 0]


for i = 1, nSHo do begin
	SHolat = [SHolat, SHother[0,i]]
	SHolon = [SHolon, SHother[1,i]]
	SHoday   = [SHoday, SHother[2,i]]
	SHomonth = [SHomonth, SHother[3,i]]
	SHoyear  = [SHoyear, SHother[4,i]]
endfor

;--------------------------------------------------------------------------------------------------;
;Establish the time arrays
;--------------------------------------------------------------------------------------------------;

thistime = julday(SHmonth,SHday,SHyear)
NHtime = julday(NHmonth,NHday,NHyear)
NHotime = julday(NHomonth, NHoday, NHoyear)
SHotime = julday(SHomonth, SHoday, SHoyear)

;--------------------------------------------------------------------------------------------------;
;Plot time versus latitude
;--------------------------------------------------------------------------------------------------;

window, 0
loadct, 0
utplot, thistime, SHlat, psym = 8, color = 0, background = 255, yrange = [-60,60], xtickunits=['Year'], charsize = 1.5, $
charthick = 1.2, ytitle = 'Latitude of Active Regions (Degrees)', xtitle = 'Date', title = 'Polarity of Active Regions in 2000-01', $
font = 1
loadct, 6
oplot, NHotime, NHolat, psym = 8, color = 50
oplot, SHotime, SHolat, psym = 8, color = 190
oplot, NHtime, NHlat, psym = 8, color = 50
oplot, thistime, SHlat, psym = 8, color = 190

;--------------------------------------------------------------------------------------------------;
;Plot longitude versus latitude
;--------------------------------------------------------------------------------------------------;

;window, 1
;loadct, 0
;help, SHlon, SHlat
;cgplot, SHlon, SHlat, psym = 1, color = 0, background = 255, yrange = [-90, 90], $
;xtitle = 'Longitude of Active regions', ytitle = 'Latitude of Active Regions', $
;title = 'Coordinates of Active Regions and Ploarity of Leading Spot'
;loadct, 6
;oplot, NHolon, NHolat, psym = 1, color = 190
;oplot, SHolon, SHolat, psym = 1, color = 50
;oplot, SHlon, SHlat, psym = 1, color = 50
;oplot, NHlon, NHlat, psym = 1, color = 190

cd, '/home/jack/SSProject/Figures/'

end
