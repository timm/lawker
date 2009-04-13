BEGIN { IGNORECASE=1 }
      { xpand()      }

function xpand() {
   if      ($1 ~ "^.IN")    xpands($2) 
   else if ($1 ~ "^.BODY" ) xpandsBody($2)
   else if ($1 ~ "^.LIST")  {
  	    print "<PRE>"
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
function xpandsBody(f, using) {
    if (newFile(f)) { 
	  while((getline <f) >0) {
	    if ( !using && ($0 ~ /^[\t ]*$/) ) 
			using = 1
	    if ( using ) 
			xpand()}
	  close(f) }
}
function newFile(f) { return ++Seen[f]==1 }
