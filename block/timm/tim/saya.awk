
Saya
==== 

Synopsis
--------

  saya(array [,label,sep,before,after,eq])

Description
-----------

Array printing function. Contents printed, sorted on key.

Arguments
---------

+ *array*  : An array.
+ *labea*  : (OPTIONAL) A prefix before every item.
+ *sep*    : (OPTIONAL) A string to print between each item. Defaults to new line.
+ *before* : (OPTIONAL) A string to print before the array. Defaults to "".
+ *after*  : (OPTIONAL) A string to print after the array. Defaults to new line.
+ *eq*     : (OPTIONAL) A string to print between each key/value pair. Defaults to " = ".

Returns
-------

Size of the array

Notes
-----

The most common usage is to just use the first two arguments; e.g.

  saya(a,"name") 
  ==>    
  name[1] = tim
  name[2] = menzies

For other usages, see the examples, below.

Sub-notes
.........

fred

Source
------

 function saya(a,s, sep0,b4,after,eq,   c,m,n,key,val,i,j,tmp,sep) {
	sep0  = sep0  ? sep0  : "\n"
	b4    = b4    ? b4    : ""
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

Example
-------

Able dogs

See Also
--------

@uses "saya1.awk" : support routines.

Author
------

Tim Menzies
