proc stop {qmon tcpth tfrcth tracefile} {
	global ns
	global pktsz
	global interval
	
	close $tracefile 
	#
	# stupid fix to force floating point arithmatic 
	#

	set drop [expr 1.0 * [$qmon set pdrops_]]
	set arr  [expr 1.0 * [$qmon set parrivals_]]
	set droprate [expr $drop/$arr]

	upvar $tcpth a
	set tracefile [open tcp.tr w]
	set time 0 
	set prev 0
	foreach el $a {
		set tmp $el
		#puts [format "%d %d %d %d" $el $tmp $prev [expr ($tmp - $prev)]] 
		set el [expr ($tmp - $prev)]
		set prev $tmp
		puts $tracefile [format "%.3f %.3f"  $time [expr $el*$pktsz*8.0]]
		set time [expr $time + $interval]
	}
	close $tracefile

	upvar $tfrcth b 
	set tracefile [open tfrc.tr w]
	set time 0 
	set prev 0
	foreach el $b {
		set tmp $el
		set el [expr ($el - $prev)*$pktsz*8]
		set prev $tmp
		puts $tracefile [format "%.3f %.3f"  $time $el]
		set time [expr $time + $interval]
	}
	close $tracefile

	set tracefile [open drop.tr w]
	puts $tracefile [format "%.6f %.3f %.3f" $droprate $drop $arr] 
	close $tracefile

	exit
}

proc max {a b} { if {$a < $b} {return $b} {return $a} }

proc dump {conn interval thput type} {
	global ns
	upvar $thput a
	lappend a [$conn set ndatapack_] 
	if {$type == "tcp"} {
		$ns at [expr [$ns now]+$interval] "dump $conn $interval tcpth tcp" 
	}
	if {$type == "tfrc"} {
		$ns at [expr [$ns now]+$interval] "dump $conn $interval tfrcth tfrc" 
	}
}

	
proc add_tcp_con {start stop} {
	global ns
	global node_
	global s_
	global r_
	global count 
	global tcp_ 
	global ftp_ 

	set x [expr 20.0*[ns-random]/2147483647.0]ms
	set y [expr 20.0*[ns-random]/2147483647.0]ms

	set i $count 
	set s_($i) [$ns node]
	set r_($i) [$ns node]
	$ns duplex-link $s_($i) $node_(r1) 100Mb $x DropTail
	$ns duplex-link $r_($i) $node_(r2) 100Mb $y DropTail
	set tcp_($i) \
		[$ns create-connection TCP/Sack1 $s_($i) TCPSink/Sack1 $r_($i) 0]
	[set tcp_($i)] set window_ 10000
	set ftp_($i) [[set tcp_($i)] attach-app FTP]
	$ns at $start "[set ftp_($i)] start"
	$ns at $stop "[set ftp_($i)] stop"

	incr count
}

proc add_tfrc_con {start stop} {
	global ns
	global node_
	global s_
	global r_
	global count 
	global tfrc_ 

	set x [expr 20.0*[ns-random]/2147483647.0]ms
	set y [expr 20.0*[ns-random]/2147483647.0]ms

	set i $count 
	set s_($i) [$ns node]
	set r_($i) [$ns node]
	$ns duplex-link $s_($i) $node_(r1) 100Mb $x DropTail
	$ns duplex-link $r_($i) $node_(r2) 100Mb $y DropTail
	set tfrc_($i) \
		[$ns create-connection TFRC $s_($i) TFRCSink $r_($i) 0]
	$ns at $start "$tfrc_($i) start"

	incr count
}

proc add_cbr_on_off_con {start on off rate} {
	global ns
	global node_
	global s_
	global r_
	global count 
	global udp_ 
	global par_

	set x [expr 20.0*[ns-random]/2147483647.0]ms
	set y [expr 20.0*[ns-random]/2147483647.0]ms

	set i $count 

	set s_($i) [$ns node]
	set r_($i) [$ns node]
	$ns duplex-link $s_($i) $node_(r1) 100Mb $x DropTail
	$ns duplex-link $r_($i) $node_(r2) 100Mb $y DropTail
	set udp_($i) \
		[$ns create-connection UDP $s_($i) UDP $r_($i) 0]

	set par_($i) [$udp_($i) attach-app Traffic/Pareto] 
	$par_($i) set burst_time_ $on
	$par_($i) set idle_time_ $off
	$par_($i) set rate_ $rate
	$par_($i) set shape 1.5 

	$ns at $start "$par_($i) start"

	incr count
}

