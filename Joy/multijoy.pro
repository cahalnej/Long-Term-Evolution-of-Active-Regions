pro multijoy

;----------------------------------------------------;
;Runs weighcent.pro over a number of .fits files
;----------------------------------------------------;

cd, '/home/jack/SSProject/2015-10-5/2001Extract/'

filenames = file_search('*.fits')

;----------------------------------------------------;
;Perform weighcent.pro on the .fits files
;----------------------------------------------------;

jkl = (N_Elements(filenames) - 1)

for i = 0, jkl do begin
	print, i
	reeditjoy, filenames[i]
	cd, '/home/jack/SSProject/2015-10-5/2001Extract/'

endfor

cd, '/home/jack/SSProject/Joy/'

end


