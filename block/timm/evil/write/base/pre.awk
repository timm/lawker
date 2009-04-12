#
#<p>
#With more stuff

 /^[ \t]+[^ \t]/ { printf (In ? ""       :"<PRE>") ; In=1}
 /^$/            { printf (In ? "</PRE>" : "")     ; In=0}
 In              { gsub("<","\\&lt;",$0) }
				 { gsub(/[ \t]*$/,"")
                   print }
 END             { if (In) print "</PRE>" }

#There there this stuff
