#!/bin/bash

DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.3" BETAM="60" PLIK="X100kfinalGERpol1.mat" SLACOMP="sieci/slacomp.mat" POLICY="cptime" PARETO=0 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.3" BETAM="60" PLIK="X100kfinalUSpol1.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cptime" PARETO=0 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.3" BETAM="60" PLIK="X100kfinalGERpol2.mat" SLACOMP="sieci/slacomp.mat" POLICY="cpfail" PARETO=0 matlab  -r sim_helper  &
DISPLAY="" LAMBDAR="3.18e-7" ALPHA="2.3" BETAM="60" PLIK="X100kfinalUSpol2.mat" SLACOMP="siecinobel-us/slacomp.mat" POLICY="cpfail" PARETO=0 matlab  -r sim_helper  &



