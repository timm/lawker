function chars(n,c,    str) {
	c = c ? c : "*"
	while ((n--) > 0 ) str=str c
	return str
}
