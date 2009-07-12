function usageHi() {
    return "usage: hello [-P string][-a][-c][-h]        \n"\
    "Options:                                           \n"\
    "+ -P string[hello]   +who we shall greet.          \n"\
    "+ -a                 +Show about notice (short).   \n"\
    "+ -c                 +Show copyright notice (long).\n"\
    "                      Currently, we display GPL3.  \n"\
    "+ -h                 +Help.                        \n" 
 }
 function aboutHi() {
        return "hello v0.1: implements a simple 'hello world' function.\n"\
        "(c) 2009 Tim Menzies, GPL3.0"
 } 
 function mainHi() {
        print "hello " opt("P") 
 }
 function goHi(    usage) {
        usage = lines2options(usageHi(),Opt)
        if ( ok2go(usage, aboutHi(), Opt) ) 
                mainHi()
        else print line1(usageHi())
 }
 BEGIN { goHi() }
