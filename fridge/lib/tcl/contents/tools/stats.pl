#!/usr/bin/perl

sub numerically {$a <=> $b}

sub round {
  my $num, $inum ;
  $num = shift ;
  $inum = int $num ;
  if (($num - $inum) > 0.5) {
    return $inum + 1;
  }
  else {
    return $inum ;
  }
}

while ($d = <>) {
	push (@a, $d);
	$sum += $d ; 
	$count ++ ;
}

$count > 0 || die "no data" ;

$avg = $sum/$count ; 
foreach  $d (@a) {
	$var += ($d-$avg)*($d-$avg) ; 
}
$var = sqrt($var/$count) ;
$cov = $var/$avg ;
$cu = $avg + 1.645*$var/sqrt($count) ; 
$cl = $avg - 1.645*$var/sqrt($count) ; 

@sorted = sort numerically @a ; 

if ($count%2 == 1) {
  $median = $sorted[$count/2] ;
}
else {
  $median = ($sorted[$count/2-1]+$sorted[$count/2])/2.0 ;
}
$q1i = round ($count*0.25) ;
$q3i = round ($count*0.75) ;
$sqir = ($sorted[$q3i] - $sorted[$q1i])/2;
$mu = $median + $sqir/2 ;
$ml = $median - $sqir/2 ;

printf ("%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n", 
         $avg, $cu, $cl, $var, $cov, $median, $mu, $ml, $sqir); 


