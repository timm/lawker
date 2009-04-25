#m 6801
# Program to check, program, and verify a 68701.
# Copied from Motorola ap note AN-832.
# Timing constants assume 4Mhz crystal.

# Variables for code stolen from 68701 data sheet.
.=128
imbeg:	.=.+2			# Start of data block.
imend:	.=.+2			# End of data block.
pntr:	.=.+2			# Start of EPROM area to be done.
wait:	.=.+2			# Counter value.

# Startup code.
.=0xb850
start:
	lds.i =0xff		# Initialize stack.
	ldaa.i 0x7		# Initialize port 1...
	staa.d p1ddr		# ...bottom 3 bits outputs...
	staa.d p1		# ...all LEDs off.

# Check if EPROM has been erased properly.
	ldx.i =0xf800		# Start of EPROM.
	stx.d pntr		# Initialize pntr while number is handy.
	ldab.i 0		# Prepare to compare.  [Why not clrb???]
erase:	ldaa.x 0		# Pick up EPROM byte.
	cba
	bne %error1		# Branch if not zero.
	cpx.i =0xffff		# Are we done?
	beq %next		# Branch on done.
	inx
	bra %erase

# Turn on "erased" LED.
next:	ldaa.i 0x6		# First LED on.
	staa.d p1

# Delay a while (3.5 s) to be sure Vpp is up.
	stx.d wait		# [this seems useless]
	ldx.i =70		# 70 times through loop.
stall1:	dex
	ldd.i =0xc350		# 50 ms loop.
	addd.d timer		# Relative to current timer value.
	clr.e =tcsr		# Clear output-compare bit.
	std.d outcmp
	ldaa.i 0x40		# Now wait for bit to come high.
stall2:	bita.d tcsr
	beq %stall2		# Branch on bit still 0.
	cpx.i =0		# 70 times yet?  [Why not tstx???]
	bne %stall1		# Branch on no.
	bra %pgint		# Branch on yes.

# Light error LED only.
error1:	ldaa.i 0x83		# Error LED only.  [Why not just 0x3???]
	staa.d p1
	bra %self

# Initialize variables for programming code.
pgint:	ldx.i =0x7800		# Start of data memory.
	stx.d imbeg
	ldx.i =0x7fff		# End of data memory.
	stx.d imend
	ldx.i =0xc350		# Programming delay, 50 ms.
	stx.d wait
	# pntr has been initialized earlier.

# Basic programming code, from 68701 data sheet.
eprom:	ldx.d pntr		# Save initial pntr on stack.
	pshx
	ldx.d imbeg		# x -> data

# Program a byte.
epr002:	pshx			# Save data ptr on stack.
	ldaa.i 0xfe		# Remove Vpp, set latch.
	staa.d epromcr		# PPC=1, PLC=0.
	ldaa.x 0		# Pick up data.
	ldx.d pntr		# x -> dest
	staa.x 0		# Store into latch.
	inx			# Update destination addr...
	stx.d pntr
	ldaa.i 0xfc		# Fire up Vpp.
	staa.d epromcr		# PPC=PLC=0.

# Wait 50 ms for programming to happen.
	ldd.d wait		# d = delay.
	addd.d timer		# d = time to wake up.
	clr.e =tcsr		# Clear output-compare flag.
	std.d outcmp		# Set alarm.
	ldaa.i 0x40		# Wait for flag.
epr004:	bita.d tcsr
	beq %epr004		# Branch on not set yet.

# Set up for next byte.
	pulx			# x -> data
	inx
	cpx.d imend		# Are we done?
	bls %epr002		# Branch on no, with x -> next data.
	ldaa.i 0xff		# Turn off Vpp, inhibit latch...
	staa.d epromcr
	pulx			# Put pntr back as it was...
	stx.d pntr

# Verify.  End of datasheet code.
	ldx.i =0x7800		# x -> data
verf2:	pshx			# Save data ptr on stack.
	ldaa.x 0		# a = data
	ldx.d pntr		# x -> eprom
	ldab.x 0		# a = eprom data
	cba			# Same?
	bne %error2		# Branch on different.
	inx			# Next...
	stx.d pntr
	pulx			# x -> data
	inx
	cpx.i =0x8000		# Done yet?
	bne %verf2		# Branch on no.

# We're done.  Light the verify LED.
	ldaa.i 0x84		# Erased & verified.  [Why not just 0x4???]
	staa.d p1

# Branch-to-self loop for completion and errors.
self:	bra %self

# Verify error.
error2:	ldaa.i 0x82		# Erased & error LEDS.  [Why not 0x2???]
	staa.d p1
	bra %self

# Vectors.
.=0xbff0
	=self
	=self
	=self
	=self
	=self
	=self
	=self
	=start			# Reset vector.
