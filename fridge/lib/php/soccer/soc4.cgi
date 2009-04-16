#!/usr/bin/gawk -f
BEGIN {
  # to run this, it must be chmod a+rx;
  # you also need:
  # init
  # and dirs and pos, which need to be chmod a+rw
  # and a directory tmp which is chmod a+rwx
  # and optionally, you need two players, which are chmod a+rx
  # and on linux boxes, the directory containing pos and dirs should be chmod a+rwx

  # to do:  static based on pos, not dirs (need to save pos for static)

  print "Content-type: text/html\n"

  srand()

  lmargin = 10
  tmargin = 10
  height = 300
  width = 600
  halfemh = 22
  halfemw = 12
  goalh = 8
  restrictw = 25
  restricth = 50

  MAXDEVP = 15
  DENSESPACE = 3
  SPARSESPACE = 8
  # -v for redplayer and greenplayer

  TRAILS = 0
  DELAY = 8
  SHOWPOS = 0

  redrgoal = height/2
  redcgoal = 0
  greenrgoal = height/2
  greencgoal = width

  com = ENVIRON["QUERY_STRING"]
  if (com ~ "init") {
    init()
    sub(/init/,"",com)
  }
  if (com+0 == com) system("sleep "com)
  split(com,temp,"&")
  for (i in temp) {
    split(temp[i],tt,"=")
    cgidat[tt[1]] = tt[2]
  }
  if ("delay1" in cgidat) system("sleep "cgidat["delay1"])
  if ("delay" in cgidat) DELAY = cgidat["delay"]
  if ("showpos" in cgidat) SHOWPOS = cgidat["showpos"]

  redplayer = cgidat["redplayer"]
  greenplayer = cgidat["greenplayer"]

  if (SHOWPOS) {
    print "<span style=position:absolute;left:10;top:"height+tmargin+30">"
    print "<table width=400 border=1><tr>"
    print "<td width=300>"
    print "<pre>"
    print "<font size=-2>"
    system("sort pos")
    print "</td><td width=300>"
    print "<pre>"
    print "<font size=-2>"
    system("sort dirs")
    print "</tr></table>"
    print "</span>"
  }

  print "<b>"redplayer"</b> vs. <b>"greenplayer"</b>"

  content = rand()"&redplayer="redplayer"&greenplayer="greenplayer
  if ("delay" in cgidat) content = content "&delay=" DELAY
  if ("showpos" in cgidat) content = content "&showpos=" SHOWPOS
  print "<meta http-equiv='refresh' content='"DELAY";URL=soc4.cgi?" content "'>"

  # the green
  print "<span style=z-index:-3;position:absolute;top:"tmargin+halfemh/2";left:"lmargin";height:"height+halfemh/2";width:"width";background-color:DDFFDD></span>"

  print "<p align=right>"
  print "<a href=dirs>dirs</a>"
  print "&nbsp;&nbsp;&nbsp;<a href=pos>pos</a>"
  print "&nbsp;&nbsp;&nbsp;<a href=soc4.cgi?init>init</a>"
  print "&nbsp;&nbsp;&nbsp;<a href=soc4.cgi?delay1=120&"content">2minpause</a>"
  print "&nbsp;&nbsp;&nbsp;<a href=start.html>params</a>&nbsp;&nbsp;&nbsp;<a href=..>stop</a>"
  print "</p>"
  graph(height/2-goalh,0,"|","red")
  graph(height/2,0,"|","red")
  graph(height/2+goalh,0,"|","red")
  graph(height/2-goalh,width,"|","green")
  graph(height/2,width,"|","green")
  graph(height/2+goalh,width,"|","green")

  # goalie boxes
  print "<span style=position:absolute;top:"tmargin+height/2-restricth/2+halfemh/2";left:"lmargin";height:"restricth";width:"restrictw";background-color:yellow;z-index:-2></span>"
  print "<span style=position:absolute;top:"tmargin+height/2-restricth/2+halfemh/2";left:"lmargin+width-restrictw";height:"restricth";width:"restrictw";background-color:yellow;z-index:-2></span>"

  while (getline < "pos" > 0) {
    # check for corruption
    if ($1 ~ /^[a-zA-Z0]$/) {
      dat[$1] = $0
      color[$1] = $2
      rdat[$1] = $3
      cdat[$1] = $4
      edat[$1] = $5
      if ($1 == "0") {
        rball = rdat["0"]
        cball = cdat["0"]
        if ($0 ~ /aloft/) notes["0"] = "aloft"
        if (match($0,/static[0-9]*/)) static["0"] = substr($0,RSTART+6,RLENGTH)
        if (match($0,/last:[0-9]*:[0-9]*/)) {
	  split(substr($0,RSTART+5,RLENGTH),temp,":")
	  rlast["0"] = temp[1]
	  clast["0"] = temp[2]
	}
      }
    }
  }
  close("pos")

  while (getline < "dirs" > 0) {
    if ($1 ~ /^[a-zA-Z0]$/) {
      dirdat[$1] = $0
      rdev[$1] = $3
      cdev[$1] = $4
      if ($1 == "0") {
	rrdev[$1] = rdev[$1]
        ccdev[$1] = cdev[$1]
      } else {
	rrdev[$1] = maxdev(rdev[$1],cdev[$1])
        ccdev[$1] = maxdev(cdev[$1],rdev[$1])
      }
      rkick[$1] = maxkick($6,$7)
      ckick[$1] = maxkick($7,$6)
      kick[$1] = $5" "$6" "$7
    }
  }
  close("dirs")

  # old way to slow the ball
  #rrdev["0"] = rdev["0"] = (abs(rdev["0"])-1)*sgn(rdev["0"])
  #ccdev["0"] = cdev["0"] = (abs(cdev["0"])-1)*sgn(cdev["0"])

  # print "moving"
  move()

  # print "making"
  if (redplayer) {
    com = "echo red | ./"redplayer
    while (com | getline) {
      if ($1 ~ /^[a-zA-Z0]$/) {
	if (color[$1] != "red") continue
        dirdat[$1] = $0
        rdev[$1] = $3
        cdev[$1] = $4
        if ($1 == "0") {
	  rrdev[$1] = rdev[$1]
          ccdev[$1] = cdev[$1]
        } else {
	  rrdev[$1] = maxdev(rdev[$1],cdev[$1])
          ccdev[$1] = maxdev(cdev[$1],rdev[$1])
        }
        rkick[$1] = maxkick($6,$7)
        ckick[$1] = maxkick($7,$6)
	kick[$1] = $5" "$6" "$7
        dnotes[$1] = $8
	for (i=9; i<=NF; i++) dnotes[$1] = dnotes[$1]" "$i
      }
    }
    close(com)
  }
  if (greenplayer) {
    com = "echo green | ./"greenplayer
    while (com | getline) {
      if ($1 ~ /^[a-zA-Z0]$/) {
	if (color[$1] != "green") continue
        dirdat[$1] = $0
        rdev[$1] = $3
        cdev[$1] = $4
        if ($1 == "0") {
	  rrdev[$1] = rdev[$1]
          ccdev[$1] = cdev[$1]
        } else {
	  rrdev[$1] = maxdev(rdev[$1],cdev[$1])
          ccdev[$1] = maxdev(cdev[$1],rdev[$1])
        }
        rkick[$1] = maxkick($6,$7)
        ckick[$1] = maxkick($7,$6)
	kick[$1] = $5" "$6" "$7
        dnotes[$1] = $8
	for (i=9; i<=NF; i++) dnotes[$1] = dnotes[$1]" "$i
      }
    }
    close(com)
  }
  makedirs()

  for (i in dat) {
    if (kicker && i==kicker) graph(rdat[i],cdat[i],"<font size=+2>"symbol(i) printme(i)"</font>",color[i])
    else graph(rdat[i],cdat[i],"<font size=-3>"symbol(i) printme(i)"</font>",color[i])
  }

  # print "writing"
  for (i in dat) {
    if (i == "0") print i, color[i], rdat[i], cdat[i], edat[i], notes[i], "static"static[i], "last:"staticlast[i] > "pos"
    else print i, color[i], rdat[i], cdat[i], edat[i], notes[i] > "pos"
  }
  close("pos")
  for (i in color) {
    if (i == "0") print i, color[i], rrdev[i], ccdev[i], kick[i], dnotes[i] > "dirs"
    else print i, color[i], rdev[i], cdev[i], kick[i], dnotes[i] > "dirs"
  }
  close("dirs")

}

