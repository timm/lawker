#use trim.awk

function s2a(str,a,  sep,  tmp,n,i) {
	sep = sep ? sep : ","
	n= split(str,tmp,sep)
	for(i=1;i<=n;i+=2)
		a[trim(tmp[i])]= trim(tmp[i+1])
}
