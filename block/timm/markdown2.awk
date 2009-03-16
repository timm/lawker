#.H1 Markdown2.awk

#.H2 Synopsis
#.P awk -f markdown2.awk file.txt > file.html
#.H2 Download 
#.P 
#Download from
#.URL  http://lawker.googlecode.com/svn/fridge/gawk/text/markdown2.awk LAWKER.
#.H2 Description
#.P 
# (Note: this code was orginally called <em>txt2html.awk</em> by its author but that caused a name
# clash inside LAWKER. Hence, I've taken the liberty of renamining it. --<a href="?who/timm">Timm</a>)
#.P The following code implements a subset of John Gruber's <a href="http://daringfireball.net/projects/markdown/">Markdown</a> langauge:  a widely-used, ultra light-weight markup language for html. 

#.UL
#.LI Paragraghs- denoted by a leading blank line.
#.LI
#Links: <pre>An [example](http://url.com/ "Title") </pre>
#.LI 
#Images: <pre>![alt text](/path/img.jpg "Title")</pre>
#.LI
#Emphasis:  **To be in italics**
#.LI
#Code: `&lt;code&gt;` spans are delimited by backticks.
#.LI
#Headings (Setex style) 
#.PRE
#Level 1 Header 
#=============== 
#
#Level 2 Header
#--------------
#
#Level 3 Header 
#______________
#./PRE
#.LI
#Heaings (Atx style):
#.P Number of leading "#" codes the heading level:
#.PRE
## Level 1 Header
##### Level 4 Header
#./PRE
#.LI Unordered lists
#.PRE
#- List item 1
#- List item 2
#./PRE
#.P Note: beginnging and end of list are automatically inferred, maybe not always correctly.
#.LI Ordered lists
#.P Denoted by a number at start-of-line.
#.PRE
#1 A numbered list item
#./PRE
#./UL
#.H2 Code
#.P 
# The following code demonstrates a "exception-style" of Awk programming. Note
#how all the processing relating to each mark-up tag is localized (exception, carrying
#round prior text and environments). The modularity of the following code should make it
#easily hackable.
#.H3 Globals
#.PRE
BEGIN {
	split('',envs,'');
	push("none",envs)
	text = "";
}
function push(x,l) { l[++l[0]]=x } 
function top(l)    { return l[l[0]] } 
function pop(l)    { return l[l[0]--] } 
#./PRE
#.H3 Images
#.PRE
/^!\[.+\] *\(.+\)/ { print images(); next }
function images(     a,b,imgtext,imgaddr) {
	split($0, a, /\] *\(/);
	split(a[1], b, /\[/);
	imgtext = b[2];
	split(a[2], b, /\)/);
	imgaddr = b[1];
	text = "";
	return "<p><img src=\"" imgaddr "\" alt=\"" imgtext "\" title=\"\" /></p>";
}
#./PRE
#.H3 Links
#.PRE
/\] *\(/ { links() }

function links(    a,b,linktext,nc,linkaddr) {
	do {
		na = split($0, a, /\] *\(/);
		split(a[1], b, "[");
		linktext = b[2];
		nc = split(a[2], c, ")");
		linkaddr = c[1];
		text = text b[1] "<a href=\"" linkaddr "\">" linktext "</a>" c[2];
		for(i = 3; i <= nc; i++)
			text = text ")" c[i];
		for(i = 3; i <= na; i++)
			text = text "](" a[i];
		$0 = text;;
		text = "";
	}
	while (na > 2);
}
#./PRE
#.H3 Code
#.PRE 
/`/    { $0 = pairedTag("`"   , "tt") }
/\*\*/ { $0 = pairedTag("\*\*", "em") }
/__/   { $0 = pairedTag("__"  , "b") }

function pariedTag(div,tag,    out,n,i,tmp) {
	n   = split($0,tmp,div)
	for(i=1;i<=n;i++)
	    out = out ((i % 2) ? $i : "<" tag ">" $i "</" tag ">") 
	return out
}
#./PRE
#.H3 Setex-style Headers
#.P (Plus h3 with underscores.)
#.PRE
/^=+$/ { heading(1,$0) ; text=""; next }
/^=+$/ { heading(2,$0) ; text=""; next }

function heading(n,txt) { return "<h" n" >" txt "</h" n ">\n" }

/^-+$/ { 
	print "<h2>" text "</h2>\n";
	text = "";
	next;
}

/^_+$/ {
	print "<h3>" text "</h3>\n";
	text = "";
	next;
}
#./PRE
#.H3 Atx-style headers
#.PRE
/^#/ {
	match($0, /#+/);
	n = RLENGTH;
	if(n > 6)
		n = 6;
	print "<h" n ">" substr($0, RLENGTH + 1) "</h" n ">\n";
	next;
}
#./PRE
#.H3 Unordered Lists
#.PRE
/^[*-+]/ {
	if (env == "none") {
		env = "ul";
		print "<ul>";
	}
	print "<li>" substr($0, 3) "</li>";
	text = "";
	next;
}

/^[0-9]./ {
	if (env == "none") {
		env = "ol";
		print "<ol>";
	}
	print "<li>" substr($0, 3) "</li>";
	next;
}
#./PRE
#.H3 Paragraphs
#.PRE
/^[ t]*$/ {
	if (env != "none") {
		if (text)
			print text;
		text = "";
		print "</" env ">\n";
		env = "none";
	}
	if (text)
		print "<p>" text "</p>\n";
	text = "";
	next;
}
#./PRE
#.H3 Default
#.PRE
// {
	text = text $0;
}
#./PRE
#.H3 End
#.PRE
END {
        if (env != "none") {
                if (text)
                        print text;
                text = "";
                print "</" env ">\n";
                env = "none";
        }
        if (text)
                print "<p>" text "</p>\n";
        text = "";
}
#./PRE
#.H2 Bugs
#.P Does not implement the full Markdown syntax.
#.H2 Author
#.P   Jesus Galan (yiyus) 2006
# &lt;yiyu DOT jgl AT gmail DOT com>
