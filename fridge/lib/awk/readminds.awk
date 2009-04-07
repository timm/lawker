#.h1 Mind-Reading Machine
#.h2 Synposis
#.P gawk -f readminds.awk 
#.P (then type "h" or "t").
#.h2 Download
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/readminds.awk LAWKER.
#.H2 Description
#.H3 Theory
#.P
#Shannon's 1953 memo, A Mind-Reading(?) Machine, describes a machine built out of relays at Bell Labs.
#.UL
  #  This machine is a somewhat simplified model of a machine designed by D.W. Hagelbarger. It plays what is essentially the old game of matching pennies or "odds and evens". This games has been discussed from the game theoretic angle by von Neumann and Morgenstern, and from the psychological point of view by Edgar Allen Poe in "The Purloined Letter". Oddly enough, the machine is aimed more nearly at Poe's method of play than von Neumann's. 
#./ul
#.P
#The machine took advantage of the difficulty of generating truly random behavior in wetware by using a small (8-state) markov model to predict its human opponents. 
#.H3 Practice
#.P
#We implement a 1970's version of this 1950's algorithm, using AWK instead of mechanical relays.
#.P
O#ur markov model is based on behavior over the last two rounds, with hpa and hpb recording the history of the player's plays, and hca and hcb recording the history of the computer's guesses. The possible cases are: the player won or lost two rounds ago, changed plays or stayed with the same play, and won or lost the last round, for a total of 23 = 8 histories, with any bias towards changing or staying in the upcoming round kept in the tally array.
#.P
#If the player has repeated their behavior for a given history at least twice, we guess according to their predicted behavior. After the first observation, we guess with a 75%/25%, split, weighted towards the bias. If the player hasn't shown any bias (or during the first two rounds of the game), we guess at hazard. 
#.H2 Code
#.H3 Begin
#.PRE
BEGIN	{
 print "+---------------------------------------------------------+"
 print "| An AWKward mind-reading machine                         |"
 print "|         (this retrogame inspired by the Bell Labs Memo: |"
 print "|          Shannon, 1953, 'A Mind-Reading (?) Machine')   |"
 print "+---------------------------------------------------------+"
 print "Shall we play a game?"
 print "Tell me either 'heads' or 'tails'."
 print "If I guess what you picked, I win.  Otherwise, you win."
 print "The match goes for 100 rounds, or someone gets 20."
 printf "your play? "
}
#</pre>
#.h3 set seed
#.pre
BEGIN	{ "date +%s" | getline seed; srand(seed) }
#</pre>
#.h3 consult model
#.pre
BEGIN	{ t = 0 }
NR > 2	{
	case = (hpa!=hca)"/"(hpa!=hpb)"/"(hpb!=hcb)
	t = tally[case]
	}

t < -1	{ guess=!hpb }
t == -1 { guess=(int(rand()+.75)?!hpb:hpb) }
t == 0	{ guess=int(rand()+.5) }
t == 1  { guess=(int(rand()+.75)?hpb:!hpb) }
t > 1	{ guess= hpb }

#</pre>
#.h3 get input
#.pre
/^[hH]/		{ play=1 }
/^[tT]/		{ play=0 }
/^[^hHtT]/	{ printf "heads or tails? "; next }
#</pre>
#.h3 report results
#<p>We also report the results of the round to the player (in case they wish to update their internal models). En passant, we update pw and cw, the number of player (resp. computer) wins.
#<pre>
	{
	printf "You played " (play?"heads":"tails")
	printf "; I guessed " (guess?"heads":"tails")
	printf ".  "(play==guess?"I":"You")" win. "
	print "("(pw+=(play!=guess))"-"(cw+=(play==guess))")"
	}
#</pre>
#.h3 update model
#<p>After finishing a round, we update the history with the results, including updating tally according to the player's behavior. Again, we wait for two rounds before touching the tally counters, at which point the history will have been fully initialized.
#<pre>
NR > 2	{ tally[case] += (hpb == play ? 1 : -1) }
	{
	hpa = hpb; hpb = play
	hca = hcb; hcb = guess
	}
#</pre>
#.h3 check for victory
#<p>At the end of each round, if we haven't met a victory 
#condition, we prompt for the next round.
#<pre>
cw+pw==100	{ printf (cw>pw?"I":"You")" won the match "
		  print  "by "(cw>pw?cw-pw:pw-cw)" games."
		  exit }
pw-cw==20	{ print "You win -- up by 20"; exit }
cw-pw==20	{ print "I win -- up by 20"; exit }
		{ printf "? " }

#</pre>
#.h3 end 
#.pre
END	{ 
	print " T H A N K   Y O U   F O R   P L A Y I N G "
	}
#./PRE
#.H2 Copyright
#.P
# Copyright (c) 2009 the authors listed at the following URL, and/or
# the authors of referenced articles or incorporated external code:
# http://en.literateprograms.org/Mind_reading_machine_(AWK)?action=history&offset=20070207160312
#.P
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#.P 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
