pro multibtotal

;----------------------------------------------------;
;Runs weighcent.pro over a number of .fits files
;----------------------------------------------------;

cd, '/home/jack/SSProject/2015-10-5/2011Extract/'

filenames = file_search('*.fits')

;----------------------------------------------------;
;Perform btotal.pro on the .fits files
;----------------------------------------------------;

jkl = (N_Elements(filenames) - 1)

for i = 0, jkl do begin
	print, i
	btotal, filenames[i]
	cd, '/home/jack/SSProject/2015-10-5/2011Extract/'

endfor

cd, '/home/jack/SSProject/Track/'



end
