#!/bin/bash

#pbz
#scl enable devtoolset-2 python27 bash
#g++ -Ofast -Wall -O3 -std=gnu++11 -shared -fPIC -static-libgcc -static-libstdc++ -o netfailsimex.mexa64  netfailsimex.cpp components.cpp -I /usr/local/MATLAB/R2015b/extern/include
#ver=$(which matlab |cut --d '/' -f 5)

#PG
ver="R2015b"

g++ -Ofast -Wall -O3 -std=gnu++11 -shared -fPIC  -static-libgcc -static-libstdc++ -o netfailsimex.mexa64  netfailsimex.cpp components.cpp -I /usr/local/MATLAB/$ver/extern/include
