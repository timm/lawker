#m 6809
glop = 100

.data
.=200
it:	=1024
	067
	77
 
.text
.=700
main:
	lda.d glop
	cmpa.i 55
	ldx.x -5(u)
	ldu.x 017(y)
	ldy.x x++
	blt %main
.=.+11
	pag2 cmpd.i =it
	cwai %f(inz)
	cwai 0xff
	pulu %r(dxy)

.data
	87
