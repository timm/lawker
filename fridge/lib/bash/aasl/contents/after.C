# common utilities incorporated in generated parser
function see2nd(des2,   gotit, lastline) {
	lastline = $0
	fill()
	gotit = ($1 == des2) ? 1 : 0
	nextline = $0
	havenext = 1
	$0 = lastline
	return gotit
}
function fail() {
	print where "syntax error"
	exit 1
}
function fill() {
	if (havenext) {
		$0 = nextline
		havenext = 0
	} else {
		getline
		while ($0 ~ /^#/) {
			if ($0 ~ /^#=/) {
				lineno = $2
				filename = $3
				where = filename "," lineno ": "
			}
			print
			getline
		}
	}
	if ($1 == "id" && b_idtype[$2] == "t")
		$1 = "typedefid"
	used = 0
}
# C-specific kludges incorporated in generated parser by `-b C'
# mostly typedef handling
BEGIN {
	b_nest = 0
	b_snest = 0
	b_scope[""] = ""
}
function b_ds() {		# declaration start
	b_nest++
	b_type[b_nest] = ""
	b_id[b_nest] = ""
}
function b_de() {		# declaration end
	b_nest--
}
function b_dt() {		# declaration is a typedef
	b_type[b_nest] = "t"
}
function b_di() {		# here's the identifier
	b_id[b_nest] = $2
}
function b_dd(   i) {		# declarator seen
	if (b_id[b_nest] == "")
		return
	i = b_id[b_nest]
	if (b_type[b_nest] == "t") {		# typedef
		b_oldidtype[b_snest i] = b_idtype[i]
		b_oldscope[b_snest i] = b_scope[i]
		b_idtype[i] = "t"
		b_scope[i] = b_snest
	} else if (b_idtype[i] == "t") {	# redeclaring typedef name
		b_oldidtype[b_snest i] = b_idtype[i]
		b_oldscope[b_snest i] = b_scope[i]
		b_idtype[i] = ""
		b_scope[i] = b_snest
	}
}
function b_ss() {		# start scope
	b_snest++
}
function b_se(   id) {		# end scope
	for (id in b_scope)
		if (b_scope[id] == b_snest) {
			b_idtype[id] = b_oldidtype[b_snest id]
			b_scope[id] = b_oldscope[b_snest id]
		}
	b_snest--
}
