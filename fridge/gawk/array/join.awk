# copyright 2009 Arnold Robbins, GPL 3.0

#.H1   <join> join </join>
#.H2    SYNOPSIS
#.P       join(array,[start,end,sep])
#.H2    DESCRIPTION
#.P       Joins at array into a string
#.H2    OPTIONS
#.DL
#.DT     a
#.DD            input array
#.DT      start
#.DD            Index for where to start in the array <b>a</b>. Default=1.
#.DT      end
#.DD            Index for where to start/stop in the array <b>a</b>. Default=size of array
#.DT      sep
#.DD            (OPTIONAL) What to write between each item. Defaults to blank space.
#./DL
#.P
#         If <em>sep</em> is set to the magic value <em>SUBSEP</em> 
#         then internally, <em>join</em> adds nothing between the items. 
#.H2    RETURNS
#.P       A string of <b>array</b>'s contents.
#.H2    EXAMPLES
#.H3 join
#.H4 array/join
#.PRE
#cd .. ; gawk -f join.awk --source 'BEGIN { 
#       split("tim tom tam", array)
#       print join(array,2) '}
#./PRE
#.H4 array/join.expect
#.PRE
#tom tam
#./PRE
#.H2 SOURCE
#.PRE
function join(a,start,end,sep,    result,i) {
    sep   = sep   ? start :  " "
    start = start ? start : 1
    end   = end ? end : sizeof(a)
    if (sep == SUBSEP) # magic value
       sep = ""
    result = a[start]
    for (i = start + 1; i <= end; i++)
        result = result sep a[i]
    return result
}
#./PRE
#.H3 HELPERS
#.PRE
function sizeof(a,   i,n) {
    # in earlier gawks, length(a) did not work in functions
    for(i in a) {print  i " " a[i] " " n; n++}
    return n
}
#./PRE
#.H2 SEE ALSO     
#.P saya
#.H2 HISTORy
#.P
#.UL
#.LI Jan 24'08: defaults extended to include <em>start,stop</em>
#.LI Jan 24'08: <em>Sizeof</em> added to handle old gawk bug
#.\LI
#.H2 AUTHOR 
#.P        Arnold Robbins, then Tim Menzies
