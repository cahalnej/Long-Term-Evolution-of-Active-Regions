pro stenflo

readcol, '/home/jack/SSProject/Joy/editedjoy.dat', fmdi, poslat, poslon, neglat, neglon, tilt, justdate, format = 'A,D,D,D,D,D,A'

convday = strmid(justdate, 8, 2)
convmonth = strmid(justdate, 5, 2)
convyear = strmid(justdate, 0, 4)
thistime = julday(convmonth,convday,convyear)

jkl = N_Elements(tilt)

rangeonemonitor = 0
rangetwomonitor = 0
rangethreemonitor = 0
rangefourmonitor = 0
rangefivemonitor = 0
rangesixmonitor = 0
rangesevenmonitor = 0
rangeeightmonitor = 0
rangeninemonitor = 0
;---------------------------------------------------------------------;
;Split the data up into 5 degree ranges
;---------------------------------------------------------------------;
for i = 0, n_elements(poslat)-1 do begin
	if (poslat[i] gt 0) && (poslat[i] lt 5) then begin
		if rangeonemonitor eq 0 then rangeone = poslat[i] else rangeone = [rangeone, poslat[i]]
		if rangeonemonitor eq 0 then tiltone = tilt[i] else tiltone = [tiltone, tilt[i]]

		rangeonemonitor = 1
	endif
	if (poslat[i] gt 5) && (poslat[i] lt 10) then begin
		if rangetwomonitor eq 0 then rangetwo = poslat[i] else rangetwo = [rangetwo, poslat[i]]
		if rangetwomonitor eq 0 then tilttwo = tilt[i] else tilttwo = [tilttwo, tilt[i]]
		rangetwomonitor = 1
	endif
	if (poslat[i] gt 10) && (poslat[i] lt 15) then begin
		if rangethreemonitor eq 0 then rangethree = poslat[i] else rangethree = [rangethree, poslat[i]]
		if rangethreemonitor eq 0 then tiltthree = tilt[i] else tiltthree = [tiltthree, tilt[i]]
		rangethreemonitor = 1
	endif
	if (poslat[i] gt 15) && (poslat[i] lt 20) then begin
		if rangefourmonitor eq 0 then rangefour = poslat[i] else rangefour = [rangefour, poslat[i]]
		if rangefourmonitor eq 0 then tiltfour = tilt[i] else tiltfour = [tiltfour, tilt[i]]
		rangefourmonitor = 1
	endif
	if (poslat[i] gt 20) && (poslat[i] lt 25) then begin
		if rangefivemonitor eq 0 then rangefive = poslat[i] else rangefive = [rangefive, poslat[i]]
		if rangefivemonitor eq 0 then tiltfive = tilt[i] else tiltfive = [tiltfive, tilt[i]]
		rangefivemonitor = 1
	endif
	if (poslat[i] gt 25) && (poslat[i] lt 30) then begin
		if rangesixmonitor eq 0 then rangesix = poslat[i] else rangesix = [rangesix, poslat[i]]
		if rangesixmonitor eq 0 then tiltsix = tilt[i] else tiltsix = [tiltsix, tilt[i]]
		rangesixmonitor = 1
	endif
	if (poslat[i] gt 30) && (poslat[i] lt 35) then begin
		if rangesevenmonitor eq 0 then rangeseven = poslat[i] else rangeseven = [rangeseven, poslat[i]]
		if rangesevenmonitor eq 0 then tiltseven = tilt[i] else tiltseven = [tiltseven, tilt[i]]
		rangesevenmonitor = 1
	endif
	if (poslat[i] gt 35) && (poslat[i] lt 40) then begin
		if rangeeightmonitor eq 0 then rangeeight = poslat[i] else rangeeight = [rangeeight, poslat[i]]
		if rangeeightmonitor eq 0 then tilteight = tilt[i] else tilteight = [tilteight, tilt[i]]
		rangeeightmonitor = 1
	endif
	if (poslat[i] gt 40) && (poslat[i] lt 45) then begin
		if rangeninemonitor eq 0 then rangenine = poslat[i] else rangenine = [rangenine, poslat[i]]
		if rangeninemonitor eq 0 then tiltnine = tilt[i] else tiltnine = [tiltnine, tilt[i]]
		rangeninemonitor = 1
	endif
endfor

