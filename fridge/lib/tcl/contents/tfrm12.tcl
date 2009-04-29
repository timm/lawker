set flows [lindex $argv 0]
set queue [lindex $argv 1]
set rate [lindex $argv 2]
set ecn [lindex $argv 3]
puts "flows:$flows queue:$queue rate:$rate ecn:$ecn"

proc stop {tracefile} {
    close $tracefile
    exit
}

proc printall { fmon } {
    puts "aggregate per-link total_drops [$fmon set pdrops_]"
    puts "aggregate per-link total_packets [$fmon set pdepartures_]"
}

set stoptime 75
# set stoptime 300

set ns [new Simulator]
set tracefile [open all.12.tr w]
#$ns trace-all $tracefile

set node_(r1) [$ns node]
set node_(r2) [$ns node]
Queue/RED set gentle_ true
if {$ecn==1} {
  Queue/RED set setbit_ true
  Agent/TCP set ecn_ 1
}

$ns duplex-link $node_(r1) $node_(r2) [set rate]Mb 20ms $queue
source queueSize.tcl
setQueueSize $rate $queue $node_(r1) $node_(r2)
$ns trace-queue $node_(r1) $node_(r2) $tracefile

set slink [$ns link $node_(r1) $node_(r2)]; # link to collect stats on
set fmon [$ns makeflowmon Fid]
$ns attach-fmon $slink $fmon

# Set up TCP connection
Agent/TFRC set packetSize_ 1000
Agent/TFRCSink set discount_ 1
Agent/TFRC set df_ 0.95
Agent/TFRC set ca_ 1
Agent/TFRCSink set smooth_ 1
for {set i 0} {$i < $flows} {incr i} {
    set node_(s$i) [$ns node]
    set node_(k$i) [$ns node]
    $ns duplex-link $node_(s$i) $node_(r1) 100Mb 2ms DropTail
    $ns duplex-link $node_(k$i) $node_(r2) 100Mb [expr $i/3]ms DropTail
    set tf$i [$ns create-connection TFRC $node_(s$i) TFRCSink $node_(k$i) 0]
    set sec [expr $i/10]
    set frac [expr $i%10]
    set starttime $sec.$frac
    $ns at $starttime "[set tf$i] start"
    $ns at $stoptime "[set tf$i] stop"
    set node_(ts$i) [$ns node]
    set node_(tk$i) [$ns node]
    $ns duplex-link $node_(ts$i) $node_(r1) 100Mb 2ms DropTail
    $ns duplex-link $node_(tk$i) $node_(r2) 100Mb [expr $i/3]ms DropTail
    set tcp$i [$ns create-connection TCP/Sack1 $node_(ts$i) TCPSink/Sack1 $node_(tk$i) 0]
    [set tcp$i] set window_ 10000
    set ftp$i [[set tcp$i] attach-app FTP]
    $ns at $starttime "[set ftp$i] start"
    $ns at $stoptime "[set ftp$i] stop"
}
set randomflows 4
if {$randomflows > $flows} {
    set randomflows $flows
}
for {set i 0} {$i < $randomflows} {incr i} {
    set tcp$i [$ns create-connection TCP/Sack1 $node_(k$i) TCPSink/Sack1 $node_(s$i) 1]
    [set tcp$i] set window_ 20
    set ftp$i [[set tcp$i] attach-app FTP]
    $ns at $i "[set ftp$i] start"
    $ns at $stoptime "[set ftp$i] stop"
}

$ns at $stoptime "printall $fmon; stop $tracefile"

$ns run
