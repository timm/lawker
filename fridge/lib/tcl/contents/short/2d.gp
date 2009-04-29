set term postscript eps 23

set size 1.0,0.6
set output "onoff.drop.eps"
set xlabel "Number of On/Off sources" 0,0
set ylabel "Mean Loss Rate (percent)" 0, 0
set xtics 50, 50, 200
set ytics ("0" 0, "20" 0.2, "40" 0.4, "60" 0.6, "80" 0.8, "100" 1)
plot [50:210][0:1] "drop.avg.dat" u 1:2 not w l, "drop.avg.dat" u 1:2:3:4 not w e 

set size 1.0,1.0
set logscale x
set xlabel "Measurement Timescale (seconds)" 
set xtics ("0.1" 0.1, "" 0.3, "" 0.4, "0.5" 0.5, "" 0.6, "" 0.7, "" 0.8, "" 0.9, "1" 1.0, "2" 2, "" 3, "" 4, "5" 5, "" 6, "" 7, "" 8, "" 9, "10" 10, "20" 20,  "" 30,  "" 40,  "50" 50,  "" 60,  "" 70,  "" 80,  "" 90,  "100" 100)


set ytics 0.2,0.2
set output "onoff.eq.2d.eps"
set ylabel "Equivalance Ratio"
set key 3.0,0.95

plot [0.4:100][0:1] \
"tfrc.15.50.200.50.avg.eq" u 1:2 title "50 on/off sources" w lp 1 1, \
"tfrc.15.50.200.50.avg.eq" u 1:2:3:4 not w e 1 1, \
"tfrc.15.50.200.100.avg.eq" u 1:2 title "100 on/off sources" w lp 2 2, \
"tfrc.15.50.200.100.avg.eq" u 1:2:3:4 not w e 2 2, \
"tfrc.15.50.200.150.avg.eq" u 1:2 title "150 on/off sources" w lp 3 3, \
"tfrc.15.50.200.150.avg.eq" u 1:2:3:4 not w e 3 3, \
"tfrc.15.50.200.200.avg.eq" u 1:2 title "200 on/off sources" w lp 4 4, \
"tfrc.15.50.200.200.avg.eq" u 1:2:3:4 not w e 4 4

set ytics 5,5
set output "onoff.tcp.cov.2d.eps"
set ylabel "TCP Coefficient of Variation"
set ytics ("0.1" 0.1,"0.2" 0.2,"" 0.3,"" 0.4,"0.5" 0.5,"" 0.6,"" 0.7,"" 0.8,"" 0.9,"1" 1,"2" 2,"" 3,"" 4,"5" 5,"" 6,"" 7,"" 8,"" 9,"10" 10,"20" 20,"" 30,"" 40,"50" 50)
set key right

set logscale xy
plot [0.35:100][0.1:50] \
"tcp.15.50.200.50.avg.cov" u 1:2 title "50 on/off sources" w lp 1 1, \
"tcp.15.50.200.50.avg.cov" u 1:2:3:4 not w e 1 1, \
"tcp.15.50.200.100.avg.cov" u 1:2 title "100 on/off sources" w lp 2 2, \
"tcp.15.50.200.100.avg.cov" u 1:2:3:4 not w e 2 2, \
"tcp.15.50.200.150.avg.cov" u 1:2 title "150 on/off sources" w lp 3 3, \
"tcp.15.50.200.150.avg.cov" u 1:2:3:4 not w e 3 3, \
"tcp.15.50.200.200.avg.cov" u 1:2 title "200 on/off sources" w lp 4 4, \
"tcp.15.50.200.200.avg.cov" u 1:2:3:4 not w e 4 4

