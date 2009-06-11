 BEGIN { 
	Pat["string"] = "^.*$";
	Pat["zerone"] = "^(0|1)$"
	Pat["posint"] = "^([0-9]+$";
	Pat["num"   ] = "^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?$";
 }

 function ok(switch,type,value) {
	if (type=="file") return fileExists(value)
	if (type=="arg")  return 1
	if (type=="")     return 1
	if (type in Pat)  return type ~ Pat[type] 
	print "Bad arg for ["swtitch"]: ["value"] does not satisfy ["type"]"
	exit -2
 }