if {$argc != 12} {
	puts "Usage: $argv0 queue (RED/DropTail) bband (Mb/s) bbuf (pkts) \
							 bdel (ms) simlen (seocnds) pktsz (bytes) \
							 numtcp numtfrc on off rate numcbr"
	exit  
}

set count 0

set queue [lindex $argv $count] 
#puts "queue = $queue"
incr count 

set bband [lindex $argv $count] 
#puts "band = $bband"
incr count 

set bbuf [lindex $argv $count]
#puts "bbuf = $bbuf"
incr count 

set bdel [lindex $argv $count]
#puts "del = $bdel"
incr count 

set simlen [lindex $argv $count]
#puts "sim = $simlen"
incr count
 
set pktsz [lindex $argv $count]
#puts "pkt = $pktsz"
incr count
 
set numtcp [lindex $argv $count]
#puts "ntcp = $numtcp"
incr count
 
set numtfrc [lindex $argv $count]
#puts "ntfrc = $numtfrc"
incr count

set on [lindex $argv $count]
#puts "on = $on"
incr count

set off [lindex $argv $count]
#puts "off = $off"
incr count

set rate [lindex $argv $count]
#puts "rate = $rate"
incr count

set numcbr [lindex $argv $count]
#puts "cbr = $numcbr"

set ns [new Simulator]

#$ns set-address-format expanded

ns-random 0

set node_(r1) [$ns node]
set node_(r2) [$ns node]

set bb [expr $bband]Mb
set bd [expr $bdel]ms
set bbuf $bbuf 

$ns duplex-link $node_(r1) $node_(r2) $bb $bd $queue
$ns queue-limit $node_(r1) $node_(r2) $bbuf 
$ns queue-limit $node_(r2) $node_(r1) $bbuf 

if {$queue=="RED"} {
    set redq [[$ns link $node_(r1) $node_(r2)] queue]
    $redq set thresh_ [max [expr int(0.5 + $bbuf*0.1)] 5] 
    $redq set maxthresh_ [max [expr int(0.5 + $bbuf*0.5)] 15] 
    $redq set linterm_ 10
		$redq set gentle_ true
}

Agent/TCP set packetSize_ $pktsz
Agent/TCP set overhead_ 0.002

Agent/TFRC set packetSize_ $pktsz
Agent/TFRC set overhead_ 0.002
Agent/TFRC set discount_ 1
Agent/TFRC set df_ 0.95
Agent/TFRC set ca_ 1
Agent/TFRCSink set smooth_ 1


Application/Traffic/Pareto set packetSize_ $pktsz
Application/Traffic/CBR set packetSize_ $pktsz

set count 1 

add_tcp_con [expr 5.0*[ns-random]/2147483647.0] $simlen
add_tfrc_con [expr 5.0*[ns-random]/2147483647.0] $simlen

for {set i 0} {$i < $numcbr} {incr i} {
	set xon [expr 2.0*$on*[ns-random]/2147483647.0]
	set xoff [expr 2.0*$off*[ns-random]/2147483647.0]
	set xrate [expr 2.0*$rate*[ns-random]/2147483647.0]Mb
	set xstart [expr 5.0*[ns-random]/2147483647.0]
	add_cbr_on_off_con $xstart $xon $xoff $xrate
}
set tcpth {0} 
set tfrcth {0} 
set tracefile [open all.tr w]
set interval 0.2
$ns at 0 "dump $tcp_(1) $interval tcpth tcp"
$ns at 0 "dump $tfrc_(2) $interval tfrcth tfrc"

set qmon [$ns monitor-queue $node_(r1) $node_(r2) ""]

#$ns at [expr $simlen*0.1] "$ns trace-queue $s_(1) $node_(r1) $tracefile"
#$ns at [expr $simlen*0.1] "$ns trace-queue $s_(2) $node_(r1) $tracefile"

$ns at $simlen "stop $qmon tcpth tfrcth $tracefile"
$ns run
