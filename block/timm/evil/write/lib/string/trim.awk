function trim(s) {
	sub(/^[ \t]*/,"",s)
	sub(/[ \t]*$/,"",s)
	return s
}
