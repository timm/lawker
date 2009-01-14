
gawk -f patterns.awk --source ' BEGIN {
         print "" 
         s2rules("a"\
                 "{b=br=break}:{(any|all)}"\
                 "{c=count}:{[0-9]*}"\
                 "d:{roundints!!}"\
                 "ef:g",
                 rules,aka); 
         for ( r in rules ) print "rules " r " " rules[r]
         for ( a in aka   ) print "aka "   a " " aka[a]         
}'

gawk -f patterns.awk  --source 'BEGIN{
   print is("23","nump!")
   print is("x23","nump!")
   print is("23.3","nump!")

}'
