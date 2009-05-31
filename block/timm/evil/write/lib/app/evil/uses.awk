#    ___         
#  _/ oo\      An evil idea:
# ( \  -/__    the Evil nested file expander 
#  \    \__)  
#  /     \     (c) 2009 by Tim Menzies, GPL 3.0
# /      _\    http://www.gnu.org/licenses/gpl.txt
# `"""""`` jgs
#
#use X   : recurses into X
#SHOW X  : recuses into X, showing the contents
#show X  : recuses into X, showing the contents, except para1
#list X  : includes file X, wrapped in "pre"
#
# -R     = root directory (where to look for files)
# -p     = print contents
# -s     = skip para one
# -i     = explore contents of included print files 
# -u     = explore contents of included used files
# -f     = print file name

 BEGIN	{ options("R,.,p,,i,,u,,f,,S,1",Opt) }
        { xpand(opt("S"))  }
 END    { if (opt("f")) print FILENAME }

 function xpand(skippingPara1, skipped,i) {
	if (opt("i") && ($1 ~ "^#SHOW"))  
		xpands($2) 
	else if (opt("i") && ($1 ~ "^#show"))  
		xpands($2,opt("S"))
	else if (opt("i") && ($1 ~ "^#list"))  {
		print "<PRE>"
		xpands($2)
		print "</PRE>"                 
      }
	else if (opt("u") && ($1 ~ "^#use"))  
		xpands($2)
	else if (opt("p"))  {
	 	  if  (skippingPara1) {
				if (skipped) print $0
		  } else print $0 
	   } 
 }
 function xpands(f,skippingPara1,  skipped, missing) {
	gsub(/"/,"",f)
	if (newFile(f,Seen)) {
		f = opt("R") "/" f
		Stack[++Stack[0]]= f
		missing = 1 
	    while((getline <f) > 0) {
			missing = 0 
			if (!skipped && ($0 ~ /^[\t ]*$/))
				skipped = 1
			xpand(skippingPara1,skipped) 
		}
		close(f) 
		if (missing)
			warn("?? [" Stack[Stack[0]-1] \
                  "] references missing file [" f \
                  "].")
	    else  { if (opt("f")) print f }
		Stack[0]--
	}
 }
 # standard one-liners
 function opt(x) {
	return (x in Opt) ? Opt[x] : warn("option ["x"] unknown")
 }
 function newFile(f,seen) { return (++seen[f])==1 }
 function saya(str,a,  i) { for(i in a) print str "[" i "]="  a[i]}
 function barph(s)        { warn(s); exit }
 function warn(s)         { print s >"/dev/stderr"; return 0 } 
 function s2a(str,a, tmp,i,n) {
	n=split(str,tmp,/,/)
	for(i=1;i<=n;i += 2) a[tmp[i]]=tmp[i+1]
	return n
 } 
 #begin world's simplest command-line parser. 
 #Upper case flags have parameters
 #After grabbing all the command-line flags, 
 #ARGV/ARGC is set to the remaining command-line vars
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
