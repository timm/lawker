BEGIN {
	env = "none";
	text = "";
}

\[.+\] *\(.+\)/ {
	split($0, a, /\] *\(/);
	split(a[1], b, /\[/);
	imgtext = b[2];
	split(a[2], b, /\)/);
	imgaddr = b[1];
	print "<p><img src=\"" imgaddr "\" alt=\"" imgtext "\" title=\"\" /></p>\n";
	text = "";
	next;
}
/\] *\(/ {
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
/`/ {
	while (match($0, /`/) != 0) {
		if (env == "tt") {
			sub(/`/, "</tt>");
			env = pcenv;
		}
		else {
			sub(/`/, "<tt>");
			pcenv = env;
			env = "tt"; } }
}
/\*\*/ {
	while (match($0, /\*\*/) != 0) {
		if (env == "emph") {
			sub(//, "</emph>");
			env = peenv;
		}
		else {
			sub(/\*\*/, "<emph>");
			peenv = env;
			env = "emph"; } }
}
/^=+$/ { print "<h1>" text "</h1>\n"; text = ""; next; }
/^-+$/ { print "<h2>" text "</h2>\n"; text = ""; next; }
/^_+$/ { print "<h3>" text "</h3>\n"; text = ""; next; }

/^#/ {
	match($0, /#+/);
	n = RLENGTH;
	if(n > 6)
		n = 6;
	print "<h" n ">" substr($0, RLENGTH + 1) "</h" n ">\n";
	next;
}
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
// { text = text $0; }
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
