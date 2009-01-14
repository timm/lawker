#Print a string in key-sort order.
function saya(s,a,q1,q2,eol,    b,i,j,n1,n2,tmp,str,sep) {
    q1  = q1  ? q1  : "";
    q2  = q2  ? q2  : "";
    eol = eol ? eol : "\n";
    n1  = asorti(a,b)
    for(i=1;i<=n1;i++) {
	sep = "";
	str = s"[";
	n2=split(b[i],tmp,SUBSEP);
	for(j=1;j<=n2;j++) {
	    str = str sep q1 tmp[j] q1;
	    sep = ","  }
	printf(str"] = %s", q2 a[b[i]] q2 eol) }
}
