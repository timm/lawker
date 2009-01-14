function flags(s,a,  i,j,tmp) {
    split(s,tmp,",")
    for(i in tmp) {
	j=tmp[i];
	gsub(/[#]/,"",j)
	a[tmp[i]]=j }
}
BEGIN      { flags("#WHAT,#WHY,#WHO,#HOW,#LICENSE",Flag) 
             print "<DOC>"            }
END        { for(I=1;I<=N;I++) note(I,Notes) 
             for(I=1;I<=F;I++) fun(I,Functions[I],Functions)
             print "</DOC>" }
/#WHAT/    { What=trim($2); print "\t<FILE>"FILENAME"</FILE>" }
$1 in Flag { Tag=Flag[$1] 
             $1=""
             print "\t<" Tag ">"trim($0)"</" Tag ">" 
}
/^#NOTES/                  { N++ }
/^#NOTES/,/^[ \t]*$/       { Notes[N,++Notes[N,0]]=$0 }
/^#FUNCTION/               { Functions[++F]= $2}
/^#FUNCTION/,/^[^#]/       { Functions[F,++Functions[F,0]]=$0 }
/#=/                       { argument(H,$0) }

function note(i,notes,  max,j) {
    print "\t<NOTE>\n\t\t<FOR>"What"</FOR>\n\t\t<TEXT><![CDATA["
    max = notes[i,0] - 1
    for(j=2;j<=max;j++) {
	line = notes[i,j]
	sub(/^#/,"",line)
	print line
    }
    print "\t\t]]></TEXT>\n\t</NOTE>"
}
function fun(i,name,a,   max,j,line,text,type,parts, sep) {
    print "\t<FUNCTION>\n\t\t<NAME>"name"</NAME>"    
    max=a[i,0] - 1
    sep=""
    for(j=2;j<=max;j++) {
	line = a[i,j]
	sub(/^#/,"",line)
	if (sub(/^RETURNS/,"",line)) {
	    returnText=trim(line)
	} else { text = text sep line; sep="\n"}
    }
     if (returnText) {
	split(returnText,parts,"#")
	type=parts[1]
	about=parts[2]
	print "\t\t<RETURNS>"
	print "\t\t\t<TYPE>"trim(type)"</TYPE>"
	print "\t\t\t<ABOUT>"trim(about)"</ABOUT>"
	print "\t\t</RETURNS>"	
    }
     print "\t\t<TEXT><![CDATA[\n" text "\n\t\t]]></TEXT>"
     print "\t</FUNCTION>"
}
function argument(f,line,opt,onetwo,arg,type,comment) {    
    opt="f"
    split(line,onetwo,/#=/)
    arg=onetwo[1]
    sub(/^.*[(]/,"",arg)
    gsub(/[, \t]/,"",arg)
    split(onetwo[2],parts,"#")
    type=parts[1]
    about=parts[2]
    if (gsub(/[\[\]]/,"",type))
	opt="t";
    print "\t<ARG>"
    print "\t\t<FOR>"Functions[F]"<FOR>"
    print "\t\t<NAME>"arg"</NAME>"
    print "\t\t<TYPE>"trim(type)"</TYPE>"
    print "\t\t<ABOUT>"trim(about)"</ABOUT>"
    print "\t\t<OPTIONAL>"opt"</OPTIONAL>"
    print "\t</ARG>"
}
function trim(s,  t) {
    t = s
    sub(/^[ \t]+/,"",t)
    sub(/[ \t]+$/,"",t)
    return t
}