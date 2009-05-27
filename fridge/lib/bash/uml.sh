#.H1 UML in Awk
#.H2 Synopsis
#.PRE
#gawk -f iml.sh  file.sdml >  sequence_diagram
#./PRE
#.H2 Description
#.P
#  This program will turn SDML into simple ascii text uml sequence
#  diagrams.  SDML is an extremely simplistic uml Sequence Diagram
#  Markup Language.  SDML is specified as:
#.UL
#.LI
#Lines starting with a [ are a comma separated list of actors (bar headers)
#.LI Events are defined easily by the following symbols:
#.DL
#.DT    >  
#.DD rightward event
#.DT    &lt;  
#.DD leftward event
#.DT    -  
#.DD extension of the previous event
#.DL
#.LI Actors can be skipped with a |
#.LI  Text on a line after a # is a comment
#.LI  Lines starting with a @ are text lines
#.LI  Lines starting with a " are indented text lines
#.LI  Lines starting with a : are comma separated list of parameter assignment lines.  Parameters are:
#.DL
#.DT E   
#.DD Event Padding (spaces on each side)
#.DT    ES  
#.DD Event Spacing (lines below)
#.DT    EA  
#.DD Events Above (put event text above arrows)

#.DT    HP  
#.DD Header Padding (spaces on each side)
#.DT    HS  
#.DD Header Spacing (lines below)

#.DT    LM  
#.DD Left Margin (spaces on the left)

#.DT    TSM 
#.DD Text Spacing Margin (lines above & below)
#.DT    TD  
#.DD Text Dots (instead of bars in text margins)
#.DT    SS  
#.DD Enable Single Arrow Spans (|---A-->|, not |-A-+-A>|)
#./DL
#./UL
#.H3 Example 
#.P Given this input:
#.PRE
#    [Client, Proxy, DNS, Server
#    Query Name->
#    Answer IP<-
#    http GET >->
#    <<-html
#./PRE
#.P this code generates:
#.PRE
#    Client          Proxy           DNS         Server
#       |              |              |             |
#       |----------Query Name-------->|             |
#       |<---------Answer IP----------|             |
#       |--http GET -->|----------http GET -------->|
#       |<----html-----|<-----------html------------|
#./PRE
#.H2 Code
#.SMALL
#.PRE
if [ "$1" = "--awkprog" ] ; then

cat - <<"EOF"

BEGIN {
  EFS="[|<>-]";
  AFS="[<>-]";
  RAFS="[{}RL]";
  FS= EFS;
  ARROWS = 2 ; # Arrowhead constant
  ST=1;

  ARG["EP"] = 1;  # Event Padding
  ARG["ES"] = 0;  # Event Spacing (lines below)
  ARG["EA"] = 0;  # Events Above

  ARG["HP"] = 2;  # Header Padding
  ARG["HS"] = 1;  # Header Spacing (lines below)

  ARG["LM"] = 0;  # Left Margin

  ARG["SP"] = 2;  # Start Row Padding (For continuous operation)

  ARG["TSM"] = 1; # Text Spacing Margin (lines above & below)
  ARG["TD"] = 1;  # Text Dots (instead of bars in text margins)
  ARG["SS"] = 1;  # Enable Single Arrow Spans (|---A-->|, not |-A-+-A>|)
}

function padding(outter, inner, extra    ,p,m) {
  p = (outter - inner);
  m = p % 2 ;
  p =  ((p - m)/2) + (extra ? m:0);
  if(p<0) return 0;
  return p;
}
function pad(char, count    ,i,r) {
  for(i=1 ; i <= count ; i++) { r = r char };
  return r;
}
function ltrim(s) { gsub(/^[     ]*/, "", s) ; return s; }

function center(string, width, padchar, favor    ,p,r,sw) {
  sw = length(string);
  p = padding(width, sw, favor=="r"?1:0);
  r = pad(padchar, p);
  r = r string;
  p = padding(width, sw, favor=="r"?0:1);
  return r pad(padchar, p);
}

function getevent_rev(row, field   ,p) {
  for(p=field-1; p>0; p--) { # search to the left
    if(RF_s[row,p] !~ AFS) return "";
    if(RF_f[row,p] != "") return RF_f[row,p];
  }
  return "";
}
function getevent_for(row, field   ,n) {
  for(n=field+1; n <= R_nf[row]; n++) { # search to the right
    if(RF_s[row,n-1] !~ AFS) return "";
    if(RF_f[row,n] != "") return RF_f[row,n];
  }
  return "";
}

function rlarrow(arrow, prevarrow) {
  if(arrow == ">") return "R";
  if(arrow == "<") return "L";
  if(arrow == "R" || arrow=="L") return arrow;
  return prevarrow;
}

