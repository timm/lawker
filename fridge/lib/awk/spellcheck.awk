#.H1 spellcheck.awk
#.P
#(For the original version of this code, see <a href="http://feedback.exalead.com/feedbacks/191466-spell-checking">http://feedback.exalead.com/feedbacks/191466-spell-checking</a>.)
#.P
# Peter Norvig of Google describes "How to Write a Spelling Corrector" at 
#<a href="http://norvig.com/spell-correct.html">http://norvig.com/spell-correct.html</a>.
# He gave a python solution, and points to a number of other implementations
# I saw one was missing for awk/gawk, so here it is
# it uses the "big.txt" file found at 
#<a href="http://norvig.com/big.txt">http://norvig.com/big.txt</a>.
#.SMALL
#.PRE
function words(text) { 
   while (getline line < text ) { 
      line=tolower(line) ;
   while (match(line,/[a-z]+/)) { 
      NWORDS[substr(line,RSTART,RLENGTH)]++ ; 
      line=substr(line,RSTART+RLENGTH) }}
}
BEGIN { words("big.txt"); } 

BEGIN { alph="abcdefghijklmnopqrstuvwxyz"; 
      for(i=1;i<=26;i++) 
         alphabet[substr(alph,i,1)]++ }

function edits1 (word,set) {
   n = length(word); 
   delete set;
   for (i=1;i<=n+1;i++) {
    if(i<=n) # deletion 
      set[substr(word,1,i-1)""substr(word,i+1)]++; 
    if(i<n)  # transposition
     set[substr(word,1,i-1)""substr(word,i+1,1)""substr(word,i,1)""substr(word,i+2)]++; 
    if(i<=n) 
      for (c in alphabet)  # alteration
         set[substr(word,1,i-1)""c""substr(word,i+1)]++; 
      for (c in alphabet) # insertion
         set[substr(word,1,i-1)""c""substr(word,i)]++; } 
}
function known_edits2(oneChange,twoChanges) { 
   delete twoChanges;
   for (e2 in oneChange) { 
      edits1(e2,set); 
      known(set,goods) ; 
      for (w in goods) { 
         twoChanges[w]=goods[w]}} 
}
function known(words,knowntable) { 
   delete knowntable; 
   found=0;
   for (w in words) 
      if(w in NWORDS) {
         found++; 
         knowntable[w]=NWORDS[w] }
   return (found) 
}
function maxtable(tab) { 
   maxval=0; 
   for(i in tab) { 
      if(tab[i]>maxval) {
         maxval=tab[i]; 
         max=i}} 
   return(max)
}
function correct(word) { 
   delete candidates; 
   candidates[word]=1;
   if( known(candidates,good) ) { }
   else {    edits1(word, candidates); 
         if ( known(candidates,good) ) { }
   else { known_edits2(candidates,candidates2); 
         if ( known(candidates2,good) ) { }
   else {    delete good; 
         good[word]=1;}}}
   print maxtable(good);
}
#./PRE
#./SMALL
# correct, one word per line
#.PRE
{ gsub(" ",""); 
  correct(tolower($0)) }
#./PRE
#.H2 Author
#.P  Gregory Grefenstette, Nov 24, 2008
