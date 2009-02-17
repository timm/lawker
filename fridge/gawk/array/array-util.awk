# copyright 2009 Jim Hart, GPL 3.0



#.H1 	<join>Array functions</join>
#.H2 	Synopsis
#.P     	ajoin(array, sep [,start,end])
#.P 		asize(array)
#.P 		acopy(array, copyOfArray)
#.H2 	Description
#.P	 
# 			<em>ajoin</em>: turns an array into a delimited string.
# 			Unlike Arnold's <em>join()</em>, SUBSEP and null aren't special separators
#.P	 		<em>asize</em>: counts the number of elements in an array
#.P	 		<em>acopy</em>: copies one array to another
#.H2 	Arguments
#.DL
#.DT		array
#.DD			 	The array to be joined.
#.DT		sep
#.DD 				Separator to be placed between elements in the string
#.DT		start
#.DD				Optional start position in the array, default is element 1
#.DT		stop
#.DD				Optional end position in the array, default is the last element
#./DL
#.H2	Returns
#.P			<em>ajoin</em> returns the 	delimited string.
#.P		 	<em>asize</em> returns length of an array for awk's which don't support length(arr).
#.P		 	<em>acopy</em> returns number of elements copied.
#.H2	Source code
#.PRE
function ajoin(array, sep, start, end,   result, i)
{
     if(!start) start = 1
     if(!end) end = asize(array)
     result = array[start]
     for (i = start + 1; i <= end; i++)
        result = result sep array[i]
     return result
}
#./PRE
#.PRE
function asize(arr,  i,a) {
     for( i in arr) ++a
     return a
}
#./PRE
#.PRE
function acopy(arr1,arr2,  i,n){
     for(i in arr1) {
          arr2[i] = arr1[i]
          n++
     }
     return n
}
#./PRE
#.H2    Example
#.BODY       gawk/array/eg/array-util
#.CODE       gawk/array/eg/array-util.out
#.H2 Change Log
#.P
#.UL
#.LI  Jan '09: created
#./UL
#.H2 Author 
#.P  Jim Hart, jhart@mail.avcnet.org
