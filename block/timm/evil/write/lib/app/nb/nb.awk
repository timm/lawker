#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   the not-so-Naive Bayes classifier/anomaly detector
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs
#use options.awk
#uses array.awk

function usageNb() {
	about()	
	prints("Usage: nb -[MKLTCDFAWhca] [train] [test]", " ",
    "'train' and test' are csv files.", 
	" ",
	" -L file      Learning csv file. L='"opt("L")"'.", 
    " -T file      Training csv file. T='"opt("T")"'.",
	" -C num       Index of class column in csv files. If negative,",
	"              the count is back from the right-hand-side. C='"opt("C")"'.",
    " -F char      Deliminter for columns in csv file. F='"opt("F")"'.",
	" -M num       Handles low frequency counts. F='"opt("M")"'.",
	" -K num       Hanldes low class counts. K='"opt("K")"'.",
    " -D char      The 'missing value' marker. D='"opt("D")"'.",
	" -A word      The name of the 'all' class. No input line can have",
	"              this name. A='"opt("A")"'.",
    " --Inf num    Largest number. Inf='"opt("Inf")"'.",
	" -w           Weird mode. Alert if the test instance is unlikely.",
    "              Disabled by default",
	" -a           Show about notice (short).",
	" -c           Show copyright notice (long).",
	" -h           Help." )
}

 BEGIN {if (ok2go(Opt,
				"What	=	nb v0.1		;"\
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
				"Inf    =   100000000000000000000000000000000	;"\
				"w      =               "))  
       {
			H=0 
	   		FS=opt("F")
	   		OFS=","
	   		mainNb() 
		} else usageNb()
 }
 function mainNb(    h,n, instances) {
	if (instances = trains(h,n))
		tests(h,n,instances, 
				  tooWeird(h,n,instances))
	else
		bad("no training data")
 }	

 #selectors
 function h()         { return -1 }
 function all()       { return 0  }
 function klass(   n) { n = opt("C"); return n < 0 ? NF + n : n }

###################################
# training
 function trains(h,n,   learnData, instances) {
	learnData = opt("L")
	while((getline < learnData) > 0) { 
		instances++;  
		train(h,n) 
	}
	close(learnData)
	return instances
 }
 function train(h,n,   i,k) {
   k = $klass()
   if (++h[k]==1) H++
   for(i=1;i<=NF;i++)
     if ($i != opt("D") ) {
   		n[k,i,$i]++
   		n[opt("A"),i,$i]++
	 }
 }
 ###################################
 # testing
 function tests(h,n,instances,w,   testData) {
	testData = ord("T")
	while((getline < testData) > 0) 
		test(n,h,instances, w) 
	close(testData)
 }
 function test(n,h,instances,w,   l,klass,report) {
	klass = likelihoods(n,h,instances,l)
	report = log(l[klass]) < w ? "?" : ""
	print $0, klass report
 }
 ##################################
 # learning what is weird
 function tooWeird(h,n,instances) {
	return opt("w") ? averageLogLikely(h,n,instances) : -1 * opt("Inf")
 }
 function averageLogLikely(h,n,instances,  data,sum,total) {
	data = opt("L")
	while((getline < data) > 0) {
		sum += log(likely(n,h,instances))
		total++
	}
	close(data)
	return (total ? sum/total : 0)
 }
 function likely(n,h,instances,  l,klass) {
	likelihoods(n,h,instances,l)
	return l[opt("A")]
 }
 ##################################
 # worker
  function likelihoods(n,h,instances,l,         klass,i,inc,temp,prior,what,like) {
   like = -1 * opt("Inf");    # smaller than any log
   for(klass in h) {
      prior=(h[klass]+opt("K"))/(instances + opt("K")*H);
      temp= log(prior)
      for(i=1;i<=NF;i++) {
         if (i != klass)
            if ( $i != opt("D") )
                temp += log((n[klass,i,$i]+opt("M")*prior)/(h[klass]+opt("M")))
      }
      l[klass]= temp
      if ( temp >= like ) {like = temp; what=klass}
   }
   return what
 }
