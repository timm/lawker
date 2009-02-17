# copyright 2009 Tim Menzies, GPL 3.0

#.H1   <join> stack  </join>
#.H2   Synopsis
#.P       		top(stack [,emptyp])
#.P       		push(x,stack)
#.P	      		pop(stack [,emptyp])
#.H2   Description
#.P       		Stack manipulation rotunes. Maintains the size of the stack at index "0".
#.H2   Arguments
#.DL
#.DT      stack
#.DD            An array, with size of array stored at index "0".
#.DT      x
#.DD            Thing to push onto a stack.
#.DT      emptyp
#.DD            (OPTIONAL) Value to return if, when popping, you hit bottom of stack. Defaults to "".
#./DL
#.H2   Returns
#.P        		Top returns the top of stack or <em>emptyp</em> if the stack is empty.
#.P        		Pop returns the popped item or <em>emptyp</em>.
#.P				Push returns the <em>pushed</em> item.
#.H2   Example
#.BODY       	gawk/array/eg/stack
#.CODE       	gawk/array/eg/stack.out
#.H2   Source
#.PRE
function top(stack,emptyp) { 
	return ((stack[0] > 0) ? stack[stack[0]] : emptyp) 
} 
function push(x,stack)  { 
	stack[++stack[0]]=x; 
	return stack[0] 
}
function pop(stack,emptyp) { 
	return ((stack[0] > 0) ? stack[stack[0]--] : emptyp) 
} 
#./PRE
#.H2 Author 
#.P  Tim Menzies
