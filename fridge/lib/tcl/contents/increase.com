#!/bin/csh
#
set ctr=650
set interval=100
./increase.run $ctr $interval
cd graphs
gnuplot s$ctr.packetrate.mf
ghostview s$ctr.packetrate.ps &
cd ..
