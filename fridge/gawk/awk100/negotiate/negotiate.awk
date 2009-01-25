BEGIN {
 #
 # this simple script regulates the play of anne jump's negotiation game
 # which is intended to model the following aspects of negotiation
 # which are absent in game-theoretic approaches:
 #
 # interplay of individual and social search
 # joint problem-solving through resource exchange
 # cost of search and satisficing search
 # multidimensionality of settlement options explored during the negotiation
 # explicit threats
 # unrestricted language
 # multiplicity of winning conditions
 # generativity of options
 #

 # this game was developed during the summer of 1997 by ronald p. loui
 # and anne h. jump, funded by the national science foundation
 # program on information technology and organizations within the
 # information, robotics, and intelligent systems division of the
 # computer and information systems engineering directorate.

 # version 1.0 of 10/97 rpl

 init()
 deal()
 firstreveal()

 negotiate()

 revealremaining()
 view("anne and ron")
 traderesources()
 doexchanges()
 view("anne and ron")
 sumcells()
 reportsums()
 reportvalue(finalrow,finalcol)

}

function negotiate() {
 if (rand() < .5) whoseturn = "anne"
 else whoseturn = "ron"
 do {
   print "\t\t\t\t_______________"
   print "\n\t\t\t\t  "whoseturn"'s turn"
   print "\t\t\t\t_______________"
   view(whoseturn)
   if (++turn <= 2) printmenu()
   if (forcingperson == whoseturn) {
     print whoseturn" has left the negotiation with "
     print lastforce
     $0 = lastforce
   } else {
     printf "\t\t\t\t"whoseturn"'s action (or 'menu')?"; getline
     if ($0 ~ /menu/) {
       printmenu()
       printf "\t\t\t\t"whoseturn"'s action?"; getline
     }
     resultingview = 0; # could be set to 1 in command
     command()
   }

   addtodialogue($0)

   if (resultingview) view(whoseturn)

   if (whoseturn == "anne") whoseturn = "ron"
   else whoseturn = "anne"
 } while (!agreement)
 return
}

