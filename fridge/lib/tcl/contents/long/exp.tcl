proc stop {tracefile} {
	global ns
  close $tracefile
	exit
}

proc max {a b} { if {$a < $b} {return $b} {return $a} }

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

if {$argc != 9} {
	puts "Usage: $argv0 queue (RED/DropTail) bband (Mb/s) bbuf (pkts) \
							 bdel (ms) simlen (seocnds) pktsz (bytes) numtcp numtfrc startlog"
	exit  
}

set count 0
set queue [lindex $argv $count] 
incr count 
set bband [lindex $argv $count] 
incr count 
set bbuf [lindex $argv $count]
incr count 
set bdel [lindex $argv $count]
incr count 
set simlen [lindex $argv $count]
incr count 
set pktsz [lindex $argv $count]
incr count 
set numtcp [lindex $argv $count]
incr count 
set numtfrc [lindex $argv $count]
incr count 
set startlog [lindex $argv $count]

#puts queue=$queue
#puts bband=$bband 
#puts bdel=$bdel 
#puts bbuf=$bbuf 
#puts simlen=$simlen 
#puts pktsz=$pktsz 
#puts df=$df 
#puts nf=$NumFeedback 

set ns [new Simulator]
set tracefile [open all.tr w]
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

set count 1 

add_tcp_con [expr 10.0*[ns-random]/2147483647.0] $simlen
add_tfrc_con [expr 10.0*[ns-random]/2147483647.0] $simlen

for {set i 1} {$i < $numtcp} {incr i} {
	add_tcp_con [expr 10.0*[ns-random]/2147483647.0] $simlen
}
for {set i 1} {$i < $numtfrc} {incr i} {
	add_tfrc_con [expr 10.0*[ns-random]/2147483647.0] $simlen
}

$ns at $simlen "stop $tracefile"
$ns at $startlog "$ns trace-queue $node_(r1) $node_(r2) $tracefile"
$ns run
