BEGIN { FS=";" ; Xpand=20}
NF < 2 {next}
{ for(i=(NF-1);i>=2;i--) {
	$i=trim($i)
	if ($i == "") continue
	if ($i == "2008") continue
	if ($i == "2009") continue
	if ($i == "2010") continue
	if ($i == "2011") continue
	if ($i == "2012") continue
	if ($i == "Jan") continue
	if ($i == "Feb") continue
	if ($i == "Mar") continue
	if ($i == "Apr") continue
	if ($i == "May") continue
	if ($i == "Jun") continue
	if ($i == "Jul") continue
	if ($i == "Aug") continue
	if ($i == "Sep") continue
	if ($i == "Oct") continue
	if ($i == "Nov") continue
	if ($i == "Dec") continue
	if (sub(/\|/,"",$i) ) continue
	N++
	what[$i]++
	}
}
function trim(s) {
	sub(/^[ \t]*/,"",s)
	sub(/[ \t\r]*$/,"",s)
	return s
}
END {
	for(i in what)
		print "<tr><td align=right> " what[i] " </td><td><a href=\"http://awk.info/?" i "\">" i " </a></td><td>" \
			  "<img src=\"http://menzies.us/csx72/img/gray.gif\"" \
              " height=\"10px\" width=\"" Xpand*what[i]*100/N "\"></a></td></tr>"
}
