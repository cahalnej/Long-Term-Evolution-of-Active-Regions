pro ar_plotcoords

cd, '/home/jack/SSProject/Results/'

readcol, '2006coords.dat', longitude, latitude, date, FORMAT = 'D,D,A'

help, latitude
help, longitude

convday = strmid(date, 8, 2)
convmonth = strmid(date, 5, 2)
convyear = strmid(date, 0, 4)

thistime = julday(convmonth,convday,convyear)
;help, thistime
;print, thistime[6]
;print, julday(1,1,2000)

utplot, thistime, latitude, title = 'Latitude of Active Regions in 2006', xtitle = 'Date', yrange = [-100,100], $
ytitle = 'Latitude (Degrees)',  xstyle = 1,  xtickunits = ['Month'], $
background = 255, color = 0, charsize=1.4, psym = 1
;xtickformat = ['Label_Date'],, timerange=[thistime(0), thistime(2309)]
loadct, 2

oplot, thistime, latitude, color = 75, psym = 1

cd, '/home/jack/SSProject/'  

end
