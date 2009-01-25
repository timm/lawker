# copyright 2009 Arnold Robbins, GPL 3.0

#.H1   <join> join </join>
#.H2    Synopsis
#.P       join(array [,start,end,sep])
#.H2    Description
#.P       Joins at array into a string
#.H2    Arguments
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
#.H2    Returns
#.P       A string of <b>a</b>'s contents.
#.H2    Example
#.CODE      gawk/array/eg/join
#.CODE      gawk/array/eg/join.out
#.H2    Source
#.PRE
function join(a,start,end,sep,    result,i) {
    sep   = sep   ? start :  " "
    start = start ? start : 1
    end   = end   ? end   : sizeof(a)
    if (sep == SUBSEP) # magic value
       sep = ""
    result = a[start]
    for (i = start + 1; i <= end; i++)
        result = result sep a[i]
    return result
}
#./PRE
#.H3 Helper
#.P In earlier gawks, <em>length(a)</em> did not work in functions. Hence....
#.PRE
function sizeof(a,   i,n) { for(i in a) n++ ; return n }
#./PRE
#.H2 Change Log
#.P
#.UL
#.LI  Jan 24'08: defaults extended to include <em>start,stop</em>
#.LI   Jan 24'08: <em>Sizeof</em> added to handle old gawk bug
#./UL
#.H2 Author 
#.P  Arnold Robbins, then Tim Menzies
