 BEGIN {

#Command line arguments (none).

#Internal globals:

     Total=0    # count of all instances
   # Classes    # table of class names/frequencies
   # Freg       # table of counters for values in attributes in classes
   # Seen       # table of counters for values in attributes
   # Attributes # table of number of values per attribute
   }

 Pass==1 {train()}
 Pass==2 {print $NF "," classify()}

 function train(    i,c) { 
   Total++;
   c=$NF;
   Classes[c]++;
   for(i=1;i<=NF;i++) {
     if ($i=="?") continue;
     Freq[c,i,$i]++
     if (++Seen[i,$i]==1) Attributes[i]++}
 }

 function classify(         i,temp,what,like,c) {  
   like = -100000; # smaller than any log
   for(c in Classes) {  
     temp=log(Classes[c]/Total); #uses logs to stop numeric errors
     for(i=1;i<NF;i++) {  
       if ( $i=="?" ) continue;
       temp += log((Freq[c,i,$i]+1)/(Classes[c]+Attributes[i]));
     };
     if ( temp >= like ) {like = temp; what=c}
   };
   return what;
 }
