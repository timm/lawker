# pretty print keys of an array. replace SUBSEP with ","
function c(i, n,out,sep,tmp) {
    n= split(i,tmp,SUBSEP)
    for(i=1;i<=n;i++) {
	out = out sep tmp[i]
	sep = ","
    }
    return "[" out "]"
}