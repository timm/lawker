#!/bin/csh
#
set ctr=640
set interval=100
./reduce.run $ctr $interval
cd graphs
sed 's/0\:/0\:150/g' < s$ctr.rate.mf > t; mv t s$ctr.rate.mf
gnuplot s$ctr.rate.mf
ghostview s$ctr.rate.ps &
cd ..
