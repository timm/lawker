#    ___         
#  _/ oo\     An evil software spirit offers
# ( \  -/__   the Evil code xpander, (c) 2009 
#  \    \__)  by Tim Menzies, GPL 3.0
#  /     \
# /      _\
# `"""""``  jgs

 BEGIN  { xpand()  }

 function xpand() {
	if      ($1 ~ "^.SHOW")  xpands($2) 
	else if ($1 ~ "^.show" ) skipPara1ThenXpand($2)
	else if ($1 ~ "^.list")  {
  	    print "<pre>"
	    xpands($2)
	    print "</pre>" } 
	else print $0
 }
 function xpands(f) {
	if (newFile(f)) {
	    while((getline <f) > 0) 
			xpand()
		close(f) }
 }
 function skipPara1ThenXpand(f, using) {
	if (newFile(f)) { 
	    while((getline <f) >0) {
	      if ( !using && ($0 ~ /^[\t ]*$/) ) 
		     	using = 1
	      if ( using ) 
		 	   xpand()}
	    close(f) }
 }
 function newFile(f) { return ++Seen[f]==1 }
