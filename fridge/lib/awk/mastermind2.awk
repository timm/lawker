#.H1 Mastermind2.awk
#.H2 Synopsis
#.P gawk -f mastermind2.awk [breaker]
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/mastermind2.awk LAWKER.
#.H2 Description
#.P This is an nteractive play against the evil computer mastermind game.
#.P
#The game showing the recursive power of the awk language.
#It also demonstrates a winning technique for the game mastermind.
#.P
#The game has two roles, breaker and maker of mastermind codes.
#A 5 digit 0 to 9 per digit code must be broken.
#The maker responds with one + for every correct digit,position guess
#and a - for every correct digit in the wrong position in the code.
#A code breaker (human or this program) must use those clues to determine
#the code. A score is kept, low score wins.
#.h2 Example
#.P In the following example, the goal is "12345".
#.PRE
#gawik -f mastermind2.awk  br
#I'll start, I'll break your code, you respond with +-
#my guess #1 12413 ++--
#my guess #2 12531 ++--
#my guess #3 13211 +--
#my guess #4 14523 +----
#my guess #5 15432 +----
#my guess #6 12345 +++++
#./PRE
#.H2 Code
BEGIN{ 
	srand();  
	if (index(ARGV[1],"br")) {
		print "I'll start, I'll break your code, you respond with +-"
		ARGV[1] = ""
		mscore += breaker(randguess())
	}
	do {
		printscore()
		print "Guess my code 5 digits 0 to 9"
		yscore += maker(randguess())
		printscore()
		print "I'll break your code, you respond with +-"
		mscore += breaker(randguess())
	} while (1)
}
END{ 
	printscore()
}
function printscore() {
	print("\nlow score wins! my score =", mscore, "yours =", yscore)
}
function randguess() {
	return incr(int((10*10*10*10*10)*rand()))
}
function smudge(ins,n,ch) {
	return substr(ins, 1, n-1) ch substr(ins, n+1)
}
function grade(val, guess, 	i, rtn, t){ 
# return + for exact hits, - for "close" for all 5 digits
	for (i = 1;i < 6; i++) {
		if (substr(val, i, 1) == substr(guess, i, 1)) {
			#exact match
			rtn = rtn "+"
			val = smudge(val, i, "x");
			guess = smudge(guess, i, "y");
			#print i, val, guess, rtn
		}
	}
	for (i = 1;i < 6; i++) {
		t = index(val, substr(guess, i, 1))
		if (t) {
			rtn = rtn "-"
			val = smudge(val, t, "u")
			guess = smudge(guess, i, "v");
			#print t, i, val, guess, rtn
		}
	}
	return rtn
}
#passed guess and old guess array
#A good guess matches all previous scores with the new guess
function checkguess(g, oldg,	i,score) {
	#print "guess " g
	for (i in oldg) {
		if (g == i) return 2 #bad, repeated guess
		if (grade(g,i) != oldg[i]) return 1 #reject this guess
	}
	return 0 #success, this is an ok guess
}
function incr(old,	new) {
	new = sprintf("%05d",old + 1)
	#print "old new", old, new
	return substr(new, length(new) -4)
}
function alignres(res, 	tem) {
	for (i=1;i<=length(res);i++) {
		if (substr(res, i, 1) == "+") tem = "+" tem
		else tem = tem "-"
	}
	#print "alignres ",res, tem
	return tem
}
function breaker(g1,	guess, res, hisinput, tries){
	guess = g1
	do {
		printf("my guess #%d %s ", ++tries, guess)
		do {
			if (getline hisinput <= 0) {
				print "whoa, some error, giving up"
				exit
			}
			if (!match(hisinput, /^[-+]*$/)) {
				print "invalid response, use only +-"
			}
		} while (RSTART == 0)
		hisinput = alignres(hisinput)
		res[guess] = hisinput
		#print "hisinput ", hisinput, res[guess]
		#for (i in res) print "res[" i "]=" res[i]
		if (res[guess] == "+++++") return tries
		# make another guess
		do {
			guess = incr(guess)
			r = checkguess(guess, res)
		} while (r == 1)
	} while (g1 != guess)
	print "you must have made a mistake, no answer is possible"
	exit
}
function maker(original,	his, tries)
{ 
	#print original," cheater!"
	do {
		if (getline his <= 0) {
			print "whoa, some error, giving up"
			exit
		}
		res = grade(original, his)
		print "try " ++tries " results",res
		if (res == "+++++") return tries
	} while (1)
}
#.H2 See Also
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/mastermind.awk mastermind.awk.
#.H2 Author
#.P Steve Calfee, USA.
