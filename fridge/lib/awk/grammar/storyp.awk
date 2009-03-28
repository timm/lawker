#.H1 Story Generation
#.H2 Synopsis
#.PRE
#echo Goal | gawk -f storyp.awk -v Grammar 
#./PRE
#.H2 Download
#.P
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/bash/story/ LAWKER.
#.P
#This code inputs a set of productions 
#and outputs a string of words in accordance with probabilities
#associated with each production.
#.H3 Short Example
#In the following grammar:
#.UL
#.LI
#Noun phrases with "the girl" are three times less likely than noun phrases with "the boy"; 
#.LI
#The Verb "runs" is nine times more likely thatn "walks"; 
#.LI
#"Modlists" are empty half the time;
#.LI
#The Adverb "slowly" is nine times more likely than "quickly".
#./UL
#.IN eg/englishp.rules
#.P 
#This can be called ten times, looking for a sentence, as follows:
#.PRE
#for((i=1;i<=10;i++)); do echo Sentence ;  done |
#gawk -f ../storyp.awk -v Grammar=englishp.rules #./PRE
#./PRE
#.IN eg/englishp
#.H2 Code
#.PRE
BEGIN {
    srand(Seed ? Seed : 1) 
    Grammar = Grammar ? Grammar : "grammar"
    while ((getline < Grammar) > 0)
        if ($2 == "->") {
            i = ++lhs[$1]              # count lhs
            rhsprob[$1, i] = $NF       # 0 <= probability <= 1
            rhscnt[$1, i] = NF-3       # how many in rhs
            for (j = 3; j < NF; j++)   # record them
               rhslist[$1, i, j-2] = $j
        } else
            print "illegal production: " $0
    for (sym in lhs)
         for (i = 2; i <= lhs[sym]; i++)
            rhsprob[sym, i] += rhsprob[sym, i-1]
}
{   if ($1 in lhs) {  # nonterminal to expand
         gen($1)
         printf("\n")
     } else 
         print "unknown nonterminal: " $0   
}
function gen(sym,    i, j) {
    if (sym in lhs) {       # a nonterminal
        j = rand()          # random production
        for (i = 1; i <= lhs[sym] && j > rhsprob[sym, i]; i++) ;       
        for (j = 1; j <= rhscnt[sym, i]; j++) # expand rhs's
            gen(rhslist[sym, i, j])
    } else
        printf("%s ", sym)
}
#./PRE
