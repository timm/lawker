#
# Perform 'match', but not depending on RSTART and RLENGTH
#
# Input: text, regular expression, array for storing match location and length
# Return: same as 'match', 1 on match, 0 on no match.
#
function locate(text,re,loc,   ret) {
	ret = match(text,re)
	loc["pos"] = RSTART
	loc["len"] = RLENGTH
	return ret
}
