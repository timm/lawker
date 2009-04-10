#.H1 m1 : A Micro Macro Processor 
#.H2 Synopsis
#.PRE
#awk -f m1.awk [file...]
#./PRE
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/m1.awk LAWKER.
#.H2 Description
#.P
# M1 is a  simple macro language that
# supports the essential operations of defining strings and replacing strings in text by
# their definitions. It also provides facilities for file inclusion and for conditional expan-
# sion of text. It is not designed for any particular application, so it is mildly useful
# across several applications, including document preparation and programming. This
# paper describes the evolution of the program; the final version is implemented in about
# 110 lines of Awk.
#.P
# M1 copies its input file(s) to its output unchanged except as modified by
# certain "macro expressions."  The following lines define macros for
# subsequent processing:
#.PRE
# @comment Any text
# @@                     same as @comment
# @define name value
# @default name value    set if name undefined
# @include filename
# @if varname            include subsequent text if varname != 0
# @unless varname        include subsequent text if varname == 0
# @fi                    terminate @if or @unless
# @ignore DELIM          ignore input until line that begins with DELIM
# @stderr stuff          send diagnostics to standard error
#./PRE
#.P
# A definition may extend across many lines by ending each line with
# a backslash, thus quoting the following newline.
#.P
# Any occurrence of @name@ in the input is replaced in the output by
# the corresponding value.
#.P
# @name at beginning of line is treated the same as @name@.
#.H3 Applications
#.H4 Form Letters
#.P
#We'll start with a toy example that illustrates some simple uses of m1. Here's a form letter that 
# I've often been tempted to use:
#.PRE 
#@default MYNAME Jon Bentley 
#@default TASK respond to your special offer 
#@default EXCUSE the dog ate my homework 
#Dear @NAME@: 
#    Although I would dearly love to @TASK@, 
#I am afraid that I am unable to do so because @EXCUSE@. 
#I am sure that you have been in this situation 
#many times yourself. 
#            Sincerely, 
#            @MYNAME@ 
#./PRE
#.P
# If that file is namedsayno.mac, it might be invoked with this text: 
#.PRE
#@define NAME Mr. Smith 
#@define TASK subscribe to your magazine 
#@define EXCUSE I suddenly forgot how to read 
#@include sayno.mac 
#./PRE
#.P
#Recall that a @default takes effect only if its variable was not previously @defined. 
#.H4 Troff Pre-Processing
#.P
#I've found m1 to be a handy Troff preprocessor. Many of my text files (including this one) start 
# with m1 definitions like: 
#.PRE
#@define ArrayFig @StructureSec@.2 
#@define HashTabFig @StructureSec@.3 
#@define TreeFig @StructureSec@.4 
#@define ProblemSize 100 
#./PRE
#.P
#Even a simple form of arithmetic would be useful in numeric sequences of definitions. The longer m1 
#variables get around Troff's dreadful two-character limit on string names; these variables are also avail- 
#able to Troff preprocessors like Pic and Eqn. Various forms of the @define, @if, and @include 
#facilities are present in some of the Troff-family languages (Pic and Troff) but not others (Tbl); m1
#provides a consistent mechanism. 
#.P
#I include figures in documents with lines like this: 
#.PRE
#@define FIGNUM @FIGMFMOVIE@ 
#@define FIGTITLE The Multiple Fragment heuristic. 
#@FIGSTART@ 
#.PS <@THISDIR@/mfmovie.pic 
#@FIGEND@ 
#./PRE
#.P
# The two @defines are a hack to supply the two parameters of number and title to the figure. The 
# figure might be set off by horizontal lines or enclosed in a box, the number and title might be printed at 
# the top or the bottom, and the figures might be graphs, pictures, or animations of algorithms. All 
# figures, though, are presented in the consistent format defined by FIGSTART and FIGEND. 
#.H4 Awk Library Management
#.P
# I have also used m1 as a preprocessor for Awk programs. The @include statement allows one 
# to build simple libraries of Awk functions (though some-  but not all- Awk implementations provide 
# this facility by allowing multiple program files). File inclusion was used in an earlier version of this 
# paper to include individual functions in the text and then wrap them all together into the completem1 
# program. The conditional statements allow one to customize a program with macros rather than run-time
# if statements, which can reduce both run time and compile time. 
#.H4 Controlling Experiments
#.P
# The most interesting application for which I've used this macro language is unfortunately too 
# complicated to describe in detail. The job for which I wrote the original version of m1 was to control a 
# set of experiments. The experiments were described in a language with a lexical structure that forced 
# me to make substitutions inside text strings; that was the original reason that substitutions are bracketed 
# by at-signs. The experiments are currently controlled by text files that contain descriptions in the experiment 
# language, data extraction programs written in Awk, and graphical displays of data written in Grap; 
# all the programs are tailored bym1commands.
#.P 
# Most experiments are driven by short files that set a few keys parameters and then@includea 
# large file with many @defaults. Separate files describe the fields of shared databases: 
#.PRE
# @define N ($1) 
# @define NODES ($2) 
# @define CPU ($3) 
# ... 
#./PRE
#.P
# These files are @included in both the experiment files and in Troff files that display data from the 
# databases. I had tried to conduct a similar set of experiments before I built m1, and got mired in muck. 
# The few hours I spent building the tool were paid back handsomely in the first days I used it. 

