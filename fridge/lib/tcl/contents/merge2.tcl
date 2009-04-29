#!/usr/local/bin/tclsh8.1

set filen1 [lindex $argv 0]

set f1 [open $filen1 "r"]

set prevflows 1
set prevrate 1
set total 0
set ctr 0

while {[eof $f1]==0} {
    set l1 [gets $f1]
    if {$l1==""} {continue}
    set rate1 [lindex $l1 0]
    set flows1 [lindex $l1 1]
    if {$flows1 != $prevflows} {
	puts "$prevrate $prevflows [expr $total/$ctr]"
	if {$rate1 != $prevrate} {
	    puts ""
	}
	set total 0
	set ctr 0
	set prevflows $flows1
	set prevrate $rate1
    }
    set tp1 [lindex $l1 2]
    set total [expr $total + $tp1]
    incr ctr
}
puts "$prevrate $prevflows [expr $total/$ctr]"

