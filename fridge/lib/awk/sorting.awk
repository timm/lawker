#.H1 Sorting in Awk
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/sorting.awk LAWKER.
#.H2 About
#.P
#Below is a script I wrote to demonstrate how to use arrays, functions,
#numerical vs string comparison, etc. 
#.P
#It also provides a framework
#for people to implement sorting algorithms for comparison. I've
#implemented a couple and I'm hoping others will contribute more in
#the same style. 
#.P
#I put very few comments in deliberately because I
#think the only parts that are hard to understand given some small
#amount of reading awk manuals are the actual sorting algorithms,
#and those should be well documented already given a reference except
#my made-up "Key Sort" but I think that's very easy to understand.
#.H2 Code
#.H3 selSort
#.P Selection Sort, O(n^2): http://en.wikipedia.org/wiki/Selection_sort
#.PRE
function selSort(keyArr,outArr,   swap,thisIdx,minIdx,cmpIdx,numElts) {
  for (thisIdx in keyArr) {
      outArr[++numElts] = thisIdx
  }
  for (thisIdx=1; thisIdx<=numElts; thisIdx++) {
      minIdx = thisIdx
      for (cmpIdx=thisIdx + 1; cmpIdx <= numElts; cmpIdx++) {
          if (keyArr[outArr[minIdx]] > keyArr[outArr[cmpIdx]]) {
              minIdx = cmpIdx
          }
      }
      if (thisIdx != minIdx) {
          swap = outArr[thisIdx]
          outArr[thisIdx] = outArr[minIdx]
          outArr[minIdx] = swap
      }
  }
  return numElts+0
}
#./PRE
#.H3 keySort
#.P
#Key Sort O(n^2): made up by Ed Morton for simplicity.
#.PRE
function keySort(keyArr,outArr,   \
                occArr,thisIdx,thisKey,cmpIdx,outIdx,numElts) {
  for (thisIdx in keyArr) {
      thisKey = keyArr[thisIdx]
      outIdx=++occArr[thisKey]  # start at 1 plus num occurrences
      for (cmpIdx in keyArr) {
          if (thisKey > keyArr[cmpIdx]) {
              outIdx++
          }
      }
      outArr[outIdx] = thisIdx
      numElts++
  }
  return numElts+0
}
#./PRE
#.H3 genSort
#.P
#This code demonstrates the use
#of arrays, functions, and string vs numeric comparisons in awk.
# It also provides a framework for people to implement various
# sorting algorithms in awk such as those listed at
#.URL   http://en.wikipedia.org/wiki/Sorting_algorithm   http://en.wikipedia.org/wiki/Sorting_algorithm
#.P
# Traverses the input array, storing it's indices in the output
# array in sorted order of the input array elements. e.g.
#.P
#.PRE
# in:  inArr["foo"]="b"; inArr["bar"]="a"; inArr["xyz"]="b"
#      outArr[] is empty
#
# out: inArr["foo"]="b"; inArr["bar"]="a"; inArr["xyz"]="b"
#      outArr[1]="bar"; outArr[2]="foo"; outArr[3]="xyz"
#./PRE
#.P
# Can sort on specific fields given a field number and
# field separator.
#.P
# sortType of "n" means sort by numerical comparison, sort by
# string comparison otherwise.
#.PRE
function genSort(sortAlg,sortType,inArr,outArr,fldNum,fldSep,           \
              keyArr,thisIdx,thisArr) {
  if (fldNum) {
      if (sortType == "n") {
          for (thisIdx in inArr) {
              split(inArr[thisIdx],thisArr,fldSep)
              keyArr[thisIdx] = thisArr[fldNum]+0
          }
      } else {
          for (thisIdx in inArr) {
              split(inArr[thisIdx],thisArr,fldSep)
              keyArr[thisIdx] = thisArr[fldNum]""
          }
      }
  } else {
      if (sortType == "n") {
          for (thisIdx in inArr) {
              keyArr[thisIdx] = inArr[thisIdx]+0
          }
      } else {
          for (thisIdx in inArr) {
              keyArr[thisIdx] = inArr[thisIdx]""
          }
      }
  }
  if (sortAlg ~ /^sel/) {
      numElts = selSort(keyArr,outArr)
  } else {
      numElts = keySort(keyArr,outArr)
  }
  return numElts
}
#./PRE
#.H3 Main Loop
#.P
#.PRE { inArr[NR]=$0 }
#.H3 Output
#.PRE
END {
  numElts = genSort(sortAlg,sortType,inArr,outArr,fldNum,FS)
  for (outIdx=1;outIdx<=numElts;outIdx++) {
      print inArr[outArr[outIdx]]
  }
}
#./PRE
#.H2 Author
#.P Ed Morton
