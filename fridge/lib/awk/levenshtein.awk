#.H1 levenshtein.awk
#.H2 Synopsis
#.PRE 
#gawk -f levenshtein.awk --source 'BEGIN {
#        print levdist("kitten", "sitting")}' 
#./PRE
#.P (The above code should print "3").
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/levenshtein.awk LAWKER.
#.H2 Notes
#.P
#The Levenshtein edit distance calculation is useful for comparing text strings for similarity, such as would be done with a spell checker.
#.P
#Hi_saito (from awk.freeshell.org) has written what looks like a straightforward implementation of the reference algorithm described in the above-linked Wikipedia article. hi_saito's code is linked to rather than included outright because no licensing terms appear on the page.
#.P
#Gnomon (from awk.freeshell.org) is planning to write a more compact (and hopefully speedier) implementation that will appear here soon. The plan is to compute and retain only those values that are necessary to calculate the edit distance, rather than calculating the entire NxM? matrix. The lazy-evaluation method, which can post substantial speed improvements, probably requires more effort and code complexity than the performance gains would be worth; still, for short strings, the lazy code could perhaps be modeled via recursion by executing from the end of the string rather than the beginning. If experiments are run, the results will also appear here.
#.P
#Here is the abovementioned streamlined implementation. There were eleven previous versions, all of which were benchmarked across gawk, mawk and busybox awk. The approaches started with a naive implementation and explored table-based, recursive (with no, single and shared memoization) and lazy models. As expected, the lazy version was incredibly fiddly and not pleasant to read or pursue. Findings will appear here later, but for now, here's the code.
#.H2 Code
#.H3 levdist
#.PRE
function levdist(str1, str2,    l1, l2, tog, arr, i, j, a, b, c) {
        if (str1 == str2) {
                return 0
        } else if (str1 == "" || str2 == "") {
                return length(str1 str2)
        } else if (substr(str1, 1, 1) == substr(str2, 1, 1)) {
                a = 2
                while (substr(str1, a, 1) == substr(str2, a, 1)) a++
                return levdist(substr(str1, a), substr(str2, a))
        } else if (substr(str1, l1=length(str1), 1) == substr(str2, l2=length(str2), 1)) {
                b = 1
                while (substr(str1, l1-b, 1) == substr(str2, l2-b, 1)) b++
                return levdist(substr(str1, 1, l1-b), substr(str2, 1, l2-b))
        }
        for (i = 0; i <= l2; i++) arr[0, i] = i
        for (i = 1; i <= l1; i++) {
                arr[tog = ! tog, 0] = i
                for (j = 1; j <= l2; j++) {
                        a = arr[! tog, j  ] + 1
                        b = arr[  tog, j-1] + 1
                        c = arr[! tog, j-1] + (substr(str1, i, 1) != substr(str2, j, 1))
                        arr[tog, j] = (((a<=b)&&(a<=c)) ? a : ((b<=a)&&(b<=c)) ? b : c)
                }
        }
        return arr[tog, j-1]
}
#./PRE
#.H3 Demo code
#.P
#Run demo.awk using  <em>gawk -f levenshtein.awk -f demo.awk</em>.
#.PRE
##demo.awk
#BEGIN {OFS = "\t"}
#{words[NR] = $0}
#END {
#   max = 0
#   for (i = 2; i in words; i++) {
#      for (j = i + 1; j in words; j++) {
#         new = levdist(words[i], words[j])
#         print words[i], words[j], new
#         if (new > max) {
#            max = new
#            bestpair = (words[i] " - " words[j] ": " new)
#         }
#      }
#   }
#   print bestpair
#}
#./PRE
#.H3 Unit tests
#.P
#Run utests.awk using <em>gawk -f levenshtein.awk -f utests.awk</em>.
##utests.awk
#.SMALL
#.PRE
#function testlevdist(str1, str2, correctval,    testval) {
#    testval = levdist(str1, str2)
#    if (testval == correctval) {
#        printf "%s:\tCorrect distance between '%s' and '%s'\n", testval, str1, str2
#        return 1
#    } else {
#        print "MISMATCH on words '%s' and '%s' (wanted %s, got %s)\n", str1, str2, correctval, testval
#        return 0
#    }
#}
#BEGIN {
#    testlevdist("kitten",    "sitting",   3)
#    testlevdist("Saturday",  "Sunday",    3)
#    testlevdist("acc",       "ac",    1)
#    testlevdist("foo",       "four",      2)
#    testlevdist("foo",       "foo",       0)
#    testlevdist("cow",       "cat",       2)
#    testlevdist("cat",       "moocow",    5)
#    testlevdist("cat",       "cowmoo",    5)
#    testlevdist("sebastian", "sebastien", 1)
#    testlevdist("more",      "cowbell",   5)
#    testlevdist("freshpack", "freshpak",  1)
#    testlevdist("freshpak",  "freshpack", 1)
#}
#./PRE
#./SMALL
#.H2 Author
#.P pierre.gaston &lt;a.t> gmail.com 
