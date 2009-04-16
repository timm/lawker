#!/usr/bin/gawk -f 
BEGIN {
  print "Content-type: text/html\n"
  srand()

  lmargin = 10
  tmargin = 10
  height = 300
  width = 600
  halfemh = 18
  halfemw = 12

  MAXDEVP = 20
  DENSESPACE = 3
  SPARSESPACE = 8
  # -v for redplayer and greenplayer

  TRAILS = 1
  DELAY = 0

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
  redplayer = cgidat["redplayer"]
  greenplayer = cgidat["greenplayer"]

  print "<b>"redplayer"</b> vs. <b>"greenplayer"</b>"

  print "<meta http-equiv='refresh' content='"DELAY";URL=soc.cgi?"rand()"&redplayer="redplayer"&greenplayer="greenplayer"'>"

  print "<span style=z-index:-3;position:absolute;top:"tmargin+halfemh";left:"lmargin+halfemw";height:"height";width:"width";background-color:DDFFDD></span>"

  print "<p align=right><a href=dirs>dirs</a>&nbsp;&nbsp;&nbsp;<a href=pos>pos</a>&nbsp;&nbsp;&nbsp;<a href=soc.cgi?init>init</a>&nbsp;&nbsp;&nbsp;<a href=soc.cgi?120>2minpause</a>&nbsp;&nbsp;&nbsp;<a href=..>stop</a></p>"
  #graph(tmargin+height/2,lmargin,"[","red")
  #graph(tmargin+height/2,lmargin+width,"]","green")
  graph(tmargin+height/2-8,lmargin,"|","red")
  graph(tmargin+height/2,lmargin,"|","red")
  graph(tmargin+height/2+8,lmargin,"|","red")
  graph(tmargin+height/2-8,lmargin+width,"|","green")
  graph(tmargin+height/2,lmargin+width,"|","green")
  graph(tmargin+height/2+8,lmargin+width,"|","green")

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
      }
    }
  }
  close("pos")

  for (i in dat) {
    graph(tmargin+rdat[i],lmargin+cdat[i],"<font size=-3>"symbol(i) printme(i)"</font>",color[i])
  }

  while (getline < "dirs" > 0) {
    if ($1 ~ /^[a-zA-Z0]$/) {
      dirdat[$1] = $0
      rdev[$1] = $3
      cdev[$1] = $4
      rrdev[$1] = rdev[$1]
      ccdev[$1] = cdev[$1]
      rkick[$1] = $6
      ckick[$1] = $7
    }
  }
  close("dirs")
  rrdev["0"] = rdev["0"] = (abs(rdev["0"])-1)*sgn(rdev["0"])
  ccdev["0"] = cdev["0"] = (abs(cdev["0"])-1)*sgn(cdev["0"])

  # print "moving"
  move()

  # print "making"
  if (redplayer) system("./"redplayer)
  if (greenplayer) system("./"greenplayer)
  makedirs()

  # print "writing"
  for (i in dat) {
    print i, color[i], rdat[i], cdat[i], edat[i], notes[i] > "pos"
  }
  close("pos")
  for (i in rrdev) {
    print i, color[i], rrdev[i], ccdev[i], kick[i] > "dirs"
  }
  close("dirs")

  if (1) {
    print "<span style=position:absolute;left:10;top:"height+tmargin+30">"
    print "<table width=100%><tr>"
    print "<td>"
    print "<pre>"
    print "<font size=-2>"
    system("sort pos")
    print "</td><td>"
    print "<pre>"
    print "<font size=-2>"
    system("sort dirs")
    print "</tr></table>"
    print "</span>"
  }

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
  for (i in dat) {
    print edat[i],i > "tmp/soc.tmp"
  }
  close("tmp/soc.tmp")

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

    if (abs(cdev[who])>1 || abs(rdev[who])>1) go = 1
    else go = 0
    # to do: make this check on each step
    if (edat[who] > 0) {
      if (rdev[who]) slope = cdev[who]/rdev[who]
      else slope = "inf"

      rdev[who] = maxdev(rdev[who])
      cdev[who] = maxdev(cdev[who])

      if (slope == "inf") {
	if (cdev[who] > 0) for (cj=1; go && cj<=cdev[who]; cj++) {
	  if (!aloftball && !myclear(who,occupied[rdat[who],cok(cdat[who]+1)])) go = 0
	  else {
	    cdat[who] = cok(cdat[who]+1)
	    occupy(who,rdat[who],cdat[who])
	  }
	} else for (cj=cdev[who]; go && cj<0; cj++) {
	  if (!aloftball && !myclear(who,occupied[rdat[who],cok(cdat[who]-1)])) go = 0
	  else {
	    cdat[who] = cok(cdat[who]-1)
	    occupy(who,rdat[who],cdat[who])
	  }
	}
      } else if (slope == 0) {
	if (rdev[who] > 0) for (rj=1; go && rj<=rdev[who]; rj++) {
	  if (!aloftball && !myclear(who,occupied[rok(rdat[who]+1),cdat[who]])) go = 0
	  else {
	    rdat[who] = rok(rdat[who]+1)
	    occupy(who,rdat[who],cdat[who])
	  }
	} else for (rj=rdev[who]; go && rj<0; rj++) {
	  if (!aloftball && !myclear(who,occupied[rok(rdat[who]-1),cdat[who]])) go = 0
	  else {
	    rdat[who] = rok(rdat[who]-1)
	    occupy(who,rdat[who],cdat[who])
	  }
	}
      } else {
	if (abs(slope) < 1) {
	  islope = 1/slope
	  if (cdev[who] > 0) for (cj=1; go && cj<=cdev[who]; cj++) {
	    if (!aloftball && !myclear(who,occupied[rok(rdat[who]+islope),cok(cdat[who]+1)])) go = 0
	    else {
	      rdat[who] = rok(rdat[who]+islope)
	      cdat[who] = cok(cdat[who]+1)
	      occupy(who,rdat[who],cdat[who])
	    }
	  } else for (cj=cdev[who]; go && cj<0; cj++) {
	    if (!aloftball && !myclear(who,occupied[rok(rdat[who]-islope),cok(cdat[who]-1)])) go = 0
	    else {
	      rdat[who] = rok(rdat[who]-islope)
	      cdat[who] = cok(cdat[who]-1)
	      occupy(who,rdat[who],cdat[who])
	    }
	  }
	} else {
	  if (rdev[who] > 0) for (rj=1; go && rj<=rdev[who]; rj++) {
	    if (!aloftball && !myclear(who,occupied[rok(rdat[who]+1),cok(cdat[who]+slope)])) go = 0
	    else {
	      rdat[who] = rok(rdat[who]+1)
	      cdat[who] = cok(cdat[who]+slope)
	      occupy(who,rdat[who],cdat[who])
	    }
	  } else for (rj=rdev[who]; go && rj<0; rj++) {
	    if (!aloftball && !myclear(who,occupied[rok(rdat[who]-1),cok(cdat[who]-slope)])) go = 0
	    else {
	      rdat[who] = rok(rdat[who]-1)
	      cdat[who] = cok(cdat[who]-slope)
	      occupy(who,rdat[who],cdat[who])
	    }
	  }
	}
      }
    } else {
      # zero the motion when tired?
      cdev[who] = rdev[who] = 0
    }

    # to do:  energy curves
    # to do:  kicking costs energy
    edat[who] = eok(edat[who]+15-sqrt(rdev[who]*rdev[who]+cdev[who]*cdev[who]))-5*rand()

    rball = rdat["0"]; cball = cdat["0"]

    # to do: ball bounce
    # to do: check for goal
    if (who == "0") {
      if (cball==redcgoal && abs(rball-redrgoal)<=1) {
	print "<font style=font-size:2in;z-index:10>GREEN SCORES!</font>"
	system("sleep 10")
	init()
	exit
      }
      if (cball==greencgoal && abs(rball-greenrgoal)<=1) {
	print "<font style=font-size:2in;z-index:10>RED SCORES!</font>"
	system("sleep 10")
	init()
	exit
      }
    }

    if (who != "0" && dirdat[who] ~ /kick/ && notes["0"] !~ /aloft/) {
      if (abs(rdat[who]-rball)<=5 && abs(cdat[who]-cball)<=5) {
	# to do: kicking error based on ball speed, player speed 
	rrdev["0"] = maxkick(rkick[who])
	ccdev["0"] = maxkick(ckick[who])
	kicked = 1
	# to do: do this w/prob
	if (dirdat[who] ~ /aloft/) {
	  notes["0"] = "aloft"
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
    ccdev["0"] *= .6
    rrdev["0"] *= .6
  }
  # don't let ball wiggle
  if (abs(ccdev["0"]) < 1 && abs(rrdev["0"]) < 1) { ccdev["0"] = 0; rrdev["0"] = 0 }

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
  # to do:  call each program
  for (i in dat) {

    if (redplayer && color[i] == "red") continue
    if (greenplayer && color[i] == "green") continue

    if (i == "0") continue
    key = index("aAbBcCdDeEfFgG",i)
    if (i != "0" && i !="a" && i != "A") {
      if (edat[i] > 20 && chaser[i] || (abs(cdat["0"]-cdat[i]) < 50 && abs(rdat["0"]-rdat[i]) < 20)) {
        ccdev[i] = maxdev(cdat["0"]-cdat[i])
        rrdev[i] = maxdev(rdat["0"]-rdat[i])
	if (rand() < .8 && (rball < 20 || rball > width-20 || rand() < .25)) {
          if (color[i] ~ /red/) kick[i] = "kick.aloft "greenrgoal-rdat[i]" "greencgoal-cdat[i]
          if (color[i] ~ /green/) kick[i] = "kick.aloft "redrgoal-rdat[i]" "redcgoal-cdat[i]
	} else {
          if (color[i] ~ /red/) kick[i] = "kick.aloft "300+900*rand()" "greencgoal-cdat[i]
          if (color[i] ~ /green/) kick[i] = "kick.aloft "-300-900*rand()" "redcgoal-cdat[i]
	}
      } else if (edat[i] > 50) {
        ccdev[i] = maxdev(cinit[i]-cdat[i])
        rrdev[i] = maxdev(rinit[i]-rdat[i])
      } else {
	ccdev[i] = 0
	rrdev[i] = 0
      }
    }
  }
}

func maxkick(x) {
  if (x > 2*MAXDEVP) return 2*MAXDEVP
  if (x < -2*MAXDEVP) return -2*MAXDEVP
  return x
}

func maxdev(x) {
  if (x > MAXDEVP) return MAXDEVP
  if (x < -1*MAXDEVP) return -1*MAXDEVP
  return x
}

func myclear(x,y) {
  # you can move into your own space or an unclaimed space
  # to do:  goalie area restriction
  if (y == "") return 1
  if (y == "0") return 1
  if (x == y) return 1
  return 0
}

function occupy(who,rrr,ccc,ri,ci) {
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
