# copyright 2009 Arnold Robbins, GPL 3.0

#.H1 <join> array </join>
#.H2 Synopsis
#.P      arrray(a)
#.H2 Description
#.P      Ensure that an array is empty
#.H2 Arguments
#.DL
#.DT     a
#.DD           input array
#./DL
#.H2    Example
#.BODY       gawk/array/eg/array
#.CODE       gawk/array/eg/array.out
#.H2  Source
#.PRE
function array(a) { split("",a,"") }
#./PRE
