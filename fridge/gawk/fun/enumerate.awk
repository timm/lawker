#.H1 Functional Enumeration in Gawk 3.1.7
#.H2 Synopsis
#.P      all( fun, array [,max]
#.P      collect( fun, array1, array2  [,max])
#.P      select( fun,  array1, array2  [,max])
#.P      reject( fun,  array1, array2 [,max])
#.P      detect( fun,  array   [,max])
#.P      inject( fun,  array,  carry [,max])
#.P All these functions return the size of <em>array</em> or <em>array2</em>
#.H2 Description
#.P
#    An interesting new feature in Gawk 3.1.7 is 
#    <a href="http://groups.google.com/group/comp.lang.awk/browse_thread/thread/7a026a902361cbc5#s">indirect functions</a>.
#    This allows the function name to be a variable, passed
#    as an argument to an array, and called using the syntax
#.PRE
#@fun(arg1,arg2,...)    
#./PRE
#.P 
#    This enables a new kind of funcational programming style
#    in Gawk. For example, generic enumeration patterns
#    can be coded once, then called many different ways
#    with different function names passed as arguments.
#.P
#    This document illustrates this style of programming.
#.H3 Enumerators
#.P For example, here are some standard enumeration functions:
#.H4 all(fun,array [,max]
#.P 
#     Applies the function <em>fun</em> to all items in the <em>array</em>.
#     If called with the <em>max</em>
#     argument, then they are iterated in the order i=1&nbsp;..&nbsp;<em>max</em>,
#     otherwise we use <em>for(i&nbsp;in&nbsp;a)</em>.
#.H4 collect(fun,array1,array2  [,max])
#.P
#    Applies <em>fun</em> to each item in <em>array1</em> and collects the
#    results in <em>array2</em>.
#.H4 select(fun,array1,array2  [,max])
#.P
#    Find all the items in <em>array1</em> that satisfies <em>fun</em> and
#    add them to <em>array2</em>.
#.H4 reject(fun,array1,array2 [,max])
#.P
#    Find all the items in <em>array1</em> that do <em>not</em> satisfy <em>fun</em> and
#    add them to <em>array2</em>.
#.H4 detect(fun,array [,max])
#.P
#    Return the first item found in  <em>array</em> that satisfies <em>fun</em>.
#    If no such item is found, then return the magic global value <em>Fail</em>.
#.H4 inject(fun,array,carry [,max])
#.P
#    (This one is a little tricky.)
#    The result of applying <em>fun</em> to each item in <em>array</em>
#    is carried into the  processing of the next item. Initially, the 
#    carried value is <em>carry</em>. This function returns the final <em>carry</em>.

#.H3 Sample Functions
#.P 
# To illusrate the above, consider the following functions. Each of these are defined for
# one  array item.
#.PRE
function odd(x)    { return (x % 2) == 1 }
function show(x)   { print "[" x "]" }
function mult(x,y) { return x * y }
function halve(x)  { return x/2 }
#./PRE
#.H3 Using the Functions 
#.UL
#.LI All-ing...
#.PRE
function do_all(   arr) { 
    split("22 23 24 25 26 27 28",arr)
    all("show",arr)
}
#./PRE
#.P When we run this ...
#.CODE eg/enum1
#.P we see every item in <em>arr</em> printed using the above <em>show</em> function ...
#.CODE eg/enum1.out

#.LI Collect-ing...
#.PRE
function do_collect(        max,arr1,arr2,i) {
    max=split("22 23 24 25 26 27 28",arr1)
    collect("halve",arr1,arr2,max)
    for(i=1;i<=max;i++) print arr2[i]
}
#./PRE
#.P When we run this ...
#.CODE eg/enum2
#.P we see every item in <em>arr</em> divided in two ...
#.CODE eg/enum2.out

