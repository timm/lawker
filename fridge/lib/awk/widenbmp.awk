#.H1 Widen_Bmp.awk
#.P                                             
# This script widens lines in .bmp files to make them more visible
# when converted to TV video images.  For the complete conversion, it
# is also necessary to mung the line colors to get rid of interpolated
# colors and togive some lines more contrast, but that is done elsewhere.
# This script is gawk specific.
#.H2 Code
#.H3 Bytes2Number
#.P
# This functions converts byte strings (binary numbers) into their 
# corresponding numeric strings so that they can be processed as gawk numbers.
# The lookup table (CharString) is a global variable.
# This code assumes that binary numbers are big-endian (most significant
# byte first) - it is up to the calling program to order the bytes.
#.P
#.P
# On the first use, the (global) LUT is created, then left for later use.  It
# consists of a list of characters from \000 to \777 in order - the (index
# value minus 1) of a character multiplied by the power of 256 corresponding
# to its position in the string is the byte's numerical weight.  The function
# doesn't care about the length of the byte string (within the integer limits
# of the gawk version and port).
#.PRE
function Bytes2Number( String,  x, y, z, Number ) {
	if( !CharString ) {
		for( x = 0; x <= 255; x++ ) CharString = CharString sprintf( "%c", x )
	}
	x = split( String, Scratch, "" )
	Number = 0
	for( y = 1; y <= x; y++ ) {
		z = index( CharString, Scratch[ y ] ) -1

		Number = Number + z * (256^(x - y))
	}
	return Number	# Note that Number is a regular gawk scalar variable.
}
#./PRE
#.H3 RealSize
#.P
# Uses a brute force approach to factor the image size into width and height
# numbers that actually match the real image size.  It searches around the
# nominal values for a pair of numbers that, when multiplied together, produce
# the known size of the image in pixels.
#.PRE
function RealSize( Wide, High, Pixels,  x, y ) {
	for( x = Wide - 5; x <= Wide +5; x++ ) {
		for( y = High - 5; y <= High + 5; y++ ) {
			if( x * y == Pixels ) {
				Width = x
				Height = y	
			}
		}
	}	
}
#.?PRE
#.H3 BEGIN
#.P
# It is necessary to tell gawk to read/write the file as binary, especially under
# Windows where ^Z in files is a killer.  Setting BINMODE to 3 will also work,
# but it throws error messages.
#.P
# Setting FS to null causes gawk to make each byte a separate field.
#.P
# Testing indicates that, in Windows at least, it is necessary to specify RS, even though
# it would appear redundant to set it to \n - not doing so results in 0A0D being
# replaced with 0A in the output, with the loss of one byte for each occurance.
# The value is arbitrary - it has been tested using one of the line colors.
#.PRE
BEGIN{
	BINMODE = "rw"
	FS= ""
    # The next two lines are not strictly necessary- 
    # there are here for clarity.
	Header = ""
	ByteCount = 0
	RS = "\n"
}
#./PRE
#.H3 For Each Record...
#.P
# Read the file into an array.  If there are multiple lines, that is, if RS appears
# in the file, insert the record separator back into the array at the end of 
# each line for which RT exists.
#.PRE
{
	for( x = 1; x <= NF; x++ ) Bytes[ ++ByteCount ] = $(x)	
	if( RT ) { Bytes[ ++ByteCount ] = RT }
}
#./PRE
#.H3 END
#.P
# Closing FILENAME here allows overwriting the original file - if that is
# desired, comment out the next line (which creates a new filename for the
# output).
#.P
# Regarding image parameters:  Width and Height are in pixels; Depth is the number of bytes
# per pixel; Data is the zero based index of the actual image in the file; Size 
# refers to the bytes in the file, not the image; ImgSize is the number of pixels
# in the image.
# Unfortunately, Width and Height may be wrong: RealSize() calculates the actual values
# as found from the data block.
#.P
# Once the image parameters are set, the two arrays for the image can be built: one to contain an unmodified
# copy (A) and one to contain a copy to be modified (B).  These arrays are
# indexed by line and dots (Height, Width); data are complete pixels.  The C 
# array is used to determine the background color: it uses the pixel data as indexes
# and the count of the number of copies of that pixel as values - the largest value
# represents the most common color, and assuming that the image is mostly background,
# therefore the background color.  This assumption will be true for almost all line art.
#.P
# When performing line widening: for each pixel that is not part of
# the background, copy its color to the four surrounding pixels, provided that
# they are background.  This approach prevents one line from encroaching on another,
# but does not prevent the ends of lines that do not intersect other lines from
# growing by one pixel on each pass through the program for each free end.
# u, v, w, and z (z has been reused) are the coordinates of the four pixels
# surrounding the one in work (defined by x and y).	
#.PRE
END{
	if( !OutFile ) OutFile = FILENAME
	close( FILENAME )
	sub( /[bB][mM][pP]$/, "widened.bmp" Arr[1], OutFile )
	Width = Bytes2Number( Bytes[ 22 ] Bytes[ 21 ] Bytes[ 20 ] Bytes[ 19 ] )
	Height = Bytes2Number( Bytes[ 26 ] Bytes[ 25 ] Bytes[ 24 ] Bytes[ 23 ] )
	Data = Bytes2Number( Bytes[ 14 ] Bytes[ 13 ] Bytes[ 12 ] Bytes[ 11 ] )
	Size = Bytes2Number( Bytes[ 6 ] Bytes[ 5 ] Bytes[ 4 ] Bytes[ 3 ] )
	Depth = Bytes2Number( Bytes[ 30 ] Bytes[ 29 ] ) / 8
	ImgSize = Bytes2Number( Bytes[ 38 ] Bytes[ 37 ] Bytes[ 36 ] Bytes[ 35 ] )
	RealSize( Width, Height, ImgSize / Depth )
    # Output the header in its original form to the target file.
	for( x = 1; x <= Data; x++ ) Header = Header Bytes[ x ]
	printf( "%s", Header ) > OutFile
    # Build the two arrays
	for( x = 1; x <= Height; x++) {
		for( y = 1; y <= Width; y++ ) {
			S = ""
            # Values for the A & B array entries are strings of 
            # bytes representing the color of the pixel, either directly or 
            # as a pointer into a palette.
			for( z = 1; z <= Depth; z++ ) S = S Bytes[ ++Data ]
			A[x,y] = S
			B[x,y] = S
			C[ S ]++
		}
	}
	
	z = 0
    # Bkg is the (assumed) background color.  
    # The code is a simple maximum value loop.
	for( x in C ) {
		y = C[x]
		if( y > z ) {
			Bkg = x
			z = y
		}
	}
   # Begin the actual line widenning code.
	for( x = 1; x <= Height; x++) {
		for( y = 1; y <= Width; y++ ) {
			if( A[x,y] !~ Bkg ) {
					u = x + 1
					v = x - 1
					w = y + 1
					z = y - 1
					if( B[u,y] ~ Bkg ) B[u,y] = A[x,y]
					if( B[v,y] ~ Bkg ) B[v,y] = A[x,y]
					if( B[x,w] ~ Bkg ) B[x,w] = A[x,y]
					if( B[x,z] ~ Bkg ) B[x,z] = A[x,y]
					if( B[u,w] ~ Bkg ) B[u,w] = A[x,y]
					if( B[u,z] ~ Bkg ) B[u,z] = A[x,y]
					if( B[v,w] ~ Bkg ) B[v,w] = A[x,y]
					if( B[v,z] ~ Bkg ) B[v,z] = A[x,y]
			}
		}
	}
	for( x = 1; x <= Height; x++) {
		for( y = 1; y <= Width; y++ ) {
			printf( "%s", B[x,y] ) > OutFile
		}
	}
}
#./PRE
#.P
# Note the final nested for loops in the above code.
# After the B array has been modified, the target file can be completed
# by reading that array out to the file pixel by pixel.  The array cannot be
# output during processing because pixels that have already been through
# the processor can still be changed.
#.H2 Author
#.P Ted Davis  tdavis@mst.edu.
