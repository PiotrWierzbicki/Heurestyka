#!/bin/bash



DISPLAY="" LAMBDAR="3.18e-7" ALPHA="0.8" BETAM="60" PLIK="P_WSa0.8GER.th2.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=120 EXIT_MATLAB=1 PROTECTION=1  matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.2" BETAM="60" PLIK="P_WSa1.2GER.th2.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=120 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.8" BETAM="60" PLIK="P_WSa2.3GER.th2.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=120 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="0.8" BETAM="60" PLIK="P_WSa0.8GER.th1.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=90 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.2" BETAM="60" PLIK="P_WSa1.2GER.th1.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=90 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.8" BETAM="60" PLIK="P_WSa2.3GER.th1.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=90 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="0.8" BETAM="60" PLIK="P_WSa0.8US.th2.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=120 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.2" BETAM="60" PLIK="P_WSa1.2US.th2.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=120 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.8" BETAM="60" PLIK="P_WSa2.3US.th2.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=120 EXIT_MATLAB=1 PROTECTION=1 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="0.8" BETAM="60" PLIK="P_WSa0.8US.th1.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=90 EXIT_MATLAB=1 PROTECTION=1  matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="1.2" BETAM="60" PLIK="P_WSa1.2US.th1.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=90 EXIT_MATLAB=1 PROTECTION=1  matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.8" BETAM="60" PLIK="P_WSa2.3US.th1.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpth" PARETO=1 POL_TH=90 EXIT_MATLAB=1 PROTECTION=1  matlab  -r sim_helper  &
