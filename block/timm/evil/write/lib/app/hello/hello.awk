#    ___         
#  _/ oo\     An evil idea: 
# ( \  -/__   hello world
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs
#use options.awk

Hello world
=========== 

Synopsis
-------- 

  hello [-ach][-P who]    

Description
----------- 

Hello.awk  is the simplest known Evil program. It prints out
"hello Who" where "Who" can can be specified from the command line.

Usage
-----

+ -P who   :Sets the "Who" inside "hello Who". Without this flag the 
            default "who" is "world"
+ -a       :Prints a short "about" string for this program.
+ -c       :Prints the (long) copyright notice for this program.
+ -h       :Print help text.

Code
----

 function usageHello() {
        about()        
        prints("Usage: hello [-P] ",
        " ",
        " -P string    who we shall greet. P='"opt("P")"'.",
        " -a           Show about notice (short).",
        " -c           Show copyright notice (long).",
        " -h           Help." )
 } 
 BEGIN {
			if (ok2go(Opt,
                      "What  =  hello v0.1  ;"\
                      "When  =  2009        ;"\
                      "Who   =  Tim Menzies ;"\
                      "Why   =  hello world ;"\
                      "P     =  world        "))  
                { mainHello() }
             else usageHello()
 }
 function mainHello() {
        print "hello " opt("P")
 }        

Author
------

Tim Menzies