function debug_events(s) {
  for(r=1; r <= NRS; r++) debug_row(r, s);
}

function debug_row(r, s) {
  if(!DEBUG_ROW) return;
  printf("Row["r"]/Stage["s"]:  ");
  for(f=1; f <= R_nf[r]; f++) {
    printf(f"="RF_f[r,f]"("RF_s[r,f]") ");
  }
  printf("\n");
}

function print_bars(num, char    ,i,out) {
  if(char == "") char = "|";
  while(num--) {
    # Center the bars under the Headers
    out = pad(" ", F_width[0]);
    for(i=1; i<= NH; i++) {
      out = out  char pad(" ", F_width[i]);
    }
    print out;
  }
}

function print_event(r, type   ,i,bar,out,aspad,span_width,arrow){
  out = pad(" ", F_width[0]);

  for(i=1; i<= MAXNF; i++) {

    out = out "|";

    arrow=" ";
    if(type == "both" || type == "arrow") {
      if(RF_s[r,i] == "{") arrow = "<";
      if(RF_s[r,i] ~ /[}RL]/)  arrow = "-";
    }
    out = out arrow;


    aspad = "-"; # arrow or space pad
    if(RF_s[r,i] == "|" || RF_s[r,i] == ""|| type == "event") aspad = " ";

    span_width = F_width[i];
    if(ARG["SS"]) while(RF_s[r,i] == "R" || RF_s[r,i+1] == "L") {
      span_width += 1 + F_width[++i]; # include bar
    }

    event ="";
    if(type == "both" || type == "event") {
      event = RF_f[r,i];
    }
    out = out center(event, span_width - ARROWS, aspad, i>MAXNF/2? "r":"l");


    if(type == "both" || type == "arrow") {
      if(RF_s[r,i] == "}") arrow = ">";
      if(RF_s[r,i] ~ /[{RL]/) arrow = "-";
    }
    out = out arrow;
  }
  out = out "|";
  print out;
}

function print_sd(start_row) {
# print "         1         2         3         4         5         6"
# print "123456789012345678901234567890123456789012345678901234567890"
  if(start_row!=1) { for(i=0; i<ARG["SP"];i++) print ""; }

  for(j=start_row; j<= NRS; j++) {

    if(R_ltype[j] == "Header") {
      NH = R_nf[j];
      out = pad(" ", ARG["HP"]+ARG["LM"]);
      i =1;
      out = out RF_f[j,i];
      hp = ARG["HP"] + ARG["LM"] + RF_l[j,i]; # header pointer (last char)
      bp = F_width[0] + 1 + F_width[i] + 1; # bar pointer
# print "HP:" hp " BP: "bp
      for(i=2; i<= NH; i++) {
        l = int(RF_l[j,i]/2); r = RF_l[j,i] -l; # Header left & right
        lp = (bp - hp) - (l + 1); # left padding
        out = out pad(" ", lp) RF_f[j,i];
        hp = bp + r - 1;
        bp = bp + F_width[i] + 1;
# print "HP:" hp " BP: "bp " LP:"lp " r:"r" l:"l
      }

      print out;
      print_bars(ARG["HS"]);
    }

    if(R_ltype[j] == "Text") {
      if(R_ltype[j-1] != "Text") {
        if(ARG["TD"]) { 
          print_bars(ARG["TSM"], ".");
        } else {
          for(l=0;l<ARG["TSM"]; l++) print "";
        }
      }

      if(T_type[j] == "indent") printf(pad(" ", F_width[0]));
      print RF_f[j,1];

      if(R_ltype[j+1] != "Text") {
        if(ARG["TD"]) { 
          print_bars(ARG["TSM"], ".");
        } else {
          for(l=0;l<ARG["TSM"]; l++) print "";
        }
      }
    }

    if(R_ltype[j] == "Event") {
      if (ARG["EA"]) {
        print_event(j, "event");
        print_event(j, "arrow");
      } else print_event(j, "both");
      print_bars(ARG["ES"]);
    }

  }
  return j;
}


/^[     ]*#/ {next} # we don't want bars for comment only lines!
/#/ { $0 = sub(/#.*$/, ""); }

/^:/ {
# print "Argument Variable Assignment" $0
  i = split(substr($0,2), v, /,/);
  for(;i>0;i--) {
    j = split(v[i], kv, "=");
    if(j==1) { ARG[kv[1]]= ""; }
    if(j==2) { ARG[kv[1]]=kv[2]; }
  }
# for(k in ARG) { printf("ARG["k"]='"ARG[k]"' "); } ; print "";
  next ;
}

{
  NRS++; # NRSequences
}

