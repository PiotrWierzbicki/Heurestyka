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


DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.3" BETAM="60" PLIK="WSa2.3US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &

DISPLAY="" LAMBDAR="3.18e-7" ALPHA="0.8" BETAM="1" PLIK="WSa0.8US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1" BETAM="1" PLIK="WSa1.0US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.2" BETAM="60" PLIK="WSa1.2US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.4" BETAM="60" PLIK="WSa1.4US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.6" BETAM="60" PLIK="WSa1.6US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.8" BETAM="60" PLIK="WSa1.8US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.0" BETAM="60" PLIK="WSa2.0US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.4" BETAM="60" PLIK="WSa2.4US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.8" BETAM="60" PLIK="WSa2.8US.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=1 matlab  -r sim_helper  &
