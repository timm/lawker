#!/bin/csh
#
set ctr=641
./reduce1.run $ctr 
cd graphs
gnuplot s$ctr.half.mf
ghostview s$ctr.half.ps &
cd ..