#.H3 The Substitution Function 
#.P
#M1 uses as fast substitution function.
# The idea is to process the string from left to right, searching for the first substitution to be made. 
# We then make the substitution, and rescan the string starting at the fresh text. We implement this idea 
# by keeping two strings: the text processed so far is in L (for Left), and unprocessed text is in
# R (for 
# Right). Here is the pseudocode for dosubs:
#.PRE
#L = Empty 
#R = Input String 
#while R contains an "@" sign do 
#	let R = A @ B; set L = L A and R = B 
#	if R contains no "@" then 
#		L = L "@" 
#		break 
#	let R = A @ B; set M = A and R = B 
#	if M is in SymTab then 
#		R = SymTab[M] R 
#	else 
#		L = L "@" M 
#		R = "@" R 
#	return L R 
#./PRE
#.H3 Possible Extensions
#.P
# There are many ways in which them1program could be extended. Here are some of the biggest 
# temptations to "creeping creaturism": 
#.UL
#.LI
# A long definition with a trail of backslashes might be more graciously expressed by a 
# @longdefinestatement terminated by a@longend. 
#.LI 
# An @undefinestatement would remove a definition from the symbol table. 
#.LI 
# I've been tempted to add parameters to macros, but so far I have gotten around the problem by 
# using an idiom described in the next section. 
#.LI
# It would be easy to add stack-based arithmetic and strings to the language by adding@pushand 
# @popcommands that read and write variables. 
#.LI
# As soon as you try to write interesting macros, you need to have mechanisms for quoting strings 
# (to postpone evaluation) and for forcing immediate evaluation. 
#./UL

