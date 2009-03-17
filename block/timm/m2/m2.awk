BEGIN {
	split("",envs,"");
	push("none",envs)
	text = "";
}

/^!\[.+\] *\(.+\)/ { print images(); next }
/\] *\(/           { $0 = links() }
/`/                { $0 = pairs("`"   , "tt") }
/**/               { $0 = pairs("**", "em") }
/__/               { $0 = pairs("__"  , "b") }
/^=+$/             { $0 = setexHeading(1,$0) ; text=""; next }
/^=+$/             { $0 = setexHeading(2,$0) ; text=""; next }
/^-+$/             { print underlined(text,1) }
/^_+$/             { print underlined(text,2) }
/^#/               { print hashed(); next }

function push(x,l) { l[++l[0]]=x } 
function top(l)    { return l[l[0]] } 
function pop(l)    { return l[l[0]--] } 
function pairs(div,tag,    out,n,i,tmp) {
	n   = split($0,tmp,div)
	for(i=1;i<=n;i++)
	    out = out ((i % 2) ? tmp[i] : "<" tag ">" tmp[i] "</" tag ">") 
	return out
}
function images() {
	text = "";
	return gensub("!\\[(.+)\\] *\\((.+)[ \t]+(.*)\\)",
			"<p><img src=\"\\2\" alt=\"\\1\" title=\"\\3\"","g")
}
function links(    out,a,b,linktext,nc,linkaddr) {
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
		out = text;;
		text = "";
	}
	while (na > 2);
	return out
}
function heading(n,txt) { 
	return "<h" n" >" txt "</h" n ">\n" 
}
function underlined(txt,n) {
	print "<h" n ">" text "</h" n ">\n";
	text = "";
	next;
}
function hashed() {
	match($0, /#+/);
	n = RLENGTH;
	n = n> 6 ? 6 : n
	return "<h" n ">" substr($0, RLENGTH + 1) "</h" n ">\n";
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
// {
	text = text $0;
}
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