set output "onoff.tfrc.cov.2d.eps"
set ylabel "TFRC Coefficient of Variation"
set logscale xy
plot [0.35:100][0.1:50] \
"tfrc.15.50.200.50.avg.cov" u 1:2 title "50 on/off sources" w lp 1 1, \
"tfrc.15.50.200.50.avg.cov" u 1:2:3:4 not w e 1 1, \
"tfrc.15.50.200.100.avg.cov" u 1:2 title "100 on/off sources" w lp 2 2, \
"tfrc.15.50.200.100.avg.cov" u 1:2:3:4 not w e 2 2, \
"tfrc.15.50.200.150.avg.cov" u 1:2 title "150 on/off sources" w lp 3 3, \
"tfrc.15.50.200.150.avg.cov" u 1:2:3:4 not w e 3 3, \
"tfrc.15.50.200.200.avg.cov" u 1:2 title "200 on/off sources" w lp 4 4, \
"tfrc.15.50.200.200.avg.cov" u 1:2:3:4 not w e 4 4


set term postscript eps 18
set size 1.0,0.8
set output "onoff.both.cov.2d.eps"
set ylabel "TCP Coefficient of Variation"
set ytics
set mytics
#set ytics ("0.1" 0.1,"" 0.2,"" 0.3,"" 0.4,"" 0.5,"" 0.6,"" 0.7,"" 0.8,"" 0.9,"1" 1,"" 2,"" 3,"" 4,"" 5,"" 6,"" 7,"" 8,"" 9,"10" 10,"" 20,"" 30,"" 40,"50" 50)
set xtics ("" 0.1, "" 0.3, "" 0.4, "" 0.5, "" 0.6, "" 0.7, "" 0.8, "" 0.9, "1" 1.0, "" 2, "" 3, "" 4, "" 5, "" 6, "" 7, "" 8, "" 9, "10" 10, "" 20,  "" 30,  "" 40,  "" 50,  "" 60,  "" 70,  "" 80,  "" 90,  "100" 100, "" 200, "" 250, "" 300, "" 350, "" 400, "" 450, "1" 500, "" 1000, "" 1500, "" 2000, "" 2500, "" 3000, "" 3500, "" 4000, "" 4500, "10" 5000, "" 10000, "" 15000, "" 20000, "" 25000, "" 30000, "" 35000, "" 40000, "" 45000, "100" 50000)
set key 20,20

set logscale x
set nologscale y
#set label "TCP" at 1500,0.04
#set label "TFRC" at 3,0.04
set xlabel "TFRC          Measurement Timescale (seconds)          TCP" 0,0
set ylabel "Coefficient of Variation" 1,0
plot [0.35:50000][0:22] \
"tfrc.15.50.200.50.avg.cov" u 1:2 title "50 on/off sources" w lp 1 1, \
"tfrc.15.50.200.50.avg.cov" u 1:2:3:4 not w e 1 1, \
"tfrc.15.50.200.100.avg.cov" u 1:2 title "100 on/off sources" w lp 2 2, \
"tfrc.15.50.200.100.avg.cov" u 1:2:3:4 not w e 2 2, \
"tfrc.15.50.200.150.avg.cov" u 1:2 title "150 on/off sources" w lp 3 3, \
"tfrc.15.50.200.150.avg.cov" u 1:2:3:4 not w e 3 3, \
"tfrc.15.50.200.200.avg.cov" u 1:2 title "200 on/off sources" w lp 4 4, \
"tfrc.15.50.200.200.avg.cov" u 1:2:3:4 not w e 4 4, \
"tcp.15.50.200.50.avg.cov.1000" u 1:2 not w lp 1 1, \
"tcp.15.50.200.50.avg.cov.1000" u 1:2:3:4 not w e 1 1, \
"tcp.15.50.200.100.avg.cov.1000" u 1:2 not w lp 2 2, \
"tcp.15.50.200.100.avg.cov.1000" u 1:2:3:4 not w e 2 2, \
"tcp.15.50.200.150.avg.cov.1000" u 1:2 not w lp 3 3, \
"tcp.15.50.200.150.avg.cov.1000" u 1:2:3:4 not w e 3 3, \
"tcp.15.50.200.200.avg.cov.1000" u 1:2 not w lp 4 4, \
"tcp.15.50.200.200.avg.cov.1000" u 1:2:3:4 not w e 4 4, \
"cov.both.line" not w l 1 1