function command(new,n,cards,i) {
 # only response to a force is a force
 if (forcingperson) {
   if ($1 !~ /fo/) print "PROTOCOL VIOLATION:  only response to force is force"
 }

 # accept
 if ($1 ~ /^ac/) {
   if (activeprop[$2,$3,otherplayer(whoseturn)]) {
     agreement = 1
     rowsettle = $2
     colsettle = $3
   } else print "PROTOCOL VIOLATION:  accept only proposed offers"
   finalrow = $2
   finalcol = $3
   agreement = 1
 }

 # propose
 if ($1 ~ /^pr/) if (kosher($2,$3)) {
   activeprop[$2,$3,whoseturn] = 1
 }

 # rescind proposal, unpropose
 if ($1 ~ /^unpr/) if (kosher($2,$3)) {
   if (!activeprop[$2,$3,whoseturn]) print "PROTOCOL VIOLATION:  propose before you rescind"
   else delete activeprop[$2,$3,whoseturn]
   for (i in sidepay)
     split(i,temp,"\034")
     if (temp[1] == $2 && temp[2] == $3 && temp[4] == whoseturn) {
       delete sidepay[i]
       print "deleting sidepayment "i" with the proposal."
     }
 }

 # search
 if ($1 ~ /^se/) if (kosher($2,$3)) {
   if (!chargeto(whoseturn)) continue
   new = getcard()
   if (whoseturn == "anne") n = sub(/\?/,new,anne[$2,$3])
   if (whoseturn == "ron") n = sub(/\?/,new,ron[$2,$3])
   if (!n) print "PROTOCOL VIOLATION:  no more cards to reveal"
   resultingview = 1
 }

 # generate substitution
 if ($1 ~ /^su/) if (kosher($2,$3)) {
   if (!chargeto(whoseturn)) continue
   n = $4
   if (whoseturn == "anne") cards = anne[$2,$3]
   if (whoseturn == "ron") cards = ron[$2,$3]
   parsetotemp(cards)
   if (temp[n] ~ /[rb]/) {
       new = getcard()
       temp[n] = temp[n]">"new
   } else print "PROTOCOL VIOLATION:  no such card to substitute"
   cards = ""
   for (i=1; i<=nt; i++) {
       cards = cards temp[i]
   }
   if (whoseturn == "anne") anne[$2,$3] = cards
   if (whoseturn == "ron") ron[$2,$3] = cards
   resultingview = 1
 }

 # threaten row or col for anne or ron
 if ($1 ~ /^fo/) {
   if (whoseturn == "anne") {
     threat = $2
     if ($3 != ".") {
       print "PROTOCOL VIOLATION:  use . for column"
       return
     }
     if (!kosher(threat,1)) {
       print "PROTOCOL VIOLATION:  no such row"
       return
     }
   }
   if (whoseturn == "ron") {
     threat = $3
     if ($2 != ".") {
       print "PROTOCOL VIOLATION:  use . for row"
       return
     }
     if (!kosher(1,threat)) {
       print "PROTOCOL VIOLATION:  no such column"
       return
     }
   }
 }

 # ask what's wrong with a proposal, whynot
 if ($1 ~ /^wh/) {
   if (!activeprop[$2,$3,whoseturn]) {
     print "PROTOCOL VIOLATION:  propose before you ask"
     return
   }
 }

 # ask if other has a card, haveyou
 if ($1 ~ /^ha/) {
   if (!iscard($2)) {
     print "PROTOCOL VIOLATION:  resource must be a card"
     return
   }
 }

 # offer a card as sidepayment to a proposal
 if ($1 ~ /^of/) {
   if (!activeprop[$2,$3,whoseturn]) {
     print "PROTOCOL VIOLATION:  amend only your own proposals"
     return
   }
   if (!(resources[whoseturn,$4])) {
     print "PROTOCOL VIOLATION:  offer only what you have"
     return
   }
   sidepay[$2,$3,$4,whoseturn] = 1
 }

 # retract an offer a card as sidepayment to a proposal, unoffer
 if ($1 ~ /^unof/) {
   if (!sidepay[$2,$3,$4,whoseturn]) {
     print "PROTOCOL VIOLATION:  no such sidepayment offered"
     return
   }
   if (!activeprop[$2,$3,whoseturn]) {
     print "PROTOCOL VIOLATION:  offer rescinded with all sidepayments"
     return
   }
   delete sidepay[$2,$3,$4,whoseturn]
 }

 # warn that breakdown is imminent
 if ($1 ~ /^wa/) {
   # nothing to do here
 }

 # force breakdown for anne or ron
 if ($1 ~ /^fo/) {
   if (whoseturn == "anne") {
     threat = $2
     if ($3 != ".") {
       print "PROTOCOL VIOLATION:  use . for column"
       return
     }
     if (!kosher(threat,1)) {
       print "PROTOCOL VIOLATION:  no such row"
       return
     }
     finalrow = $2
   }
   if (whoseturn == "ron") {
     threat = $3
     if ($2 != ".") {
       print "PROTOCOL VIOLATION:  use . for row"
       return
     }
     if (!kosher(1,threat)) {
       print "PROTOCOL VIOLATION:  no such column"
       return
     }
     finalcol = $3
   }
   if (forcingperson) {
     # this is the response to a force
     agreement = 1
   }
   forcingperson = whoseturn
   lastforce = $0
 }

}

function iscard(x) {
 if (x ~ /^[rb][0-9]$/) return 1
 if (x ~ /^[rb]10$/) return 1
 if (x ~ /^[rb]11$/) return 1
 if (x ~ /^[rb]12$/) return 1
 if (x ~ /^[rb]13$/) return 1
 return 0
}

function otherplayer(x) {
 if (x == "anne") return "ron"
 if (x == "ron") return "anne"
}

function addtodialogue(x) {
 print whoseturn,x >> "anne.dialogue"
 close("anne.dialogue")
}

