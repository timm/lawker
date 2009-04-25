predef:	6809.ops 6809.opsup
	( awk -f opgen 6809.ops ; cat 6809.opsup ) >predef

pdcheck:	predef
	awk '{print $$1}' predef | sort | uniq -d
