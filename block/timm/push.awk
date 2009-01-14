function empty(a,   i) { for(i in a) return 0; return 1}
function push1(a,x) { 
    if (empty(a)) {print 1; split("",a,"")}; 
    a[length(a)+1]=x 
}
function push2(a,x) { a[++a[0]]=x }
