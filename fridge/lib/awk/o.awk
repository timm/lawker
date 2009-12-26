#.H1 Sorting Arrays Via the Shell
#.H2 Synopsis
#.PRE
# o(array [,string,control])
#./PRE
#.UL
#.LI If <em>string</em> is supplied, it is printed as a prefix to each list item.
#.LI If <em>control</em> is an integer, the <em>array</em>'s contents are printed 1 to <em>control</em>.
#.LI If <em>control</em> is a string, it is passed to as an argument to a UNIX <em>sort</em> command.
#./UL
#.H2 Download
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/o.awk LAWKER.
#.H2 Notes
#.P
#Much has been written in <a 
#href="http://groups.google.com/group/comp.lang.awk/browse_thread/thread/989d048946536fea#">
#comp.lang.awk</a> and <a href="http://awk.info/?Sorting">awk.info</a> about using 
#Awk code to sort Awk arrays. While all that code is clever and
#good, I wondered if a little shell scripting would simplify the task.
#.P
#On the plus side:
#.UL
#.LI The code is very short (11 lines!).
#.LI The code's functionality is very easy to modify. If the third argument is a string, it is passed to a UNIX <em>sort</em> command. This command supports a <a href="http://www.freebsd.org/cgi/man.cgi?query=sort&apropos=0&sektion=0&manpath=FreeBSD+8.0-RELEASE&format=html">very large list</a> of control options.
#./UL
#.P
#On the negative side:
#.UL
#.LI This code is operating system dependent. It only words on Mac, UNIX, LINUX, and Windoze (with Cygwin installed).
#.LI 
#When this code runs, it forks a sub-process. So it may be a little slower to run than the
#other methods documented in comp.lang.awk and awk.info.
#./UL
#.P
#All that said, I use this code all the time- it is very useful during debugging to dump
#the contents of the internal structures in my Awk code.
#.P
#By the way, if you want to see an even shorter sort routine (that  uses a platform 
#independent shell programming
#trick), check out
#<a href="http://awk.info/?doc/quicksort2.html">David Long</a>'s amazing quicksort.
#.H2 Code
#.H3 Example 
#.P Input:
#.PRE
function odemo(  a,b,i,n) {
	n = split("watermelon,banana,apple,grape",a,/,/);
	print "\nEG1"; o(a,"fruit")
	print "\nEG2"; o(a,"fruit",3)
	print "\nEG3"; o(a,"fruit","-k 6")
	for(i in a)
		b[a[i]] = i
	print "\nEG4"; o(b,"fruit")
	print "\nEG5"; o(b,"fruit","-r -k 2")
}
#./PRE
#.P
#Output:
#.PRE
#gawk -f o.awk --source "BEGIN { odemo() }"
#./PRE
#.P Print the array, no control string. Defaults to sorting on the index.
#.PRE
#EG1
#fruit[ 1 ]      =        [ watermelon ]
#fruit[ 2 ]      =        [ banana ]
#fruit[ 3 ]      =        [ apple ]
#fruit[ 4 ]      =        [ grape ]
#./PRE
#.P Print array, passing a numeric control string. Prints only the first three items, sorted on the index.
#.PRE
#EG2
#fruit[ 1 ]      =        [ watermelon ]
#fruit[ 2 ]      =        [ banana ]
#fruit[ 3 ]      =        [ apple ]
#./PRE
#.P Print array, sorted on the contents.
#.PRE
#EG3
#fruit[ 3 ]      =        [ apple ]
#fruit[ 2 ]      =        [ banana ]
#fruit[ 4 ]      =        [ grape ]
#fruit[ 1 ]      =        [ watermelon ]
#./PRE
#.P Print an array with strings for keys. Prints in array label order.
#.PRE
#
#EG4
#fruit[ apple ]  =        [ 3 ]
#fruit[ banana ] =        [ 2 ]
#fruit[ grape ]  =        [ 4 ]
#fruit[ watermelon ]     =        [ 1 ]
#./PRE
#.P Print an array with strings for keys. Prints in reverse array label order.
#.PRE
#EG5
#fruit[ watermelon ]     =        [ 1 ]
#fruit[ grape ]  =        [ 4 ]
#fruit[ banana ] =        [ 2 ]
#fruit[ apple ]  =        [ 3 ]
#./PRE
#.H3 Main driver
#.P The code is short, yes?
#.PRE
function o(a, str,control,   i) {
   if (control ~ /^[0-9]/) 
      for(i=1;i<=control;i++)
         print str "[ " i " ]\t=\t [ " a[i] " ]"
  else  {
      com = control ? control : " -n -k 2" 
      com = "sort " com  " #" rand(); # ensure com is unique
      for(i in a)
         print str "[ " i " ]\t=\t [ " a[i] " ]" | com;
      close(com);
}}
#./PRE
#.H2 Author
#.P
#Debbie Forbes
