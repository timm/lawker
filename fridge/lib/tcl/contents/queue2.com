#!/bin/csh
#To look at individual flows, and the queue behavior. 
# Low levels of statistical multiplexing.
set flows=40
set rate=15
set stoptime=30
set inserttime=20
set ctr=760
./queue.run $ctr 0 TCP $flows $rate $stoptime $inserttime
# Parameters: filename; type for 3rd flow; type for all flows.
cd graphs
sed 's/title "queue size"/notitle/' < s760.queue.mf > t.mf
gnuplot t.mf
gnuplot s760.queue.mf
gnuplot s761.queue.mf 
ghostview s761.queue.ps &
cd ..
#
set ctr=770
./queue.run $ctr 0 TFRC $flows $rate $stoptime $inserttime
cd graphs
sed -e 's/title "queue size"/notitle/' -e 's/0:/0:250/' < s770.queue.mf > t.mf
gnuplot t.mf
gnuplot s770.queue.mf
gnuplot s771.queue.mf
ghostview s771.queue.ps &
cd ..
