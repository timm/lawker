#!/sw/bin/gawk -f 

#.H1 Better Handler of Command-Line Options
#.H2 Synposis
#.PRE
#gawk -f lib.awk -f options.awk -f ok.awk -f hello.awk [-h][-c][-a][-P who] 
#./PRE
#.H2 Download
#.P 
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/optionsDemo.awk LAWKER.
#.H2 Description
#.P
#I've never been happy with standard methods for passing variables into Awk. Command lines like:
#.PRE
#gawk -f mycode.awk -v Seed=$RANDOM -v OutputDir=$HOME/tmp -v MaxErrors=2
#./PRE
#leave the code defenceless agains one-letter typos in the variable names.
#.P
#Similary, seperate config files like:
#.PRE
## file= myconfigrc.awk
#BEGIN {Seed=ENVIRON["RANDOM"]
#       OutputDir=ENVIRON["HOME"] "/tmp"
#       MaxErrors=2
#}
#./PRE
#allow for command lines like this:
#.PRE
#gawk -f mycode.awk -f configrc.awk
#./PRE
#but if another script wants to call <tt>mycode</tt> many different
#ways then the other script has to do sone, possible tedious, mucking around with temporary
#files. Also, the <em>myconfigrc.awk</em> option is actually as bad, or worse, than
#the commmand-line approach:
#.UL
#.LI
# As before, it leaves the code defenceless against one-letter
#typos. 
#.LI
#Further, it offers less functionality that the command-line option. For example,
#the within Awk access to <em>RANDOM</em> seen at top of <em>myconfigrc</em> returns
#an empty string, and not a system-generated random value.
#./UL
#.P
#I've often been tempted by the brevity of the "within-string" option:
#.PRE
#gawk -f mycode.awk --source '
#      BEGIN {Seed='$RANDOM'; OutputDir='$HOME/tmp'; MaxErrors='2';}'
#./PRE
#but this approach is a little too arcane for most folks, which makes it error
#prone to modify.
#.P
#Because of the above, I am a frequent user of Arnold Robbin's excellent
#"getopt" code that
#allows command lines like
#.PRE
#gawk -f mycode.awk -s $RANDOM -o $HOME/tmp -e 2
#./PRE
#but even this code has drawbacks:
#.UL
#.LI It does not allow for "long names" such as "--help";
#.LI 
#It introduces five global variables into Awk. Lately I've been building lots
#of library code in Awk and I have become obsessive about <em>not</em> polluting
#the global name space with new variables. 
#.LI Arnold's code does not satisfy "DRY"; i.e. don't repeat yourself.
#./UL 
#.P
#Also, Arnold's "getopt" is  perhaps too complex. 
#For example, in the following, I show 13 lines of code
#that replaces the 80 lines of "getopt", 
#handles the common usages of Arnold's function,
#uses no global variables, and supports long names.
#./UL
#.P
#(Embarressed cough: I do actually use one global variable in the following. Lately
#I've come to view globals 
#like chemotherapy- not desirable, but sometimes necessary.)
#.H3 Define Switches and Defaults
#.P
#The code assumes that switches beginning with upper case letters 
#take arguments, while lower case switches are booleans.
#For example, the following string could be used to define
#four switches, the first of which takes an argument (and has the default
#value "world". 
#.PRE
#"P = world; h = ; c = ; a = "
#./PRE
#The other switches are standard for many applciations:
#.DL
#.DT -c
#.DD Print a (long) GNU GPL v3 copyright notice;
#.DT -a
#.DD Print a (short, 2 line) "about" string;
#.DT -h
#.DD Print some help regarding the proper ussage of this tool.
#./DL
#The above string can be converted into an array of "array[switch]=default" 
#in the the usual way:
#.PRE
 
#./PRE
#.P 
#For example, this code builds a array with keys "P,h,c,a" and values
#"world,,," (respectively):
#.PRE
#s2a("P = world; h = ; c = ; a = ",options, "[=;]")
#./PRE
#.H2 The Options function
#.P
#To review: using <tt>s2a</tt> and strings like 
#"P=world;h=;c=;a="
# we can quickly define switches and
#their defaults. Also, if we start a switch with an upper case letter,
#we can identify what switches take arguments.
#That all said, we can now look at the code that changes a switch's default
#value using command-line arguments:
#.PRE
function options(opt,input,n0,               n,key,i,j,k,tmp) {
    for(i=1;i<=n0;i++)  {
        key = input[i]
        if (sub(/^[-]+/,"",key))  { # ........................ [1]
            if (key in opt)         # ........................ [2]
                opt[key] = ("_" key "?" in opt) ? input[++i] : 1 # [3]
            else bad("-"key" unknown. Try -h for help.")     # [4]
        } else { i--; break }       # ........................ [5]
    }
	n=0
    for(j=i+1;j <= n0;j++) {n++; tmp[n]=input[j]} #................... [6]
    split("",input,"")                    #................... [7]
    for(j=1;j<=n;j++) input[j] = tmp[j]       #................... [8]
    return n                             #................... [9]
 }
