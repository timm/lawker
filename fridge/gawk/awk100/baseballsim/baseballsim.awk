#! /pkg/gnu/bin/gawk -f
BEGIN {
 if (output=="") output = 0
 if (!iters) iters = 2000
 if (remake=="") remake = 1
 if (!prog) prog = "makelineup"

 # output = 1
 # iters = 1

 srand()
 if (remake) {
   print "making new problem."
   makebatters()
   if (rand() < .5) rl="l"
   else rl="r"
   print rl > "rl.last"
   close("rl.last")
 } else {
   print "restoring last problem.  use -v remake=1 to make new problem."
   fgetp()
   getline rl < "rl.last"
   close("rl.last")
 }

 print "starting pitcher is "rl"-handed"
 print "making lineup with "prog".  use -v prog=foo to use foo instead."

 com = "echo "rl" | "prog
 print "batting order is "
 if (rl == "l") negrl = "r"
 else negrl = "l"
 for (i=1; i<=9; i++) {
   com | getline n
   player[i] = n
   if (n < 0 || n != int(n) || n > 15) { print n" out of bounds.\nyou lose."; exit }
   if (used[n]) { print n" already used in lineup.\nyou lose."; exit }
   used[n] = 1
   hits[n] = b1[n,rl]+b2[n,rl]+b3[n,rl]+b4[n,rl]
   # small cheat here to make denominators nonzero
   if (!ab[n,rl]) ab[n,rl] = 1
   if (!ab[n,negrl]) ab[n,negrl] = 1
   avg[n] = hits[n]/ab[n,rl]
   offhits[n] = b1[n,negrl]+b2[n,negrl]+b3[n,negrl]+b4[n,negrl]
   offavg[n] = offhits[n]/ab[n,negrl]
   printf i".  "player[i]" :  \t"
   printf "%3.3f",avg[n]
   printf "\t"
   printf "%3.3f",offavg[n]
   printf "\t"
   printf "hr="b4[n,rl]+b4[n,negrl]
   printf "\t"
   printf "ab/hr="int(.5+(ab[n,rl]+ab[n,negrl])/(.1+b4[n,rl]+b4[n,negrl]))
   print ""
 }

 while (++repeat <= iters) {
   playball()
   if (output) print "RUNS = "runs
   totruns += runs
   if (firstchase) { totfirsts+=firstchase; nfirsts++ }
 }
 print chasings " chasings total"
 printf "%3.2f",chasings/iters
 print " chasings per game"
 printf "%3.2f",totfirsts/nfirsts
 print " is the average inning of first chase"
 print totruns " runs total"
 printf "%3.2f",totruns/iters
 print " runs per game"
}

