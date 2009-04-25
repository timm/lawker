# Regression test.
r:	aaa 01pgm.s try.s
	aaa 01pgm.s
	cmp 01pgm.x 01pgm.x.good
	aaa try.s
	cmp try.x try.x.good

clean:
	rm -f *.a *.defs *.x junk* tmp? dtr

dtr:
	makedtr README Makefile 01pgm.s 01pgm.x.good 6801/* 6809/* aaa \
	abst anon/* aux/* try.s try.x.good >dtr
