#.H1 Eliza
#.H2 Synopsis
#.P gawk -f eliza.awk
#.H2 Download
#.P Download from <a href="http://lawker.googlecode.com/svn/fridge/lib/awk/eliza.awk">LAWKER</a>.
#.H2 Description
#.P
#.EM From Wikipedia:
#ELIZA was a computer program and an early example of (by modern standards) primitive natural language processing. ELIZA operated by processing users' responses to scripts, the most famous of which was DOCTOR, a simulation of a Rogerian psychotherapist. In this mode, ELIZA mostly rephrased the user's statements as questions and posed those to the 'patient.' ELIZA was written by Joseph Weizenbaum between 1964 to 1966.
#.H3 Example dialogue
#.PRE
#This is a Gawk implementation of the famous ELIZA program by Joseph Weizenbaum.
#To end, type SHUT UP
#
#HI, IM ELIZA, TELL ME YOUR PROBLEM
#I hate dogs
#CAN YOU ELABORATE ON THAT ?
#Dogs remind me of Mylie Cyrus
#CAN YOU ELABORATE ON THAT ?
#You're kidding, right? Mylie Cyrus is one of the biggest stars on the planet
#WHAT MAKES YOU THINK I AM KIDDING, RIGHT? MYLIE CYRUS IS ONE OF THE BIGGEST STARS ON THE PLANET ?
#Cause you did not know about Mylie
#WE WERE DISCUSSING YOU -- NOT ME
#No,  I was discussing Mylie
#Oh, I ID NOT KNOW ABOUT MYLIE
#Well aren't you stupid
#Oh, I TUPID
#can you get her number?
#WE WERE DISCUSSING YOU -- NOT ME
#sorry
#PLEASE DON'T APOLOGIZE !
#but you sound so angry
#YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU ?
#i think you are  a robot
#Oh, I RE  A ROBOT
#yes
#I UNDERSTAND
#no you don't
#YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU ?
#hey- is this eliza?
#WHAT'S ABOUT ME ?
#I want to take you to dinner
#YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU ?
#I feel you are really stupid
#WE WERE DISCUSSING YOU -- NOT ME
#SHUT UP
#WELL, PLEASE PAY YOUR BILL. ITS EXACTLY ... $101
#./PRE
#.H2 Code
#.H3 Set up
#.PRE
BEGIN {
	SetUpEliza() 
	print "This is a Gawk implementation of the "\
          "famous ELIZA program by Joseph Weizenbaum. "\
	      "To end, type SHUT UP\n";
	print ElizaSays("");
}
{ print ElizaSays($0) }
#./PRE
#.H3 ElizaSays
#.PRE 
function ElizaSays(YouSay) {
 if (YouSay == "") {
   cost = 0
   answer = "HI, IM ELIZA, TELL ME YOUR PROBLEM"
 } else {
   q = toupper(YouSay)
   gsub("'", "", q)
   if(q == qold) {
     answer = "PLEASE DONT REPEAT YOURSELF !"
   } else {
     if (index(q, "SHUT UP") > 0) {
       answer = "WELL, PLEASE PAY YOUR BILL. ITS EXACTLY ... $"\
                int(100*rand()+30+cost/100)
		1;
     } else {
       qold = q
       w = "-"                 # no keyword recognized yet
       for (i in k) {          # search for keywords
         if (index(q, i) > 0) {
           w = i
           break
         }
       }
       if (w == "-") {         # no keyword, take old subject
         w    = wold
         subj = subjold
       } else {                # find subject
         subj = substr(q, index(q, w) + length(w)+1)
         wold = w
         subjold = subj        #  remember keyword and subject
       }
       for (i in conj)
          gsub(i, conj[i], q)   # conjugation
       # from all answers to this keyword, select one randomly
       answer = r[indices[int(split(k[w], indices) * rand()) + 1]]
       # insert subject into answer
       gsub("_", subj, answer)
     }
   }
 }
 cost += length(answer) # for later payment : 1 cent per character
 return answer
}
#./PRE
#.H3 SetUpEliza
#.PRE
function SetUpEliza() {
 srand()
 wold = "-"
 subjold = " "

 # table for conjugation
 conj[" ARE "     ] = " AM "
 conj["WERE "     ] = "WAS "
 conj[" YOU "     ] = " I "
 conj["YOUR "     ] = "MY "
 conj[" IVE "     ] =\
 conj[" I HAVE "  ] = " YOU HAVE "
 conj[" YOUVE "   ] =\
 conj[" YOU HAVE "] = " I HAVE "
 conj[" IM "      ] =\
 conj[" I AM "    ] = " YOU ARE "
 conj[" YOURE "   ] =\
 conj[" YOU ARE " ] = " I AM "

 # table of all answers
 r[1]   = "DONT YOU BELIEVE THAT I CAN  _"
 r[2]   = "PERHAPS YOU WOULD LIKE TO BE ABLE TO _ ?"
 r[3]   = "YOU WANT ME TO BE ABLE TO _ ?"
 r[4]   = "PERHAPS YOU DONT WANT TO _ "
 r[5]   = "DO YOU WANT TO BE ABLE TO _ ?"
 r[6]   = "WHAT MAKES YOU THINK I AM _ ?"
 r[7]   = "DOES IT PLEASE YOU TO BELIEVE I AM _ ?"
 r[8]   = "PERHAPS YOU WOULD LIKE TO BE _ ?"
 r[9]   = "DO YOU SOMETIMES WISH YOU WERE _ ?"
 r[10]  = "DONT YOU REALLY _ ?"
 r[11]  = "WHY DONT YOU _ ?"
 r[12]  = "DO YOU WISH TO BE ABLE TO _ ?"
 r[13]  = "DOES THAT TROUBLE YOU ?"
 r[14]  = "TELL ME MORE ABOUT SUCH FEELINGS"
 r[15]  = "DO YOU OFTEN FEEL _ ?"
 r[16]  = "DO YOU ENJOY FEELING _ ?"
 r[17]  = "DO YOU REALLY BELIEVE I DONT _ ?"
 r[18]  = "PERHAPS IN GOOD TIME I WILL _ "
 r[19]  = "DO YOU WANT ME TO _ ?"
 r[20]  = "DO YOU THINK YOU SHOULD BE ABLE TO _ ?"
 r[21]  = "WHY CANT YOU _ ?"
 r[22]  = "WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM _ ?"
 r[23]  = "WOULD YOU PREFER IF I WERE NOT _ ?"
 r[24]  = "PERHAPS IN YOUR FANTASIES I AM _ "
 r[25]  = "HOW DO YOU KNOW YOU CANT _ ?"
 r[26]  = "HAVE YOU TRIED ?"
 r[27]  = "PERHAPS YOU CAN NOW _ "
 r[28]  = "DID YOU COME TO ME BECAUSE YOU ARE _ ?"
 r[29]  = "HOW LONG HAVE YOU BEEN _ ?"
 r[30]  = "DO YOU BELIEVE ITS NORMAL TO BE _ ?"
 r[31]  = "DO YOU ENJOY BEING _ ?"
 r[32]  = "WE WERE DISCUSSING YOU -- NOT ME"
 r[33]  = "Oh, I _"
 r[34]  = "YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU ?"
 r[35]  = "WHAT WOULD IT MEAN TO YOU, IF YOU GOT _ ?"
 r[36]  = "WHY DO YOU WANT _ ?"
 r[37]  = "SUPPOSE YOU SOON GOT _"
 r[38]  = "WHAT IF YOU NEVER GOT _ ?"
 r[39]  = "I SOMETIMES ALSO WANT _"
 r[40]  = "WHY DO YOU ASK ?"
 r[41]  = "DOES THAT QUESTION INTEREST YOU ?"
 r[42]  = "WHAT ANSWER WOULD PLEASE YOU THE MOST ?"
 r[43]  = "WHAT DO YOU THINK ?"
 r[44]  = "ARE SUCH QUESTIONS IN YOUR MIND OFTEN ?"
 r[45]  = "WHAT IS IT THAT YOU REALLY WANT TO KNOW ?"
 r[46]  = "HAVE YOU ASKED ANYONE ELSE ?"
 r[47]  = "HAVE YOU ASKED SUCH QUESTIONS BEFORE ?"
 r[48]  = "WHAT ELSE COMES TO MIND WHEN YOU ASK THAT ?"
 r[49]  = "NAMES DON'T INTEREST ME"
 r[50]  = "I DONT CARE ABOUT NAMES -- PLEASE GO ON"
 r[51]  = "IS THAT THE REAL REASON ?"
 r[52]  = "DONT ANY OTHER REASONS COME TO MIND ?"
 r[53]  = "DOES THAT REASON EXPLAIN ANYTHING ELSE ?"
 r[54]  = "WHAT OTHER REASONS MIGHT THERE BE ?"
 r[55]  = "PLEASE DON'T APOLOGIZE !"
 r[56]  = "APOLOGIES ARE NOT NECESSARY"
 r[57]  = "WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE ?"
 r[58]  = "DON'T BE SO DEFENSIVE"
 r[59]  = "WHAT DOES THAT DREAM SUGGEST TO YOU ?"
 r[60]  = "DO YOU DREAM OFTEN ?"
 r[61]  = "WHAT PERSONS APPEAR IN YOUR DREAMS ?"
 r[62]  = "ARE YOU DISTURBED BY YOUR DREAMS ?"
 r[63]  = "HOW DO YOU DO ... PLEASE STATE YOUR PROBLEM"
 r[64]  = "YOU DON'T SEEM QUITE CERTAIN"
 r[65]  = "WHY THE UNCERTAIN TONE ?"
 r[66]  = "CAN'T YOU BE MORE POSITIVE ?"
 r[67]  = "YOU AREN'T SURE ?"
 r[68]  = "DON'T YOU KNOW ?"
 r[69]  = "WHY NO _ ?"
 r[70]  = "DON'T SAY NO, IT'S ALWAYS SO NEGATIVE"
 r[71]  = "WHY NOT ?"
 r[72]  = "ARE YOU SURE ?"
 r[73]  = "WHY NO ?"
 r[74]  = "WHY ARE YOU CONCERNED ABOUT MY _ ?"
 r[75]  = "WHAT ABOUT YOUR OWN _ ?"
 r[76]  = "CAN'T YOU THINK ABOUT A SPECIFIC EXAMPLE ?"
 r[77]  = "WHEN ?"
 r[78]  = "WHAT ARE YOU THINKING OF ?"
 r[79]  = "REALLY, ALWAYS ?"
 r[80]  = "DO YOU REALLY THINK SO ?"
 r[81]  = "BUT YOU ARE NOT SURE YOU _ "
 r[82]  = "DO YOU DOUBT YOU _ ?"
 r[83]  = "IN WHAT WAY ?"
 r[84]  = "WHAT RESEMBLANCE DO YOU SEE ?"
 r[85]  = "WHAT DOES THE SIMILARITY SUGGEST TO YOU ?"
 r[86]  = "WHAT OTHER CONNECTION DO YOU SEE ?"
 r[87]  = "COULD THERE REALLY BE SOME CONNECTIONS ?"
 r[88]  = "HOW ?"
 r[89]  = "YOU SEEM QUITE POSITIVE"
 r[90]  = "ARE YOU SURE ?"
 r[91]  = "I SEE"
 r[92]  = "I UNDERSTAND"
 r[93]  = "WHY DO YOU BRING UP THE TOPIC OF FRIENDS ?"
 r[94]  = "DO YOUR FRIENDS WORRY YOU ?"
 r[95]  = "DO YOUR FRIENDS PICK ON YOU ?"
 r[96]  = "ARE YOU SURE YOU HAVE ANY FRIENDS ?"
 r[97]  = "DO YOU IMPOSE ON YOUR FRIENDS ?"
 r[98]  = "PERHAPS YOUR LOVE FOR FRIENDS WORRIES YOU"
 r[99]  = "DO COMPUTERS WORRY YOU ?"
 r[100] = "ARE YOU TALKING ABOUT ME IN PARTICULAR ?"
 r[101] = "ARE YOU FRIGHTENED BY MACHINES ?"
 r[102] = "WHY DO YOU MENTION COMPUTERS ?"
 r[103] = "WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEMS ?"
 r[104] = "DON'T YOU THINK COMPUTERS CAN HELP PEOPLE ?"
 r[105] = "WHAT IS IT ABOUT MACHINES THAT WORRIES YOU ?"
 r[106] = "SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS ?"
 r[107] = "WHAT DOES THAT SUGGEST TO YOU ?"
 r[108] = "I SEE"
 r[109] = "IM NOT SURE I UNDERSTAND YOU FULLY"
 r[110] = "COME COME ELUCIDATE YOUR THOUGHTS"
 r[111] = "CAN YOU ELABORATE ON THAT ?"
 r[112] = "THAT IS QUITE INTERESTING"
 r[113] = "WHY DO YOU HAVE PROBLEMS WITH MONEY ?"
 r[114] = "DO YOU THINK MONEY IS EVERYTHING ?"
 r[115] = "ARE YOU SURE THAT MONEY IS THE PROBLEM ?"
 r[116] = "I THINK WE WANT TO TALK ABOUT YOU, NOT ABOUT ME"
 r[117] = "WHAT'S ABOUT ME ?"
 r[118] = "WHY DO YOU ALWAYS BRING UP MY NAME ?"
 # table for looking up answers that
 # fit to a certain keyword
 k["CAN YOU"]      = "1 2 3"
 k["CAN I"]        = "4 5"
 k["YOU ARE"]      =\
 k["YOURE"]        = "6 7 8 9"
 k["I DONT"]       = "10 11 12 13"
 k["I FEEL"]       = "14 15 16"
 k["WHY DONT YOU"] = "17 18 19"
 k["WHY CANT I"]   = "20 21"
 k["ARE YOU"]      = "22 23 24"
 k["I CANT"]       = "25 26 27"
 k["I AM"]         =\
 k["IM "]          = "28 29 30 31"
 k["YOU "]         = "32 33 34"
 k["I WANT"]       = "35 36 37 38 39"
 k["WHAT"]         =\
 k["HOW"]          =\
 k["WHO"]          =\
 k["WHERE"]        =\
 k["WHEN"]         =\
 k["WHY"]          = "40 41 42 43 44 45 46 47 48"
 k["NAME"]         = "49 50"
 k["CAUSE"]        = "51 52 53 54"
 k["SORRY"]        = "55 56 57 58"
 k["DREAM"]        = "59 60 61 62"
 k["HELLO"]        =\
 k["HI "]          = "63"
 k["MAYBE"]        = "64 65 66 67 68"
 k[" NO "]         = "69 70 71 72 73"
 k["YOUR"]         = "74 75"
 k["ALWAYS"]       = "76 77 78 79"
 k["THINK"]        = "80 81 82"
 k["LIKE"]         = "83 84 85 86 87 88 89"
 k["YES"]          = "90 91 92"
 k["FRIEND"]       = "93 94 95 96 97 98"
 k["COMPUTER"]     = "99 100 101 102 103 104 105"
 k["-"]            = "106 107 108 109 110 111 112"
 k["MONEY"]        = "113 114 115"
 k["ELIZA"]        = "116 117 118"
}
#./PRE
#.H2 Author
#.P Arnold Robbins 