#./PRE
#.P
#The function updates the values in the <tt>opt</tt> array
#then throws away the switches from the <tt>input</tt>. It then
#returns the size of the remaining arguments (in Awk, this would be files
#that the rest of the code would process).
#.P 
#This is not a complex function- explainaing it actually
#takes nearly as many lines as the code itself:
#.OL
#.LI 
# If we can remove a leading "<tt>-</tt>" for an argument, it is a flag.
#.LI
#If we can find that flag in our list of pre-defined options, it is a legal flag.
#.LI
#If the flag starts with an upper case letter, we assume that there is
#an argument to read at the current input position, plus one. Else,
#we just set that flag to "1".
#.LI
# If the next thing on the command line is not a flag, we have read one
#item too many. If so, we:
#.UL
#.LI reset the pointer into the list of options back one value. 
#.LI stop reading flags.
#./UL
#.LI 
#Now we have to remove the flags we read from the command-line array.
#To do that, we first copy everything after the flags we read
# to  a temporary variable.
#.LI Then we reset the command-line array to the empty array.
#.LI Then we copy the contents of the temporary into the revised array.
#.LI Finally, we return the size of the newly created array.
#./OL
#.P
#A standard usage of the function is:
#is
#.PRE
#s2a("a=;c=;h=;" str,opt,"[=;]")
#ARGC = options(opt,ARGV,ARGC)
#./PRE
#.P
#Note that
#the idiom <tt>a=;c=;h=; str</tt>
#combines a user supplied <tt>str</tt>
#of switches with some standard switches.
#.H2 Example
#.P
# Shown below is a simple "hello world" application that accepts an optional "-P who" argument. By default,
#"who=world" but for a more personnel greeting such as "hello ken", this code can be called with "-P ken".

#.P
#This code also supports standard options such as  showing a
#copyright notice, printing an about string, and showing help text.
#This help text is defined in
#the <em>usageHello</em> function:
#.PRE
  
 function builtInOptions(opt) {
	opt["dumpOptions"]=0
 }
 function dumpOptions(opt) {
	print "BEGIN {"
	for(i in opt)
		print "\tOpt[\""i"\"]\t=\t\""opt[i]"\";"
	print "}"
 }
 function lines2options(str,opt,    tmp,n,i,out) {
	builtInOptions(opt)
	n=split(str,tmp,"\n")
	for(i=1;i<=n;i++) 
		if ( tmp[i] ~ /^\+.*\+/ )  
			 out = out "\n" line2option(tmp[i],opt)
		else out = out "\n" tmp[i];
	return out
 }
 function line2option(line,opt,    parts,switch,type,default,typeDefault) {
	split(line,parts,/\+/)
	sub(/^[ \t]*[-]+/,"",parts[2])
	switch  = trim(parts[2])
	if(switch !~ " ") 
		opt[switch] = ""
	else {
		split(switch,tmp,/[ \[\]]/)
		switch  = trim(word1(tmp[1]))
		type    = trim(word1(tmp[2]))
		default = trim(word1(tmp[3])) 
		opt[switch]     = default 
		opt["_" switch "?"] = type
    } 
	gsub(/\+/," ",line)
	return line
 }
 #./PRE
#.P 
#The help text is printed if the <em>ok2go</em> function fails. Otherwise, the main function
#is called:
#.PRE
 
 function ok2go(usage, about, opt) { # returns 0 if bad options
	ARGC = options(opt,ARGV,ARGC)
	for(i in opt) 
	  	if (i !~ /^_/)
			ok(i,opt["_" i "?"], opt[i])
	if (opt("dumpOptions")) { dumpOptions(opt);  exit 0 }
	if (opt("c")) { copyleft(about); exit -1 }
	if (opt("a")) { print about;     exit 0  }
	if (opt("h")) { print about "\n" usage;     exit 0  }
	return 1
 }
#./PRE
#.P 
#The <tt>opt</tt> function assumes the existance of a global called <em>Opt</em>
#whose keys are the legal switches for the system (and <tt>Opt</tt> is created
#in the first line of the <tt>BEGIN</tt> block shown above. This function
#complains if we use an illegal variable name.
#.PRE
 function opt(x) {
	return (x in Opt) ? Opt[x] : bad(Opt["What"] " option ["x"] unknown")
 }
#./PRE
#.P
#Since globals are evil
#I try to use them as few of them as possible. In the above code, you see I use
#<tt>Opt</tt> to store some meta-information about the code (the <tt>Who,What,When,Why</tt>)
#of the code.
#.H2 Code

 function copyleft(about) {
	print about
    print ""
    print "This program is free software; you can redistribute it and/or"
    print "modify it under the terms of the GNU Lesser General Public"
    print "License as published by the Free Software Foundation; version 2.1."
    print ""
    print "This program is distributed in the hope that it will be useful"
    print "but WITHOUT ANY WARRANTY; without even the implied warranty of"
    print "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU"
    print "Lesser General Public License for more details."
    print ""
    print "You should have received a copy of the GNU Lesser General Public"
    print "License along with this program; if not write to the Free Software"
    print "Foundation Inc. 51 Franklin St Fifth Floor Boston MA 02110-1301 USA."
 }

#.P Turn the string "key1,value1,key2,value2,.." into a array where a[key_i]=value_i
#.H2 Author
#.P Tim Menzies
