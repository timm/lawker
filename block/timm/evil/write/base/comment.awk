/^[ \t]*$/ 	{ dump(); next; }
			{ text = (text ? text "\n" : "" ) $0 }
END         { dump() }

function dump() {
	if (text) {
		if (text ~ /^[ \t][^ \t]/)
			print text "\n"
		else  {
			gsub(/\n/,"\n#",text)
			print "#" text "\n"
		}
	}
	text = "";
}