/^;/ { ST=print_sd(ST); next; }  # Allow continuous operation

/^@/ {
# print "text line"
  R_ltype[NRS] = "Text";
  T_type[NRS] = "left";
  sub(/^@/,"");
  RF_f[NRS,1]=$0;
  next;
}

/^"/ {
# print "text line"
  R_ltype[NRS] = "Text";
  T_type[NRS] = "indent";
  sub(/^"/,"");
  RF_f[NRS,1]=$0;
  next;
}

/^\[/ {
# print "Event Headers (Titles)" $0
  R_ltype[NRS] = "Header";

  sub(/^\[/,"");
  FS=","; $0 = $0; # resplit line
  R_nf[NRS] = NF;
  if(MAXNF < R_nf[NRS]-1) MAXNF= R_nf[NRS]-1; # print MAXNF;
  for(i=1; i<= NF; i++) {
    f= ltrim($i);
    RF_f[NRS,i]=f;
    RF_l[NRS,i]= length(f);
    RF_s[NRS,i]= ",";
  }
  for(i=1; i<= NF; i++) {
    F_width[i] = padding(RF_l[NRS,i] + 2*ARG["HP"], 1, 1) +\
                 padding(RF_l[NRS,i+1] + 2*ARG["HP"], 1, 0)\
                 -1; # Do not include width of bar
    if(F_width[i] < 2*ARG["HP"])  F_width[i] = 2*ARG["HP"];

# print padding(RF_l[NRS,i] + 2*ARG["HP"], 1, 1) " "\
#       padding(RF_l[NRS,i+1] + 2*ARG["HP"], 1, 0);
  }
  F_width[0] = padding(RF_l[NRS,1] + 2*ARG["HP"], 1, 1);
# print padding(RF_l[NRS,1] + 2*ARG["HP"],1,0);
  if(F_width[0] < ARG["HP"])  F_width["0"] = ARG["HP"];
  F_width[0] += ARG["LM"];
# for(i=0; i<= MAXNF; i++) printf("FW["i"]="F_width[i]" "); print ""

  FS=EFS;
  next;
}

{
# print "Event Line: " $0 ; DEBUG_ROW=1;
  R_ltype[NRS] = "Event";

  stl=0;
  for(i=1; i<= NF; i++) {
    f = $i;
    l = length(f);
    stl += l +1;
    s = substr($0, stl, 1);

    RF_f[NRS,i]= f;
    RF_s[NRS,i]= s;
  }
  R_nf[NRS] = NF;
  debug_row(NRS, 1);

  # Fill in missing (assumed) fields
  for(i=1; i<= R_nf[NRS]; i++) {
    if (RF_f[NRS,i]=="") RF_f[NRS,i] = getevent_rev(NRS, i);
    if (RF_f[NRS,i]=="") RF_f[NRS,i] = getevent_for(NRS, i);
  }
  debug_row(NRS, 2);

  # ->  <-   ->>  >->  <-<  <<-
  # >-  -<        >>-  -<<
  # R>  <L   R>>  >R>  <L<  <<L

  for(i=1; i<= R_nf[NRS]; ) {
    if(RF_s[NRS,i] ~ AFS) {
      if(RF_s[NRS,i] == "-") { # left tail
        for(n=i+1; n<= R_nf[NRS]; n++) {
          if(RF_s[NRS,n]==">") {
            pi=i; i=n;  RF_s[NRS,n]="}";
            for(n--; n>=pi; n--) RF_s[NRS,n]="R"; n= R_nf[NRS];
          } else if(RF_s[NRS,n]=="<") {
            pi=i; i=n;  RF_s[NRS,pi]="{";
            for(; n>pi; n--) RF_s[NRS,n]="L"; n= R_nf[NRS];
          }
        }
        i++;
      } else if(RF_s[NRS,i+1] != "-") { # singleton
        RF_s[NRS,i]= RF_s[NRS,i]==">" ? "}":"{";
        i++;
      } else {
        rl= rlarrow(RF_s[NRS,i], "");
        for(n=i+1; n<= R_nf[NRS] && RF_s[NRS,n] ~ AFS; n++) {
          rl= rlarrow(RF_s[NRS,n], rl);
        }
        n--;
        if (RF_s[NRS,n] == "-") { # right tail
          if (rl=="R") RF_s[NRS,n--]="}";
          for(; n>=i && RF_s[NRS,n] == "-"; n--) RF_s[NRS,n]=rl;
          if (rl=="L") RF_s[NRS,n]="{"; else RF_s[NRS,n]="R";
        } else if (RF_s[NRS,n-1] != "-") { # singleton
          RF_s[NRS,n]= RF_s[NRS,n]==">" ? "}":"{";
        } else { # double ended -
          if(RF_s[NRS,i]=="<") { # trumps no matter what
            RF_s[NRS,i]="{";
            for(i++; i<= R_nf[NRS] && RF_s[NRS,i]=="-"; i++) {
              RF_s[NRS,i]="L";
            }
          } else {
            for(n=i+1; n<= R_nf[NRS] && RF_s[NRS,n] =="-"; n++) ;
            if(RF_s[NRS,n]==">") {
              RF_s[NRS,n]="}";
              for(n--; n>i && RF_s[NRS,n]=="-"; n--) {
                RF_s[NRS,n]="R";
              }
            } else { # >-<  # > is on the right and trumps
              for(; i<= R_nf[NRS] && RF_s[NRS,i]=="-"; i++) {
                RF_s[NRS,i]="R";
              }
              RF_s[NRS,i]="}";
            }
          }
        }
      }
    } else i++;
  }

  debug_row(NRS, 3);


  # ~ we need to test this with multi shifts (arrow/bar/arrow)
  shift = 0;
  for(i=1; i<= R_nf[NRS]+1; i++) {
    if(RF_s[NRS,i-1] ~ RAFS && RF_s[NRS,i] !~ RAFS) shift++;
    if(shift) RF_f[NRS,i-shift]=RF_f[NRS,i];
  }
  R_nf[NRS] = R_nf[NRS] - shift;
  debug_row(NRS, 4);

  # Trim empty trailing fields
  for(i= R_nf[NRS]; i>0 && RF_f[NRS,i]==""; i--) R_nf[NRS]--;
  debug_row(NRS, 5);

  # Get event wlength and adjust the max length of each event
  for(i=1; i<= R_nf[NRS]; i++) {
    RF_l[NRS,i]= length(RF_f[NRS,i]);
    if(RF_l[NRS,i] > E_ml[i]) E_ml[i] = RF_l[NRS,i];
  }

  # Adjust the max width of each column (headers/events)
  if(MAXNF < R_nf[NRS]) MAXNF= R_nf[NRS]; # print MAXNF;
  for(i=1; i<= MAXNF; i++) {
    w = E_ml[i] + 2 * ARG["EP"] + ARROWS;
    if (F_width[i] < w)  F_width[i] = w;
#   printf("FW:"F_width[i]" W:"w" ");
  }
# print ""
}

END { ST=print_sd(ST); }


EOF
exit
fi


Usage()
{
  cat - <<-EOF

  use(v1.0): $0 file.sdml >  sequence_diagram

  This program will turn SDML into simple ascii text uml sequence
  diagrams.  SDML is an extremely simplistic uml Sequence Diagram
  Markup Language.  SDML is specified as:

  .Lines starting with a [ are a comma separated list
    of actors (bar headers)
  .Events are defined easily by the following symbols:
    >  rightward event
    <  leftward event
    -  extension of the previous event
  .Actors can be skipped with a |
  .Text on a line after a # is a comment
  .Lines starting with a @ are text lines
  .Lines starting with a " are indented text lines
  .Lines starting with a : are comma separated list of
    parameter assignment lines.  Parameters are:

    E   Event Padding (spaces on each side)
    ES  Event Spacing (lines below)
    EA  Events Above (put event text above arrows)

    HP  Header Padding (spaces on each side)
    HS  Header Spacing (lines below)

    LM  Left Margin (spaces on the left)

    TSM Text Spacing Margin (lines above & below)
    TD  Text Dots (instead of bars in text margins)
    SS  Enable Single Arrow Spans (|---A-->|, not |-A-+-A>|)

  Example SDML Input:

    [Client, Proxy, DNS, Server
    Query Name->
    Answer IP<-
    http GET >->
    <<-html

  Sequence Diagram Output:

    Client          Proxy           DNS         Server
       |              |              |             |
       |----------Query Name-------->|             |
       |<---------Answer IP----------|             |
       |--http GET -->|----------http GET -------->|
       |<----html-----|<-----------html------------|

  Copyright:  Martin Fick <mogulguy@yahoo.com>, Date: 2008-02-15
  License:    None.  This is released into the public domain: do
              as you wish.

EOF
exit
}

[ "$1" = "--help"  -o  "$1" = "-h"  -o  "$1" = "-u" ] &&  Usage

#
# Hack to attempt to make this somewhat portable
#

AWK_PROG="`"$0" --awkprog`"

AWK=awk  # default (should work most places)
[ -x /usr/bin/nawk ] && AWK=/usr/bin/nawk # solaris

$AWK "$AWK_PROG" "$@"
#./PRE
#./SMALL
#.H2 Author
#.P Martin Fick