bintilt = [0,mean(tiltone), mean(tilttwo), mean(tiltthree), mean(tiltfour), $
mean(tiltfive), mean(tiltsix), mean(tiltseven)]
avlatval = [0,mean(rangeone), mean(rangetwo), mean(rangethree), mean(rangefour), $
mean(rangefive), mean(rangesix), mean(rangeseven)]
tilterrors = [0, stddev(tiltone)/((n_elements(tiltone))^(0.5)), stddev(tilttwo)/((n_elements(tilttwo))^(0.5)), $
stddev(tiltthree)/((n_elements(tiltthree))^(0.5)), stddev(tiltfour)/((n_elements(tiltfour))^(0.5)), $
stddev(tiltfive)/((n_elements(tiltfive))^(0.5)), stddev(tiltsix)/((n_elements(tiltsix))^(0.5)), $
stddev(tiltseven)/((n_elements(tiltseven))^(0.5))]
rangeerrors = [0, stddev(rangeone)/((n_elements(rangeone))^(0.5)), stddev(rangetwo)/((n_elements(rangetwo))^(0.5)), $
stddev(rangethree)/((n_elements(rangethree))^(0.5)), stddev(rangefour)/((n_elements(rangefour))^(0.5)), $
stddev(rangefive)/((n_elements(rangefive))^(0.5)), stddev(rangesix)/((n_elements(rangesix))^(0.5)), $
stddev(rangeseven)/((n_elements(rangeseven))^(0.5))]


y_model = 0.26*avlatval
S = total((bintilt-y_model)^2)
print, S

for m = 0.0, 0.5, 0.01 do begin
	if m eq 0 then marray = m
	if m ne 0 then marray = [marray, m]
	y_model = m*avlatval
	S = total((bintilt-y_model)^2)
	if m eq 0 then sarray = S
	if m ne 0 then sarray = [sarray, S]
endfor

minS = min(sarray)
index = where(sarray eq minS)
slope = marray[index]

window, 0, xsize=650, ysize=400
cgplot, avlatval, bintilt, psym=-4, xtitle = 'Latitude (deg)', $
ytitle = 'Tilt Angle (Deg)', charsize = 1.5, err_yhigh = tilterrors, $
err_ylow = tilterrors, title = 'Mean tilt angle vs. latitude', err_clip=1

cgoplot, avlatval, 0.25*avlatval, color='dodger blue'
cgoplot, avlatval, 0.26*avlatval, color='red'

AL_Legend, ['SMART Fit', 'Dasi-Espuing'], PSym=[0,0], $
LineStyle=[0,0], Color=['red','dodger blue'], position=[25, 2], $
charsize = 1.3, charthick=1.3, thick = 1.3

;------------------------------------------------------------------------;
;Calculate R-Squared Value
;------------------------------------------------------------------------;
ybar = total(bintilt)/(n_elements(bintilt))
SStot = total((bintilt-ybar)^2)
SSres = total((bintilt-0.25*avlatval)^2)

Rsquared = 1 - (SSres/SStot)

print, 'The R-Squared Value is', Rsquared

;-------------------------------------------------------------------------------------------------------------;
;Flip the SH data around
;-------------------------------------------------------------------------------------------------------------;
for i = 0, n_elements(poslat)-1 do begin
	if neglat[i] lt 0 then begin
		if i eq 0 then lats = abs(neglat[i]) else lats = [lats,abs(neglat[i])]
		if i eq 0 then cortilt = tilt[i]*(-1) else cortilt = [cortilt, tilt[i]*(-1)]
	endif else begin
		if i eq 0 then lats = neglat[i] else lats = [lats,abs(neglat[i])]
		if i eq 0 then cortilt = tilt[i] else cortilt = [cortilt, tilt[i]]
	endelse
endfor

;---------------------------------------------------------------------;
;Split the data up into 5 degree ranges
;---------------------------------------------------------------------;
rangeonemonitor = 0
rangetwomonitor = 0
rangethreemonitor = 0
rangefourmonitor = 0
rangefivemonitor = 0
rangesixmonitor = 0
rangesevenmonitor = 0
rangeeightmonitor = 0
rangeninemonitor = 0

