#use options.awk
#uses array.awk

BEGIN {N=0 # number of instances
	   M=1 # laplace estimator
	   K=2 # 
	   array(H) # array of hypotheises
 }
 function train(   i) {
   Instances++
   if (++H[$Klass]==1) Klasses++
   for(i=1;i<=Attr;i++)
     if (i != Klass)
      if ($i !~ /\?/)
   		Count[klass,col,value]++;
 } 
 function likelihood(l,         klass,i,inc,temp,prior,what,like) {
   like = -10000000000;    # smaller than any log
   for(klass in H) {
      prior=(H[klass]+K)/(Instances + (K*Klasses));
      temp= log(prior)
      for(i=1;i<=Attr;i++) {
         if (i != Klass)
            if ( $i !~ /\?/ )
                temp += log((Count[klass,i,$i]+M*prior)/(H[klass]+M))
      }
      l[klass]= temp
      if ( temp >= like ) {like = temp; what=klass}
   }
   return what
}

