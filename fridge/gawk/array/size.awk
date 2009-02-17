# copyright 2009 Tim Menzies, GPL 3.0

#.H1   <join> array size predicates  </join>
#.H2   Synopsis
#.P       		empty(array)
#.P       		unempty(array)
#.H2   Description
#.P       		Predicates for the size of an array.
#.H2   Arguments
#.DL
#.DT      array
#.DD            An array.
#./DL
#.H2   Returns
#.P        		<em>unempty</em> returns "1" if array has contents, "0" otherwise.
#.P        		<em>empty</em> returns "0" if array has contents, "1" otherwise.
#.H2   Source
#.PRE
function unempty(a,  i) { for(i in a) return 1; return 0 }
function empty(a)       { return  unempty(a) ? 0 : 1 }
#./PRE
#.H2   Example
#.BODY       gawk/array/eg/size
#.CODE       gawk/array/eg/size.out
#.H2 Author 
#.P  Tim Menzies
