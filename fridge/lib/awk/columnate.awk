#.H1 Columnate
#.H2 Synopsis
#.PRE 
##e.g.
#gawk -F: -f columnate.awk /etc/passwd
#./PRE
#.H2 Download
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/columnate.awk LAWKER.
#.H2 About
#This script columnates the input file, so that columns line up like in the GNU column(1) command. Its output is like that of column -t. First, awk reads the whole file, keeps track of the maximum width of each field, and saves all the lines/records. At the END, the lines are printed in columnated format. If your terminal is not too narrow, you'll get a handsome display of the file.
#.H2 Code
#.PRE
{   line[NR] = $0    # saves the line
    for (f=1; f<=NF; f++) {
        len = length($f)
        if (len>max[f])
            max[f] = len }  # an array of maximum field widths
}
END {
    for(nr=1; nr<=NR; nr++) {
        nf = split(line[nr], fields)
        for (f=1; f<nf; f++)
            printf "%-*s", max[f]+2, fields[f]
        print fields[f] }     # the last field need not be padded
}
#./PRE
#.H2 Author
#.P
# h-67-101-152-180.nycmny83.dynamic.covad.net

