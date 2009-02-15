BEGIN {
	FS="\t"
	print "\n\n\n\n\n\n\n <files>"
}
NF < 2 {next}
{print "\t<file where=\""$1"\">"
 for(i=2;i<=NF;i++)
	if ($i) 
		if (sub(/^[ \t]*\|/,"",$i) )
			print "\t\t<title>"$i"</title>"
		else
			print "\t\t<what>"$i"</what>"
  print "\t</file>"
}
END {
	print "  </files>"
	print "</things>"
	}
