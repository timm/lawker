set interval [lindex $argv 0]
set stoptime 20
set changetime 10

proc stop {} {
 	exit
}

set ns [new Simulator]
set node_(r1) [$ns node]
set node_(r2) [$ns node]
set rate 15
set queue DropTail
set i 0

$ns duplex-link $node_(r1) $node_(r2) [set rate]Mb 20ms $queue
set lossylink_ [$ns link $node_(r1) $node_(r2)]

source queueSize.tcl
setQueueSize $rate $queue $node_(r1) $node_(r2)

# Set up TCP connection
Agent/TFRC set packetSize_ 1000
# Agent/TFRC set packetSize_ 40
Agent/TFRC set printStatus_ 1
Agent/TFRCSink set discount_ 1
Agent/TFRCSink set printLoss_ 1
Agent/TFRCSink set smooth_ 1
Agent/TFRC set df_ 0.95
Agent/TFRC set ca_ 1

set node_(s$i) [$ns node]
set node_(k$i) [$ns node]
$ns duplex-link $node_(s$i) $node_(r1) 100Mb 10ms DropTail
$ns duplex-link $node_(k$i) $node_(r2) 100Mb 10ms DropTail
set tf$i [$ns create-connection TFRC $node_(s$i) TFRCSink $node_(k$i) 0]
set starttime 0

$ns at $starttime "[set tf$i] start"
$ns at $stoptime "[set tf$i] stop"

$ns at $stoptime "stop"

set em [new ErrorModule Fid]
$lossylink_ errormodule $em
$em default pass

set emod [$lossylink_ errormodule]
set errmodel [new ErrorModel/Periodic]
$errmodel unit pkt
## $errmodel set offset_ $interval
## $errmodel set period_ $interval
$errmodel set offset_ 10
$errmodel set period_ $interval
$ns at $changetime "$errmodel set period_ 2"
$emod insert $errmodel
$emod bind $errmodel 0

$ns run
