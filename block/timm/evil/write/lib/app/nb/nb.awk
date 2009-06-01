#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   the not-so-Naive Bayes classifier/anomaly detector
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs
#use options.awk

function usageNb() {
	about()	
	prints("Usage: nb -[MKLTCDFAWhca] [train] [test]", " ",
    "'train' and test' are csv files.", " ",
	"In the following, the options below the line are internal",
	"varaibles that you probably will never change.",
	" ",
	" -L file      Learning csv file. L='"opt("L")"'.", 
    " -T file      Training csv file. T='"opt("T")"'.",
	" -w           Weird mode. Alert if the test instance is unlikely.",
    "              Disabled by default.",
    " -F char      Deliminter for columns in csv file. F='"opt("F")"'.",
    " -D char      The 'missing value' marker. D='"opt("D")"'.",
	" -C num       Index of class column in csv files. If negative,",
	"              the count is back from the right-hand-side. C='"opt("C")"'.",
	" -a           Show about notice (short).",
	" -c           Show copyright notice (long).",
	" -h           Help." ,
	" -------------------------------------------------",
	" -M num       Handles low frequency counts. F='"opt("M")"'.",
	" -K num       Handles low class counts. K='"opt("K")"'.",
	" -A word      The name of the 'all' class. No input line can have",
	"              this name. A='"opt("A")"'.",
    " --Inf num    Largest number. Inf='"opt("Inf")"'.")
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
	   		FS=opt("F")
	   		OFS=","
	   		mainNb() 
		} else usageNb()
 }
 function mainNb(    h,n) {
	trains(h,n) ? tests(h,n,tooWeird(h,n)) : bad("no training data")
 }	

 #selectors
 function klass(   n) { n = opt("C"); return n < 0 ? NF + n +1 : n }
 function instances(h) { return h[opt("A")] }

###################################
# training
 function trains(h,n,   learnData) {
	learnData = opt("L")
	while((getline < learnData) > 0)  
		train(h,n) 
	close(learnData)
	return instances(h)
 }
 function train(h,n,   i,k,class) {
   k     = klass()
   class = $k
   h[opt("A")]++
   if(++h[class] == 1) H++ # without the gawk bug, length(H) should do the same
   for(i=1;i<=NF;i++)
     if (i != k)
        if ( $i != opt("D") ) {
   			n[class,   i,$i]++
   			n[opt("A"),i,$i]++
	 }
 }
 ###################################
 # testing
 function tests(h,n,w,   testData) {
	testData = opt("T")
	while((getline < testData) > 0) 
		test(h,n, w) 
	close(testData)
 }
 function test(h,n,w,   l,klass,report) {
	klass = likelihoods(h,n,l)
	report = l[klass] < w ? "?" : ""
	print  $NF, klass report
 }
 ##################################
 # learning what is weird
 function tooWeird(h,n) {
	return opt("w") ? averageLikely(h,n) : -1 * opt("Inf")
 }
 function averageLikely(h,n,     data,sum,total) {
	data = opt("L")
	while((getline < data) > 0) {
		sum += likely(h,n)
		total++
	}
	close(data)
	return (total ? sum/total : 0)
 }
 function likely(h,n,  l,klass) {
	likelihoods(h,n,l)
	return l[opt("A")]
 }
 ##################################
 # worker
  function likelihoods(h,n,l,    k,class,i,inc,temp,prior,what,like) {
   like = -1 * opt("Inf");    # smaller than any log,
   k = klass()
   for(class in h) {
      prior = (h[class]+opt("K"))/(instances(h) + opt("K")*H);
      temp  = log(prior)
      for(i=1;i<=NF;i++) {
         if (i != k)
            if ( $i != opt("D") )
                temp += log((n[class,i,$i]+opt("M")*prior)/(h[class]+opt("M")))
      }
      l[class]= temp
      if ( temp >= like ) 
		if (class != opt("A")) {
			like = temp
			what=class
	  }
   }
   return what
 }
