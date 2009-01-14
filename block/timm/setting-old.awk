# experimental simplication to getopt. don't use yet.
# tim@menzies.us http://menzies.us


## handle inits 

    
function s2rules(s,rules,aka,     a,f,i,j,n,rule,flags) {
    n=split(s,a,"")
    for(i=1;i<=n;i++) {
	rule="";                 # usually: no arguments so no constraints
	if (a[i]==":") {         # but, special case: there is an argument
 	    rule="anyp!";        # so this isn't usual-  we have a constraint
	    if (a[i+1] == "{") { # extra special case:  specified constraint
		j    = upto("}",a,i,n) 
	        rule = a2s(a,i+2,j-1)      # remember the specified constraint
	        i    = j }}    
	if (rule) {                        # if we found a constraint
	    for(f in flags)                # constrain the active flags
	       rules[flags[f]] = rule   
        } else {                           # else, process flags
	    split("",flags,"")             # find new flags
	    flags[1]=a[i]                  # usually, one flag of one character
	    if (a[i] == "{")  {            # special case, multiple flags 
		j  = upto("}",a,i,n)
		subwords(a,i+1,j-1,flags,"=")
		i  = j }
	    for(f in flags)                 # for all flags
		aka[flags[f]]=flags[1] }}}  # their real name is the first flag


function options(s,opt,rules,aka,  i,tmp,out,key,val) {
    s2rules(s,rules,aka)
    out=0
    for(i=1;i<=ARGC;i++) {
	key=ARGV[i]
	val=""
	if (gsub(/^-/,"",key)) {
	    if (! (key in aka)) 
		barph("uknown flag [" key "]")
	    if (key in rules)  
		val=ARGV[++i]     
	} else { out=1 } 
	if (out) { 
	    push(tmp,key)
	} else { 
	    option(aka[key],val,opt,at(rules,key)) }
    }
    split("",ARGV,"")
    ARGC=0
    for(i=1;i<=tmp[0];i++)
	ARGV[++ARGC]=tmp[i];
}
function barph(s) { print "error: "s; exit }
function option(x,y,opt,rule)  {
    if (! rule)        # no argument expected
	return goodOption(x,1,opt)
    if (y == "")       # there is a missing argument
	return barph("missing value for [" x "]")
    if (! is(y,rule)) # argument found, but it is bad
	return barph("bad value [" y "] for [" x "]") 
    goodOption(x,y,opt)
}
function goodOption(x,y,opt) {
    if (opt[x] == y) return y
    opt[x]=y
    return newOption(x,y)
}
function push(a,x) { 
    return a[++a[0]]=x 
}
#function setting(x,opt,y) {
#    if (x in opt) { opt[x]=y } 
#    else { print a " " x "=" y }
#}