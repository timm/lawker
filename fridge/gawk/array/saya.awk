#.H1   <join> saya</join>
#.H2   Synopsis
#.P       		saya(array [,label,sep,before,after,eq])
#.H2   Description
#.P				Array printing function. Contents printed, sorted on key.
#.H2   Arguments
#.DL
#.DT      array
#.DD            An array.
#.DT      label
#.DD            (OPTIONAL) A prefix before every item.
#.DT      sep
#.DD            (OPTIONAL) A string to print between each item. Defaults to new line.
#.DT      before
#.DD            (OPTIONAL) A string to print before the array. Defaults to "".
#.DT      after
#.DD            (OPTIONAL) A string to print after the array. Defaults to new line.
#.DT      eq
#.DD            (OPTIONAL) A string to print between each key/value pair. Defaults to " = ".
#./DL
#.H2   Returns
#.P        		Size of the array
#.H2   Notes
#.P	   	  The most common usage is to just use the first two arguments; e.g.
#.PRE
#saya(a,"name") ==>
#
#name[1] = tim
#name[2] = menzies
#./PRE
#.P		For other usages, see the examples, below.
#.H2   Source
#.PRE
function saya(a,s, sep0,b4,after,eq,   c,m,n,key,val,i,j,tmp,sep) {
	sep0  = sep0  ? sep0  : "\n"
	b4    = b4    ? b4    : "\n"
	after = after ? after : "\n"
	eq    = eq    ? eq    : " = "
	pre   = s     ? s"["  : ""
	post  = s     ? "]"   : ""
	m     = asorti(a,b)
	printf("%s",b4)
	for(i=1;i<=m;i++)  {
		key=b[i]
		val=a[b[i]]
		printf("%s", sep pre  )
		n=split(key,tmp,SUBSEP)
		c = ""
		for(j=1;j<=n;j++)	{	
			printf("%s", c tmp[j]  )
			c=","
		}
		printf("%s", post eq val )
		sep=sep0;
	};
	printf("%s",after)
	return m
}
#./PRE
#.H2   Example
#.BODY       gawk/array/eg/saya
#.CODE       gawk/array/eg/saya.out
#.H2 Author 
#.P  Tim Menzies

