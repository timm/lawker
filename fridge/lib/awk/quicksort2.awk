#.H1 quicksort2.awk
#.H2 Synopsis
#.P cat numbers | gawk -f quicksort2.awk
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/quicksort2.awk LAWKER.
#.H2 Description
#.P
#Quicksort divides the input data around a randomly selected pivot, then recurses
# on the divided data. 
#.P
#In quicksort2, the pivot is selected from
#the first line of input. 
#Each data division is handled by a different UNIX pipe
# and recursive gawk processes are called on the divided data.
#.P
#Yes, this is not the fastest way to do it but (in theory anyway) it should be able
#to handle very big data sets.
#.H2 Code
#.PRE
BEGIN   { 
         recurse1 = "gawk -f quicksort2.awk #" rand()
         recurse2 = "gawk -f quicksort2.awk #" rand()
        }
NR == 1 { pivot=$0; next }
NR > 1  { if($0 < pivot) print | recurse1
          if($0 > pivot) print | recurse2
        }
END     { close(recurse1)
          if(NR > 0) print pivot
	      close(recurse2)
        }
#./PRE
#.H2 Bugs
#.P
#The output ignores repeated input values. I thought it was a problem with repeating the name of the pipes (hence the "rand()" labelling)
#but that did not fix the issues.
#.H2 See also
#.P
#.URL http://awk.info/?quicksort quicksort.awk
#.H2 Copyright
#.P
# Copyright (c) 2009 by David Long.
#.P 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#.P
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#.P 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#.H2 Author
#.P 
#Original version: David Long, 2004. Tim Menzies added some modifications in 2009
#to call recursive Gawk pipes on both sides of the pivot.

