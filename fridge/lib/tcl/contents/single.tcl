set flows [lindex $argv 0]
set queue [lindex $argv 1]
set rate [lindex $argv 2]
set ecn [lindex $argv 3]
set discount [lindex $argv 4]

proc stop {} {
 	exit
}


set ns [new Simulator]
set node_(r1) [$ns node]
set node_(r2) [$ns node]
Queue/RED set gentle_ true
if {$ecn==1} {
  Queue/RED set setbit_ true
  Agent/TCP set ecn_ 1
}

$ns duplex-link $node_(r1) $node_(r2) [set rate]Mb 20ms $queue
set lossylink_ [$ns link $node_(r1) $node_(r2)]

source queueSize.tcl
setQueueSize $rate $queue $node_(r1) $node_(r2)

# Set up TCP connection
Agent/TFRC set packetSize_ 1000
Agent/TFRCSink set discount_ $discount
Agent/TFRCSink set printLoss_ 1
Agent/TFRCSink set smooth_ 1
Agent/TFRC set printStatus_ 1
Agent/TFRC set df_ 0.95
Agent/TFRC set ca_ 1

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
    $ns at 20 "[set tf$i] stop"
}
set randomflows 1
if {$randomflows > $flows} {
    set randomflows $flows
}
for {set i 0} {$i < $randomflows} {incr i} {
    set tcp$i [$ns create-connection TCP/Sack1 $node_(k$i) TCPSink/Sack1 $node_(s$i) 1]
    [set tcp$i] set window_ 8
    set ftp$i [[set tcp$i] attach-app FTP]
    $ns at $i "[set ftp$i] start"
    $ns at 20 "[set ftp$i] stop"
}

$ns at 20 "stop"

set em [new ErrorModule Fid]
$lossylink_ errormodule $em
$em default pass

set emod [$lossylink_ errormodule]
set errmodel [new ErrorModel/List]
$errmodel unit pkt
$errmodel droplist { 50 150 250 350 450 550 650 750 850 950 1050 1150 1250 1350 1450 1550 1560 1570 1580 1590 1600 1610 1620 1630 1640 1650 1660 1670 1680 1690 1700 1900 2100 2300 2500 2700 2900 3100 3300 3500 3700 3900 4100 }
$emod insert $errmodel
$emod bind $errmodel 0

$ns run