function playball( den) {

 firstchase = ""
 newwalks = newhits = newruns = newhomers = 0
 runs = 0
 nthbatter = 0
 if (output) print "\n\nNEW GAME"
 for (inning=1; inning<=9; inning++) {
   if (output) print "inning "inning
   for (i in base) delete base[i]
   while (outs < 3) {
     tobat++
     tobat %= 9
     if (!tobat) tobat=9
     who = player[tobat]
     nexttobat = ((tobat+1) % 9)
     if (!nexttobat) nexttobat=9
     nextwho = player[nexttobat]
     ++nthbatter
     if (output) printf nthbatter":  " who" up to bat."
     if (output) if (base[3]) printf "  runner on 3rd."
     if (output) if (base[2]) printf "  runner on 2nd."
     if (output) if (base[1]) printf "  runner on 1st."
     if (output) print ""
     r = rand()
     if (r < hits[who]/(ab[who,rl]+bb[who,rl])) {
       newhits++
       if (output) printf "\thit: "
       xb = rand()
       if (xb < b4[who,rl]/hits[who]) {
         newhomers++
         if (output) print "\tHOME RUN!"
         runners = (base[1]!="") + (base[2]!="") + (base[3]!="")
         for (i in base) delete base[i]
         runs += runners+1
         newruns += runners+1
         if (output) print "\t\t\t"runners+1 " run(s) score(s)"
       } else if (xb < (b3[who,rl]+b4[who,rl])/hits[who]) {
         if (output) print "\ttriple"
         runners = (base[1]!="") + (base[2]!="") + (base[3]!="")
         for (i in base) delete base[i]
         base[3] = who
         runs += runners
         newruns += runners
         if (runners) if (output) print "\t\t\t"runners " run(s) score(s)"
       } else if (xb < (b2[who,rl]+b3[who,rl]+b4[who,rl])/hits[who]) {
         if (output) print "\tdouble"
         runners = (base[2]!="") + (base[3]!="")
         delete base[2]; delete base[3]
         if (rand() < .2) {
           base[3] = base[1]
           if (base[3]) if (output) print "\trunner held up at third"
         } else {
           runners += (base[1]!="")
           delete base[1]
         }
         base[2] = who
         base[1] = ""
         runs += runners
         newruns += runners
         if (runners) if (output) print "\t\t\t"runners " run(s) score(s)"
       } else {
         if (output) print "\tsingle"
         runners = (base[2]!="") + (base[3]!="")
         delete base[2]; delete base[3]
         if (rand() < .7) base[2] = base[1]
         else {
           base[3] = base[1]
           if (base[3]) if (output) print "\trunner takes extra base"
         }
         base[1] = who
         runs += runners
         newruns += runners
         if (runners) if (output) print "\t\t\t"runners " run(s) score(s)"
         if (!base[2]) {
           # try to steal
           den = cs[who,rl]+stb[who,rl]
           if (!den) den = 1
           if (rand() < stb[who,rl]/den && stealsituation()) {
             if (rand() < stb[who,rl]/den + .1*rand() - .1*rand()) {
               if (output) print "\tstolen base"
               if (output) print "\tstolen base ratio = "stb[who,rl]/den
               base[2] = base[1]
               delete base[1]
             } else {
               if (output) print "\tthrown out trying to steal"
               if (output) print "\tstolen base ratio = "stb[who,rl]/den
               delete base[1]
               outs++
             }
           }
         }
       }
     } else if (r < (bb[who,rl]+hits[who])/(ab[who,rl]+bb[who,rl]) || pitcharound()) {
       if (output) print "\twalk"
       newwalks++
       if (base[3] && base[2] && base[1]) {
         runs++
         newruns++
         if (output) print "\t\t\t"runners " run(s) score(s)"
         base[3] = base[2]
         base[2] = base[1]
         base[1] = who
       } else if (!base[1]) {
         base[1] = who
       } else if (!base[2]) {
         base[2] = base[1]
         base[1] = who
       } else if (!base[3]) {
         base[3] = base[2]
         base[2] = base[1]
         base[1] = who
       }
       if (!base[2]) {
         # try to steal
         den = cs[who,rl]+stb[who,rl]
         if (!den) den = 1
         if (rand() < stb[who,rl]/den && stealsituation()) {
           if (rand() < stb[who,rl]/den + .1*rand() - .1*rand()) {
             if (output) print "\tstolen base"
             if (output) print "\tstolen base ratio = "stb[who,rl]/den
             base[2] = base[1]
             delete base[1]
           } else {
             if (output) print "\tthrown out trying to steal"
             if (output) print "\tstolen base ratio = "stb[who,rl]/den
             outs++
           }
         }
       }
     } else {
       if (output) print "\tout"
       outs++
       if (outs < 3) {
         # check for sac fly
         den = ab[who,rl] - hits[who,rl]
         if (notwhiff() && (base[3]||(base[2]&&!base[3])||(base[1]&&!base[2])) && rand() < .2 + 5*sf[who,rl]/den) {
           if (base[3]) {
             delete base[3]
             runs++
             newruns++
             if (output) print "\tsacrifice fly"
             if (output) print "\t\t\t"1 " run(s) score(s)"
           }
           if (base[2] && !base[3] && rand() < .2) {
             base[3] = base[2]
             delete base[2]
             if (output) print "\trunner advances"
           }
           if (base[1] && !base[2] && rand() < .1) {
             base[2] = base[1]
             delete base[1]
             if (output) print "\trunner advances"
           }
         } else if (notwhiff() && ((base[1] && !base[2])||(base[2] && !base[3])) && rand() < 10*sb[who,rl]/den) {
           # check for sac bunt/grounder
           if (!base[3]) { base[3] = base[2]; delete base[2] }
           if (!base[2]) { base[2] = base[1]; delete base[1] }
           if (output) print "\tsacrifice bunt"
           if (output) print "\trunner(s) advance(s)"
         } else if (notwhiff() && base[1] && rand() < .5) {
           outs++
           delete base[1]
           if (output) print "\tout"
           if (output) print "\tdouble play"
           if (outs < 3 && base[3]) {
             delete base[3]
             runs++
             newruns++
             if (output) print "\t\t\t"1 " run(s) score(s)"
           }
         } else if (notwhiff() && rand() < .005 && base[1] && (base[2]||base[3]) && !outs) {
           outs = 3
           delete base
           if (output) print "\tout"
           if (output) print "\tout"
           if (output) print "\ttriple play"
         } else if (notwhiff() && rand() < .005 && base[2] && base[3] && !outs) {
           outs = 3
           delete base
           if (output) print "\tout"
           if (output) print "\tout"
           if (output) print "\ttriple play"
         }
       }
     }
     if (newhits >= 8 || newruns >= 4 || newhomers >= 3 || newwalks >= 8) {
       if (output) print "\t\t\tPITCHER CHASED!  INNING="inning
       if (!firstchase) firstchase = inning
       chasings++
       newwalks = newhits = newruns = newhomers = 0
       if (rl == "r") rl = "l"
       else rl = "r"
       if (output) print "batters adjusting to new pitcher"
       for (i=1; i<=9; i++) {
         n = player[i]
         hits[n] = b1[n,rl]+b2[n,rl]+b3[n,rl]+b4[n,rl]
         avg[n] = hits[n]/ab[n,rl]
         if (output) printf i".  "player[i]" :  \t"
         if (output) printf "%3.3f",avg[n]
         if (output) print ""
       }
     }
   }
   outs = 0
   delete base
 }
}