function firstreveal(n) {
 for (n=1; n<=5; n++) {
   revealanne(int(rand()*rows)+1, int(rand()*cols)+1)
   revealron(int(rand()*rows)+1, int(rand()*cols)+1)
 }
}

function revealanne(i,j) { sub(/\?/,getcard(),anne[i,j]) }

function revealron(i,j) { sub(/\?/,getcard(),ron[i,j]) }

function chargeto(x) {
 if (x ~ /anne/) {
   if (annefreeused < annefree) { annefreeused++; return 1 }
   if (annecostused < annecost) { annecostused++; return 1 }
   print "PROTOCOL VIOLATION:  sorry, no search left"
   return 0
 }
 if (x ~ /ron/) {
   if (ronfreeused < ronfree) { ronfreeused++; return 1 }
   if (roncostused < roncost) { roncostused++; return 1 }
   print "PROTOCOL VIOLATION:  sorry, no search left"
   return 0
 }
}

function kosher(x,y,res) {
 res = 1
 if (x != int(x) || y != int(y)) res = 0
 if (x < 1 || y < 1) res = 0
 if (x > rows || y > cols) res = 0
 if (!res) print "PROTOCOL VIOLATION:  no such proposal"
 return res
}

function printmenu() {
  print "accept x y    accept the proposal <x,y>"
  print "prop x y      make (or repeat) a proposal"
  print "unprop x y    rescind a proposal"
  print "search x y    reveal more about a proposal"
  print "sub x y n     generate substitution for the nth card of a proposal"
  print "whynot x y    ask why not a proposal"
  print "threaten . y  threaten breakdown with column y (ron only)"
  print "threaten x .  threaten breakdown with row x (anne only)"
  print "warnbreak     warn that breakdown is imminent"
  print "force . y     unilaterally breakdown (ron only)"
  print "force x .     unilaterally breakdown (anne only)"

  print "haveyou c     ask for the resource, c"
  print "idohave c     confirm having c"
  print "idonthave c   deny having c"
  print "offer x y c   offer a resource, conditional on agreeing to <x,y>"
  print "unoffer x y c retract an offered resource"

}

function init() {
 srand()
 rows = int(10*rand())+3
 cols = int(4*rand())+3

 system("clear")
 print "\t\t\tA BETTER NEGOTIATION GAME"
 print ""
 print ""
 print ""

 print "rows " rows " (anne controls under breakdown)"
 print "cols " cols " (ron controls under breakdown)"
 annefree = int(10*rand())+1
 annecost = int(10*rand())+1
 annecount = int(20*rand())+1
 annefreeused = 0; annecostused = 0
 ronfree = int(10*rand())+1
 roncost = int(10*rand())+1
 roncount = int(10*rand())+1
 ronfreeused = 0; roncostused = 0

 system("rm -f anne.dialogue")
 print rows,cols > "anne.dialogue"
}

function deal(i,j,new) {
 basic = "???"
 for (i=1; i<=rows; i++) {
   for (j=1; j<=cols; j++) {
     anne[i,j] = basic
     ron[i,j] = basic
   }
 }
 augment(1,1)
 augment(2,2)
 augment(2,3)
 augment(3,3)
 augment(4,1)

 anneresources = ""
 for (i=1; i<=annecount; i++) {
   new = getcard()
   if (!index(anneresources," "new)) anneresources = anneresources " " new
   resources["anne",new] = 1
 }
 gsub("^ ","",anneresources)
 ronresources = ""
 for (i=1; i<=roncount; i++) {
   new = getcard()
   if (!index(ronresources," "new)) ronresources = ronresources " " new
   resources["ron",new] = 1
 }
 gsub("^ ","",ronresources)
}

function getcard(rank,color) {
 if (rand() < .5) color = "r"
 else color = "b"

 rank = int(rand()*13)+1

 return color rank
}

function augment(x,y, i,j) {
 for (i=1; i<=x; i++) {
   for (j=1; j<=y; j++) {
     anne[i,j] = anne[i,j] "?"
     ron[rowrev(i),colrev(j)] = ron[rowrev(i),colrev(j)] "?"
   }
 }
}

