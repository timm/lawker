#!/usr/bin/perl

$basefilenam = shift ; 
$timescale = 0.01 ;
open ip, $basefilenam or die "Can not open file $basefilenam" ;
undef $/ ;
$data = <ip>  ;
close ip ; 

@lines = split /\n/, $data ;
foreach $line (@lines) {
	($time, $th) = split /\s+/, $line ;
	push (@td, $th) ; 
}

foreach $ts (@ARGV) {
	@oparray = () ;
	$aggr = int($ts/$timescale) ; 
	$count = 1 ;
	$sum = 0 ;
	foreach $th (@td) {
		$sum = $sum + $th ;
		if ($count%$aggr == 0 && $count > 0) {
			push @oparray, sprintf "%f %f\n", $count*$timescale, $sum/$ts ; 
			$sum = 0 ; 
		}
		$count ++ ;
	}
	open op, sprintf (">$basefilenam.%s.multi", $ts) 
	  or die "Can not open file $ts" ;
	print op @oparray ;
	close op ;
}
