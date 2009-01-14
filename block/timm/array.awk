# returns a value in an arary without changing the arry
function at(a,k) { 
    return k in a ? a[k] : "" 
}
#arrays to strings
function upto(stop,a,i,n,   k) {
    for(k=i;k<=n;k++) 
	if (a[k] ~ stop) 
	    return k
    return n
}
function a2s(a,i,j,   k,out) {
    for(k=i; k<=j; k++) 
	out= out a[k]
    return out
}
function subwords(a,i,j,words,sep,   n) { 
    n=split(a2s(a,i,j),words,sep)
    return n
}
function push(a,x) { 
    return a[++a[0]]=x 
}