for i = 0, n_elements(poslat)-1 do begin
	if (poslat[i] lt 0) && (poslat[i] gt -5) then begin
		if rangeonemonitor eq 0 then rangeone = poslat[i] else rangeone = [rangeone, poslat[i]]
		if rangeonemonitor eq 0 then tiltone = tilt[i] else tiltone = [tiltone, tilt[i]]

		rangeonemonitor = 1
	endif
	if (poslat[i] lt -5) && (poslat[i] gt -10) then begin
		if rangetwomonitor eq 0 then rangetwo = poslat[i] else rangetwo = [rangetwo, poslat[i]]
		if rangetwomonitor eq 0 then tilttwo = tilt[i] else tilttwo = [tilttwo, tilt[i]]
		rangetwomonitor = 1
	endif
	if (poslat[i] lt -10) && (poslat[i] gt -15) then begin
		if rangethreemonitor eq 0 then rangethree = poslat[i] else rangethree = [rangethree, poslat[i]]
		if rangethreemonitor eq 0 then tiltthree = tilt[i] else tiltthree = [tiltthree, tilt[i]]
		rangethreemonitor = 1
	endif
	if (poslat[i] lt -15) && (poslat[i] gt -20) then begin
		if rangefourmonitor eq 0 then rangefour = poslat[i] else rangefour = [rangefour, poslat[i]]
		if rangefourmonitor eq 0 then tiltfour = tilt[i] else tiltfour = [tiltfour, tilt[i]]
		rangefourmonitor = 1
	endif
	if (poslat[i] lt -20) && (poslat[i] gt -25) then begin
		if rangefivemonitor eq 0 then rangefive = poslat[i] else rangefive = [rangefive, poslat[i]]
		if rangefivemonitor eq 0 then tiltfive = tilt[i] else tiltfive = [tiltfive, tilt[i]]
		rangefivemonitor = 1
	endif
	if (poslat[i] lt -25) && (poslat[i] gt -30) then begin
		if rangesixmonitor eq 0 then rangesix = poslat[i] else rangesix = [rangesix, poslat[i]]
		if rangesixmonitor eq 0 then tiltsix = tilt[i] else tiltsix = [tiltsix, tilt[i]]
		rangesixmonitor = 1
	endif
	if (poslat[i] lt -30) && (poslat[i] gt -35) then begin
		if rangesevenmonitor eq 0 then rangeseven = poslat[i] else rangeseven = [rangeseven, poslat[i]]
		if rangesevenmonitor eq 0 then tiltseven = tilt[i] else tiltseven = [tiltseven, tilt[i]]
		rangesevenmonitor = 1
	endif
	if (poslat[i] lt -35) && (poslat[i] gt -40) then begin
		if rangeeightmonitor eq 0 then rangeeight = poslat[i] else rangeeight = [rangeeight, poslat[i]]
		if rangeeightmonitor eq 0 then tilteight = tilt[i] else tilteight = [tilteight, tilt[i]]
		rangeeightmonitor = 1
	endif
	if (poslat[i] lt -40) && (poslat[i] gt -45) then begin
		if rangeninemonitor eq 0 then rangenine = poslat[i] else rangenine = [rangenine, poslat[i]]
		if rangeninemonitor eq 0 then tiltnine = tilt[i] else tiltnine = [tiltnine, tilt[i]]
		rangeninemonitor = 1
	endif
endfor

SHbintilt = [0,mean(tiltone), mean(tilttwo), mean(tiltthree), mean(tiltfour), $
mean(tiltfive), mean(tiltsix), mean(tiltseven)]
SHavlatval = [0,mean(rangeone), mean(rangetwo), mean(rangethree), mean(rangefour), $
mean(rangefive), mean(rangesix), mean(rangeseven)]
SHtilterrors = [0, stddev(tiltone)/((n_elements(tiltone))^(0.5)), stddev(tilttwo)/((n_elements(tilttwo))^(0.5)), $
stddev(tiltthree)/((n_elements(tiltthree))^(0.5)), stddev(tiltfour)/((n_elements(tiltfour))^(0.5)), $
stddev(tiltfive)/((n_elements(tiltfive))^(0.5)), stddev(tiltsix)/((n_elements(tiltsix))^(0.5)), $
stddev(tiltseven)/((n_elements(tiltseven))^(0.5))]
SHrangeerrors = [0, stddev(rangeone)/((n_elements(rangeone))^(0.5)), stddev(rangetwo)/((n_elements(rangetwo))^(0.5)), $
stddev(rangethree)/((n_elements(rangethree))^(0.5)), stddev(rangefour)/((n_elements(rangefour))^(0.5)), $
stddev(rangefive)/((n_elements(rangefive))^(0.5)), stddev(rangesix)/((n_elements(rangesix))^(0.5)), $
stddev(rangeseven)/((n_elements(rangeseven))^(0.5))]

