pro MDI_example


;  Read in the file and pertinent image header keywords. 
;  *****************************************************

data = rfits('fd__01d.2136.0003.fits',head=hd,/scale)
obs_time = strtrim(sxpar(hd, 'T_OBS'),2)
pangle = sxpar(hd, 'P_ANGLE')
radius = sxpar(hd,'R_SUN')
x0 = sxpar(hd, 'X0')
y0 = sxpar(hd, 'Y0')
dattim = strmid(obs_time,0,16)


; Crop and rotate the image. 
;***************************
 
cropped = circle_mask(data, x0, y0, 'GE', radius, mask=0)
rotated = rot(cropped, pangle, 1, x0, y0)


; Write the result to a FITS file and display the result:
; *******************************************************
 
writefits, 'fd_Ic_6h_01d.2136.0002123.fits', rotated           
xtv, rotated(*,*)                                   

; Initialize the display.
;************************

tv2, 512, 512, /init		


; Read a row of pixels that bisect a sunspot into an array.
;********************************************* 

sunspot_profile = intarr(2,936)
for x = 45, 980 do begin
   i = x - 45
   sunspot_profile(0,i) = x
   sunspot_profile(1,i) = rotated(x,350)
end

pix = sunspot_profile(0,*)
int = sunspot_profile(1,*)


; Plot the sunspot profile and write the result to a GIF file.
;*************************************************************

title = 'Sunspot Profile'
ylabel = 'Intensity'
xlabel = 'Pixel'
plot, color = 1, background = 250, pix, int, title=title, xtitle=xlabel, ytitle = ylabel
write_gif, 'sunspot_profile.gif', tvrd()
pause

;
;

; Scale and rebin the rotated, cropped image for easier display and write it to a GIF file.
;******************************************************************************************

scaled = bytscl(rotated, min=1000, max=14000)
im = rebin(scaled,512,512)

tv2, im(*,*)
title = 'MDI Intensitygram:  ' + dattim
xyouts2, 100, 500, title, charsize=1.5
write_gif, 'im.gif', tvrd()
pause


; Calculate the average of the central 100 pixels and print the result.
;**********************************************************************

total = 0
 for x = 251, 260  do begin
   for y = 251, 260  do begin
     total = total + im(x,y)
   endfor
 endfor 
avg = total / 100
print, 'AVERAGE:  ', avg

end

