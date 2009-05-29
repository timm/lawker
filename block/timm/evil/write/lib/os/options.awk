#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   the Evil command line processor
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs

#begin world's simplest command-line parser. 
#Upper case flags have parameters
#After grabbing all the command-line flags, 
#ARGV/ARGC is set to the remaining command-line vars

 function opt(x) {
	return (x in Opt) ? Opt[x] : warn("option ["x"] unknown")
 }

 function options(str,opt,  key,i,j,k,n,tmp1,tmp2) {
	# first: split "str" to initialize "opt"
	n=split(str,tmp1,/,/)
	for(i=1;i<=n;i += 2) 
		opt[tmp1[i]]=tmp1[i+1]
	# second: explore the arguments till no more flags
    for(i=1;i<=ARGC;i++)  {
		key = ARGV[i]
		if (sub(/^-/,"",key))  { # we have a new flag
			if (key in opt)      # if flag is legal, change its value
				# if flag begins with upper case, 
                # then take value from command line 
				opt[key] = (key ~ /^[A-Z]/) ? ARGV[++i] : 1
			else print "? unknown key ["key"]" >"/dev/stderr"
		} else { i--; break }
	}
	# third: clear the flags from ARGC, ARGV 
	for(j=i+1;j<=ARGC;j++) 
		tmp2[j-i]=ARGV[j]
	split("",ARGV,"")
	for(k in tmp2) 
		ARGV[k] = tmp2[k]
	ARGC -= i
	return ARGC
 }
