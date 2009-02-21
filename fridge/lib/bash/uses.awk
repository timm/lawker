$1=="#use" { use($2) }
END        { show(FILENAME) }

function show(x) {
    if (Prefix) printf " " Prefix 
    printf  " " x
}
function use(f) {
    gsub(/[\"']/,"",f)
    if (++Seen[f]==1) { # loop detection
	while((getline < f)>0)  
	    if ($1 == "#use") 
		use($2)
	show(f)
        close(f) }
}