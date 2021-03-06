Pro TestWrite

;Jack Cahalane 15:24 September 30th 2015
;A quick programme that reads the intensity files and writes the
;relelvant data to a file

cd, '/home/jack/SSProject/2015-10-5/2000Extract/'

filenames = file_search('*.fits')

result = readfits(filenames[0], hdr)

new_array =  hdr[where(strmatch(hdr, 'DATE_OBS*', /FOLD_CASE) eq 1)]

;#-----------------------------------------------------------------#
; Write the filename and date of observation to a file
;#-----------------------------------------------------------------#

for i =1, 366 do begin
	result = readfits(filenames[i], hdr)
	b = hdr[where(strmatch(hdr, 'DATE_OBS*', /FOLD_CASE) eq 1)]
	new_array = [new_array, b]
endfor

write_csv, 'dataregur.txt', filenames, new_array

cd, '/home/jack/SSProject/2015-10-5/'

end
