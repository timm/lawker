#.H1 rcalc
#.H2 Synposis
#.PRE
##eg
# gawk -v target=89000 -f rcalc.awk 
#./PRE
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/rcalc.awk LAWKER.
#.H2 About
#.P
# Calculate resistor pair value from e24 series to make up arbitrary value
#.P
# When designing and building electronic projects I mostly use 1% resistors
#  that come in the E24 series (24 values per decade).
#.P
# Frequently there's a need for some arbitrary value (between 10R and 1M
#  in this script) resistor that can be made with a series or parallel
#  combination of two standard values.
#.P
# This script searches the E24 standard value space for pairs of resistors
#  that will produce or come close to the desired arbitrary resistor value.
#.H2 Example
#.PRE
#$ gawk -v target=89000 -f rcalc.awk
#       Result         Ra      Rb  Connect    Error
#       88800.00    82000    6800  series    -0.22%
#       88888.89   200000  160000  parallel  -0.12%
#       89000.00    56000   33000  series
#       89000.00    62000   27000  series
#       89130.43   820000  100000  parallel  +0.15%
#       89137.93   470000  110000  parallel  +0.15%
#       89189.19   220000  150000  parallel  +0.21%
#./PRE
#.H2 Code
#.SMALL
#.PRE
BEGIN {
     print "Result      Ra   Rb  Connect    Error"

     max_error = 0.005         # +/- 0.5%
     max_multiplier = 10000       # try four decades

     format = "%8.2f  %7d %7d  %-8s  %+4.2f%%"
     formnz = "%8.2f  %7d %7d  %-8s"

     limit_hi = target * (1 + max_error)
     limit_lo = target * (1 - max_error)

$0 = "10 11 12 13 15 16 18 20 22 24 27 30 33 36 39 43 47 51 56 62 68 75 82 91"

     for (i = 1; i < 25; i++) {
       e24[i] = $i
     }
     for (u = 1; u < 25; u++) {
       for (v = 1; v < 25; v++) {
            for (i = 1; i <= max_multiplier; i *= 10) {
                 x = e24[u] * i
                 if (x == target) {
                   continue
                 }
                 for (j = 1; j <= max_multiplier; j *= 10) {
                   y = e24[v] * j
                   if (y == target) {
                        continue
                   }
                   combo(e24[u] * i, e24[v] * j)
                 }
            }
       }
     }
     exit      # skip file reader
}
function combo(a, b,   c) {
     # parallel
     c = a * b / (a + b)
     combo2(a, b, c, "parallel")
     # series
     c = a + b
     combo2(a, b, c, "series")
}
function combo2(a, b, c, d,   e, f) {
     # avoid duplicates and ignore result when error too big
     if (a < b || c < limit_lo || c > limit_hi) { return }
     e = 100 * (c - target) / target      # percentage error
     f = (e == 0 ? formnz : format)       # select output format
     result[n++] = sprintf(f, c, a, b, d, e)
}
END {
     # sort by result value, print list
     n = asort(result, sort_result)
     for (i = 1; i <= n; i++) {
       print sort_result[i]
     }
}
#./PRE
#./SMALL
#.H2 Author
#.P
# Copyright (c) 2009 Grant Coady &lt;http://bugsplatter.id.au> GPLv2
