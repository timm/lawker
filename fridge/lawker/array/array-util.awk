# Jim Hart, jhart@mail.avcnet.org, Public Domain
# Jan 2009


# array functions

# Contents:
#	- ajoin: turns an array into a delimited string
#	- asize: counts the number of elements in an array
#	- acopy: copies one array to another
#================


# turn sequential array into string with delimiter

# unlike Arnold's join(), SUBSEP and null aren't special separators

# Input:
#	- the array to be joined
#	- separator to be placed between elements in the string
#	- optional start position in the array, default is element 1
#	- optional end position in the array, default is the last element
#
# Dependencies:
#	- the asize() function
#
# Returns:
#	- delimited string

function ajoin(array, sep, start, end,   result, i)
{
	if(!start) start = 1
	if(!end) end = asize(array)
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}



# returns length of an array for awk's which don't support length(arr)
# Input:
#	- an array
#
# Returns:
#	- the number of elements in the array as an unsigned integer

function asize(arr,  i,a) {
  for( i in arr) ++a
  return a
}



# copy one array to another
# Input:
#	- an array
#	- name of the array to receive the copy
#
# Returns:
#	- number of elements copied

function acopy(arr1,arr2,  i,n){
	for(i in arr1) {
		arr2[i] = arr1[i]
		n++
	}
	return n
}
