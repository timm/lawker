#    ___         
#  _/ oo\      Evil deeds maketh 
# ( \  -/__    the Evil nested file accessor 
#  \    \__)  
#  /     \     (c) 2009 by Tim Menzies, GPL 3.0
# /      _\    http://www.gnu.org/licenses/gpl.txt
# `"""""`` jgs

 BEGIN	{ str2opt("R,.,p,0,i,0,u,0",Opt) }
	   	{ xpand()  }
 END 	{ if (Opt["f"]) print FILENAME }

 function xpand(skippingPara1, skipped) {
	if      (Opt["i"] && ($1 ~ "^.SHOW"))  xpands($2) 
	else if (Opt["i"] && ($1 ~ "^.show"))  xpands($2,1)
	else if (Opt["i"] && ($1 ~ "^.list"))  {
			print "<PRE>"
			xpands($2)
			print "</PRE>"
	} else if (Opt["u"] && ($1 ~ "^#use")) {
			gsub(/"/,"")
			for(I=2;I<=NF;I++)
				xpands($I)  
    } else if (Opt["p"]) 
		{   
            if  (skippingPara1) {
				if (skipped) print $0
			} else print $0 
		}
 }
 function xpands(f,skippingPara1,  skipped, missing) {
	if (newFile(f,Seen)) {
		f = Opt["R"] "/" f
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
			print "# ?? [" Stack[Stack[0]-1] \
                  "] references missing file [" f \
                  "]." >"/dev/stderr"
	    else 
			if (!Opt["p"])
				print f
		Stack[0]--
	}
 }
 function newFile(f,seen) { 
	return ++seen[f]==1 
 }
 function str2opt(str,opt,  key,i,j,k,tmp) {
	s2a(str,opt)
    for(i=1;i<=ARGC;i++)  {
		key = ARGV[i]
		if (sub(/^-/,"",key))  {
			if (key in opt) 
				opt[key] = (key ~ /^[A-Z]/) ? ARGV[++i] : 1
			else print "? unknown key ["key"]">"/dev/stderr"
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
 function saya(str,a,  i) {
	for(i in a)
		print str "[" i "]="   a[i] 
 }
