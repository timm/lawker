THEM = Makefile README aasl.1 aasl.aasl aaslg aaslr \
	before common interp lex sem syn \
	taasl.aasl tsem tsyn c.aasl plus.C todo after.0 after.C

default:	ready

ced:	ed.lexed c.syn
	time awk -f c.syn ed.lexed >junk.e
	sed 's/^typedefid/id/' junk.e | cmp - ed.lexed
	rm -f junk.e

ed.lexed:	ed.c c.lex
	cc -E ed.c | awk -f c.lex >$@

ed.c:	/usr/src/bin/ed/ed.c
	cp /usr/src/bin/ed/ed.c .

c.lex:	../aacc/p.lex
	cp ../aacc/p.lex $@

c.syn:	c.aasl after.C
	AASLDIR=. aaslg -b C c.aasl >$@

ready:	after.0 after.C

r:	aasl.aasl taasl.aasl lex syn sem tsyn tsem after.0 after.C
	AASLDIR=. aaslg aasl.aasl | cmp - syn
	AASLDIR=. aaslg -t taasl.aasl | cmp - tsyn

c.aasl:	../aacc/c.aasl Makefile
	sed 's/ ![a-z][a-z]*//g;s/\(	\)![a-z][a-z]*/\1/g' ../aacc/c.aasl >$@

after.C:	common plus.C
	( sed 's/^#C//' common ; cat plus.C ) >$@

after.0:	common
	sed '/^#/d' common >$@

dtr:	$(THEM)
	makedtr $(THEM) >$@

p:
	ti aasl.aasl before common plus.C | hplist
	ti Makefile aaslg aaslr todo | hplist
	hplist lex syn sem interp aasl.1

clean:
	rm -f junk* dtr *.old core after.* ed.c ed.lexed c.syn c.lex

spotless:	clean
	rm -f c.aasl
