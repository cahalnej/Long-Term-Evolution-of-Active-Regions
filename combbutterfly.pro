pro combbutterfly

cd, '/home/jack/SSProject/Results/'

readcol, '1997coords.dat', ninesevenlong, ninesevenlat, ninesevendate, FORMAT = 'D,D,A'
readcol, '1998coords.dat', nineeightlong, nineeightlat, nineeightdate, FORMAT = 'D,D,A'
readcol, '1999coords.dat', nineninelong, nineninelat, nineninedate, FORMAT = 'D,D,A'
readcol, '2000coords.dat', zerolongitude, zerolatitude, zerodate, FORMAT = 'D,D,A'
readcol, '2001coords.dat', onelongitude, onelatitude, onedate, FORMAT = 'D,D,A'
readcol, '2002coords.dat', twolongitude, twolatitude, twodate, FORMAT = 'D,D,A'
readcol, '2003coords.dat', threelongitude, threelatitude, threedate, FORMAT = 'D,D,A'
readcol, '2004coords.dat', fourlongitude, fourlatitude, fourdate, FORMAT = 'D,D,A'
readcol, '2005coords.dat', fivelongitude, fivelatitude, fivedate, FORMAT = 'D,D,A'
readcol, '2006coords.dat', sixlongitude, sixlatitude, sixdate, FORMAT = 'D,D,A'
readcol, '2007coords.dat', sevenlongitude, sevenlatitude, sevendate, FORMAT = 'D,D,A'

latitude = [ninesevenlat, nineeightlat, nineninelat, zerolatitude, onelatitude, twolatitude, threelatitude, fourlatitude, fivelatitude, sixlatitude, sevenlatitude]
date = [ninesevendate, nineeightdate, nineninedate, zerodate, onedate, twodate, threedate, fourdate, fivedate, sixdate, sevendate]

convday = strmid(date, 8, 2)
convmonth = strmid(date, 5, 2)
convyear = strmid(date, 0, 4)

thistime = julday(convmonth,convday,convyear)
;help, thistime
;print, thistime[6]
;print, julday(1,1,2000)

utplot, thistime, latitude, title = 'Latitude of Active Regions', xtitle = 'Date', yrange = [-50,50], $
ytitle = 'Latitude (Degrees)',  xstyle = 1,  xtickunits = ['Year'], $
background = 255, color = 0, charsize=1.4, psym = 1
;xtickformat = ['Label_Date'],, timerange=[thistime(0), thistime(2309)]
loadct, 2

oplot, thistime, latitude, color = 75, psym = 1

cd, '/home/jack/SSProject/'  

end
