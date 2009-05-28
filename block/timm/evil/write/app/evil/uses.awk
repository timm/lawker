#    ___         
#  _/ oo\      An evil idea:
# ( \  -/__    the Evil nested file accessor 
#  \    \__)  
#  /     \     (c) 2009 by Tim Menzies, GPL 3.0
# /      _\    http://www.gnu.org/licenses/gpl.txt
# `"""""`` jgs

# -R     = root directory (where to look for files)
# -p     = print contents
# -s     = skip para one
# -i     = explore contents of included print files 
# -u     = explore contents of included used files
# -f     = print file name

 BEGIN	{ str2opt("R,.,p,,i,,u,,f,,s,1",Opt) 
		  saya("opt",Opt)
        }
        { xpand(Opt["s"])  }
 END    { if (Opt["f"]) print FILENAME }

 function xpand(skippingPara1, skipped,i) {
	print "0 " $0
	if (Opt["i"] && ($1 ~ "^#SHOW"))  {
		print 1; xpands($2) 
	    }
	else if (Opt["i"] && ($1 ~ "^#show"))  {
		print 2; xpands($2,Opt["s"])
	    }
	else if (Opt["i"] && ($1 ~ "^#list"))  {
		print "<PRE>"
		print 3; xpands($2)
		print "</PRE>"                 
        }
	else if (Opt["u"] && ($1 ~ "^#use"))  {
		print 4;
		for(i=2;i<=NF;i++) {
			print 4.1 " " $i
			xpands($i)  
	    }}
	else if (Opt["p"])  {
          print 5
	 	  if  (skippingPara1) {
				if (skipped) print $0
		       } 
          else print $0 
		 } 
 }
 function xpands(f,skippingPara1,  skipped, missing) {
	gsub(/"/,"",f)
	print ">> " f " | " $1
	if (newFile(f,Seen)) {
		f = Opt["R"] "/" f
		Stack[++Stack[0]]= f
	    saya("stack",Stack)
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
	    else  {
			if (Opt["f"]) 
				print f
	    }
		Stack[0]--
	}
 }
 # standard one-liners
 function newFile(f,seen) { return (++seen[f])==1 }
 function saya(str,a,  i) { for(i in a) print str "[" i "]="  a[i]}
 function barph(s)        { warn(s); exit }
 
 #begin world's simplest command-line parser. 
 #Upper case flags have parameters
 function warn(s) { 
	print s >"/dev/stderr" 
 } 
 function str2opt(str,opt,  key,i,j,k,tmp) {
	s2a(str,opt)
    for(i=1;i<=ARGC;i++)  {
		key = ARGV[i]
		if (sub(/^-/,"",key))  {
			if (key in opt) 
				opt[key] = (key ~ /^[A-Z]/) ? ARGV[++i] : 1
			else warn("? unknown key ["key"]")
		} else { i--; break }
	}
	for(j=i+1;j<=ARGC;j++) tmp[j-i]=ARGV[j]
	split("",ARGV,"")
	for(k in tmp) ARGV[k] = tmp[k]
	ARGC -= i
 }
 function s2a(str,a, tmp,i,n) {
	n=split(str,tmp,/,/)
	for(i=1;i<=n;i += 2) a[tmp[i]]=tmp[i+1]
	return n
 }
