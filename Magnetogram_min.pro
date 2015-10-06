Pro Magnetogram_min, filename

;Jack Cahalane 09:49 2nd of October 2015
;A program that, hopefully, finds the row where the magnetic minimum
;is contained and plots the profile for that row

;#----------------------------------------------------------------------#
;Extract the header info for the first file
;#----------------------------------------------------------------------#

data = readfits(filename, hdr)
obs_time = strtrim(sxpar(hdr, 'T_OBS'),2)
pangle = sxpar(hdr, 'P_ANGLE')
radius = sxpar(hdr,'R_SUN')
x0 = sxpar(hdr, 'X0')
y0 = sxpar(hdr, 'Y0')
dattim = strmid(obs_time,0,16)


;#---------------------------------------------------------------------#
; Crop and rotate the image. 
;#---------------------------------------------------------------------#
 
cropped = circle_mask(data, x0, y0, 'GE', radius, mask=0)
rotated = rot(cropped, pangle, 1, x0, y0)

;#---------------------------------------------------------------------#
; Write the result to a FITS file and display the result:
;#---------------------------------------------------------------------#
 
;writefits, 'trial1.fits', rotated           
;xtv, rotated(*,*)                                   


;#----------------------#
; Initialize the display.
;#----------------------#

tv2, 512, 512, /init		


;#--------------------------------------------------------#
; Read a row of pixels that bisect a sunspot into an array.
;#--------------------------------------------------------#

sunspot_profile = intarr(2,936)
for x = 45, 980 do begin
   i = x - 45
   sunspot_profile(0,i) = x
   sunspot_profile(1,i) = rotated(x,720)
end

pix = sunspot_profile(0,*)
int = sunspot_profile(1,*)

;#-----------------------------------------------------------#
; Plot the sunspot profile and write the result to a GIF file.
;#-----------------------------------------------------------#

title = 'Sunspot Profile at'+dattim
ylabel = 'Intensity'
xlabel = 'Pixel'
plot, color = 1, background = 250, pix, int, title=title, xtitle=xlabel, ytitle = ylabel, yrange = [-2000, 2000]
write_gif, dattim+'.gif', tvrd()

;cd, '/home/jack/SSProject/Extract/'



end