func rok(x) {
  x = int(.5+x)
  if (x < 0) return 0
  if (x > height) return height
  return x
}

func cok(x) {
  x = int(.5+x)
  if (x < 0) return 0
  if (x > width) return width
  return x
}

func eok(x) {
  x = int(.5+x)
  if (x < 0) return 0
  if (x > 100) return 100
  return x
}

func printme(x) {
  if (x=="0") return ""
  return x
}

func symbol(x) {
  if (x=="0" && notes["0"] ~ /aloft/) return "^"
  if (x=="0") return "@"
  return ""
}

func sgn(x) {
  if (x < 0) return -1
  if (x > 0) return 1
  return 0
}

func abs(x) {
  if (x < 0) return -x
  return x
}

func move(  n) {
  goalie["a"] = 1
  goalie["A"] = 1

  for (i in dat) {
    print edat[i],i > "tmp/soc.tmp"
    orgedat[i] = edat[i]
  }
  close("tmp/soc.tmp")
  system("chmod a+rw tmp/soc.tmp")

  com = "sort -nr tmp/soc.tmp"
  while (com | getline) {
    order[++n] = $2
  }
  close(com)

  for (i=1; i<=n; i++) {
    who = order[i]
    # to do:  occupied indexed by team
    # occupied[rdat[who],cdat[who]] = who
    occupy(who,rdat[who],cdat[who])
  }

  for (i=1; i<=n; i++) {
    who = order[i]

    if (who == "0" && notes["0"] ~ /aloft/) aloftball = 1
    else aloftball = 0

    trykick(who)

    if (abs(cdev[who])>1 || abs(rdev[who])>1) go = 1
    else go = 0
    if (edat[who] > 0) {
      if (rdev[who]) slope = cdev[who]/rdev[who]
      else slope = "inf"

      if (slope == "inf") {
	if (ccdev[who] > 0) for (cj=1; go && cj<=ccdev[who]; cj++) {
	  if (!aloftball && !myclear(who,rdat[who],cok(cdat[who]+1))) go = 0
	  else {
	    edat[who]--
	    if (edat[who] <= 0) go = 0
	    cdat[who] = cok(cdat[who]+1)
	    occupy(who,rdat[who],cdat[who])
	    trykick(who)
	  }
	} else for (cj=ccdev[who]; go && cj<0; cj++) {
	  if (!aloftball && !myclear(who,rdat[who],cok(cdat[who]-1))) go = 0
	  else {
	    edat[who]--
	    if (edat[who] <= 0) go = 0
	    cdat[who] = cok(cdat[who]-1)
	    occupy(who,rdat[who],cdat[who])
	    trykick(who)
	  }
	}
      } else if (slope == 0) {
	if (rrdev[who] > 0) for (rj=1; go && rj<=rrdev[who]; rj++) {
	  if (!aloftball && !myclear(who,rok(rdat[who]+1),cdat[who])) go = 0
	  else {
	    edat[who]--
	    if (edat[who] <= 0) go = 0
	    rdat[who] = rok(rdat[who]+1)
	    occupy(who,rdat[who],cdat[who])
	    trykick(who)
	  }
	} else for (rj=rrdev[who]; go && rj<0; rj++) {
	  if (!aloftball && !myclear(who,rok(rdat[who]-1),cdat[who])) go = 0
	  else {
	    edat[who]--
	    if (edat[who] <= 0) go = 0
	    rdat[who] = rok(rdat[who]-1)
	    occupy(who,rdat[who],cdat[who])
	    trykick(who)
	  }
	}
      } else {
	if (abs(slope) > 1) {
          islope = 1/slope
	  if (ccdev[who] > 0) for (cj=1; go && cj<=ccdev[who]; cj++) {
	    if (!aloftball && !myclear(who,rok(rdat[who]+islope),cok(cdat[who]+1))) go = 0
	    else {
	      edat[who]--
	      if (edat[who] <= 0) go = 0
	      rdat[who] = rok(rdat[who]+islope)
	      cdat[who] = cok(cdat[who]+1)
	      occupy(who,rdat[who],cdat[who])
	      trykick(who)
	    }
	  } else for (cj=ccdev[who]; go && cj<0; cj++) {
	    if (!aloftball && !myclear(who,rok(rdat[who]-islope),cok(cdat[who]-1))) go = 0
	    else {
	      edat[who]--
	      if (edat[who] <= 0) go = 0
	      rdat[who] = rok(rdat[who]-islope)
	      cdat[who] = cok(cdat[who]-1)
	      occupy(who,rdat[who],cdat[who])
	      trykick(who)
	    }
	  }
	} else {
	  if (rrdev[who] > 0) for (rj=1; go && rj<=rrdev[who]; rj++) {
	    if (!aloftball && !myclear(who,rok(rdat[who]+1),cok(cdat[who]+slope))) go = 0
	    else {
	      edat[who]--
	      if (edat[who] <= 0) go = 0
	      rdat[who] = rok(rdat[who]+1)
	      cdat[who] = cok(cdat[who]+slope)
	      occupy(who,rdat[who],cdat[who])
	      trykick(who)
	    }
	  } else for (rj=rrdev[who]; go && rj<0; rj++) {
	    if (!aloftball && !myclear(who,rok(rdat[who]-1),cok(cdat[who]-slope))) go = 0
	    else {
	      edat[who]--
	      if (edat[who] <= 0) go = 0
	      rdat[who] = rok(rdat[who]-1)
	      cdat[who] = cok(cdat[who]-slope)
	      occupy(who,rdat[who],cdat[who])
	      trykick(who)
	    }
	  }
	}
      }
    } else {
      # zero the motion when tired?  NO
      # cdev[who] = rdev[who] = 0
    }

    edat[who] += 20
    edat[who] -= sqrt(rkick[who]*rkick[who]+ckick[who]*ckick[who])/3
    edat[who] -= 10*rand()
    if (edat[who] < orgedat[who]) {
      # cross a boundary and suffer an epenalty
      key = (index("aAbBcCdDeEfFgG",who)*length(greenplayer)+length(redplayer))%10
      if (edat[who] < 10*key && orgedat[who] > 10*key) {
        edat[who] -= 5*key
	# print "epenalty "who,key
      }
    }
    edat[who] = eok(edat[who])

    trykick(who)

    # check for goal
    if (who == "0") {
      rball = rdat["0"]
      cball = cdat["0"]
      edat["0"] = 100
      if (notes["0"] !~ /aloft/ || rand() < .5) {
        if (cball==redcgoal && abs(rball-redrgoal)<=goalh) {
	  print "<font style=font-size:1in;z-index:10>GREEN SCORES!</font>"
	  print greenplayer" SCORES ON "redplayer >> "score.log"
	  system("sleep 10")
	  init()
	  exit
        }
        if (cball==greencgoal && abs(rball-greenrgoal)<=goalh) {
	  print "<font style=font-size:1in;z-index:10>RED SCORES!</font>"
	  print redplayer" SCORES ON "greenplayer >> "score.log"
	  system("sleep 10")
	  init()
	  exit
        }
      }
    }

  }

  if (TRAILS) for (s in occupied) {
    split(s,temp,SUBSEP)
    graph(temp[1],temp[2],".","EEEEEE",-1)
    # graph(temp[1],temp[2],occupied[s],"black")
  }

}

