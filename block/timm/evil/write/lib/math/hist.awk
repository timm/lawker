#use chars.awk

 function histogram(a,title,\
                   bin,width1,width2,width3,fs,char,nosort,\
				   n,i,h,fmt,mini,maxi,max,mult,one) {
	bin    = bin    ? bin  : 1
	width1 = width1 ? width1 : 10
	width2 = width2 ? width2 : 10
	width3 = width3 ? width3 : 40
	fs     = fs     ? fs     : "|"
	char   = char   ? char   : "*"
	fmt    = "%" width1 "s " fs " %" width2 "s " fs " %s\n"
	print title
	if  (nosort) 
		for(i in a) n++
	else n=asort(a)	
	max = maxi = -1000000000000
	mini = -1*maxi
	for(i = 1;i<=n;i++)  {
		one =   bin * int(a[i]/bin)
		if (one > maxi) maxi = one
		if (one < mini) mini = one
		h[one]++
		if (h[one]> max) max = h[one]	
	}
	mult = (max > width3) ? width3/max : 1
	print chars(width1+width2+width3+3,"-")
	printf(fmt,"bin","freq","")
	print chars(width1+width2+width3+3,"-")
	for(i = mini; i <= maxi; i += bin) 
		if (i in h) 
			printf(fmt,i*bin,h[i],chars(h[i]*mult,char))
		else 
			printf(fmt,i*bin,0,"")
 }
 function histogramTest(  n,a,i) {
	n=1000
	while(n--) a[++i]=rand() ^ 3
	histogram(a,"random numbers",0.1)
 } 