#.LI Select-ing...
#.PRE
function do_select(        all,less,arr1,arr2,i) {
    all  = split("22 23 24 25 26 27 28",arr1)
    less = select("odd",arr1,arr2,all)
    for(i=1;i<=less;i++) print arr2[i]
}
#./PRE
#.P When we run this ...
#.CODE eg/enum3
#.P we see every item in <em>arr</em> that satisfies <em>odd</em>....
#.CODE eg/enum3.out

#.LI Reject-ing...
#.PRE
function do_reject(        all,less,arr1,arr2,i) {
    all  = split("22 23 24 25 26 27 28",arr1)
    less = reject("odd",arr1,arr2,all)
    for(i=1;i<=less;i++) print arr2[i]
}
#./PRE
#.P When we run this ...
#.CODE eg/enum4
#.P we see every item in <em>arr</em> that <em>do not</em> satisfies <em>odd</em>....
#.CODE eg/enum4.out

#.LI Detect-ing
#.PRE
function do_detect(        all,arr1) {
    all  = split("22 23 24 25 26 27 28",arr1)
    print detect("odd",arr1,all)   
}
#./PRE
#.P When we run this ...
#.CODE eg/enum5
#.P we see the first item in <em>arr</em> that satisfies <em>odd</em>....
#.CODE eg/enum5.out

#.LI Inject-ing...
#.PRE
function do_inject(        all,less,arr1,arr2,i) {
    split("1 2 3 4 5",arr1)
    print inject("mult",arr1,1)
}
#./PRE
#.P When we run this ...
#.CODE eg/enum6
#.P we see every the result of multiplying every item in  <em>arr</em> by its predecessor.
#.CODE eg/enum6.out
#./UL

#.H2 Code
#.P
# Note one design principle in the following: any newly generated arrays have indexes <em>1..max</em>
# where <em>max</em> is the number of elements in that array.
#.H3 all
#.PRE
function all (fun,a,max,   i) {
	if (max) 
		for(i=1;i<=max;i++) @fun(a[i]) 
	else  
		for(i in a) @fun(a[i])
}
#./PRE
#.H3 collect
#.PRE
function collect (fun,a,b,max,   i) {
	if (max)
	    for(i=1;i<=max;i++) {n++; b[i]= @fun(a[i]) }
	else
	    for(i in a) {n++; b[i]= @fun(a[i])}
	return n
}
#./PRE
#.H3 select
#.PRE
function select (fun,a,b,max,   i,n) {
	if (max)
		for(i=1;i<=max;i++) {
		    if (@fun(a[i])) {n++; b[n]= a[i] }}
	else
		for(i in a) {
		    if (@fun(a[i])) {n++; b[n]= a[i] }}
	return n
}
#./PRE
#.H3 reject
#.PRE
function reject (fun,a,b,max,   i,n) {
	if (max)
		for(i=1;i<=max;i++) {
		    if (! @fun(a[i])) {n++; b[n]= a[i] }}
	else
		for(i in a) {
		    if (! @fun(a[i])) {n++; b[n]= a[i] }}
	return n
}
#./PRE
#.H3 detect
#.PRE
BEGIN {Fail="someUnLIKELYSymbol"}
function detect (fun,a,max,   i) {
	if (max)
		for(i=1;i<=max;i++) {
			if (@fun(a[i])) return a[i] }
	else	
		for(i in a) {
			if (@fun(a[i])) return a[i] }
	return Fail
}
#./PRE
#.H3 inject
#.PRE
function inject (fun,a,carry,max,   i) {
	if (max)
		for(i=1;i<=max;i++)
			 carry = @fun(a[i],carry) 
	else
		for(i in a)
			 carry = @fun(a[i],carry) 
	return carry
}
#./PRE
#.H2 Bugs
#.P 
# The above code does not pass around any state information that
# the <em>fum</em> functions can use. So all their deliberations are either
# with the current array values (integers or strings) or with global state.
# It might be worthwhile writing new versions of the above with one more argument,
# to carry that sate.
#.H2 Author
#.TO tim@menzies.us Tim Menzies
