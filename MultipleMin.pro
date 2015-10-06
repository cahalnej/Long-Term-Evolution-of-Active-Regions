Pro MultipleMin

;#-------------------------------------#
;Jack Cahalane
;A procedure to extract solar profiles for a single row of
;pixels across a number of files
;#-------------------------------------#

;#----------------------------------------------------------------------#
;Change to correct directory and load all the filenames into an array
;#----------------------------------------------------------------------#

cd, '/home/jack/SSProject/Extract/Data/'

filenames = file_search('*.fits')

for i = 0, 79 do begin
	filename = filenames[i]
	Magnetogram_min, filename

endfor

cd, '/home/jack/SSProject/Extract/'

end

