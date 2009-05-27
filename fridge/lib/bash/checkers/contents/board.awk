### This Awk program using GNU extensions provides a simple
 # checkerboard for two commands to play against eachother
 # by simply passing moves back and forth.  The players must
 # know how to start by being given a '1' or '2' as a
 # command-line argument.  Black is assumed to play first.
 #
 # Like a real checkerboard, the rules are enforced by the
 # players and not by the board itself.  This program 
 # is not a referee.
 #
 # CopyLeft 2004, 2005 Aaron Hawley
 ##

BEGIN {
  # player1 = "./player1"; # command-line argument (-v player1=)
  # player2 = "./player2"; # command-line argument (-v player2=)
  player1black = player1 " 1"; #play first
  player2white = player2 " 2"; #play second
  n_plays = 0;
  do {
    player1black |& getline play1;
    print play1 " # play by black (" player1 ")";
    print play1 |& player2white;
    n_plays++;
    player2white |& getline play2;
    print play2 " # play by white (" player1 ")";
    print play2 |& player1black;
    n_plays++;
  } while (play1 != "" && play1 > 0 \
	   && play2 != "" && play2 > 0);
  close(player1black);
  close(player2white);
  print "Number of plays: " n_plays;
}

## TODO: check return values of programs on each turn.

