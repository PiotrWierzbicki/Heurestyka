#!/bin/bash

#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="3" BETAM=60 PLIK="l38a24b60time.mat" matlab  -r helper_time_ws &
#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="1.5" BETAM=60 PLIK="l38a15b60time.mat" matlab  -r helper_time_ws &
#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="1" BETAM="0.1" PLIK="l38a10b01time.mat" matlab  -r helper_time_ws &
#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="0.8" BETAM="0.1" PLIK="l38a08b01time.mat" matlab  -r helper_time_ws &


#DISPLAY="" LAMBDAR="1e-7" ALPHA="3" BETAM=60 PLIK="l10a24b60time.mat" matlab  -r helper_time_ws &
#DISPLAY="" LAMBDAR="1e-7" ALPHA="1.5" BETAM=60 PLIK="l10a15b60time.mat" matlab  -r helper_time_ws &
#DISPLAY="" LAMBDAR="1e-7" ALPHA="1" BETAM="01" PLIK="l10a10b01time.mat" matlab  -r helper_time_ws &
#DISPLAY="" LAMBDAR="1e-7" ALPHA="0.8" BETAM="01" PLIK="l10a08b01time.mat" matlab  -r helper_time_ws &



#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="3" BETAM=60 PLIK="l38a24b60fail.mat" matlab  -r helper_fail_ws &
#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="1.5" BETAM=60 PLIK="l38a15b60fail.mat" matlab  -r helper_fail_ws &
#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="1" BETAM="0.1" PLIK="l38a10b01fail.mat" matlab  -r helper_fail_ws &
#DISPLAY="" LAMBDAR="3.8e-7" ALPHA="0.8" BETAM="0.1" PLIK="l38a08b01fail.mat" matlab  -r helper_fail_ws &


#DISPLAY="" LAMBDAR="1e-7" ALPHA="3" BETAM=60 PLIK="l10a24b60fail.mat" matlab  -r helper_fail_ws &
#DISPLAY="" LAMBDAR="1e-7" ALPHA="1.5" BETAM=60 PLIK="l10a15b60fail.mat" matlab  -r helper_fail_ws &
#DISPLAY="" LAMBDAR="1e-7" ALPHA="1" BETAM="01" PLIK="l10a10b01fail.mat" matlab  -r helper_fail_ws &
#DISPLAY="" LAMBDAR="1e-7" ALPHA="0.8" BETAM="01" PLIK="l10a08b01fail.mat" matlab  -r helper_fail_ws &



for fn in WSa*
do
	echo $fn
	DISPLAY="" FILE_NAME=$fn EXIT_MATLAB=1  matlab  -r analiza 
done

rm plots.pdf
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=plots.pdf *.pdf

