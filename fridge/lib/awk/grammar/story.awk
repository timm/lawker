#.H1 Story.awk
#.H2 Synopsis
#.PRE
#echo Goal | gawk -f story.awk [ -v Grammar=FILE ] [ -v Seed=NUMBER ] 
#./PRE
#.H2 Download
#.P
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/grammar LAWKER.
#.H2 Description
#.P
#This code inputs a set of productions 
#and outputs a string of words that satisfy the production rules.
#.P
#This page describes two versions of that system: 
#<a href="http://lawker.googlecode.com/svn/fridge/lib/awk/grammar/story.awk">story.awk</a>
#and
#<a href="http://lawker.googlecode.com/svn/fridge/lib/awk/grammar/storyp.awk">storyp.awk</a>.
#The former selects productions at random with equal probability. The latter
#allows the user to bias the selection by adding weights at the end  of line, after
#each production. 
#.H2 Options
#.DL
#.DT -v Grammer=FILE ]
#.DD Sets the FILE containing the productions. Defaults to "grammar".
#.DT -v Seed=NUM
#.DD 
# Sets the seed for the random number generator. Defaults to "1". 
#A useful idiom for generating random text is to use <em> Seed=$RANDOM</em>
#./DL
#.H2 Examples
#.H3 A Short Example
#.P 
# This grammar..
#.LISTING eg/english.rules
# ... and this input ...
#.LISTING eg/english
# ... generates these sentences:
#.LISTING eg/english.out
#.H3 A Longer Example
#.P Here is the standard sci-fi story generator ...
#<center>
#<a href="http://lawker.googlecode.com/svn/fridge/share/img/movie_generator.gif">
#<img border=1 width=500 src="http://lawker.googlecode.com/svn/fridge/share/img/movie_generator.gif">
#</a>
#</center>
#.P
#Using the above, we can generate the following stories:
#.CODE eg/story.out
#.P
#This is generated from the following code:
#.LISTING eg/story
#.P running on the following grammar:
#.LISTING eg/scifi.rules
#.H3 Biasing the Story
#.P
#Here is a grammar suitable for storyp.awk. Note that number at end of line that biases how often a
#production is selected. For example, "runs" and "slowly" are nine times more likely than other Verbs
# and Adverbs.
#.LISTING eg/englishp.rules
#The following code executes the biases story generation:
#.LISTING eg/englishp
#.P
#This produces the following output. Note that, usually, we run slowly.
#.LISTING eg/englishp.out
#.H2 Code
#.H3 Story.awk
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
#.H3 Storyp.awk
#.P
#Storyp.awk is almost the same as story.awk but it is assumed that each line ends in a number
# that will bias how often that production gets selected.
#.LISTING storyp.awk
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
