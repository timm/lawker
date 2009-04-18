#.H1 pschoose.awk
#.H2 Synopsis
#.P gawk -f pschoose
#.H2 Download
#.P Download from <a href="http://lawker.googlecode.com/svn/fridge/lib/awk/pschoose.awk">LAWKER</a>
#.H2 Description
#Pulls out a range of pages from postscript and just print those.
#.H2 Details
#.P 	<b>Pagerange</b> :	 list of pages from command line.
#.P <b>Pages</b> : 	array with broken out list.
#.P
# At end:
# 	"(n in Pages)" is true if page n should be printed
#.H2 Code
#.PRE
#Set up the list of paes to print.
function set_pagerange(        n, m, i, j, f, g)
{
	delete Pages

	n = split(Pagerange, f, ",")
	for (i = 1; i <= n; i++) {
		if (index(f[i], "-") != 0) { # a range
			m = split(f[i], g, "-")
			if (m != 2 || g[1] >= g[2]) {
				printf("bad list of pages: %s\n",
					f[i]) > "/dev/stderr"
				exit 1
			}
			for (j = g[1]; j <= g[2]; j++)
				Pages[j] = 1
		} else
			Pages[f[i]] = 1
	}
}

BEGIN {
	# constants
	TRUE = 1
	FALSE = 0

	if (ARGC != 3) {
		print "usage: pschoose range-spec file\n" > "/dev/stderr"
		exit 1
	}
	Pagerange = ARGV[1]
	delete ARGV[1]
	set_pagerange()
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
	# only save it if we will want to print it
	if (Npage in Pages)
		Page[Npage, ++line] = $0
}

END {
	# print the prologue
	for (i = 1; i in Prolog; i++)
		print Prolog[i]

	# print the actual body
	for (i = 1; i <= Npage; i++) {
		if (i in Pages) {
			for (j = 1; (i, j) in Page; j++) {
				print Page[i, j]
			}
		}
	}

	# print the epilog
	for (i = 1; i in Epilog; i++)
		print Epilog[i]
}
#./PRE
#.H2 Author
#.P Arnold Robbins