func graph(r,c,x,xcolor,zz) {
  if (!zz) zz=0
  print "<span style=position:absolute;z-index:"zz";top:"tmargin+r";left:"lmargin+c";color:"xcolor">"x"</span>"
}

func makedirs() {
  # ball slows
  if (!kicked) {
    if (notes["0"] ~ /aloft/) {
      ccdev["0"] *= .7
      rrdev["0"] *= .7
    } else {
      ccdev["0"] *= .5
      rrdev["0"] *= .5
    }
  }
  # don't let ball wiggle
  if (abs(ccdev["0"]) < 1 && abs(rrdev["0"]) < 1) { 
    ccdev["0"] = 0
    rrdev["0"] = 0 
    notes["0"] = ""
  }
  # ball static count
  if ((ccdev["0"] == 0 && rrdev["0"] == 0) || (clast["0"] == cdat["0"] && rlast["0"] == rdat["0"])) {
    static["0"]++
    # print "ball has been sitting for "static["0"]
    if (static["0"] > 40) {
      print "RANDOM REPOSITIONING OF BALL!"
      static["0"] = 0
      rdat["0"] = rand()*height
      cdat["0"] = rand()*width
    }
  } else static["0"] = 0
  staticlast["0"] = rdat["0"]":"cdat["0"]

  # ball falls
  if (!kicked && notes["0"] ~ /aloft/) {
    if (rand() < .3) notes["0"] = ""
    if (ccdev["0"] < 1 && rrdev["0"] < 1) notes["0"] = ""
  }

  while (getline < "init") {
    rinit[$1] = $3
    cinit[$1] = $4
  }
  close("init")
  if (rand() < .9) chaser["f"] = 1
  if (rand() < .9) chaser["g"] = 1
  if (rand() < .7) chaser["F"] = 1
  if (rand() < .7) chaser["G"] = 1
  if (rand() < .4) chaser["c"] = 1
  if (rand() < .4) chaser["C"] = 1
  if (rand() < .4) chaser["b"] = 1
  if (rand() < .4) chaser["B"] = 1

  # to do:  vision based on direction, speed, ball, player
  for (i in dat) {

    if (redplayer && color[i] == "red") continue
    if (greenplayer && color[i] == "green") continue

    if (i == "0") continue

    key = index("aAbBcCdDeEfFgG",i)
    if (i != "0" && i !="a" && i != "A") {
      if (edat[i] > 20 && chaser[i] || (abs(cdat["0"]-cdat[i]) < 50 && abs(rdat["0"]-rdat[i]) < 20)) {
        cdev[i] = maxdev(cdat["0"]-cdat[i],rdat["0"]-rdat[i])
        rdev[i] = maxdev(rdat["0"]-rdat[i],cdat["0"]-cdat[i])
        if (edat[i] > 20 && abs(cdat["0"]-cdat[i]) < 20 && abs(rdat["0"]-rdat[i]) < 20) {
	  if (rand() < .8 && (cball < 20 || cball > width-20 || rand() < .25)) {
            if (color[i] ~ /red/) kick[i] = "kick.aloft " (greenrgoal-rdat[i]) " "greencgoal-cdat[i]
            if (color[i] ~ /green/) kick[i] = "kick.aloft " (redrgoal-rdat[i]) " "redcgoal-cdat[i]
	  } else {
            if (color[i] ~ /red/) kick[i] = "kick.aloft " (300+200*rand()) " "greencgoal-cdat[i]
            if (color[i] ~ /green/) kick[i] = "kick.aloft " (-300-200*rand()) " "redcgoal-cdat[i]
	  }
	} else kick[i] = ""
      } else if (edat[i] > 50) {
        cdev[i] = maxdev(cinit[i]-cdat[i],rinit[i]-rdat[i])
        rdev[i] = maxdev(rinit[i]-rdat[i],cinit[i]-cdat[i])
	kick[i] =""
      } else {
	cdev[i] = 0
	rdev[i] = 0
	kick[i] =""
      }
    }
  }
}

