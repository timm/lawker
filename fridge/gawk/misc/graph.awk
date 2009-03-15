#.H1 Graph.awk
#.H2 Synopsis
#.P gawk -f graph.awk graphFile
#.H2 Description
#.P A processor for a little language, specialized for graph-drawing.
#The code inputs  data, which includes a specification of a graph
#The output is 
#data plotted in specified area
#.P For example, here is an input specification:
#.PRE
#.IN eg/graph1.dat
#./PRE
#.P It produces the following output
#.PRE
#.IN eg/graph1.out
#./PRE
#.H2 Code
#.H3 Initialization
#.P Set frame dimensions: height and width; offset for x and y axes.
#.PRE
BEGIN {                
    ht = 24; wid = 80  
    ox = 6; oy = 2     
    number = "^[-+]?([0-9]+[.]?[0-9]*|[.][0-9]+)" \
                            "([eE][-+]?[0-9]+)?$"
}
#./PRE
#.H3 Handling patterns
#.P Skip comments
#.PRE
/^[ \t]*#/     { next } 
#./PRE
#.P Simple tags
#.PRE
$1 == "height" { ht = $2;  next }
$1 == "width"  { wid = $2; next }
$1 == "label"  {                       # for bottom
    sub(/^ *label */, "")
    botlab = $0
    next
}
$1 == "bottom" && $2 == "ticks" {     # ticks for x-axis
    for (i = 3; i <= NF; i++) bticks[++nb] = $i
    next
}
$1 == "left" && $2 == "ticks" {       # ticks for y-axis
    for (i = 3; i <= NF; i++) lticks[++nl] = $i
    next
}
$1 == "range" {                       # xmin ymin xmax ymax
    xmin = $2; ymin = $3; xmax = $4; ymax = $5
    next
}
#./PRE
#.P Handling numerics.
#.PRE
$1 ~ number && $2 ~ number {  # pair of numbers
    nd++                      # count number of data points
    x[nd] = $1; y[nd] = $2
    ch[nd] = $3               # optional plotting character
    next
}
$1 ~ number && $2 !~ number { # single number
    nd++                      # count number of data points
    x[nd] = nd; y[nd] = $1; ch[nd] = $2
    next
}
#./PRE
#.P Line functions, defined by a slope "m" and a y-intercept "b".
#.PRE
$1 == "mb" {  # m b [mark]
	expand()
    for(i=xmin;i<=xmax;i++) {
		nd++; x[nd]=i; y[nd]=$2*i + $3; ch[nd]=$4 
    }
    next;
}		
#./PRE
#.P Final case: input error.
#.PRE
{ print "?? line " NR ": ["$0"]" >"/dev/stderr" }
#./PRE
#.P Draw the graph
#.PRE
END { expand();   frame(); ticks(); label(); data(); draw() }
#./PRE
#.H3 Functions
#.P Expand the "x" and "y" boundaries to include all points.
#.PRE 
function expand(note) { if (xmin == "") expand1(note) }
function expand1(note) {
 	xmin = xmax = x[1]    
    ymin = ymax = y[1]
    for (i = 2; i <= nd; i++) {
        if (x[i] < xmin) xmin = x[i]
        if (x[i] > xmax) xmax = x[i]
        if (y[i] < ymin) ymin = y[i]
        if (y[i] > ymax) ymax = y[i] }
}
#./PRE
#.P Draw the frame around the graph.
#.PRE
function frame() {        
    for (i = ox; i < wid; i++) plot(i, oy, "-")     # bottom
    for (i = ox; i < wid; i++) plot(i, ht-1, "-")   # top
    for (i = oy; i < ht; i++) plot(ox, i, "|")      # left
    for (i = oy; i < ht; i++) plot(wid-1, i, "|")   # right
}
#./PRE
#.P Create tick marks for both axes.
#.PRE
function ticks(    i) {   
    for (i = 1; i <= nb; i++) {
        plot(xscale(bticks[i]), oy, "|")
        splot(xscale(bticks[i])-1, 1, bticks[i])
    }
    for (i = 1; i <= nl; i++) {
        plot(ox, yscale(lticks[i]), "-")
        splot(0, yscale(lticks[i]), lticks[i])
    }
}
#./PRE
#.P Center labels under x-axis.
#.PRE
function label() {        
    splot(int((wid + ox - length(botlab))/2), 0, botlab)
}
#./PRE
#.P Create data points.
#.PRE
function data(    i) {    
    for (i = 1; i <= nd; i++)
        plot(xscale(x[i]),yscale(y[i]),ch[i]=="" ? "*" : ch[i])
    for(i in mark) print mark[i]
}
#./PRE
#.P Print graph from array.
#.PRE
function draw(    i, j) { 
    for (i = ht-1; i >= 0; i--) {
        for (j = 0; j < wid; j++)
            printf((j,i) in array ? array[j,i] : " ")
        printf("\n")
    }
}
#./PRE
#.P Scale x-values, y-values.
#.PRE
function xscale(x) {      
    return int((x-xmin)/(xmax-xmin) * (wid-1-ox) + ox + 0.5)
}
function yscale(y) {      
    return int((y-ymin)/(ymax-ymin) * (ht-1-oy) + oy + 0.5)
}
#./PRE
#.P Put one character into array.
#.PRE
function plot(x, y, c) {  
    array[x,y] = c
}
#./PRE
#.P Put string "s" into array.
#.PRE
function splot(x, y, s,    i, n) { 
    n = length(s)
    for (i = 0; i < n; i++)
        array[x+i, y] = substr(s, i+1, 1)
}
#./PRE
#.H2 Author
#.P 
# This code comes from the original Awk book by Alfred Aho, Peter Weinberger &  Brian Kernighan and contains some small
# modifications by  <A href="?who/timm">Tim Menzies</a>.
