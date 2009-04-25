#.H1 Quicksort.awk
#.H2 Synopsis
#.P cat numbers | gawk -f quicksort1.awk
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/quicksort1.awk LAWKER.
#.H2 Description
#.P
#Some Awk implementations come with built in sort routines (e.g. Gawk's asort and asorti functions). But it
#can be useful to code these yourself, especially in you are doing data structure tricks.
#.P
#Quicksort selects a pivot and divides the data into values above and below the pivot. Sorting then
#recurses on these sub-lists.
#.H2 Code
#.H3 Loading the data
#.PRE
BEGIN { RS = ""; FS = "\n" }
      { A[NR] = $0 } 
END {
	qsort(A, 1, NR)
	for (i = 1; i <= NR; i++) {
		print A[i]
		if (i == NR) break
		print ""
	}
}
#./PRE
#.H3 Sorting the data
#.PRE
function qsort(A, left, right,   i, last) {
	if (left >= right)
		return
	swap(A, left, left+int((right-left+1)*rand()))
	last = left
	for (i = left+1; i <= right; i++)
		if (A[i] < A[left])
			swap(A, ++last, i)
	swap(A, left, last)
	qsort(A, left, last-1)
	qsort(A, last+1, right)
}
function swap(A, i, j,   t) {
	t = A[i]; A[i] = A[j]; A[j] = t
}
#./PRE
#.H2 See also
#.P
#.URL http://awk.info/?quicksort2 quicksort2.awk
#.H2 Authors
#.P Alfred Aho, Peter Weinberger,  Brian Kernighan, 1988.
