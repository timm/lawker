#.H1 Towers of Hanoi
#.H2 Synopsis
#.P gawk -f hanoi.awk  [-n Disks]
#.H2 Description
#.P
#The objective is to move N discks from stack 0 to stack 1,
#always putting a smaller disc on top of a larger one.
#or on an empty stack
#.H2 Options
#.DL
#.DT
#-n
#.DD
#Number of disks, defaults to 5.
#./DL
#.H2 Example
#.PRE
#gawk -f hanoi.awk -n 4
#0 4321
#1 
#2 
#
#0 432
#1 
#2 1
#
#0 43
#1 2
#2 1
#
#0 43
#1 21
#2 
#
#0 4
#1 21
#2 3
#
#0 41
#1 2
#2 3
#
#0 41
#1 
#2 32
#
#0 4
#1 
#2 321
#
#0 
#1 4
#2 321
#
#0 
#1 41
#2 32
#
#0 2
#1 41
#2 3
#
#0 21
#1 4
#2 3
#
#0 21
#1 43
#2 
#
#0 2
#1 43
#2 1
#
#0 
#1 432
#2 1
#
#0 
#1 4321
#2 
#./PRE
#.H2 Details
#.H3 Globals
#.DL
#.DT 
# sp[i] 
#.DD
# stack pointer for the ith stack = next free space
#.DT
#stack[i,j] 
#.DD
# value of stack i at position j
#./DL
#.H3 Code
#.P Main:
#.PRE
BEGIN {
  n = arg("-n",5)
  for (j=0; j<n; j++) push(0,n-j)
  showstacks()
  hanoi(n,0,1,2)
}
#./PRE
#.P 
#.PRE
function hanoi(n,a,b,c) {
  if (n==1) {
    move(a,b)
  } else {
    hanoi(n-1,a,c,b)
    move(a,b)
    hanoi(n-1,c,b,a)
  }
}
function move(i,j) {
  push(j,pop(i))
  showstacks()
}
#./PRE
#.P Showing the stack:
#.PRE
function showstacks(  i,j) {
  for (i=0; i<=2; i++) {
    printf "%s ", i
    for (j=0; j<sp[i]; j++) printf "%s", stack[i,j]
    print "" }
  print ""
}
#./PRE
#.P Standard stuff:
#.PRE
function arg(tag,default) {
  for(i in ARGV) 
	if (ARGV[i] ~ tag) 
		return ARGV[i+1]
  return default
}
function push(i,v) { stack[i,sp[i]++]=v }
function pop(i)    { return stack[i,--sp[i]] }
#./PRE
#.H2 Author
#.P
#Alan Linton, 2001
