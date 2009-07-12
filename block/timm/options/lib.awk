 function warn(str) { print str >"/dev/stderr" }
 function bad(str)  { warn(str); exit}

 function word1(str,    words) { split(str,words,/[ \t]/); return words[1]  }
 function line1(str,    lines) { split(str,lines,/\n/)   ; return lines[1]  }

 function trim(s) { # trim leading/trailing blanks
	sub(/^[ \t]*/,"",s)
	sub(/[ \t]*$/,"",s)
	return s
 } 
 function fileExists(f,  exists) { #return 1/0 if file "f" does/not exist
	exists = (getline < f) > 0;	
	close(f);
	return exists;
 }
