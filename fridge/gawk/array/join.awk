# copyright 2009 Arnold Robbins, GPL 3.0

#.H1   <join> join </join>
#.H2    SYNOPSIS
#.P       join(array,[start,end,sep])
#.H2    DESCRIPTION
#.P       Joins at array into a string
#.H2    OPTIONS
#.DL
#.DT     array
#.DD            input array
#.DT      start,end
#.DD            Indexes for where to start/stop in the array.
#.DT      sep
#.DD            (OPTIONAL) What to write between each item. Defaults to blank space.
#./Dl
#.P
#         If <em>sep</em> is set to the magic value <em>SUBSEP</em> 
#         then internally, <em>join</em> adds nothing between the items. 
#.H2    RETURNS
#.P       A string of <b>array</b>'s contents.
#.H2    EXAMPLES
#.PRE
#% gawk -f join.awk --source 'BEGIN { 
#       split("tim tom tam", array)
#       print join(array,2) '}
#
# tom tam
#./PRE
#.H2 SOURCE
#.PRE
function join(array,start,end,sep,    result,i) {
    sep   = sep   || " "
    start = start || 1
    end   = end   || length(array)
    if (sep == SUBSEP) # magic value
       sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}
#./PRE
#.H2 SEE ALSO     
#.P saya
#.H2 AUTHOR 
#.P        Arnold Robbins