for m = 0.0, 0.5, 0.01 do begin
	if m eq 0 then marray = m
	if m ne 0 then marray = [marray, m]
	y_model = m*avlatval
	S = total((bintilt-y_model)^2)
	if m eq 0 then sarray = S
	if m ne 0 then sarray = [sarray, S]
endfor

minS = min(sarray)
index = where(sarray eq minS)
slope = marray[index]
result = min(slope)
help, result

;window, 1, xsize=650, ysize=400
cgoplot, abs(SHavlatval), abs(SHbintilt), psym=-3, color = 'Purple'
;, xtitle = 'Latitude (deg)', $
;ytitle = 'Tilt Angle (Deg)', charsize = 1.5, err_yhigh = SHtilterrors, $
;err_ylow = SHtilterrors, title = 'Mean tilt angle vs. latitude', err_clip=1

TotLat = (abs(SHavlatval) + avlatval)/2
TotTilt = (abs(SHbintilt) + bintilt)/2
cgoplot, TotLat, TotTilt, psym = -15, color = 'Green'

for m = 0.0, 0.5, 0.01 do begin
	if m eq 0 then marray = m
	if m ne 0 then marray = [marray, m]
	y_model = m*TotLat
	S = total((TotTilt-y_model)^2)
	if m eq 0 then sarray = S
	if m ne 0 then sarray = [sarray, S]
endfor

Errors = (SHTiltErrors + tilterrors)/2
RangeErr = (SHRangeErrors + rangeerrors)
print, max(RangeErr)

minS = min(sarray)
index = where(sarray eq minS)
slope = marray[index]
result = min(slope)
print, result

window, 1, xsize=650, ysize=400
cgplot, TotLat, TotTilt, psym = -15, xtitle = 'Latitude (deg)', err_xhigh = RangeErr, $
ytitle = 'Tilt Angle (Deg)', charsize = 1.5, err_yhigh = Errors, err_xlow = RangeErr, $
err_ylow = Errors, title = 'Mean tilt angle vs. latitude', err_clip=1, yrange = [0, 10]

cgoplot, TotLat, 0.28*TotLat, color='dodger blue'
cgoplot, TotLat, result*TotLat, color='red'

cgLegend, Title=['SMART SOHO', 'Dasi-Espuing'], PSym=[0,0], $
LineStyle=[0,0], Color=['red','dodger blue'], Location=[27, 2], $
/Data

xloc = 31.72
yloc = 2.4
;------------------------------------------------------------------------;
;Calculate R-Squared Value
;------------------------------------------------------------------------;
ybar = total(TotTilt)/(n_elements(TotTilt))
SStot = total((TotTilt-ybar)^2)
SSres = total((TotTilt-0.25*TotLat)^2)

Rsquared = 1 - (SSres/SStot)

print, 'The R-Squared Value is', Rsquared
cgText, xloc, yloc, 'R = ' + String(Rsquared, Format='(F0.3)'), $
Charsize=fcharsize

yloc = yloc+0.55
cgText, xloc, yloc, 'y = ' + String(result, Format='(F0.2)') + 'x', $
Charsize=fcharsize

for i = 0, n_elements(TotTilt)-1 do begin
	product = TotTilt[i]-0.26*TotTilt[i]
	prodsqr = product^2
	if i eq 0 then endprod = prodsqr else endprod = endprod+prodsqr
endfor

ystddev = (endprod/(n_elements(TotTilt)-2))^0.5

;---------------------------------------------------------------------;
;Calculate the standard error in the intercept
;---------------------------------------------------------------------;

topline = (ystddev^2)*(total(TotLat^2))
bottomone = n_elements(TotLat)*total(TotLat^2)
bottomtwo = (total(TotLat))^2
bottomline = bottomone-bottomtwo
bstddev = topline/bottomline

;---------------------------------------------------------------------;
;Calculate the standard error in the slope
;---------------------------------------------------------------------;
topline = (ystddev^2)*n_elements(TotLat)
mstddev = (topline/bottomline)

print, ystddev, bstddev, mstddev

end
