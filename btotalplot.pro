pro btotalplot

cd, '/home/jack/SSProject/Results/'

readcol, 'decaydata.dat', justdate, longitude, latitude, leadingb, leadingnum, $
trailingb, trailingnum, stronger, format='A,D,D,D,D,D,D,A', SKIPLINE=1

;------------------------------------------------------------------------------;
;Some preliminary housekeeping necessary for later on.
;------------------------------------------------------------------------------;
num = n_elements(leadingnum)
print, num
monitor=0
altmonitor=0
realtmonitor=0
cases=0

;------------------------------------------------------------------------------;
;The for loop to determine in what percentage of cases does the leading spot
;have more pixels with a mag field exceeding 500 Gauss.
;------------------------------------------------------------------------------;

for i = 0, num-1 do begin
	if abs(leadingb[i]) gt abs(trailingb[i]) then monitor=monitor+1
endfor

monitor = float(monitor)
total = monitor/num
print, total*100, ' %'

;------------------------------------------------------------------------------;
;The same but only for umbra's less than 200 pixels in area.
;------------------------------------------------------------------------------;
monitor=0
altmonitor=0
realtmonitor=0
cases=0

for i = 0, num-1 do begin
	cases = cases+1
	if leadingnum[i] gt trailingnum[i] then monitor = monitor + 1
endfor
print, cases, monitor
monitor = float(monitor)
total = monitor/num
print, total*100, ' %'
;------------------------------------------------------------------------------;
;Plot the distribution of pixel number for both leading and trailing spots.
;------------------------------------------------------------------------------;
binsize = 20.0

window, 0, xsize = 900, ysize = 500
cgHistoplot, abs(leadingnum), BINSIZE=binsize, /Fill, xrange=[0,1500], $
title = 'Distribution of Susnpot Umbral Areas', yrange = [0, 3500], $
xtitle = 'Area of Sunspot Umbra (Pixels)', ytitle = 'Number of Identified Umbras', $
HISTDATA=h, LOCATIONS=loc
cgHistoplot, abs(trailingnum), BINSIZE=binsize, /OPlot, color='navy', $
HISTDATA=sech, LOCATIONS=secloc, /outline

AL_Legend, ['Leading Spot', 'Trailing Spot'], PSym=[0,0], $
LineStyle=[0,0], Color=['red','dodger blue'], position=[1000, 3000], $
charsize = 1.3, charthick=1.3, thick = 1.3
binCenters = loc + (binsize / 2.0)
yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
cgPlot, binCenters, yfit, COLOR='red', THICK=2, /OVERPLOT

binCENTERS = secloc + (binsize / 2.0)
secyfit = GaussFit(binCenters, sech, coeff, NTERMS=3)
cgPlot, binCenters, secyfit, COLOR='dodger blue', THICK=2, /OVERPLOT

;------------------------------------------------------------------------------;
;Now to work out the percentage of cases below certain thresholds
;------------------------------------------------------------------------------;
magthres = [1492, 1400, 1300, 1200, 1100, 1000, 950, 900,850,  800, 775, 750, 725]
magthres = [magthres, 700, 675, 650, 625, 600, 575, 550, 525, 500, 475, 450, 425]
magthres = [magthres, 400, 375, 350, 325, 300, 275, 250, 225, 200, 175, 150, 125]
magthres = [magthres, 100, 90, 80, 70, 60, 50, 40, 35, 30, 25, 20, 15, 13, 10, 9]
magthres = [magthres, 8, 7, 6, 5, 4, 3, 2, 1]

for j = 0, n_elements(magthres)-1 do begin

for i = 0, num-1 do begin

	if leadingnum[i] && trailingnum[i] lt magthres[j] then begin
		cases=cases+1
		if abs(leadingb[i]) gt abs(trailingb[i]) then altmonitor=altmonitor+1
	endif

endfor
if j eq 0 then totcases = cases else totcases = [totcases,cases]
altmonitor=float(altmonitor)
altresult=altmonitor/cases
if j eq 0 then totalt = altresult else totalt = [totalt, altresult]
cases=0
altmonitor=0
endfor

;------------------------------------------------------------------------------;
;Plot this information
;------------------------------------------------------------------------------;

window, 1
cgplot, magthres, totalt*100, ytitle = 'Percentage of Pairs', yrange = [50, 100], $
xtitle = 'Area of the Sunspot Umbra (Pixels)', xrange = [0, 1000], $
title = 'Percentage of Pairs Where the Leading B Field > Trailing B Field'
cgoplot, magthres, totalt*100, psym=-15, color='dodger blue'

;------------------------------------------------------------------------------;
;Do the same but in determine percentage based on area
;------------------------------------------------------------------------------;

for j = 0, n_elements(magthres)-1 do begin

for i = 0, num-1 do begin

	if leadingnum[i] && trailingnum[i] lt magthres[j] then begin
		cases=cases+1
		if leadingnum[i] gt trailingnum[i] then realtmonitor=realtmonitor+1
	endif

endfor
if j eq 0 then totcases = cases else totcases = [totcases,cases]
realtmonitor=float(realtmonitor)
realtresult=realtmonitor/cases
if j eq 0 then totalt = realtresult else totalt = [totalt, realtresult]
cases=0
realtmonitor=0
endfor

;------------------------------------------------------------------------------;
;Plot this information
;------------------------------------------------------------------------------;

window, 2
cgplot, magthres, totalt*100, title = 'Percentage of Pairs Where Area of Leading Umbra > Area Trailing of Umbra', yrange = [50, 100], $
xtitle = 'Area of the Sunspot Umbra (Pixels)', xrange = [0, 1000], ytitle = 'Percentage of Pairs'
cgoplot, magthres, totalt*100, psym=-15, color='dodger blue'

;------------------------------------------------------------------------------;
;Find thje number of cases in each 200 pixel range
;------------------------------------------------------------------------------;



cd, '/home/jack/SSProject/Track/'

end
