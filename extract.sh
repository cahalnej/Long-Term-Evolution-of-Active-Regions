#!/bin/bash

#----------------------------------------------------------------------#
#a bash script to extract one file from a group of folders
#----------------------------------------------------------------------# 

cd 2000

a='fd_M_96m_01d.002'
name='fd_M_96m_01d.2'
d='.0005.fits'

b='851'
c=$a$b
cd $c

e=$name$b$d

echo $e

cp $e /home/jack/SSProject/2015-10-5/2000Extract

cd ..

for i in {852..921..1}
	do
		b=$i
		c=$a$b
		cd $c
		e=$name$b$d
		cp $e /home/jack/SSProject/2015-10-5/2000Extract
		cd ..
done
