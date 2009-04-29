#!/usr/local/bin/tclsh8.1

set tcpall [open "s3xxx.tcpcov" "w"]
set tcpmean [open "s3xxx.tcpmeancov" "w"]
set tfrmall [open "s3xxx.tfrmcov" "w"]
set tfrmmean [open "s3xxx.tfrmmeancov" "w"]
for {set ctr 3000} {$ctr<=3010} {incr ctr} {
#    set tcpfile [open "s$ctr.tcpcov" "w"]
#    set tfrmfile [open "s$ctr.tfrmcov" "w"]
    set tcpmeanval 0
    set lossmean 0
    set tfrmmeanval 0
    for {set i 0} {$i<10} {incr i} {
	set tcpi [open "s$ctr.$i.tcpcov" "r"]
	set tcpl [open "s$ctr.$i.p" "r"]
	set line [gets $tcpi]
	set loss [gets $tcpl]
	close $tcpi
	close $tcpl
#	puts $tcpfile $line
	set val [lindex $line 1]
	set loss [lindex $loss 1]
	set lossmean [expr $lossmean + $loss]
#	puts $tcpall "\n$line"
	puts $tcpall "$loss $val"
	set tcpmeanval [expr $tcpmeanval + $val]

	set tfrmi [open "s$ctr.$i.tfrmcov" "r"]
	set line [gets $tfrmi]
	close $tfrmi
#	puts $tfrmfile $line
	set val [lindex $line 1]
	puts $tfrmall "$loss $val"
	set tfrmmeanval [expr $tfrmmeanval + $val]
    }
    puts $tcpmean "[expr $lossmean/10.0] [expr $tcpmeanval/10.0]"
    puts $tfrmmean "[expr $lossmean/10.0] [expr $tfrmmeanval/10.0]"
#    close $tcpfile
#    close $tfrmfile
}
close $tcpmean
close $tfrmmean
close $tcpall
close $tfrmall