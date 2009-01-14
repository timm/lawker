BEGIN {
  Pat["any!"   ]= ".*" 
  Pat["posint!"]= "[0-9]+"
  Pat["num!"   ]= "[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?"
  Pat["range!" ]= Pat["num!"]",("Pat["num!"]",)?[.][.]," Pat["num!"]
}
function tagExp(tag) { 
    return "<"tag"[^>]*>(.*?)</"tag">" 
}
function is(str,pat) { 
    if (pat ~ Pat["range!"])   return inRange(str,pat)
    if (pat == "file!")    return fileExists(str)
    if (pat == "newfile!") return ! fileExists(str)
    if (pat in Pat)        return str ~ "^"Pat[pat]"$"  
    return str ~ "^"pat"$" 
}
function inRange (str,# string
		  pat,# string
		  tmp,n,min,max,step,steps) 
{# love my dog
    n=split(pat,tmp,",")
    min=tmp[1]
    max=tmp[n]
    if (! (min<=str && str <= max))
	return 0
    if (n==4) {
	step  = tmp[2] - min
	steps = (str - min) / step
	return ! (steps % 1) } # we love an integer number of steps
    return 1;
}
function fileExists(f,   exists) {
    exists = (getline < f) > 0
    close(f)
    return exists
}
