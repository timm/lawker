BEGIN { IGNORECASE=1 }
      { xpand()    }
        
function xpand(pre) {
    if      ($1 ~ "^#.IN")    xpands($2,pre)
    else if ($1 ~ "^#.BODY" )  xpandsBody($2,pre)
    else if ($1 ~ "^#.CODE")  {
	print "<p>" $2 "\n<" "pre>"
	xpands($2,1)
	print "</" "pre>" } 
    else if ($1 ~ "^#.TO") 
	print "< href=\""$2"\">" $3 "</a>"
    else 
	xpand1(pre)
}
function xpand1(pre) {
    pre ? gsub(/</,"\\&lt;") : sub(/^#/,"")
    print $0 
}
function xpands(f,pre) {
    if (++Seen[f]==1) { # loop detection
	while((getline <f) > 0) xpand(pre)
	close(f) }
}
function xpandsBody(f,pre, using) {
    if (++Seen[f]==1) { 
	while((getline <f) >0) {
	    if ( !using && ($0 ~ /^[\t ]*$/) ) using = 1
	    if ( using ) xpand(pre)}
	close(f) }
}
function xpandHtml(    str,tag) {
    if ($0 ~ /^#\.H1/) {         
	$1=""; print "<" "h1><join>" $0 "</join></" "h1>" }
    else if (sub(/^#\./,"",$1)) {
	tag=$1;  $1=""
	print "<" tag ">"  (($0 ~ /^[ \t]*$/) ? "" : $0"</"tag">")
    } else 
	print $0
} 