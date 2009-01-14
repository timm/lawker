cat array.awk |
gawk -f barph.awk   -f array.awk -f saya.awk \
     -f setting.awk -f patterns.awk --source 'BEGIN { demo(); }
      
function demo(   s,rules,aka) {
     s="ab{-help=h=?}:{posint!}W:N:{11.2,11.6,..,12.9}O:{1,..,10}"
     s2rules(s,rules,aka)
     saya("rules",rules)pat
     main(s,"-b -W 40",opt)
     saya("opt",opt)
}
function newOption(x,y) {
   print "x=" x "; y=" y "."
}

FNR<10{print FILENAME " " FNR " " $0}
' -a -b -a -? 23 -a -W sadds -? 2 --help 23 -N 12.4 -O  10