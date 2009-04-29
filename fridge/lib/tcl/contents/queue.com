#!/bin/csh
#To look at individual flows, and the queue behavior. 
# Low levels of statistical multiplexing.
set flows=4
set rate=1.5
set stoptime=30
set inserttime=20
set ctr=700
./queue.run $ctr 0 TCP $flows $rate $stoptime $inserttime
# Parameters: filename; type for 3rd flow; type for all flows.
cd graphs
gnuplot s700.queue.mf
gnuplot s701.queue.mf 
#  ghostview s$ctr.queue.ps &
cp s700.queue.ps ~/papers/unicast/figures
cp s701.queue.ps ~/papers/unicast/figures
cd ..
#
set ctr=710
./queue.run $ctr TFRC TCP $flows $rate $stoptime $inserttime
cd graphs
gnuplot s710.queue.mf
gnuplot s711.queue.mf
#  ghostview s$ctr.queue.ps &
# cp s$ctr.queue.ps ~/papers/unicast/figures
cd ..
#
set ctr=720
./queue.run $ctr 0 TFRC $flows $rate $stoptime $inserttime
cd graphs
gnuplot s720.queue.mf
gnuplot s721.queue.mf 
#  ghostview s720.queue.ps &
#  ghostview s721.queue.ps & 
cp s720.queue.ps ~/papers/unicast/figures
cp s721.queue.ps ~/papers/unicast/figures
cd ..
#
set ctr=730 
./queue.run $ctr TCP TFRC $flows $rate $stoptime $inserttime
cd graphs
gnuplot s730.queue.mf
gnuplot s731.queue.mf
#  ghostview s$ctr.queue.ps &
# cp s$ctr.queue.ps ~/papers/unicast/figures
cd ..

