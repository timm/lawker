set flows [lindex $argv 0]
set queue [lindex $argv 1]
set rate [lindex $argv 2]
set ecn [lindex $argv 3]
set type3 [lindex $argv 4]
set typeall [lindex $argv 5]
set stoptime [lindex $argv 6]
set inserttime [lindex $argv 7]
set randomflows 4
if {$argc > 8} {
  set randomflows [lindex $argv 8]
}
set randomsim 1
if {$argc > 9} {
  set randomsim [lindex $argv 9]
}
set queuefactor 1
if {$argc > 10} {
  set queuefactor [lindex $argv 10]
  puts "queuefactor: $queuefactor"
} 
puts "flows:$flows queue:$queue rate:$rate ecn:$ecn"

source tracequeue.tcl

proc stop {tracefile} {
    close $tracefile
    exit
}

proc printall { fmon stoptime rate } {
	set drops [$fmon set pdrops_]
	set packets [$fmon set pdepartures_]
	set bytes [$fmon set bdepartures_]
	set droprate [expr double($drops) / $packets ]"
#	set bytespersec 187500
	set bytespersec [expr double($rate)*1000000.0/8]
	set maxbytes [expr double($bytespersec) * $stoptime ]
	set util [expr double($bytes)/$maxbytes]
        puts "drops $drops pkts $packets drop_rate $droprate"
	puts "pkts $packets bytes $bytes util $util"
} 

set ns [new Simulator]
set tracefile [open all.tr w]
#$ns trace-all $tracefile

set node_(r1) [$ns node]
set node_(r2) [$ns node]
Queue/RED set gentle_ true
if {$ecn==1} {
  Queue/RED set setbit_ true
  Agent/TCP set ecn_ 1
}

$ns duplex-link $node_(r1) $node_(r2) [set rate]Mb 20ms RED
source queueSize.tcl 
setQueueSize2 $rate $queue $node_(r1) $node_(r2) $queuefactor

$ns trace-queue $node_(r1) $node_(r2) $tracefile
  set redqueue [[$ns link $node_(r1) $node_(r2)] queue]
if {$queue=="RED"} {
  enable_tracequeue $ns $redqueue
} else {
  enable_tracequeue $ns $redqueue
}

# Set up TCP connection
Agent/TFRC set packetSize_ 1000
Agent/TFRCSink set discount_ 1
Agent/TFRCSink set smooth_ 1
Agent/TFRC set df_ 0.95    
Agent/TFRC set ca_ 1
Agent/TCP set window_ 10000
#
set slink [$ns link $node_(r1) $node_(r2)]; 
set fmon [$ns makeflowmon Fid]
$ns attach-fmon $slink $fmon
#
for {set i 0} {$i < $flows} {incr i} {
    if {$i==3 && ($type3 == "TFRC" || $type3 == "TCP")} {
	set type $type3
    } elseif {$typeall ==0} {
	# half TCP, half TFRC
	set type TCP
	if {$i%2==0} {
	    set type TFRC
	} 
    } else {
        set type $typeall
    }
    set node_(s$i) [$ns node]
    set node_(k$i) [$ns node]
    $ns duplex-link $node_(s$i) $node_(r1) 100Mb 2ms DropTail
    set delay [expr $i/3]ms
    if {$randomsim==0} {
      set delay 2ms
    }
    $ns duplex-link $node_(k$i) $node_(r2) 100Mb $delay DropTail

    set sec [expr $i*$inserttime/($flows+1)] 
    set frac [expr $i%10]
    set starttime $sec.$frac
    if {$type=="TCP"} {
        set tcp$i [$ns create-connection TCP/Sack1 $node_(s$i) TCPSink/Sack1 $node_(k$i) 0]
        set ftp$i [[set tcp$i] attach-app FTP]
        $ns at $starttime "[set ftp$i] start"
        $ns at $stoptime "[set ftp$i] stop"
    } elseif {$type=="TFRC"} {
        set tf$i [$ns create-connection TFRC $node_(s$i) TFRCSink $node_(k$i) 0]
        $ns at $starttime "[set tf$i] start"
        $ns at $stoptime "[set tf$i] stop"
    }
}

# Reverse traffic:
Agent/TCP set window_ 8
set node_(st1) [$ns node]
set node_(kt1) [$ns node]
$ns duplex-link $node_(st1) $node_(r1) 100Mb 2ms DropTail
$ns duplex-link $node_(kt1) $node_(r2) 100Mb 1ms DropTail
for {set i 0} {$i < $randomflows} {incr i} {
    set tcp$i [$ns create-connection TCP/Sack1 $node_(kt1) TCPSink/Sack1 $node_(st1) 1]
    set ftp$i [[set tcp$i] attach-app FTP]
    $ns at $i "[set ftp$i] start"
    $ns at $stoptime "[set ftp$i] stop"
}

# Web mice:  average load 1000 packets.
# 1.5 Mbps gives 5625 packets for 30-second sim.
set maxpkts 20
set bandwidthfraction 0.2
# set randomflows 100
set totalpackets [expr $rate*$stoptime*1000000/8000]
set randomflows [expr $bandwidthfraction*$totalpackets*2/$maxpkts]
if {$randomsim==0} {
  set randomflows 0
}
set rng_ [new RNG]
for {set i 0} {$i < $randomflows} {incr i} {

    set tcp [$ns create-connection TCP/Sack1 $node_(st1) TCPSink/Sack1 $node_(kt1) 1]
    set ftp [[set tcp] attach-app FTP]
    set numpkts [$rng_ uniform 0 $maxpkts]
    set starttime [$rng_ uniform 0 $stoptime]
    $ns at $starttime "[set ftp] produce $numpkts"
    $ns at $stoptime "[set ftp] stop"
}

$ns at $stoptime "printall $fmon $stoptime $rate"
$ns at $stoptime "close $tchan_"
$ns at $stoptime "stop $tracefile"

$ns run
