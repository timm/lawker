#!/usr/local/bin/tclsh8.1

set file [open [lindex $argv 0] "r"]
while {[eof $file]==0} {
    set line [gets $file]
    if {$line==""} {break}
    set flows [lindex [split [expr [lindex $line 0] + 0.5] "."] 0]
    set rate [lindex $line 1]
    if {[info exists v($flows)]} {
	set v($flows) [expr $v($flows) + $rate]
	incr s($flows)
    } else {
	set v($flows) $rate
	set s($flows) 1
    }
}
close $file

foreach flows [lsort -real [array names v]] {
    set mean($flows) [expr $v($flows)/$s($flows)]
}

set file [open [lindex $argv 0] "r"]
while {[eof $file]==0} {
    set line [gets $file]
    if {$line==""} {break}
    set flows [lindex [split [expr [lindex $line 0] + 0.5] "."] 0]
    set rate [lindex $line 1]
    set diff [expr $rate - $mean($flows)]
    if {[info exists var($flows)]} {
	set var($flows) [expr $var($flows) + $diff*$diff]
    } else {
	set var($flows) [expr $diff*$diff]
    }
}
close $file

foreach flows [lsort -real [array names v]] {
    puts "$flows [expr sqrt($var($flows)/$s($flows))/$mean($flows)]"
}