function notwhiff( res,den) {
 if (lastcheked == nthbatter) return lastwhiffresult
 den = ab[who,rl] - hits[who]
 if (rand() > k[who,rl]/den) res = 1
 lastchecked = nthbatter
 lastwhiffresult = res
 return res
}

function pitcharound( res,emptybase) {
 emptybase = 1
 if (base[1] && base[2] && base[3]) emptybase = 0
 if (hits[who]/ab[who,rl] > .275 && b4[who,rl]/ab[who,rl] > .08 && !base[1] && rand()<.4) res = 1
 if (hits[who]/ab[who,rl] > .275 && b4[who,rl]/(1+b1[who,rl]) > .25 && !base[1] && rand()<.2) res = 1
 if (hits[who]/ab[who,rl] > .250 && ((base[2]&&!base[1])||(base[3]&&!base[1])) && outs==1 && rand()<.5) res = 1
 if (emptybase && (bb[who,rl]+hits[who])/(ab[who,rl]+bb[who,rl]) - (bb[nextwho,rl]+hits[nextwho])/(ab[nextwho,rl]+bb[nextwho,rl]) > .200) res = 1
 if (emptybase && (bb[who,rl]+hits[who])/(ab[who,rl]+bb[who,rl]) - (bb[nextwho,rl]+hits[nextwho])/(ab[nextwho,rl]+bb[nextwho,rl]) > .150 && rand()<.4) res = 1
 if (res) if (output) print "\tpitching around batter"
 return res
}

function stealsituation() {
 if (!base[3] && !base[2] && outs==2) return 1
 if (!base[3] && !base[2] && rand() < .3) return 1
 if (rand() < .1) return 1
 return 0
}

function makebatters() {
 srand()
 for (i=1; i<=15; i++) {
   make(i)
   # printp(i,"l")
   # printp(i,"r")
   fprintp(i,"l")
   fprintp(i,"r")
 }
 close("batters")
}

func fgetp( n,w,i) {
 FS = "\t"
 while (getline < "batters") {
   n = $1; w = $2
   for (i=3; i<=NF; i++) { split($i,temp,"="); $i = temp[2] }
   ab[n,w] = $3
   b1[n,w] = $4
   b2[n,w] = $5
   b3[n,w] = $6
   b4[n,w] = $7
   bb[n,w] = $8
   sf[n,w] = $9
   sb[n,w] = $10
   k[n,w] = $11
   stb[n,w] = $12
   cs[n,w] = $13
 }
 close("batters")
}

func fprintp(n,w) {
 printf n"\t"w"\t" > "batters"
 printf "ab="ab[n,w]"\t" > "batters"
 printf "b1="b1[n,w]"\t" > "batters"
 printf "b2="b2[n,w]"\t" > "batters"
 printf "b3="b3[n,w]"\t" > "batters"
 printf "b4="b4[n,w]"\t" > "batters"
 printf "bb="bb[n,w]"\t" > "batters"
 printf "sf="sf[n,w]"\t" > "batters"
 printf "sb="sb[n,w]"\t" > "batters"
 printf "k="k[n,w]"\t" > "batters"
 printf "stb="stb[n,w]"\t" > "batters"
 printf "cs="cs[n,w] > "batters"
 print "" > "batters"
}

func printp(n,w) {
 printf n"\t"w"\t"
 printf "ab="ab[n,w]"\t"
 printf "b1="b1[n,w]"\t"
 printf "b2="b2[n,w]"\t"
 printf "b3="b3[n,w]"\t"
 printf "b4="b4[n,w]"\t"
 printf "bb="bb[n,w]"\t"
 printf "sf="sf[n,w]"\t"
 printf "sb="sb[n,w]"\t"
 printf "k="k[n,w]"\t"
 printf "stb="stb[n,w]"\t"
 printf "cs="cs[n,w]
 print ""
}



