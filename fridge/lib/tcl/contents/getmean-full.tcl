#!/usr/local/bin/tclsh8.1

set file [open [lindex $argv 0] "r"]
set linkspeed [lindex $argv 1]
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

foreach flows [lsort -real [array names v]] {
    puts "$linkspeed $flows [expr $v($flows)/$s($flows)]"
}