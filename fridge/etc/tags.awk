BEGIN {
	FS=";"
	print "\n\n\n\n\n\n\n <files>"
}
NF < 2 {next}
{print "\t<file where=\""trim($1)"\">"
 for(i=2;i<=NF;i++)
	if ($i) 
		if (sub(/^[ \t]*\|/,"",$i) )
			print "\t\t<title>"trim($i)"</title>"
		else
			print "\t\t<what>"trim($i)"</what>"
  print "\t</file>"
}
function trim(s) {
	sub(/^[ \t]*/,"",s)
	sub(/[ \t]*$/,"",s)
	return s
}
END {
	print "  </files>"
	print "</things>"
	}
