#!/usr/local/bin/tcsh -f

set NS = "../ns"
set TCL = "./exp.tcl"

set q = RED 
set simlen  = 5000
set pktsz = 1000 
set maxtrials = 10 
set bdel = 50
set bbuf = 200 
set on = 1 
set off = 2 
set rate = 0.5 
set bband = 15

set tot = 1 
foreach numcbr (50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200)
	set count = 0 
	while ($count < $maxtrials) 
		
		#
		# what is the key to idenify this run?
		#
		set start = `date +%s`
		set key = $bband.$bdel.$bbuf.$numcbr.$count
	
		#
		# run the simulation
		#
	
		$NS $TCL $q $bband $bbuf $bdel $simlen $pktsz 0 0 $on $off $rate $numcbr 
	
		#
		# gzip trace files, name them uniquely
		#
	
		mv tcp.tr tcp.$key.tr
		mv tfrc.tr tfrc.$key.tr
		mv drop.tr drop.$key.tr

		gzip tcp.$key.tr
		gzip tfrc.$key.tr
		gzip drop.$key.tr

		set end = `date +%s`
		set t = `expr $end - $start` 
		echo $tot == $key done == $t
	
		set count = `expr $count + 1`
		set tot = `expr $tot + 1`
	end
end

echo done

