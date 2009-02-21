#This code uses gawk 3.7's indirect function calls
#use globals.awk  # we need "Fail"

# creation
function newl(l)  { l["-"] = l["+"] = 0 }

# querying
function sizel(l) { return l["+"] - l["-"]}
function topl(l)  { return l[l["+"]] }
function taill(l) { return l[l["-"]+1] }

# printing
function sayl(l,s)  { if (s) print s ; dol("sayl1",l) }
function sayl1(x,i) { print "\t" i " = " x }

# push and pop to top of list

function popl(l) { 
    return (l["-"] == l["+"]) ? Fail : l[l["+"]--]   
}
function pushl(x,l, ignore) { # bogus ignore needed when called by appendl
    return l[++l["+"]] = x 
}

# insert and delete to bottom of list
function insertl(x,l) { return l[--l["-"]+1] = x }
function deletel(l)  { return (l["-"] == l["+"]) ? Fail : l[(++l["-"])] }

# bulk insider of one list after another
function appendl(new,old)  { 
    withl("pushl", new,old) 
}
# bulk insert of one list before another
function prependl(new,target,  min1, min2,max2,i,j) {
    min1 = target["-"] -= sizel(new)
    min2=new["-"]
    max2=new["+"]
    j=0
    for(i=min2;i<=max2;i++) {
	target[ min1 +j ] = new[i]
	j =j+1 }
}
# Mapping functions
function withl(fun,l1,l2,  min,max,i) {
    min = l1["-"]
    max = l1["+"]
    for(i=min+1;i<=max;i++) 
	@fun(l1[i],l2,i - min) 
}
function dol(fun,l,  min,max,i) {
    min = l["-"]
    max = l["+"]
    for(i=min+1;i<=max;i++) 
	@fun(l[i],i - min) 
}
