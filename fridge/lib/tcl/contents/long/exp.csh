#!/usr/local/bin/tcsh -f

set NS = "../ns"
set TCL = "./exp.tcl"

set q = RED 
set simlen = 150 
set slog = 50 
set pktsz = 1000
set maxtrials = 14 

set tot = 1 
foreach bband (15)
	foreach bdel (50)
		foreach bbuf (100)
			foreach fn (16)
				set count = 0 
				while ($count < $maxtrials) 
		
					#
					# what is the key to idenify this run?
					#
					set start = `date +%s`
					set key = $bband.$bdel.$bbuf.$fn.$count
	
					#
					# run the simulation
					#
					
					echo $key start 
					$NS $TCL $q $bband $bbuf $bdel $simlen $pktsz $fn $fn $slog 
	
					#
					# reduce the trace file, gzip it, name it uniquely
					#
				
					echo reducing trace file
					/bin/rm -f xx
					cut -f1,2,5,6,9,10 -d' ' all.tr | \
					grep -v -E "^r" | \
					sed -e "s/tcpFriend/f/g" \
					    -e "s/tcp/t/g" \
					    -e "s/cbr/b/g" \
					    -e "s/udp/u/g" \
					    -e "s/pareto/p/g" \
					    -e "s/exp/e/g" > xx
					
					/bin/mv xx all.tr.$key.tr
					nice gzip all.tr.$key.tr  
					/bin/rm all.tr

					set end = `date +%s`
					set t = `expr $end - $start` 
					echo $tot == $key done == $t
	
					set count = `expr $count + 1`
					set tot = `expr $tot + 1`
				end
			end
		end
	end
end
