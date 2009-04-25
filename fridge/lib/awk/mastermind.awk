#.H1 mastermind.awk
#.H2 Synopsis
#.P gawk -f mastermind.awk
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/mastermind.awk LAWKER.
#.H2 Description
#.P
# The aim of the game is to guess 4 numbers from 0,1,2,3,4,5,6,7,8,9.
# A "hit" is the right number  in the right position and a "blow"
# is the right number in a wrong position.
#.P
#You lose the game if you fail to guess after 10 rounds.
#.H2 Example
#.PRE
# +++  Hit & Blow  +++   <Push Enter>
#
#[ 1] >> 1234
#              ##  1 Hit  2 Blow
#[ 2] >> 1256
#              ##  1 Hit  1 Blow
#[ 3] >> 1789
#              ##  1 Hit  0 Blow
#[ 4] >> 1243 
#              ##  1 Hit  2 Blow
#[ 5] >> 1340
#              ##  3 Hit  0 Blow
#[ 6] >> 1320
#
#  Congratulations !!  (1320)
#./PRE
#.H2 Code
#.PRE
BEGIN{ 
	srand();  
	c=1;  
	print "\n\n +++  Hit & Blow  +++   <Push Enter>\n";
	q[z=p=int(9*rand())+1]=1;  
	for(i=2; i<=4;) 
		if(q[p=int(10*rand())]<1){ 
			q[p]=i++;  
			z=z*10+p; }
}
{ if((n=int($0+0))>=1023 && n<=9876) { 
		++c;
   		v=0;  
		for(i=4; i>0; n=int(n/10)) 
			v+=(q[p=n%10]==i--)?10:(q[p]>0)?1:0;
    			if	(v==40) exit; 
				else printf("%16s %2d Hit %2d Blow\n", "##", v/10, v%10);
 	}
 	if	(c>10) exit; 
	else printf("[%2d] >> ", c);
}
END{ 
	printf("\n  %s  (%d)\n", (v==40)?"Congratulations !!":"Over times", z); 
}
#./PRE
#.H2 Author
#.P The author's name is YSA.
