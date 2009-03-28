#.H1 Story Generation
#.H2 Synopsis
#.PRE
#echo Goal | gawk -f storyp.awk -v Grammar 
#./PRE
#.H2 Download
#.P
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/grammar/story.awk LAWKER.
#.P
#This code inputs a set of productions 
#and outputs a string of words that satisfy the production rules.
#.H3 A Short Example
#.P This input ...
#echo Sentence | gawk -f ../story.awk -v Grammar=english.rules 
#./PRE
# ... generates this sentence
#.PRE
#the boy runs very slowly
#./PRE
#.H3 A Longer Example
#.P Here is the standard sci-fi story generator ...
#<center>
#<a href="http://lawker.googlecode.com/svn/fridge/share/img/movie_generator.gif">
#<img wdith=300 src="http://lawker.googlecode.com/svn/fridge/share/img/movie_generator.gif">
#</a>
#</center>
#.P
#Using the above, we can generate the following stories:
#.CODE eg/story.out
#.P
#This is generated from the following grammar:
#.CODE eg/scifi.rules
#.H2 Code
#.PRE
BEGIN { 
    srand(Seed ? Seed : 1) 
	Grammar = Grammar ? Grammar : "grammar"
	while (getline < Grammar > 0)
	    if ($2 == "->") {
		    i = ++lhs[$1]              # count lhs
		    rhscnt[$1, i] = NF-2       # how many in rhs
		    for (j = 3; j <= NF; j++)  # record them
		        rhslist[$1, i, j-2] = $j
	    } else
		     if ($0 !~ /^[ \t]*$/)
        	    print "illegal production: " $0
}
{   if ($1 in lhs) {  # nonterminal to expand
        gen($1)
        printf("\n")
    } else 
        print "unknown nonterminal: " $0   
}
function gen(sym,    i, j) {
    if (sym in lhs) {       # a nonterminal
        i = int(lhs[sym] * rand()) + 1   # random production
        for (j = 1; j <= rhscnt[sym, i]; j++) # expand rhs's
            gen(rhslist[sym, i, j])
    } else {
        gsub(/[A-Z]/," &",sym)
        printf("%s ", sym) }
}
#./PRE
#.H2 Author
#.P
#The code comes from 
#Alfred Aho, Brian  Kernighan, and Peter  Weinberger from the 
# book "The AWK Programming Language",
#Addison-Wesley, 1988. 
#.P
#The scifi grammar was written by Tim Menzies, 2009, based on 
#one from 
#"The Science Fiction Horror Movie Pocket Computer" by Gahan Wilson,
#( in "The Year's Best Science Fiction No. 5", edited by
#Harry Harrison and Brian Aldiss, Sphere, London, 1972).
