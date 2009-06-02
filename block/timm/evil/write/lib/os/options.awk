#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   the Evil options processor
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs
#
#----------------------------------------
#begin world's simplest options parser. 
#Upper case flags have parameters
#
#After grabbing all the command-line flags, 
#ARGV/ARGC is set to the remaining command-line vars
#
#IMPORTANT: this code assumes that, elsewhere, there is a
#function "usage" that prints help text.
#
#uses copyleft.awk
#uses bad.awk
#uses s2a.awk
#uses prints.awk
#uses saya.awk

 function opt(x) {
	return (x in Opt) ? Opt[x] : bad(Opt["What"] " option ["x"] unknown")
 }
 function ok2go(opt,str) { # returns 0 if bad options
	s2a("a=;c=;h=;" str,opt,"[=;]")
	ARGC = options(opt,ARGV,ARGC)
	if (opt("c")) { copyleft(); exit }
	if (opt("a")) { about();    exit }
	if (opt("h")) { return 0;        }
	return 1
 }
 function options(opt,input,n,  key,i,j,k,tmp) {
	# first: explore the arguments till no more flags
    for(i=1;i<=n;i++)  {
		key = input[i]
		if (sub(/^[-]+/,"",key))  { # we have a new flag
			if (key in opt)      # if flag is legal, change its value
				# if flag begins with upper case, 
                # then take value from command line 
				opt[key] = (key ~ /^[A-Z]/) ? input[++i] : 1
			else bad("-"key" unknown. Try -h for help.")
		} else { i--; break }
	}
	# second: clear the flags from n, input 
	for(j=i+1;j<=n;j++) 
		tmp[j-i]=input[j]
	split("",input,"")
	for(k in tmp) 
		input[k] = tmp[k]
	n -= i
	return n
 }
