# Copyright 2008  James A. Hart, jhart@mail.avcnet.org
# All rights reserved
# License: any version of the GNU Public License

#################################################################################
##### Convert pipe delimited data into different formats, mainly XHTML tables.
## Most commonly used to convert database query results into XHTML tables using
#  either <table> or <div>, but also supports export formats (see below).
## Parameters:
#             - text with a pipe (|) symbol between fields possibly with spaces on
#               either side; record delimiter can be C/R-N/L (DOS/Windows), C/R (Mac),
#               or N/L (*nix).
#             - desired format; XHTML table default
#             - does the first row contain column names? (1 or 0 expected)
#
## Results: a table with rows and columns that correspond to those in the delimted
#           input. If the first row contains column names, they will be treated as
#           column headers in table formats that support them.
#
## Currently supported output  formats: table, div (with fixed class names), tab, csv
#################################################################################

function pipe2table(text,format,headers,   ad,rd,cd,results,rows,cols,rc,cc,i,j){
	if(!format) format = "table"
	rd="\r\n|\r|\n"; cd="[ \\t]*\\|[ \\t]*"
	if(match(text,rd))
		ad = substr(text,RSTART,RLENGTH)
	else return "text must have a row delimiter, i.e. C/R-N/L (DOS/Windows), C/R (Mac),  or N/L (*nix)."
	if(!(format ~ /table|div|tab|csv|TABLE|DIV|TAB|CSV/))
		return "format " format " isn't currently supported"
	if(format ~ /table|TABLE/) 
		results = results "<TABLE>"
	else if(format ~ /div|DIV/)
		results = results "<DIV class=\"table\">"
	rc = split(text,rows,rd)
	for(i=1;i<=rc;i++){
		cc = split(rows[i],cols,cd) 
		if(format ~ /table|TABLE/) 
			results = results "<TR>"
		else if(format ~ /div|DIV/)
			results = results "<DIV class=\"table-row\">"
		for(j=1;j<=cc;j++) {
			if(format ~ /table|TABLE/) 
				if(headers && i == 1) 
					results = results "<TH>" cols[j] "</TH>"
				else 
					results = results "<TD>" cols[j] "</TD>"
			else if(format ~ /div|DIV/)
				results = results "<DIV class=\"table-cell\">" cols[j] "</DIV>"
			else if(format ~ /tab|TAB/)
				if(j == 1)
					results = results cols[j]
				else
					results = results "\t" cols[j]
			else if(format ~ /csv|CSV/)
				if(j == 1)
					results = results "\"" cols[j] "\""
				else
					results = results ",\"" cols[j] "\""
		}
		if(format ~ /table|TABLE/) 
			results = results "</TR>"
		else if(format ~ /div|DIV/)
			results = results "</DIV>"
		results = results ad
	}
	if( format ~ /table|TABLE/) 
		results = results "</TABLE>"
	else if(format ~ /div|DIV/)
		results = results "</DIV>"
	return results
}
