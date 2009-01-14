#WHAT    settings
#WHY     A lightweight global-less command-line parser 
#WHO     Tim Menzies
#HOW     Inputs string like '-k 7 --help' and outputs a array of settings.
#LICENSE http://code.google.com/p/LICENSE.txt
#NOTES
#<h2>Why Another Command-line Processor?</h2>
#<p>Arnold Robbin's excellent getopt function handles posix style command
#line arguments. But it has some drawbacks: the code makes some use of globals;
# it cannot support flags of more than one letter; 
# and it does not for valid arguments to flags.
#<p>Setting.awk, on the other hand, 

#FUNCTION main
#RETURNS  number # revised value to ARGC
#Some comments
#on
#many lines
function main(s,#=        string   # settings format
	      defaults,#= [string] # command-line format 
	      opt,#=      [array]  # e.g. opt[flag] = setting
	      n,tmp) 
{   n=split(defaults,tmp," ")
    options(s,n,tmp,opt)
    ARGC = options(s,ARGC,ARGV,opt)
    return ARGC
}    
function options(s,n,a,opt,rules,aka,  i,tmp,out,key,val) {
    s2rules(s,rules,aka)
    out=0
    for(i=1;i<=n;i++) {
	key=a[i]
	val=""
	if (gsub(/^-/,"",key)) {
	    if (! (key in aka)) 
		barph("uknown flag [" key "]")
	    if (key in rules)  
		val=a[++i]     
	} else { out=1 } 
	if (out) { 
	    push(tmp,key)
	} else { 
	    option(aka[key],val,opt,at(rules,key)) }
    }
    split("",a,"")
    n=0
    for(i=1;i<=tmp[0];i++)
	a[++n]=tmp[i];
    return n
}
function option(x,y,opt,rule)  {
    if (! rule)        # no argument expected
	return goodOption(x,1,opt)
    if (y == "")       # there is a missing argument
	return barph("missing value for [" x "]")
    if (! is(y,rule))  # argument found, but it is bad
	return barph("bad value [" y "] for [" x "]") 
    goodOption(x,y,opt)
}
function goodOption(x,y,opt) {
    if (opt[x] == y) return y
    opt[x]=y
    return newOption(x,y)
}
function s2rules(s,rules,aka,     a,f,i,j,n,rule,flags) {
    n=split(s,a,"")
    for(i=1;i<=n;i++) {
	rule="";                 # usually: no arguments so no constraints
	if (a[i]==":") {         # but, special case: there is an argument
 	    rule="any!";        # so this isn't usual-  we have a constraint
	    if (a[i+1] == "{") { # extra special case:  specified constraint
		j    = upto("}",a,i,n) 
	        rule = a2s(a,i+2,j-1)       # remember the specified constraint
	        i    = j }}    
	if (rule) {                         # if we found a constraint...
	    for(f in flags)                 # ... then constrain active flags
	       rules[flags[f]] = rule   
        } else {                            # else, process new flags
	    split("",flags,"")              # find new flags
	    flags[1]=a[i]                   # usually, one flag of one character
	    if (a[i] == "{")  {             # special case, multiple flags 
		j  = upto("}",a,i,n)
		subwords(a,i+1,j-1,flags,"=")
		i  = j 
		
	    }
	    for(f in flags)                 # for all flags
		aka[flags[f]]=flags[1] 	}}}  # their real name is the first flag



