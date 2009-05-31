#Comment out everything code

 /^[ \t]*#/            { print ; next }
 /^ [^ ]/              { Code=1 }
 /^$/                  { Code=0 }
                       { print (Code ? $0 : "# " $0) }

#There there this stuff
