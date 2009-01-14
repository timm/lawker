###
# POST and GET form data handling for awk
#
#	Why:	'casue its fast and small compared to perl
#	ToDo:	Cookie functions (actually done, just not 100%)
###
#	By:	Alan Yates <alany@ay.com.au>
###

###
# just call this at BEGIN to return query in query_data[] array
###
function parse_query(query, query_tmp, tmp, tmp2) {
	query = ENVIRON["QUERY_STRING"];
	if(!query) getline query;
	split(query, query_tmp, "[&|]");
	for(tmp in query_tmp) {
		split(query_tmp[tmp], tmp2, "=");
		tmp2[2] = unmangle(tmp2[2]);
		gsub("+", " ", tmp2[2]);
		query_data[tmp2[1]] = tmp2[2];
	}
}
function unmangle(query,    new, i, char, n) {
	n = length(query)
	for(i = 1; i <= n; i++) {
		char = substr(query, i, 1);
		if(char == "%") {
			char = htod(substr(query, i+1, 2))
			i += 2;
		}
		new = new sprintf("%c", char);
	}
	return new;
}
function htod(hex, table, n) {
	hex = toupper(hex);
	table = "0123456789ABCDEF";
	n = index(table, substr(hex, 2, 1)) - 1;
	n += 16 * (index(table, substr(hex, 1, 1)) - 1);
	return n;
}

###
# Outputs a header with the option to set a cookie or goto a location
###
function header(location, cookie) {
	printf("Content-Type: text/html\n");
	if(cookie) printf("Set-Cookie: %s\n", cookie);
	if(location) printf("Location: %s\n", location);
	printf("Pragma: no-cache\n\n");
}

###
# Debug: dump enviroment vars
###
function dump_env(tmp) {
	printf("<PRE>");
	for(tmp in ENVIRON) printf("%s=%s\n", tmp, ENVIRON[tmp]);
	printf("</PRE>\n");
}

###
# Debug: dump unmangled query, call parse_query() first!
###
function dump_qry(tmp) {
	printf("<PRE>");
	for(tmp in query_data) printf("%s=%s\n", tmp, query_data[tmp]);
	printf("</PRE>\n");
}
