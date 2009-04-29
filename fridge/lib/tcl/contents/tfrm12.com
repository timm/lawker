#!/bin/csh
##
## SACK1, TCP competing with TFRC
## tfrm12.run modified for a starttime of 15 for tracing.
## tfrm12.tcl modified for a stop time of 75.
./tfrm12.run
./tfrm12.run1
cd graphs
gnuplot s253.mf
gnuplot s253.loss1.mf
ghostview s253.ps &
ghostview s253.loss1.ps &
cd ..
