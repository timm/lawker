#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   the Evil not-so-Naive Bayes classifier/anomaly detector
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs
#use options.awk
#uses array.awk

function usage() {
	about()	
	prints("Usage: nb -[MKLTCDFAWhca] [train] [test]", " ",
    "'train' and test' are csv files.", 
	" ",
	" -L file  Learning csv file. Currently, L="opt("L")",", 
    " -T file  Training csv file. Currently, T="opt("T")",",
	" -C num   Index of class column in csv files. If negative,",
	"          the count is back from the right-hand-side.",
	"          Currently, C="opt("C")".",
    " -F char  Deliminter for columns in csv file. Currently, F="opt("F")".",
	" -M num   Handles low frequency counts. Currently M="opt("M")".".
	" -K num   Hanldes low class counts. Currently, K="opt("K")",",
    " -D char The 'missing value' marker. Currently, D="opt("D")".",
	" -A word  The name of the 'all' class. No input line can have",
	"          this name. Currently, A="opt("A")".",
	" -w       Weird mode. Alert if the test instance is unlikely.",
    "          Disabled by default",
	" -c       Show copyright notice (long).".
	" -a       Show about notice (short).",
	" -h       Help." )
}

BEGIN {start(   "What	=	nb v0.1		;"\
				"When	=	2009		;"\
				"Who	=	Tim Menzies	;"\
				"Why	=	a Naive Bayes anomaly detector/classifier;"\
				"M      =   2			;"\
				"K      =   1			;"\
				"L      =   -			;"\
				"T      =   test.csv	;"\
				"C      =   -1			;"\
				"D      =   ?			;"\
				"F      =   ,			;"\
				"A      =   _all		;"\
				"w      =               ;"
				Opt)
	   H=0 s#; number of hypotheses
	   FS=opt("F")
	   main()
 }
 function main(    all,h,n, instances) {
	instances = trains(opt("L"),h,n)
	if(instances)
		tests(opt("T"),h,n,instances)
	else warn("no training data")
 }	
 #selectors
 function h()         { return -1 }
 function all()       { return 0  }
 function klass(   n) { n = opt("C"); return n < 0 ? NF + n : n }

 function trains(f,h,n,   instances) {
	while((getline < f) > 0) { instances++;  train(h,n) }
	close(f)
	return instances
 }
 function tests(f,h,n) {
	while((getline < f) > 0) test(h,n) 
	close(f)
 }
 function train(h,f,n,  i,k) {
   k = $klass()
   if (++h[k]==1) H++
   for(i=1;i<=NF;i++)
     if ($i != opt("D") ) {
   		n[k,i,$i]++
   		n[opt("A"),i,$i]++
	 }
 } 

 
 function likelihood(h,n,instances,l,         klass,i,inc,temp,prior,what,like) {
   like = -10000000000;    # smaller than any log
   for(klass in h) {
      prior=(h[klass]+opt("K"))/(instances + opt("K")*H);
      temp= log(prior)
      for(i=1;i<=NF;i++) {
         if (i != Klass)
            if ( $i !~ /\?/ )
                temp += log((Count[klass,i,$i]+M*prior)/(H[klass]+M))
      }
      l[klass]= temp
      if ( temp >= like ) {like = temp; what=klass}
   }
   return what
}

