pro multirunextract

;----------------------------------------------------;
;A programme to write the results of run_ar_extract to
;a txt file
;----------------------------------------------------;

cd, '/home/jack/SSProject/2015-10-5/2007Extract/'

filenames = file_search('*.fits')

;---------------------------------------------------;
;Perform ar_extract on the fits files
;---------------------------------------------------;

jkl = N_Elements(filenames) - 1

for i = 378, jkl do begin

	testrun, filenames[i]
	cd, '/home/jack/SSProject/2015-10-5/2007Extract/'

endfor

end