function rowrev(i) { return rows-i+1 }
function colrev(i) { return cols-i+1 }

function makesearch(x,y, i,result) {
 result = ""
 for (i=1; i<=x; i++) result = result "0"
 for (i=1; i<=y; i++) result = result "1"
 return result
}

function view(who, max,i,j,temp2) {
 # format is the longest string
 if (who ~ /anne/) {

 for (j=1; j<=cols; j++) {
   max = 0
   for (i=1; i<=rows; i++) {
     if (length(anne[i,j]) > max) max = length(anne[i,j])
   }
   max++
   format[j] = "%"max"s"
 }

 print ""
 print "anne's resources: " anneresources
 print "anne's search: " makesearch(annefree-annefreeused,annecost-annecostused)
 print "anne's payoffs (preferring upper left)"
 printf "%4s",""
 for (j=1; j<=cols; j++) { printf format[j],j }
 print ""
 for (i=1; i<=rows; i++) {
   printf "%4s",i" "
   for (j=1; j<=cols; j++) {
     printf format[j],anne[i,j]
   }
   print ""
 }

 }

 if (who ~ /ron/) {

 for (j=1; j<=cols; j++) {
   max = 0
   for (i=1; i<=rows; i++) {
     if (length(ron[i,j]) > max) max = length(ron[i,j])
   }
   max++
   format[j] = "%"max"s"
 }

 print ""
 print "ron's resources: " ronresources
 print "ron's search: " makesearch(ronfree-ronfreeused,roncost-roncostused)
 print "ron's payoffs (preferring lower right)"
 printf "%4s",""
 for (j=1; j<=cols; j++) { printf format[j],j }
 print ""
 for (i=1; i<=rows; i++) {
   printf "%4s",i" "
   for (j=1; j<=cols; j++) {
     printf format[j],ron[i,j]
   }
   print ""
 }

 }

 for (i in activeprop) {
   split(i,temp,"\034")
   if (temp[3] == who) print "\tyou have proposed: "temp[1],temp[2]
   for (j in sidepay) {
     split(j,temp2,"\034")
     if (temp[1] == temp2[1] && temp[2] == temp2[2] && temp2[4] == whoseturn) {
       print "\t\twith sidepayment "temp2[3]
     }
   }
 }
 for (i in activeprop) {
   split(i,temp,"\034")
   if (temp[3] != who) print "\tproposed to you: "temp[1],temp[2]
   for (j in sidepay) {
     split(j,temp2,"\034")
     if (temp[1] == temp2[1] && temp[2] == temp2[2] && temp2[4] == otherplayer(whoseturn)) {
       print "\t\twith sidepayment "temp2[3]
     }
   }
 }

 if (forcingperson) {
   printf force" has left the negotiation, forcing "
   if (forcingperson == "anne") print "row "finalrow
   if (forcingperson == "ron") print "col "finalcol
 }

}

function revealremaining(i,new) {
 for (i in anne) {
   while (anne[i] ~ /\?/) {
     new = getcard()
     sub(/\?/,new,anne[i])
   }
 }
 for (i in ron) {
   while (ron[i] ~ /\?/) {
     new = getcard()
     sub(/\?/,new,ron[i])
   }
 }
}

function sumcells(i,j,k,temp,cell,total) {
 for (i=1; i<=rows; i++) {
   for (j=1; j<=cols; j++) {
     total = 0
     cell = anne[i,j]
     split(cell,temp,"[rb]")
     for (k in temp) total += temp[k]
     anneval[i,j] = total

     total = 0
     cell = ron[i,j]
     split(cell,temp,"[rb]")
     for (k in temp) total += temp[k]
     ronval[i,j] = total
   }
 }
}

