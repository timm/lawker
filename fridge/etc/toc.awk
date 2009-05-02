BEGIN {FS=";"}

NF < 2 { next }
{   
	$NF=trim($NF);
	sub(/\|/,"",$NF)
	Raw=$NF
	Title=tolower($NF)
	if(Title) { Raws[Title]=Raw; Urls[Title]=trim($1);  Titles[Title]}
}
END {
	N=asorti(Titles)
	print "<h1><join>Table of Contents</join></h1>"
	print "<p><table>"
	for(I=1;I<=N;I++)
		Old=print1(Titles[I],tolower(substr(Titles[I],1,1)),Old)
	print "</table>"
}
function print1(title,letter,old,   pre) {
	pre=""
	if (letter != old) {
		pre =  letter 
		Mode = 1 - Mode
	}
	print "<tr class=row" Mode"><td>"toupper(pre)"</td><td><a href=\"http://awk.info/?" \
			Urls[title] "\">" Raws[title] "</a></td></td>"	
	return letter
}
function trim(s) {
	sub(/^[ \t]*/,"",s)
	sub(/[ \t\r]*$/,"",s)
	return s
}

