gawk -f patterns.awk --source ' BEGIN {
         print ""
         s2rules("ab:c",rules,aka); 
         for ( r in rules ) print "rules " r " " rules[r]
         for ( a in aka   ) print "aka "   a " " aka[a]         
}'
