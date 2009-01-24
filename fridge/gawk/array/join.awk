# copyright 2009 Arnold Robbins, GPL 3.0

#.H1   <join> join </join>
#.H1    SYNOPSIS
#.P       join(array,[start,end,sep])
#.H1    DESCRIPTION
#.P       Joins at array into a string
#.H1    OPTIONS
#.DL
#.DT      array
#.DD            input array
#.DT      start,end
#.DD            Indexes for where to start/stop in the array.
#.DT      sep
#.DD            (OPTIONAL) What to write between each item. Defaults to blank space.
#./DT
#.P
#         If <em>sep</em> is set to the magic value <em>SUBSEP</em> 
#         then internally, <em>join</em> adds nothing between the items. 
#.H1    RETURNS
#.P       A string of <b>array</b>'s contents.
#.H1    EXAMPLES
#.PRE
#% gawk -f join.awk --source 'BEGIN { 
#         split("name,age",A,",")
#         print join(A,1,2)
# }'
# name age
#./PRE
#.H1 SOURCE
#.PRE
function join(array,start,end,sep,    result,i)
{
    if (sep == "")
       sep = " "
    else if (sep == SUBSEP) # magic value
       sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}
#./PRE
#.H1 SEE ALSO     
#.P 
saya
#.H1 AUTHOR 
#/P        Arnold Robbins