function reportsums(i,j) {
 print ""
 print "\t\tanne's final payoffs"
 printf "\t\t%4s",""
 for (j=1; j<=cols; j++) { printf "%4s",j }
 print ""
 for (i=1; i<=rows; i++) {
   printf "\t\t%4s",i" "
   for (j=1; j<=cols; j++) {
     printf "%4s",anneval[i,j]
   }
   print ""
 }

 print ""
 print "\t\tron's final payoffs"
 printf "\t\t%4s",""
 for (j=1; j<=cols; j++) { printf "%4s",j }
 print ""
 for (i=1; i<=rows; i++) {
   printf "\t\t%4s",i" "
   for (j=1; j<=cols; j++) {
     printf "%4s",ronval[i,j]
   }
   print ""
 }

}

function reportvalue(x,y) {
 print ""
 print "\t\t\tanne gets "anneval[x,y] - annecostused
 print "\t\t\tron gets "ronval[x,y] - roncostused
}

function doexchanges(i,j,max,maxval,cards,k,l,exchanges,thisval,thiscolor,oppcolor,oppcard) {
 for (i=1; i<=rows; i++) {
   for (j=1; j<=cols; j++) {

     cards = anne[i,j]
     for (k in temp) delete temp[k]
     parsetotemp(cards)
     for (k=1; k<=nt; k++) {
       for (l in exchanges) delete exchanges[l]
       split(temp[k],exchanges,">")
       max = exchanges[1]
       for (l=1; l in exchanges; l++) {
         thisval = substr(exchanges[l],2)
         maxval = substr(max,2)
         if (thisval+0 > maxval+0) max = exchanges[l]
         thiscolor = substr(exchanges[1],1,1)
         if (thiscolor == "b") oppcolor = "r"
         else oppcolor = "b"
         oppcard = oppcolor thisval
         if (!(resources["anne",oppcard])) break
         if (l+1 in exchanges) print oppcard " permits anne an exchange at "i,j
       }
       temp[k] = max
     }
     anne[i,j] = ""
     for (k=1; k<=nt; k++) anne[i,j] = anne[i,j] temp[k]

     cards = ron[i,j]
     for (k in temp) delete temp[k]
     parsetotemp(cards)
     for (k=1; k<=nt; k++) {
       for (l in exchanges) delete exchanges[l]
       split(temp[k],exchanges,">")
       max = exchanges[1]
       for (l=1; l in exchanges; l++) {
         thisval = substr(exchanges[l],2)
         maxval = substr(max,2)
         if (thisval+0 > maxval+0) max = exchanges[l]
         thiscolor = substr(exchanges[1],1,1)
         if (thiscolor == "b") oppcolor = "r"
         else oppcolor = "b"
         oppcard = oppcolor thisval
         if (!(resources["ron",oppcard])) break
         if (l+1 in exchanges) print oppcard " permits ron an exchange at "i,j
       }
       temp[k] = max
     }
     ron[i,j] = ""
     for (k=1; k<=nt; k++) ron[i,j] = ron[i,j] temp[k]

   }
 }
}

function parsetotemp(cards) {
 # cards might be "r12>r7>b8b5???"
 # sets the global vals temp and nt
 nt = 0
 while (cards) {
   first = substr(cards,1,1)
   take = 1
   while (substr(cards,take+1,1) ~ /[0-9>]/) {
     take++
     if (substr(cards,take,1) == ">") take++
   }
   temp[++nt] = substr(cards,1,take)
   cards = substr(cards,take+1)
 }
}

function traderesources(temp,i,benfactor,beneficiary,card) {
 for (i in sidepay) {
   split(i,temp,"\034")
   if (temp[1] == finalrow && temp[2] == finalcol) {
     benefactor = temp[4]
     beneficiary = otherplayer(benefactor)
     card = temp[3]
     delete resources[benefactor,card]
     resources[beneficiary,card] = 1
     if (beneficiary == "anne") anneresources = anneresources " " card
     if (beneficiary == "ron") ronresources = ronresources " " card
     if (benefactor == "anne") {
       anneresources = " " anneresources
       gsub(" "card,"",anneresources)
       gsub("^ ","",anneresources)
     }
     if (benefactor == "ron") {
       ronresources = " " ronresources
       gsub(" "card,"",ronresources)
       gsub("^ ","",ronresources)
     }
     print "TRADE: " benefactor " gives " beneficiary " " card
   }
 }
}
