#.H1 Reading RSS Feeds
#.H2 Synopsis
#.PRE
# myrss("rss;url;N" [,between])
#./PRE
#.H2 Download
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/myrss.awk LAWKER.
#.H2 About
#.P 
# The function
#.EM myrss("rss;url;N")
# returns the first 
#.EM N
# items from an rss feed found in
#.EM url.
#.P
# The functional optionally accepts a 
#.EM between
# string that is printed between each item.
#.P
#The code is designed to be customized. Quirks in the RSS stream, or quirks in the formatting are handled by a set
#of seperate 
#.EM my
# functions that be quickly altered to return the desired strings.
#.H2 Notes
#.P
#The code uses a 
#.EM slurp
#function that reads the entire stream as one string using
#.EM wget
#then splits it into an array on the &lt; character.
#.P
#After a few simplifications, the approach turns out  to be very fast. For example, using
#.PRE
#wget -O -
#./PRE
# is faster than 
#.PRE
#wget -O tmpfile; cat tmpfile
#./PRE
#.P
#Also, version one of this code split the RSS feed using
#the disjunction
#.EM [<>].
#This proved to be much slower  than just slurping in splitting on "\n" then subsequently splitting
#on "&lt;". 
#.P 
#The above two optimizations changed the runtimes for the following example 
#from 0.9 seconds to 0.88 seconds. This is very fast considering that just wgetting the RSS feed  takes 0.08 seconds.
#.H2 Example
#.SMALL
#.PRE 
# % gawk -f myrss.awk --source 'BEGIN {
#   print "<ul>"
#   print myrss("rss;lawker.blogspot.com/feeds/posts/default?alt=rss;5","<li>\n")
#   print "</ul>"
# '}
#./PRE
#./SMALL
#.P
#This generaetes the following list from the AWK.INFO rss feed
#.UL
#.LI <a href="http://lawker.blogspot.com/2009/12/awkinfo-now-top-20-website.html">Dec 02</a> Awk.info now a top-20 website.
#.LI <a href="http://lawker.blogspot.com/2009/12/zork-in-awk.html">Dec 02</a> Praveen Puri offers a Zork-clone, in Awk.
#.LI <a href="http://lawker.blogspot.com/2009/12/sorting-in-awk.html">Dec 01</a> Ed Morton sorts out everything (using Awk)
#.LI <a href="http://lawker.blogspot.com/2009/12/smallest-formatter-ever.html">Dec 01</a> Is this the smartest (smallest) formatter ever written?
#.LI <a href="http://lawker.blogspot.com/2009/11/norvigs-spell-checker-in-awk.html">Nov 30</a> Gregory Grefenstette implements Norvig's spell checker.
#./UL
#.H2 Code
#.H3 Top-Level Drive
#.PRE
function myrss(rss, between, tmp) {
  split(rss,tmp,";");
  return myrss1(tmp[2],tmp[3],between);
}
#./PRE
#.H3 Main workder
#.PRE
function myrss1(feed,max,  between,  n,all,sep,out,date,url,txt,seen) {
  n = slurp("wget -q -O - http://" feed,">",all);
  for(i=1;i<=n; i++) {
    if (all[i] ~ /^<pubDate/) 
      date = myDate(all[i+1])
    else if (all[i] ~ /^<description/) 
      txt = myText(all[i+1])
    else if (all[i] ~ /^<enclosure/) {
      url = myUrl(all[i]);
      out = out sep myReport(url,date,txt);
      sep = between ? between : "\n";
      if (++seen >= max) 
          return out;
    }}
  return out;
}
#./PRE
#.H3 Helper Functions
#.P
#.EM slurp
# reads an entire file into an array.
#.PRE
function slurp(com,sep,all) { slurp0(com); return split($0,all,sep)     }
function slurp0(com)        { RS=""; FS="\n"; com | getline; close(com) }
#./PRE
#.H3 Formatting Functions
#.P
#Most of the formatting control is isolated in the following functions.
#Change these to change the appearance of the feeds.
#.PRE
function myDate(str, tmp)       { split(str,tmp," ");   return tmp[3]  " " tmp[2] } 
function myText(str)            { sub(/&lt;.*/,"",str); return str }
function myUrl(str)             { sub(/<.*/,"",str);    return str }
function myReport(url,date,txt) { return "<a href=\"" url "\">" date "</a>" txt}
#./PRE
#.H2 Author
#.P
#Tim Menzies
