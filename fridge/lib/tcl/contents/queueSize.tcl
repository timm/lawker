proc setQueueSize {rate queue node1 node2} {
global ns 
switch $rate {
    60 {
        $ns queue-limit $node1 $node2 1000
        $ns queue-limit $node2 $node1 1000
        if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ 100
            $redq set maxthresh_ 500
            $redq set linterm_ 10
        }
    }
    15 {
        $ns queue-limit $node1 $node2 250
        $ns queue-limit $node2 $node1 250
        if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ 25
            $redq set maxthresh_ 125
            $redq set linterm_ 10
        }
    }
    1.5 {
        $ns queue-limit $node1 $node2 25
        $ns queue-limit $node2 $node1 25
        if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ 3
            $redq set maxthresh_ 13
            $redq set linterm_ 10
        }
    }
}
}

proc setQueueSize3 {rate queue node1 node2} {
    global ns 
    set limit [expr 15*$rate]
    $ns queue-limit $node1 $node2 $limit
    $ns queue-limit $node2 $node1 $limit
    if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ [expr 3 + $limit/10]
            $redq set maxthresh_ [expr 10 + $limit/3]
            $redq set linterm_ 10
    } 
}



proc setQueueSize2 {rate queue node1 node2 {queuefactor 1}} {
global ns 
switch $rate {
    60 {
	set limit1 1000
	set limit [expr $limit1 / $queuefactor]
        $ns queue-limit $node1 $node2 $limit
        $ns queue-limit $node2 $node1 $limit
        if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ 15
            $redq set maxthresh_ 60
            $redq set linterm_ 10
        } elseif {$queue=="DropTail"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ $limit
            $redq set maxthresh_ $limit
            $redq set linterm_ 10
        }
    }
    15 {
	set limit1 250
	set limit [expr $limit1 / $queuefactor]
        $ns queue-limit $node1 $node2 $limit
        $ns queue-limit $node2 $node1 $limit
        if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
#            $redq set thresh_ 5
#            $redq set maxthresh_ 20
            $redq set thresh_ 5
            $redq set maxthresh_ 100
            $redq set linterm_ 10
        } elseif {$queue=="DropTail"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ $limit
            $redq set maxthresh_ $limit
            $redq set linterm_ 10
        }
    }
    1.5 {
	set limit1 30
	set limit [expr $limit1 / $queuefactor]
        $ns queue-limit $node1 $node2 $limit
        $ns queue-limit $node2 $node1 $limit
        if {$queue=="RED"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ 3
            $redq set maxthresh_ 12
            $redq set linterm_ 10
        } elseif {$queue=="DropTail"} {
            set redq [[$ns link $node1 $node2] queue]
            $redq set thresh_ $limit
            $redq set maxthresh_ $limit
            $redq set linterm_ 10
        }
    }
}
}

proc setQueueSize4 {rate queue node1 node2} {
    global ns
    set limit 20*$rate
    $ns queue-limit $node1 $node2 $limit
    $ns queue-limit $node2 $node1 $limit
    if {$queue=="RED"} {
        set redq [[$ns link $node1 $node2] queue]
        $redq set thresh_ 3+$rate
        $redq set maxthresh_ 10*$rate
        $redq set linterm_ 10
    } elseif {$queue=="DropTail"} {
        set redq [[$ns link $node1 $node2] queue]
        $redq set thresh_ $limit
        $redq set maxthresh_ $limit
        $redq set linterm_ 10
    }
}

## proc setQueueSize1 {rate queue node1 node2} {
## global ns
## switch $rate {
##     60 {
## 	# delay-bandwidth product 300 pkts
## 	    # average queuing delay should be less than propagation delay,
## 	    #   for large propagation delays.
## 	    # for very small propagation delays, average queueing delay
## 	    #   of 10ms or so should not be an issue.  Overall delays of 
## 	    #   30ms can start to be noticeable to the user.
## 	    # delay is of concern when it gets up to 30ms.
## 	    # buffer could have up to 50 ms, even for small RTTs.
## 	    # guideline: maxthresh should be half the one-way d-b product
## 	    #  of the 20ms link, but at least 4.
## 	    # 10 ms: 75 packets.
## 	}
##     }
##     15 {
## 	# delay-bandwidth product 75 pkts: 1875 pps, RTT 0.04 sec 
## 	    $redq set thresh_ 5
## 	    $redq set maxthresh_ 20
## 	    $redq set linterm_ 10
## 	}
##     }
##     1.5 {
## 	# delay-bandwidth product 7.5 pkts.
## 	}
##     }
## }
## }
