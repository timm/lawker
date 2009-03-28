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
