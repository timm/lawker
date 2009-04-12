 BEGIN              { IGNORECASE = 1 }
 /^<[h]1>/          { Header=$0; next}
 /^[<]h[23456789]>/ { 
       T++ ;
      Toc[T]  = gensub(/(.*)<h(.*)>[ \t]*(.*)[ \t]*<\/h(.*)>(.*)/,
      "<""h\\2><""font color=black>\\&bull;</font></a> <""a href=#" T ">\\3</a></h\\4>",
                "g",$0)
		Pre="<a name="T"></a>" }
     { Line[++N] = Pre $0; Pre="" }
 END { print Header;
       print "<" "h2>Contents</h2>"
       print "<" "div id=\"htmltoc\">"
       for(I=1;I<=T;I++) print Toc[I]	
       print "<" "/div><!--- htmltoc --->"
       print "<" "div id=\"htmlbody\">"
       for(I=1;I<=N;I++) print Line[I]
       print "</" "div><!--- htmlbody --->"		
     }'

