set term postscript eps 25

#
# cov 
#

set size 1.0,0.8
set output "steady.cov.2d.eps"
set xlabel "Timescale for throughput measurement (seconds)"
set ylabel "Coefficient of Variation"
set logscale x
set nologscale y
set xtics ("0.2" 0.2, "" 0.3, "" 0.4, "0.5" 0.5, "" 0.6, "" 0.7, "" 0.8, "" 0.9, "1" 1.0, "2" 2, "" 3, "" 4, "5" 5, "" 6, "" 7, "" 8, "" 9, "10" 10)
#set ytics (0.1, 0.2, "" 0.3, "" 0.4, 0.5, "" 0.6, "" 0.7, "" 0.8, "" 0.9, 1.0)
set ytics
#set mytics
plot [0.2:10][0:0.6] "tfrc.15.50.100.16.avg.cov" u 1:2 t "TFRC" w l, \
     "tfrc.15.50.100.16.avg.cov" u 1:2:3:4 notitle w er,\
     "tcp.15.50.100.16.avg.cov" u 1:2 t "TCP" w l, \
		 "tcp.15.50.100.16.avg.cov" u 1:2:3:4 notitle w er

#
# eq
#

set ytics 0, 0.2
set size 1.0,1.0
set output "steady.eq.2d.eps"
set xlabel "Timescale for throughput measurement (seconds)"
set ylabel "Equivalance ratio (TFRC vs TCP)" 
set logscale x
set nologscale y
plot [0.2:10][0:1]"tfrc.15.50.100.16.avg.eq" u 1:2 not w l, \
     "tfrc.15.50.100.16.avg.eq" u 1:2:3:4 notitle w er

    
set output "steady.intra.eq.2d.eps"
set xlabel "Timescale for throughput measurement (seconds)"
set ylabel "Equivalance ratio (flows of same type)"
set logscale x 
set nologscale y
set key 5.5,0.17
plot [0.2:10][0:1] "tfrc.15.50.100.16.avg.intra.eq" u 1:2 t "TFRC" w l, \
     "tfrc.15.50.100.16.avg.intra.eq" u 1:2:3:4 notitle w er,\
     "tcp.15.50.100.16.avg.intra.eq" u 1:2 t "TCP" w l, \
		 "tcp.15.50.100.16.avg.intra.eq" u 1:2:3:4 notitle w er

set output "steady.both.eq.2d.eps"
set xlabel "Timescale for throughput measurement (seconds)"
set ylabel "Equivalance ratio"
set logscale x 
set nologscale y
set key 5.5,0.17
plot [0.2:10][0:1] "tfrc.15.50.100.16.avg.intra.eq" u 1:2 t "TFRC vs TFRC" w lp 1 1, \
     "tfrc.15.50.100.16.avg.intra.eq" u 1:2:3:4 notitle w er 1 1,\
     "tcp.15.50.100.16.avg.intra.eq" u 1:2 t "TCP vs TCP"  w lp 2 2, \
     "tcp.15.50.100.16.avg.intra.eq" u 1:2:3:4 notitle w er 2 2, \
     "tfrc.15.50.100.16.avg.eq" u 1:2 title "TFRC vs TCP" w lp 3 4, \
     "tfrc.15.50.100.16.avg.eq" u 1:2:3:4 notitle w er 3 4
