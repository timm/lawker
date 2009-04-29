#!/bin/csh
#
set ctr=600
set discount=1
./single.run $ctr $discount
cd graphs
gnuplot s$ctr.mf
ghostview s$ctr.ps &
gnuplot s$ctr.loss.mf
ghostview s$ctr.loss.ps &
gnuplot s$ctr.rate.mf
ghostview s$ctr.rate.ps &
cd ..

