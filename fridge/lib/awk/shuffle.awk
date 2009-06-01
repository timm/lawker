#.H1 shuffle.awk
#.H2 Synopsis
#.P To rearrange the items in the input list:
#.PRE
# nshuffle(Array)
#./PRE
#.P To rearrange the items in a copy of the input list:
#.PRE
# shuffle(Array,Copy)
#./PRE
#.P 
#The above calls assumes that array item zero stores the length of the array.
#If this is not the case, use:
#.PRE
# shuffles(Array,Copy)
#./PRE
#.H2 Download
#.P Download from <a href="http://lawker.googlecode.com/svn/fridge/lib/awk/shuffle.awk">LAWKER</a>.
#.H2 Description
#.P
#Suppose we want to shuffle items  an array into
# a random order. This shuffle sort do so in linear
#time and memory.
#.P
#The algorithm comes from the dawn of computer time but
#I first heard of it from Bart Massey (at Portland State). Thank Bart for the 
#clarity of the explanation and blame me for any silliness in the
#implementation.
#
#.H3 The Slow Way
#
#.P
#A simple way to shuffle an input array of elements is to:
#
#.UL
#.LI Allocate an output array of the same size. 
#.LI Copy items selected at random from the input to the output array. 
#.LI Compact the input array by sliding the first part of the array down to fill the hole left by the removed item.
#./UL
#.P
#This
#algorithm is clearly correct.  However, the algorithm
#requires time quadratic in the size of the list, and 2x
#space.
#
#.H3 The Better Way
#
#.P
#We can easily reduce the time complexity to O(N).
#The only thing done with the input array is to
#select random elements from it, the order of the elements
#in it is irrelevant.  Therefore, instead of closing the
#hole left by a removed element by shifting elements,
#we'll close it by moving the first remaining element of the
#input array to fill the gap.
#
#.P
#Note an important invariant of the algorithm: 
#
#.PRE
#   the number of elements left in the input array 
# + the number of elements in the output array 
# ------------------------------------------------
# = the number of elements initially passed in.  
#./PRE
#
#
#.P
#This means that once an element is
#removed from the input array and the hole filled, there is
#a fresh hole created right at the beginning of the input
#array.  Let us put the newly removed element in that hole.
#Now we can dispense with the output array altogether, and
#just return the input array.  Now the space complexity is
#just x+1.
#
#.H2 Code
#.P This code assumes that the array "a" stores its size at "a[0]".
#.PRE
function nshuffle(a,  i,j,n,tmp) {
  n=a[0]; # a has items at 1...n
  for(i=1;i<=n;i++) {
    j=i+round(rand()*(n-i));
    tmp=a[j];
    a[j]=a[i];
    a[i]=tmp;
  };
  return n;
}
function round(x) { return int(x + 0.5) }
#./PRE
#.P
#<EM>nshuffle</EM> is fast, but rearranges the order of 
#items in the original list.
#<EM>shuffle</EM> generates a new
#copy of the list with the items in a random order.
#.PRE
function shuffle(a,b) {
  for(i in a) b[i]=a[i];
  nshuffle(b);
}
#./PRE
#.P
#<EM>nshuffle</EM> also assumes that the list is stores the list size
#at position zero. If this is not the case, use <EM>shuffles</EM>.
#.PRE
function shuffles(a,b,   c,n) {
  for(i in a) {n++; c[i]=a[i]};
  c[0]=n;
  shuffle(c,b);
}
#./PRE
#.H2  Correctness proof
#.P
#By number of loop iterations 
#<DL>
#<DT>
#Base case:</DT><DD>
#When i = 0 
#the 0 array elements in a below i form a
#shuffled list of 0 elements.  All remaining elements are
#candidates for append. </DD>
#<DT>
#Inductive case:</DT><DD>
#Assume that i = k 
#and that the sequence of elements in a below k are a random
#subsequence of the input values of length k.  Now 
#every
#possible remaining candidate is equally likely to occur at
#position k in this iteration.  Thus 
#at the end of the
#iteration 
#i = k + 1 
#and the sequence of elements in a
#below k + 1 are a random subsequence of the input values of
#length k + 1.</DD></DL>
#
#
#.H2 Examples
#
#.H3  Random orders
#
#.P
#One way to use the above is to run down a list in a random order. For example:
#
#.PRE
BEGIN {
  if (ShuffleDemo) {
  		if (Seed) { srand(Seed) } else { srand() };
  		s2i(ShuffleDemo,L1," ");
  		shuffles(L1,L2);
  		while(Item =pop(L2)) print Item;
  }
}
function s2i(str,a,sep,   n,i,tmp) {
  n=split(str,tmp,sep);
  for(i=1;i<=n;i++) a[i]=tmp[i];
  return n;
}
function pop(a,   x,i) {
  i=a[0]--;  
  if (!i) {return ""} else {x=a[i]; delete a[i]; return x}
} 
#./PRE
#
#.P
#The above can be run using 
#
#.PRE
# gawk -f shuffle.awk  -v ShuffleDemo="aa bb cc dd"
#./PRe
#
#.P
#If you run this twice, you'll see two different orderings. Here's one:
#
#.PRE
# cc
# aa
# dd
# bb
#./PRE
#
#.P
#And here's another:
#
#.PRE
# dd
# bb
# cc
# aa
#./PRE
#
#.H3 Fast sampling
#
#.P
#If you are generating the above lists very quickly, then be aware that
#<EM>srand()</EM> initializes its random number generator using CPU time in <EM>seconds</EM>.
#So, if you are calling the above command line many times per second, you can
#get repeated outputs. 
#
#.P
#The fix is to supply a seed from the Bash <EM>$RANDOM</EM> variable:
#
#.PRE
# gawk -f shuffle.awk -v ShuffleDemo="aa bb cc dd" -v Seed=$RANDOM
#./PRE
#
#.P
#Since <EM>$RANDOM</EM>  updates
#much faster than once a second, the above call will generate (far) fewer repeats.
#
#.H3 Repeats
#
#.P
#If you want to repeat some prior run (say, during debugging),
#set the <EM>Seed</EM> variable on the
#command line using (e.g.) 
#
#.PRE
# gawk -f shuffle.awk -v ShuffleDemo="aa bb cc dd" -v Seed=23
#./PRE
#
#.P
#This will always print out the same ordering.
