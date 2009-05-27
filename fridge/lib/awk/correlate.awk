#.H1 Correlate.awk
#.H2 Synopsis
#.PRE
#cat data | gawk -f correlate.awk 
#./PRE
#.H2 Notes 
#.P
#This script calculates the correlation between two columns of numbers.
#.P 
#For more Sherwood scripts, see 
#.URL http://www.cs.ucsb.edu/~sherwood/awk/ Some useful Awk scripts.
#.H3 Example
#.PRE
#cat <<EOF | gawk -f correlate.awk
#1	1.417600305
#2	2.265271781
#3	3.241368347
#4	4.367711955
#5	5.390612315
#6	6.296879718
#7	7.43218197
#8	8.117831008
#9	9.338019481
#10	10.01823657
#EOF
#./PRE
#.P This outputs
#.PRE
#NR=10
#ssx=82.5
#ssy=79.0584
#ssxy=80.6985
#r=0.999227
#./PRE
#.H2 Code
#.PRE
{   xy+=($1*$2); 
	x+=$1; 
	y+=$2; 
	x2+=($1*$1); 
	y2+=($2*$2);
} 
END { 
	print "NR=" NR; 
	ssx=x2-((x*x)/NR); 
	print "ssx=" ssx; 
	ssy=y2-((y*y)/NR); 
	print "ssy=" ssy; 
	ssxy = xy - ((x*y)/NR); 
	print "ssxy=" ssxy; 
	r=ssxy/sqrt(ssx*ssy); 
	print "r=" r; 
}
#./PRE
#.H2 Author
#.P Tim Sherwood
