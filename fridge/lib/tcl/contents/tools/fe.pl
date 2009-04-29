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

sub stdev {
	local ($size, $avg, @array) = @_ ; 
	my $count ; 
	$count = 0 ;
	foreach $num (@array) {
		$var += ($num-$avg)*($num-$avg) ; 
		$count ++ ;
		if ($count > $size) {
			break ; 
		}
	}
	$var = sqrt($var/$size) ; 
	return $var ;
}


$fnamA = shift ; 
$fnamB = shift ; 

open fA, $fnamA or die "Can't open file $fnamA" ;
open fB, $fnamB or die "Can't open file $fnamB" ;

undef $/ ;

$_ = <fA> ;
@A = split /\n/ ;
close fA ;

$_ = <fB> ;
@B = split /\n/ ;
close fB ;

#
#if ($#A != $#B) {
#	printf ("file sizes differ\n");
#	exit(1) ; 
#}
#

if ($#A > $#B) {
	$min = $#B ; 
}
else {	
	$min = $#A ;
}

$count = 0 ;
foreach $e (@A) {
	($at, $ad) = split /\s+/, $e ; 
	$e = shift @B ; 
	($bt, $bd) = split /\s+/, $e ; 
	if ($at != $bt) {
		printf "file timings differ :$at: :$bt: :$count: :$min:\n";
		exit(1) ; 
	}
	$suma += $ad ; $sumb += $bd ; 

	if ($ad < 0.0001) {
		$ad = 0.0001 ; 
	}
	if ($bd < 0.0001) {
		$bd = 0.0001 ; 
	}

	$ratio = $ad/$bd ; 

	#
	# this takes the min of (a/b, b/a)
	# change to "<" if you need max
	#

	if ($ratio > 1) {
		$ratio = 1.0/$ratio ; 
	}

	if ( ($ad > 0.002) || ($bd > 0.0002) ) {
		push (@equiv, $ratio); 
		$sum += $ratio ;
		#printf ("%f %f %f\n", $ad, $bd, $ratio);	
	}

	push @adata, $ad ;
	push @bdata, $bd ;
	$count ++ ; 
	if ($count >= $min) {
		last ; 
	}
}

$countE = $#equiv + 1;

$avgE = $sum/$count ; 
$avgA = $suma/$count ;
$avgB = $sumb/$count ;

$varE = stdev($countE, $avgE, @equiv); 
$varA = stdev($count, $avgA, @adata); 
$varB = stdev($count, $avgB, @bdata); 

@sorted = sort numerically @equiv ;
if ($count%2 == 1) {
	$median = $sorted[$count/2] ; 
}
else {
	$median = ($sorted[$count/2-1]+$sorted[$count/2])/2.0 ;
}

$q1i = round ($count*0.25) ;
$q3i = round ($count*0.75) ;
$sqir = ($sorted[$q3i] - $sorted[$q1i])/2;

printf ("%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n", 
         $suma/$sumb, $median, $median-$sqir/2, $median+$sqir/2, 
				 $sorted[$count-1], $avgE, $varE, $avgA, $varA, $avgB, $varB); 

