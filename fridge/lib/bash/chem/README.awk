.H1 Chem
.H2 INSTALLATION
.P
The file chem invokes chem.awk, which is where the dirty
work gets done.  chem.awk tells pic to include a copy
of chem.macros;  you will need to change a pathname on
the 2nd line of chem.awk.
.P
You need current versions of awk and pic.  In particular,
your awk has to support functions and your pic has to know
about the copy statement.  So if you get weird messages
from either of those, it's time to update.
.P
There are several test files called *.p.

.H2 INTRODUCTION
.P
"chem" is yet another preprocessor like eqn, pic, etc., 
this time for producing chemical structure diagrams.
Today's version is best suited for organic chemistry
(bonds, rings) and it's excruciatingly slow sometimes.
Who knows what the future may hold.
.P
In a style reminiscent of eqn and pic, diagrams are
written in a special language and occur in a document
surrounded by lines beginning
.tt	.cstart
and
.tt	.cend
.P
(in the first column, naturally).  Anything outside
these is copied through intact;  whatever is between
.cstart and .cend is converted into pic commands to
draw the diagram.
.P
So as a bare minimum,
.pre
	.cstart
	CH3
	bond
	CH3
	.cend
./pre
.P
prints two CH3 groups with a bond between them.
To actually print this, you must run chem, pic,
troff, and your output filter on whatever file
contains the input:
.tt	chem [file...] | pic | troff ... | ...
.P
(By the way, chem needs the current version of awk;
you will get some mysterious error messages from awk
if your version is too old.  You will also profit from
having sensible and consistent definitions for the PS
and PE macros.)


.H2 THE LANGUAGE

.P
The chem input language is rather small.  It provides
bonds of several styles, moieties (e.g., C, NH3, ...),
rings of several styles, and a way to glue them together
as desired.  In addition, since chem is a pic preprocessor,
it's possible to include pic statements in the middle of
a diagram to draw things not provided for by chem itself.
.H3 Bonds
.P
.tt	bond [direction] [length n] [from Name | picstuff]
.P
draws a single bond in direction from nearest corner of Name
"bond" can also be double bond, front bond, back bond, etc.
(We'll get back to "Name" in a minute.)
.P
"direction" is the angle in degrees (0 up, positive clockwise)
or a direction word like up, down, sw (= southwest), etc.
If no direction is specified, the bond goes in the current
direction (usually that of the last bond).
.P
Normally the bond begins at the last object placed;  this
can be changed by naming a "from" place.  For instance,
to make a simple alkyl chain:
.pre
	CH3
	bond		(this one goes right from the CH3)
	C		(at the right end of the bond)
	double bond up	(from the C)
	O		(at the end of the double bond)
	bond right from C
	CH3
./pre
.P A length in inches may be specified to override the default length.
Other pic commands can be tacked on to the end of a bond command,
to created dotted or dashed bonds or to specify a "to" place.

.H3 Names
.P
In the alkyl chain above, notice that the carbon atom C
was used both to draw something and as the name for a place.
A moiety always defines a name for a place;  you can use
your own names for places instead, and indeed, for rings
you will have to.  A name is just

.tt	Name: ...
.P
"Name" is often the name of a moiety like CH3, but it
needn't be.  Any name that begins with a capital letter
and contains only letters and numbers is ok:
.pre
	First:  bond
		bond 30 from First
./pre
.P draws something like
.pre
	     /
	____/
./pre

.h3 Moieties
.P
A moiety is a string of characters beginning with a capital letter,
such as N(C2H5)2.  Numbers are converted to subscripts (unless
they appear to be fractional values, as in N2.5H).  The moiety
names itself after special characters have been stripped out:
N(C2H5)2) has the name NC2H52.
.P
BP is a special "branch point" (i.e., line crossing) that doesn't print.
.P
Normally a moiety is placed right after the last thing mentioned,
but it may be positioned by pic-like commands, e.g.,

.pre	CH3 at C + (0.5,0.5)
.P
Text within quotes "..." is treated more or less like a
moiety except that no changes are made to the quoted part.


.H3 Rings:
.P
There are lots of rings, but only 5 and 6-sided rings get
much support.  "ring" by itself is a 6-sided ring;
"benzene" is the benzene ring with a circle inside.
"aromatic" puts a circle into any kind of ring.
.pre
	ring [pointing up|right|left|down] [aromatic] 
		[put Mol at n] [double i,j k,l ...]
		[picstuff]
./pre
.P
The vertices of a ring are numbered 1,2,... from the vertex
that points in the natural compass direction.  So for a
hexagonal ring with the point at the top, the top vertex is 1,
while if the ring has a point at the east side, that is
vertex 1.  This is expressed as
.pre
	R1: ring pointing up
	R2: ring pointing right
./pre
.P
The ring vertices are named .V1 .. .Vn, with .V1 in the
pointing direction.  So the corners of R1 are R1.V1 (the "top"),
R1.V2, R1.V3, R1.V4 (the "bottom"), etc., whereas for R2,
R2.V1 is the rightmost vertex and R2.V4 the leftmost.  These
vertex names are used for connecting bonds or other rings.
For example:
.pre
	R1: benzene pointing right
	R2: benzene pointing right with .V6 at R1.V2
./pre
.P
creates two benzene rings connected along a side.
.P
Interior double bonds are specified as "double n1,n2 n3,n4 ...";
each number pair adds an interior bond.  So the alternate form
of a benzene ring is
.pre ring double 1,2 3,4 5,6
.P
Heterocycles (rings with something other than carbon at a vertex)
are written as "put X at V", as in
.pre	R: ring put N at 1 put O at 2
.P
In this heterocycle, R.N and R.O become synonyms for R.V1 and R.V2.
.P
There are two 5-sided rings.  "ring5" is pentagonal with a side
that matches the 6-sided ring;  it has four natural directions.
A "flatring" is a 5-sided ring created by chopping one corner
of a 6-sided ring so that it exactly matches the 6-sided rings.
.P
The description of a ring has to fit on a single line.

/h3
Miscellaneous
.P
The specific construction

.pre	bond... ; moiety		(spaces matter!)
.P
is equivalent to
.pre
	bond
	moiety
./pre
.P
Otherwise, each item has to be on a separate line (and only one line).		
.P
A period "." in column 1 signals a troff command, which is copied
through as is.
.p
A line whose first non-blank character is a # is treated as a comment.
.p
A line whose first word is "pic" is copied through as is after
the "pic" has been removed.
.p
The command

.pre	size n
.p
scales the diagram so it looks plausible at point size n
(default is 10 point).
.p
Anything else is assumed to be pic and is copied through with
a label.

.h2 WISH LIST
.p
It's too slow (but it's too early in the game to optimize).
.p
Error checking is minimal;  errors are usually detected
and reported in an oblique fashion by pic.
.p
There's no library or file inclusion mechanism, and there's
no shorthand for repetitive structures.
.p
The extension mechanism is to create pic macros, but these
are tricky to get right and don't have all the properties
of built-in objects.
.p
There's no in-line chemistry yet (e.g., analogous to
the $...$ construct of eqn).
.p
There is no way to control entry point for bonds on groups.
Normally a bond connects to the carbon atom if entering from
the top or bottom and otherwise to the nearest corner.
.p
Bonds from substituted atoms on heterocycles do not join
at the proper place without adding a bit of pic.
.p
There is no decent primitive for brackets.
.p
Text (quoted strings) doesn't work very well.
.p
A squiggle bond is needed.


.H2 Author
.P
If something doesn't work, or if you can see a way to
make something better, let us know.
.pre
	jon bentley
	lynn jelinski
	brian kernighan
./pre
