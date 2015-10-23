pro ar_getwcs

;-------------------------------------------------------------;
;A programme to get the wcs coords for a group of .fits files 
;-------------------------------------------------------------;

cd, '/home/jack/SSProject/Results/'

readcol, 'twoksevenresults.dat', fmdi, xpixel, ypixel, date, FORMAT = 'A,D,D,A'

;-------------------------------------------------------------;
;Read all the .fits files in a folder
;-------------------------------------------------------------;

cd, '/home/jack/SSProject/2015-10-5/2007Extract/'
filenames = file_search('*.fits')

;--------------------------------------------------------------;
;The FOR loop
;--------------------------------------------------------------;

jkl = N_Elements(xpixel)-1

for i=0,jkl do begin
	cd, '/home/jack/SSProject/2015-10-5/2007Extract/'
	result = readfits(fmdi[i], hdr)
	wcs = fitshead2wcs(hdr)
	coord = wcs_get_coord(wcs, [xpixel[i], ypixel[i]])
	wcs_convert_from_coord, wcs, coord, 'hg', lon, lat

	new_array =  hdr[where(strmatch(hdr, 'DATE_OBS*', /FOLD_CASE) eq 1)]
	justdate = STRMID(new_array, 11, 10)
	
	cd, '/home/jack/SSProject/Results/'
	openu, lun, '2007coords.dat', /GET_LUN, /APPEND
	printf, lun, format='(%"\t%f\t%f\t%s\n")', lon, lat, date[i]
	free_lun, lun

	;openu, lun, '2000dates.dat', /GET_LUN, /APPEND
	;printf, lun, justdate
	;free_lun, lun
	
endfor

end
