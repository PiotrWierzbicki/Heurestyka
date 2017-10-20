#!/bin/bash

#pbz
#scl enable devtoolset-2 python27 bash
#g++ -Ofast -Wall -O3 -std=gnu++11 -shared -fPIC -static-libgcc -static-libstdc++ -o createstates.mexa64  createstates.cpp components.cpp -I /usr/local/MATLAB/R2015b/extern/include


ver="R2015b"
#PG
g++ -Ofast -Wall -O3 -std=gnu++11 -shared -fPIC -static-libgcc  -static-libstdc++ -o createstates.mexa64  createstates.cpp components.cpp -I /usr/local/MATLAB/$ver/extern/include
g++ -Ofast -Wall -O3 -std=gnu++11 -shared -fPIC  -static-libgcc  -static-libstdc++  -o sbpp.mexa64  sbpp.cpp -I /usr/local/MATLAB/$ver/extern/include