#.H2 Code
#.P
# The following code is short (around 100 lines),
# which is 
# significantly shorter than other macro processors; see, 
# for instance, Chapter 8 of Kernighan and Plauger [1981]. 
# The program uses several techniques that can be applied in many Awk programs. 
#.UL
#.LI Symbol tables are easy to implement with Awk¿s associative arrays. 
#.LI 
# The program makes extensive use of Awk's string-handling facilities: 
# regular expressions, string 
# concatenation, gsub, index, andsubstr. 
#.LI
# Awk's file handling makes the dofile procedure straightforward. 
#.LI
# The readline function and pushback mechanism associated with buffer are of general utility. 
#./UL
#.H3 error
#.PRE
function error(s) {
	print "m1 error: " s | "cat 1>&2"; exit 1
}
#./PRE
#.H3 dofile
#.PRE
function dofile(fname,  savefile, savebuffer, newstring) {
	if (fname in activefiles)
		error("recursively reading file: " fname)
	activefiles[fname] = 1
	savefile = file; file = fname
	savebuffer = buffer; buffer = ""
	while (readline() != EOF) {
		if (index($0, "@") == 0) {
			print $0
		} else if (/^@define[ \t]/) {
			dodef()
		} else if (/^@default[ \t]/) {
			if (!($2 in symtab))
				dodef()
		} else if (/^@include[ \t]/) {
			if (NF != 2) error("bad include line")
			dofile(dosubs($2))
		} else if (/^@if[ \t]/) {
			if (NF != 2) error("bad if line")
			if (!($2 in symtab) || symtab[$2] == 0)
				gobble()
		} else if (/^@unless[ \t]/) {
			if (NF != 2) error("bad unless line")
			if (($2 in symtab) && symtab[$2] != 0)
				gobble()
		} else if (/^@fi([ \t]?|$)/) { # Could do error checking here
		} else if (/^@stderr[ \t]?/) {
			print substr($0, 9) | "cat 1>&2"
		} else if (/^@(comment|@)[ \t]?/) {
		} else if (/^@ignore[ \t]/) { # Dump input until $2
			delim = $2
			l = length(delim)
			while (readline() != EOF)
				if (substr($0, 1, l) == delim)
					break
		} else {
			newstring = dosubs($0)
			if ($0 == newstring || index(newstring, "@") == 0)
				print newstring
			else
				buffer = newstring "\n" buffer
		}
	}
	close(fname)
	delete activefiles[fname]
	file = savefile
	buffer = savebuffer
}
#./PRE
#.H3 readline
#.P
#Put next input line into global string "buffer".
#Return "EOF" or "" (null string).
#.PRE
function readline(  i, status) {
	status = ""
	if (buffer != "") {
		i = index(buffer, "\n")
		$0 = substr(buffer, 1, i-1)
		buffer = substr(buffer, i+1)
	} else {
		# Hume: special case for non v10: if (file == "/dev/stdin")
		if (getline <file <= 0)
			status = EOF
	}
	# Hack: allow @Mname at start of line w/o closing @
	if ($0 ~ /^@[A-Z][a-zA-Z0-9]*[ \t]*$/)
		sub(/[ \t]*$/, "@")
	return status
}
#./PRE
#.H3 gobble
#.PRE
function gobble(  ifdepth) {
	ifdepth = 1
	while (readline() != EOF) {
		if (/^@(if|unless)[ \t]/)
			ifdepth++
		if (/^@fi[ \t]?/ && --ifdepth <= 0)
			break
	}
}
#./PRE
#.H3 dosubs
#.PRE
function dosubs(s,  l, r, i, m) {
	if (index(s, "@") == 0)
		return s
	l = ""	# Left of current pos; ready for output
	r = s	# Right of current; unexamined at this time
	while ((i = index(r, "@")) != 0) {
		l = l substr(r, 1, i-1)
		r = substr(r, i+1)	# Currently scanning @
		i = index(r, "@")
		if (i == 0) {
			l = l "@"
			break
		}
		m = substr(r, 1, i-1)
		r = substr(r, i+1)
		if (m in symtab) {
			r = symtab[m] r
		} else {
			l = l "@" m
			r = "@" r
		}
	}
	return l r
}
#./PRE
#.H3 docodef
#.PRE
function dodef(fname,  str, x) {
	name = $2
	sub(/^[ \t]*[^ \t]+[ \t]+[^ \t]+[ \t]*/, "")  # OLD BUG: last * was +
	str = $0
	while (str ~ /\\$/) {
		if (readline() == EOF)
			error("EOF inside definition")
		# OLD BUG: sub(/\\$/, "\n" $0, str)
		x = $0
		sub(/^[ \t]+/, "", x)
		str = substr(str, 1, length(str)-1) "\n" x
	}
	symtab[name] = str
}
#./PRE
#.H3 BEGIN
#.PRE
BEGIN {	
    EOF = "EOF"
	if (ARGC == 1)
		dofile("/dev/stdin")
	else if (ARGC >= 2) {
		for (i = 1; i < ARGC; i++)
			dofile(ARGV[i])
	} else
		error("usage: m1 [fname...]")
}
#./PRE
#.H2 Bugs
#.P
# M1 is three steps lower than m4.  You'll probably miss something
# you have learned to expect.
#.H2 History
#.P
#M1 was documented in the 1997 sedawk book by Dale Dougherty & Arnold Robbins (ISBN 1-56592-225-5)
#but may have been written earlier.
#.P
#This page was adapted from 
#131.191.66.141:8181/UNIX_BS/sedawk/examples/ch13/m1.pdf (download from
#<a href="http://lawker.googlecode.com/svn/fridge/share/pdf/m1.pdf">LAWKER</a>).
#.H2 Author
#.P 
#Jon L. Bentley.