func maxkick(x,y,  z,zscale) {
  z = sqrt(x*x + y*y)
  if (z > 3*MAXDEVP) zscale = z/(3*MAXDEVP)
  else zscale = 1
  return x/zscale
}

func maxdev(x,y,  z,zscale) {
  z = sqrt(x*x + y*y)
  if (z > MAXDEVP) zscale = z/MAXDEVP
  else zscale = 1
  return x/zscale
}

func myclear(x,rr,cc,  y) {
  y = occupied[rr,cc]
  # ball can move past its kicker
  if (x == "0" && y == kicker) return 1
  # you can move into your own space or an unclaimed space
  if (!goalie[x] && (cc < restrictw || cc > width-restrictw) && abs(rr-height/2) < restricth/2) return 0 
  if (y == "") return 1
  if (y == "0") return 1
  if (x == y) return 1
  return 0
}

function occupy(who,rrr,ccc,ri,ci) {
  if (who == "0") return
  for (ri=-DENSESPACE; ri<=DENSESPACE; ri++)
    for (ci=-DENSESPACE; ci<=DENSESPACE; ci++)
      if (!occupied[rrr+ri,ccc+ci]) occupied[rrr+ri,ccc+ci] = who
  for (ri=-SPARSESPACE; ri<=SPARSESPACE; ri+=4)
    if (ri) for (ci=-SPARSESPACE; ci<=SPARSESPACE; ci+=4)
      if (ci) if (!occupied[rrr+ri,ccc+ci]) occupied[rrr+ri,ccc+ci] = who
}

