#!/pkg/gnu/bin/gawk -f
#
# Demonstration to DoD of a clustering algorithm suitable for streaming data
#
# Copyright 2009, Ronald Loui
#
# For more on this program, see http://awk.info/?awk100/006boris
#
# usage gawk -f boris.awk > borisOut.html
# also, the following CGI GET params are used
# n=N        : problem size and m is the cluster target during set-up 
# m=M        : cluster target during set-up
# anneal=A   : whether or not to anneal
# smooth=S   : usually try to put a cliff in the data whenever we do iterative tests

BEGIN {
  print "Content-type: text/html\n"
  print "<style>"
  print "td {font-size:8pt}"
  print "</style>"
  cgidat = ENVIRON["QUERY_STRING"]
  split(cgidat,temp,"&")
  for (i in temp) {
    split(temp[i],ttt,"=")
    cd[ttt[1]] = ttt[2]
  }
  n = cd["n"]
  m = cd["m"]
  smooth = cd["smooth"]
  anneal = cd["anneal"]
  skip = cd["skip"]
  if (!n) n = 20
  if (!m) m = 4
  if (!anneal) anneal = 1
  if (!smooth) smooth = 8
  if (skip == "") skip = 1
  srand()
  init()
  print "classes = "m
  display(p)
  for (ep=1; ep<=100; ep++) {
    print "\tepoch"ep
    if (anneal && rand() < exp(-ep/smooth)) {
      randstep = 1
      jbest = ibest = int(1+rand()*n)
      while (ibest==jbest) jbest = int(1+rand()*n)
      print "<font color=red>taking random step</font>"
    } else {
      randstep = 0
      # better do this just in case all are skipped (very improbable!)
      jbest = ibest = int(1+rand()*n)
      while (ibest==jbest) jbest = int(1+rand()*n)
      best = ""
      for (i=1; i<=n; i++) {
        for (j=i+1; j<=n; j++) {
          if (skip && rand() < exp(-ep/smooth)) {
            print "<font color=red>(skipping "i,j")</font>"
            continue
          }
          swap(i,j)
          # display(temp)
          ts = score()
          # print ts
          if (best=="" || ts > best) { best = ts; ibest = i; jbest = j }
        }
      }
      if (!anneal && !skip && best < lastbest) exit
      lastbest = best
    }
    swap(ibest,jbest)
    # commit
    for (i=1; i<=n; i++) for (j=1; j<=n; j++) p[i,j] = temp[i,j]
    if (randstep) {
      lastbest = best = score()
      print "random swap is "who[ibest],who[jbest]
      print "score is "best
    } else {
      print "best swap is "who[ibest],who[jbest]
      print "score is "best
    }
    # track the changes
    tempwho = who[ibest]
    who[ibest] = who[jbest]
    who[jbest] = tempwho
    display(p)
  }
}
func display(arr, i,j) {
  print "<table border=1 cellpadding=0 cellspacing=0>"
  print "<tr><td></td>"
  for (j=1; j<=n; j++) print "<td>"who[j]"</td>"
  print "</tr>"
  for (i=1; i<=n; i++) {
    print "<tr><td>"who[i]"</td>"
    for (j=1; j<=n; j++) {
      print "<td bgcolor=" f(arr[i,j]) " width=10 height=5>&nbsp;</td>"
    }
    print "</tr>"
  }
  print "</table>"
}
func abs(x) {
  if (x<0) return -x
  return x
}
func f(n) {
  raw = int(n*60.0+.5)
  if (raw < 0) raw = 0
  if (raw > 255) raw = 255
  first = int(raw/16)
  second = raw%16
  key = "0123456789ABCDEF"
  res = substr(key,first+1,1)substr(key,second+1,1)
  return res res res
}
func swap(i,j, ii,jj,key) {
  for (ii=1; ii<=n; ii++) key[ii] = ii
  key[i] = j; key[j] = i
  #ck = 0
  for (ii=1; ii<=n; ii++) for (jj=1; jj<=n; jj++) {
    temp[ii,jj] = p[key[ii],key[jj]]
    #ck += temp[ii,jj]
  }
  #print "temp="ck
}
# begin export2c
func score(  i,j,res) {
  res = 0
  for (i=1; i<=n; i++) {
    for (j=1; j<=n; j++) {
      # loui
      res -= temp[i,j]/(.1+abs(i-j))
      # pjm
      #res += abs(temp[i,j]-temp[w(i-1),w(j+1)])
      #res += abs(temp[i,j]-temp[w(i+1),w(j-1)])
      #res += abs(temp[i,j]-temp[w(i+1),w(j+1)])
      #res += abs(temp[i,j]-temp[w(i-1),w(j-1)])
    }
  }
  res = 1000-res
  return res
}
# end export2c
func init() {
  for (i=1; i<=n; i++) who[i] = i
  for (i=1; i<=n; i++) {
    for (j=1; j<=n; j++) {
      if (p[j,i]!="") { p[i,j] = p[j,i]; continue }
      kmax = 5
      if (i%m == j%m) kmax *=3
      if (diff=abs(i%m-j%m) < m/2) kmax+=diff
      for (k=1; k<=kmax; k++) {
        p[i,j] += rand()
      }
    }
  }
}
func w(i) {
  if (i>=1 && i<=n) return i
  if (i<1) return n
  if (i>n) return 1
}