func make(n, hits,avg,totab,w,pct,outs,fanpct,bbpct,stpct) {
 stpct = .1*rand()
 if (rand() < .3) stpct += .2*rand()
 totab = int( 50*rand() + (rand()<.5)*(300 + rand()*rand()*150) ) + 10
 if (rand() < .5) ab[n,"l"] = int( (.4 + .2*rand()) * totab ) +2
 else ab[n,"l"] = int( rand() * totab )
 ab[n,"r"] = totab - ab[n,"l"]
 # let's try to have nonzero ab's for easier denominators
 if (ab[n,"r"] <= 0) ab[n,"r"] = 1
 if (ab[n,"l"] <= 0) ab[n,"l"] = 1
 w = "l"
 avg = .125 + .100*rand() + .100*rand()*rand() + (rand()<.3)*(.030+.050*rand())
 hits = int ( avg  * ab[n,w] )
 outs = ab[n,w] - hits
 #print "avg = "; printf "%3.3f",hits/ab[n,w]; print ""
 pct = .20*rand() + .12*rand()*rand() + .30*rand()*rand()*rand()
 b4[n,w] = int( hits * pct )
 hits -= b4[n,w]
 if (rand() < .2 || stpct > .2) b3[n,w] = int( .08*rand() * hits )
 else b3[n,w] = int( .02*rand() * hits )
 hits -= b3[n,w]
 b2[n,w] = int( (.1 + .3*rand()) * hits )
 b1[n,w] = hits
 #print "slg = "; printf "%3.3f",(4*b4[n,w]+3*b3[n,w]+2*b2[n,w]+b1[n,w])/ab[n,w]; print ""
 if (rand()*pct > rand()*rand()) fanpct = .25 + .1*rand()
 else fanpct = .3*rand()
 k[n,w] = int( fanpct * outs )
 if (rand() < .3) bbpct = .1*rand() + (.5-fanpct)
 else if (pct > .2) bbpct = .3+.2*rand()
 else bbpct = .3*rand()
 bb[n,w] = int( outs * bbpct )
 #print "oba = "; printf "%3.3f",(hits+bb[n,w])/(ab[n,w]+bb[n,w]); print ""
 stb[n,w] = int( (hits+bb[n,w])*stpct )
 cs[n,w] = int( rand()* stb[n,w] )
 sf[n,w] = int(.1 * (ab[n,w] - hits) * rand())
 sb[n,w] = int(.1 * (ab[n,w] - hits) * rand() * .4 )

 w = "r"
 if (rand() < .3) avg = avg + .025*rand() - .025*rand()
 else avg = .125 + .100*rand() + .100*rand()*rand() + (rand()<.3)*(.030+.050*rand())
 hits = int ( avg  * ab[n,w] )
 outs = ab[n,w] - hits
 #print "avg = "; printf "%3.3f",hits/ab[n,w]; print ""
 if (rand() < .3) pct = pct + .050*rand() - .050*rand()
 else pct = .20*rand() + .12*rand()*rand() + .30*rand()*rand()*rand()
 b4[n,w] = int( hits * pct )
 hits -= b4[n,w]
 if (rand() < .3) b3[n,w] = int( .08*rand() * hits )
 else b3[n,w] = int( .02*rand() * hits )
 hits -= b3[n,w]
 b2[n,w] = int( (.1 + .3*rand()) * hits )
 b1[n,w] = hits
 #print "slg = "; printf "%3.3f",(4*b4[n,w]+3*b3[n,w]+2*b2[n,w]+b1[n,w])/ab[n,w]; print ""
 if (rand() < .8) fanpct = fanpct + .05*rand() - .05*rand()
 else if (rand()*pct > rand()*rand()) fanpct = .25 + .1*rand()
 else fanpct = .3*rand()
 k[n,w] = int( fanpct * outs )
 if (rand() < .8) bbpct = bbpct + .05*rand() - .05*rand()
 else if (rand() < .3) bbpct = .1*rand() + (.5-fanpct)
 else if (pct > .2) bbpct = .3+.2*rand()
 else bbpct = .3*rand()
 bb[n,w] = int( outs * bbpct )
 #print "oba = "; printf "%3.3f",(hits+bb[n,w])/(ab[n,w]+bb[n,w]); print ""
 stb[n,w] = int( (.95 + .1*rand())(hits+bb[n,w])*stpct )
 cs[n,w] = int( rand()* stb[n,w] )
 sf[n,w] = int(.1 * (ab[n,w] - hits) * rand())
 sb[n,w] = int(.1 * (ab[n,w] - hits) * rand() * .4 )


 if (!ab[n,"l"] || !ab[n,"r"]) print "YES, THERE IS AN AB DENOM BUG"
}
