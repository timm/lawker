#.H1 getXML.awk
#.H2 Synopsis
#.P
# gawk -f getXML.awk <xml-file>
#.H2 Download
#.P Download from <a href="http://lawker.googlecode.com/svn/fridge/lib/awk/getxml.awk">LAWKER</a>
#.H2 Example 
#.PRE
#BEGIN {
#    while ( getXML(ARGV[1],1) ) {
#        print XTYPE, XITEM;
#        for (attrName in XATTR)
#            print "\t" attrName "=" XATTR[attrName];
#    }
#    if (XERROR) {
#        print XERROR;
#        exit 1;
#    }
#}
#./PRE
#.H2 Details
#.P
# Main function, read snext xml-data into XTYPE,XITEM,XATTR
#.PRE
#getXML( file, skipData ): 
#./PRE
#.DL
#.DT   file
#.DD path to xml file
#.DT   skipData 
#.DD flag: do not read "DAT" (data between tags) sections
#./DL
#.H3 External variables:
#.DL
#.DT   XTYPE  
#.DD type of item read, e.g. "TAG"(tag), "END"(end tag), "COM"(comment), "DAT"(data)
#.DT   XITEM  
#.DD value of item, e.g. tagname if type is "TAG" or "END"
#.DT   XATTR  
#.DD Map of attributes, only set if XTYPE=="TAG"
#.DT  XPATH   
#.DD Path to current tag, e.g. /TopLevelTag/SubTag1/SubTag2
#.DT  XLINE   
#.DD current line number in input file
#.DT  XNODE   
#.DD XTYPE, XITEM, XATTR combined into a single string
#.DT  XERROR  
#.DD error text, set on parse error
#./DL
#.H3 Returns
#.DL
#.DT
#    1         
#.DD on successful read: XTYPE, XITEM, XATTR are set accordingly
#.DT    ""        
#.DD at end of file or parse error, XERROR is set on error
#./DL
#.H3 Private Data
#.DL
#.DT  _XMLIO
#.DD buffer, XLINE, XPATH for open files
#./DL
#.H2 Code
#<font size="-3">
#.PRE
function getXML( file, skipData           \
				,end,p,q,tag,att,accu,mline,mode,S0,ex,dtd) {
    XTYPE=XITEM=XERROR=XNODE=""; split("",XATTR);
    S0=_XMLIO[file,"S0"]; XLINE=_XMLIO[file,"line"]; 
	XPATH=_XMLIO[file,"path"]; dtd=_XMLIO[file,"dtd"];
    while (!XTYPE) {
        if (S0=="") { if (1!=(getline S0 <file)) break; XLINE++; S0=S0 RS; }
        if ( mode == "" ) {
            mline=XLINE; accu=""; p=substr(S0,1,1);
            if ( p!="<" && !(dtd && p=="]") )         
				mode="DAT";
            else if ( p=="]" ) 
				{ S0=substr(S0,2);  mode="DTE"; end=">"; dtd=0; }
            else if ( substr(S0,1,4)=="<!--" ) 
				{ S0=substr(S0,5);  mode="COM"; end="-->"; }
            else if ( substr(S0,1,9)=="<!DOCTYPE" ) 
                { S0=substr(S0,10); mode="DTB"; end=">"; }
            else if ( substr(S0,1,9)=="<![CDATA[" ) 
                { S0=substr(S0,10); mode="CDA"; end="]]>"; }
            else if ( substr(S0,1,2)=="<!" ) 
				{ S0=substr(S0,3);  mode="DEC"; end=">"; }
            else if ( substr(S0,1,2)=="<?" ) 
				{ S0=substr(S0,3);  mode="PIN"; end="?>"; }
            else if ( substr(S0,1,2)=="</" ) 
				{ S0=substr(S0,3);  mode="END"; end=">";
                tag=S0;sub(/[ \n\r\t>].*$/,"",tag);
				S0=substr(S0,length(tag)+1);
                ex=XPATH;sub(/\/[^\/]*$/,"",XPATH);
				ex=substr(ex,length(XPATH)+2);
                if (tag!=ex) { 
                   	XERROR="unexpected close tag <" ex ">..</" tag ">"; 
					break; } }
            else{                                     
				S0=substr(S0,2);  mode="TAG";
                tag=S0;sub(/[ \n\r\t\/>].*$/,"",tag);
				S0=substr(S0,length(tag)+1);
                if ( tag !~ /^[A-Za-z:_][0-9A-Za-z:_.-]*$/ ) { 
                    XERROR="invalid tag name '" tag "'"; break; }
                XPATH = XPATH "/" tag; } }
        else if ( mode == "DAT" ) {                            
            p=index(S0,"<"); 
			if ( dtd && (q=index(S0,"]")) && (!p || q<p) ) p=q;
            if (p) {
                if (!skipData) { XTYPE="DAT"; 
                       XITEM=accu unescapeXML(substr(S0,1,p-1)); }
                S0=substr(S0,p); mode=""; }
            else{ if (!skipData) accu=accu unescapeXML(S0); S0=""; } }
        else if ( mode == "TAG" ) {   
			sub(/^[ \n\r\t]*/,"",S0); if (S0=="") continue;
            if ( substr(S0,1,2)=="/>" ) {
                S0=substr(S0,3); mode=""; XTYPE="TAG"; 
				XITEM=tag; S0="</"tag">"S0; }
            else if ( substr(S0,1,1)==">" ) {
                S0=substr(S0,2); mode=""; XTYPE="TAG"; XITEM=tag; }
            else{
                att=S0; sub(/[= \n\r\t\/>].*$/,"",att); 
				S0=substr(S0,length(att)+1); mode="ATTR";
                if ( att !~ /^[A-Za-z:_][0-9A-Za-z:_.-]*$/ ) { 
                    XERROR="invalid attribute name '" att "'"; 
					break; } } }
        else if ( mode == "ATTR" ) {  
				sub(/^[ \n\r\t]*/,"",S0); if (S0=="") continue;
            if ( substr(S0,1,1)=="=" ) { S0=substr(S0,2); mode="EQ"; }
            else                       { XATTR[att]=att; mode="TAG"; 
                                         XNODE=XNODE att"="att"\001"; } }
        else if ( mode == "EQ" ) {    
					sub(/^[ \n\r\t]*/,"",S0); if (S0=="") continue;
            end=substr(S0,1,1);
            if ( end=="\"" || end=="'" ) {
					S0=substr(S0,2);accu="";mode="VALUE";}
            else{
                accu=S0; sub(/[ \n\r\t\/>].*$/,"",accu); 
				S0=substr(S0,length(accu)+1);
                XATTR[att]=unescapeXML(accu); mode="TAG"; 
				XNODE=XNODE att"="XATTR[att]"\001"; } }
        else if ( mode == "VALUE" ) { # terminated by end
            if ( p=index(S0,end) ) {
                XATTR[att]=accu unescapeXML(substr(S0,1,p-1)); 
				XNODE=XNODE att"="XATTR[att]"\001";
                S0=substr(S0,p+length(end)); mode="TAG"; }
            else{ accu=accu unescapeXML(S0); S0=""; } }
        else if ( mode == "DTB" ) { # terminated by "[" or ">"
            if ( (q=index(S0,"[")) && (!(p=index(S0,end)) || q<p ) ) {
                XTYPE=mode; XITEM= accu substr(S0,1,q-1); 
				S0=substr(S0,q+1); mode=""; dtd=1; }
            else if ( p=index(S0,end) ) {
                XTYPE=mode; XITEM= accu substr(S0,1,p-1); 
				S0="]"substr(S0,p); mode=""; dtd=1; }
            else{ accu=accu S0; S0=""; } }
        else if ( p=index(S0,end) ) {  # terminated by end
            XTYPE=mode; XITEM= ( mode=="END" ? tag : accu substr(S0,1,p-1) );
            S0=substr(S0,p+length(end)); mode=""; }
        else{ accu=accu S0; S0=""; } }
    _XMLIO[file,"S0"]=S0; _XMLIO[file,"line"]=XLINE; 
	_XMLIO[file,"path"]=XPATH; _XMLIO[file,"dtd"]=dtd;
    if (mode=="DAT") { mode=""; if (accu!="") XTYPE="DAT"; XITEM=accu; }
    if (XTYPE) { XNODE=XTYPE"\001"XITEM"\001"XNODE; return 1; }
    close(file);
    delete _XMLIO[file,"S0"]; delete _XMLIO[file,"line"]; 
	delete _XMLIO[file,"path"]; delete _XMLIO[file,"dtd"];
    if (XERROR) XERROR=file ":" XLINE ": " XERROR;
    else if (mode) XERROR=file ":" mline ": " "unterminated " mode;
    else if (XPATH) XERROR=file ":" XLINE ": "  "unclosed tag(s) " XPATH;
} 
#./PRE
#./FONT
#.P
# Unescape data and attribute values, used by getXML.
#.PRE
function unescapeXML( text ) {
    gsub( "&apos;", "'",  text );
    gsub( "&quot;", "\"", text );
    gsub( "&gt;",   ">",  text );
    gsub( "&lt;",   "<",  text );
    gsub( "&amp;",  "\\&",  text );
    return text
}
#./PRE
#.P
#Close xml file
#.PRE
function closeXML( file ) {
    close(file);
    delete _XMLIO[file,"S0"]; delete _XMLIO[file,"line"]; 
    delete _XMLIO[file,"path"]; delete _XMLIO[file,"dtd"];
    delete _XMLIO[file,"open"]; delete _XMLIO[file,"IND"];
}
#./PRE
#.H2 Author
#.P Jan Weber 