func init() {
  system("/bin/cp -f init pos")
  print "" > "dirs"
  close("dirs")
  system("chmod a+rw pos dirs")
}

func trykick(who) {

  if (who == "0") return
  if (!kicked) {
    if (who != "0" && dirdat[who] ~ /kick/ && notes["0"] !~ /aloft/) {
      if (abs(rdat[who]-rball)<=6 && abs(cdat[who]-cball)<=10) {
	# kicking error based on ball speed, player speed, dist
	rrdev["0"] = rkick[who]
	rrdev["0"] += rand()*rrdev["0"]/20 - rand()*rrdev["0"]/20
	rrdev["0"] += rand()*rkick[who]/20 + rand()*rrdev[who]/20
	rrdev["0"] -= rand()*rkick[who]/20 + rand()*rrdev[who]/20
	ccdev["0"] = ckick[who]
	ccdev["0"] += rand()*ccdev["0"]/20 - rand()*ccdev["0"]/20
	ccdev["0"] += rand()*ckick[who]/20 + rand()*ccdev[who]/20
	ccdev["0"] -= rand()*ckick[who]/20 + rand()*ccdev[who]/20
	# static["0"] = 0
	# not necessarily moved if kicked!
	kicked = 1
        kicker = who
	if (dirdat[who] ~ /aloft/) {
	  if (rand() < .95-rrdev[who]/10-ccdev[who]/10) notes["0"] = "aloft"
	}
      }
    }

    # to do: ball bounce

  }
}

