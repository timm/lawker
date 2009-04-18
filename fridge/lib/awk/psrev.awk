#.H1 psrev.awk
#.H2 Synopsis
#.P gawk -f psrev.awk
#.H2 Download
#.P Download from <a href="http://lawker.googlecode.com/svn/fridge/lib/awk/psrev.awk">LAWKER</a>
#.H2 Description
#.P Reverse the pages in a postscript file.
#.H2 Code
#.PRE
BEGIN {
	# constants
	TRUE = 1
	FALSE = 0

	# Initialize global booleans
	Twoup = FALSE

	# process command line flags
	for (i = 1; i in ARGV && ARGV[i] ~ /^-/; i++) {
		if (ARGV[i] == "-2")
			Twoup = TRUE
		else
			printf("psrev: unrecognized option %s\n",
				ARGV[i]) > "/dev/stderr"
		delete ARGV[i]
	}
}

NR == 1, /^%%Page:/ {
	if (! /^%%Page/) {
		Prolog[++nprolog] = $0
		next
	}
}

/^%%Trailer/ || In_trailer {
	In_trailer = TRUE
	Epilog[++nepilog] = $0
	next
}

/^%%Page: /	{
	++Npage
	line = 0
}

# for all non-special lines
{
	Page[Npage, ++line] = $0
}

END {
	# print the prologue
	for (i = 1; i in Prolog; i++)
		print Prolog[i]

	# print the actual body
	if (Twoup) {
		hasodd = (Npage %2 == 1)
		if (hasodd) {
			# print last page
			for (j = 1; (Npage, j) in Page; j++)
				print Page[Npage, j]
			# make a fake last page for psnup
			printf "%%%%Page: %d %d\n", Npage+1, Npage+1
			printf "showpage\n"
#			print "%%BeginPageSetup"
#			print "BP"
#			print "%%EndPageSetup"
#			print "EP"
		}
		lastpage = (hasodd ? Npage - 1 : Npage)
		for (i = lastpage; i > 0; i -= 2) {
			for (k = i - 1; k <= i; k++)
				for (j = 1; (k, j) in Page; j++)
					print Page[k, j]
		}
	} else {
		# regular 1 up printing
		for (i = Npage; i > 0; i--)
			for (j = 1; (i, j) in Page; j++)
				print Page[i, j]
	}

	# print the epilog
	for (i = 1; i in Epilog; i++)
		print Epilog[i]
}
#./PRE
#.H2 Author
#.P Arnold Robbins
