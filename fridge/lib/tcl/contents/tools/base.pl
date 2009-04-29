#!/usr/bin/perl

%flow = () ;

#
# Flow indexed on sndr-rcvr pairs
# TYPE (tcp/tfrm), TP (array of throughputs), NEXT, COUNT
# 
#

$starttime = shift ;
$ext = shift ;

#
# base granularity is 10ms. We will not go below that
#

$gran = 0.01;  

$numTotBits = 0 ; 

$TYPE = 0 ; 
$NEXT = 1 ; 
$COUNT = 2 ; 
$TOT = 3 ; 
$TP = 4 ; 

while (<>) {

	#
	# Look at enqueue events 
	#

	(/^\+/) || next ; 

	($event, $time, $type, $pktsz, $sndr, $rcvr) = split /\s+/ ; 

	$simlen = $time - $starttime ;
	
	#
	# Flow id is sndr-rcr
	#

	$flowid = $sndr*1000 + $rcvr ; 

	if (!($flow[$flowid][$TYPE])) {
		$flowidhash{$flowid} = 1 ;
		$flow[$flowid][$TYPE] = $type ; 
		$flow[$flowid][$NEXT] = $starttime - $gran ; 
		while ($time > $flow[$flowid][$NEXT]) {
			$flow[$flowid][$COUNT] ++; 
			$flow[$flowid][$NEXT] = $flow[$flowid][$NEXT] + $gran ; 
		}
	}
	else {
		#($flow[$flowid][$TYPE] eq $type) || die "Problem with flow hash" ;
		if ($time > $flow[$flowid][$NEXT]) {
			while ($time > $flow[$flowid][$NEXT]) {
				$flow[$flowid][$NEXT] = $flow[$flowid][$NEXT] + $gran ;
				$flow[$flowid][$COUNT] ++ ; 
			}
		}
	}
	$flow[$flowid][$TOT] += 8*$pktsz ; 
	$flow[$flowid][$TP][$flow[$flowid][$COUNT]-1] += 8*$pktsz ; 
	$numTotBits+= 8*$pktsz;
}
close fp ; 

%numFlowType = () ;

foreach $flowid (sort {$b <=> $a} keys %flowidhash) {
	$ftype = $flow[$flowid][$TYPE] ;
	if ($ext eq "") {
		open fp, sprintf (">%s.%d.base.dat", $ftype, ++$numFlowType{$ftype}) ;
	}
	else {
		open fp, sprintf (">%s.%d.base.%s.dat", $ftype, ++$numFlowType{$ftype}, $ext) ;
	}
	$time = 0 ;
	foreach $bytes (@{$flow[$flowid][$TP]}) {
		printf fp "%f %d\n", $time+$starttime, $bytes; 
		$time += $gran ; 
	}
	close fp ;
	$tot += $flow[$flowid][$TOT] ;
}

#
#foreach $flowid (sort {$b <=> $a} keys %flowidhash) {
#	$ftype = $flow[$flowid][$TYPE] ;
#	printf ("%10s %10.2f %.2f %.2f\n", $ftype,  
#	         $flow[$flowid][$TOT], $flow[$flowid][$TOT]/$tot, 
#					 $flow[$flowid][$TOT]/($simlen*1000));
#}
#printf ("==================\n");
#foreach $flowType (keys %numFlowType) {
#	$first = 1 ; 
#	$numFlowTot = 0 ;
#	foreach $flowid (sort {$b <=> $a} keys %flowidhash) {
#		($flow[$flowid][$TYPE] eq $flowType) || next ;			
#		($first == 1) && ($first = 0 , $max = $flow[$flowid][$TOT], $min = $max) ;
#		($max >= $flow[$flowid][$TOT]) || ($max = $flow[$flowid][$TOT]) ; 
#		($min <= $flow[$flowid][$TOT]) || ($min = $flow[$flowid][$TOT]) ;
#		$numFlowTot += $flow[$flowid][$TOT] ; 
#	}
#	printf "%s %d %.2lf %.2lf\n",
#												 $flowType,  
#												 $numFlowType{$flowType},
#												 $numFlowTot/($numTotBits*$numFlowType{$flowType}), 
#												 $min/$max ; 
#}
#
