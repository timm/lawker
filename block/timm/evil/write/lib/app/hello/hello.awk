#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   hello world
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs
#use options.awk
#uses array.awk

function usageHello() {
	about()	
	prints("Usage: hello [-W] ",
	" ",
	" -W string    who we shall greet. W='"opt("W")"'.",
   	" -a           Show about notice (short).",
	" -c           Show copyright notice (long).",
	" -h           Help." )
}

 BEGIN {
	    if (ok2go(Opt,
				"What	=	hello v0.1  ;"\
				"When	=	2009		;"\
				"Who	=	Tim Menzies	;"\
				"Why	=	hello world ;"\
				"W      =   world		"))  
        {
	   		mainHello() 
		} else usageHello()
 }
 function mainHello() {
	print "hello " opt("W")
 }	
