#!/pkg/gnu/bin/gawk -f
#ARGCOL by Mark Foltz (foltz@triton.wustl.edu)
#5/94 for Dr. Loui
BEGIN {
   text = 0
   help = 0
   supports = 1
   supported = 2
   attacks = 3
   attacked = 4
   closed = 5
   no_claims = 0
   master = 0
   width = 30
   for(i=0;i<100;i++) {
           claim[i, text] = ""
           claim[i, attacked] = -1
           claim[i, attacks] = -1
           claim[i, supports] = -1
           claim[i, supported, 0] = 1
           claim[i, supported, 1] = -1
           claim[i, closed] = 0
   }
   for(i=0;i<100;i++) lin[i] = 0
   cont = 1
   while (cont) {
       cont = get_next_claim()
   }
       for (ee=0;ee<no_claims;ee++) {
           if ((claim[ee,attacks] < 0) && (claim[ee,supports] < 0)) {
               print_claim((make2(ee) "0001"))
               max_len = 0
               no_lines = 0
               for (ww in out) {
                   if (length(out[ww]) > max_len) {
                       max_len = length(out[ww])
                   }
                   no_lines++
               }
               for (ww in out) {
                   while(length(out[ww]) < max_len) out[ww] = out[ww] "|" print_spaces(width)
               }
               out[""] = ""
               for (ee=100;ee>0;ee--) {
                       if (closed_col[ee] == 1) {
                       for (ff in out) out[ff] = substr(out[ff],1,(ee-1)*(width+1)) substr(out[ff],1+(width+1)*ee)
                       }
               }
               for (ee=0;ee<no_lines;ee++) if (out[ee] ~ /[a-zA-Z]/) print out[ee]
           }
       }
}

function print_spaces(no) {
   x = ""
   for(z=0;z<no;z++) x = x " "
   return x
}

function print_claim(stk) {
   for (i in lin) lin[i] = 0
   for (i in out) out[i] = ""
   while(!(stk == "")) {
   junk = split(stk, tmp)
   nxt = tmp[1]
   stk = ""
   for (zz=2;zz<=junk;zz++) {
       stk = stk " " tmp[zz]
   }
   no = int(substr(nxt, 1, 2))
   col = int(substr(nxt, 3, 2))
   spc = int(substr(nxt, 5, 2))
   siz = width - spc
   if (claim[no, closed] == 1) {
       if (!(col == 0)) {
           lines_added = 0
           while (length(out[lin[col]]) <= col*(width-1)) {
               out[lin[col]] = out[lin[col]] "|" print_spaces(width)
               lines_added++
           }
           for(xx=0;xx<lines_added;xx++) lin[col-xx-1]++
       }
   if((claim[no,attacks] > -1) && (!(col == 0))) {
       while (lin[col] < attacked_line) {
           out[lin[col]] = out[lin[col]] "|" print_spaces(width)
           lin[col]++
       }
   }
   out[lin[col]] = out[lin[col]] no print_spaces(spc-length(no)+1) justify("<closed>",width-spc)
   lin[col]++
   } else {
   format(a, claim[no, text], siz)
   if((claim[no,attacks] > -1) && (!(col == 0))) {
       while (lin[col] < attacked_line) {
           out[lin[col]] = out[lin[col]] "|" print_spaces(width)
           lin[col]++
       }
   }
   if(claim[no,attacked] > -1) attacked_line = lin[col]
   for(yy=0;yy<a[0];yy++) {
       if (!(col == 0)) {
           lines_added = 0
           while (length(out[lin[col]+yy]) <= col*(width-1)) {
               out[lin[col]+yy] = out[lin[col]+yy] "|" print_spaces(width)
               lines_added++
           }
           for(xx=0;xx<lines_added;xx++) lin[col-xx-1]++
       }
       if (yy == 0) {
           out[lin[col] + yy] = out[lin[col] + yy] no print_spaces(spc-length(no)+1) justify(a[yy+1],width-spc)
       } else {
           out[lin[col] + yy] = out[lin[col] + yy] "|" print_spaces(spc) justify(a[yy+1],width-spc)
       }
   }
   lin[col] += a[0]
   if (!(col == 0)) {
   while (lin[col] < lin[col-1]) {
      out[lin[col]] = out[lin[col]] "|" print_spaces(width)
      lin[col]++
   }
   }
       for (y=1;y<=claim[no, supported, 0];y++) {
           if (claim[no, supported, y] > 0) stk = push(stk, (make2(claim[no, supported, y]) make2(col) make2(spc+1)))
       }
   if (claim[no,attacked] > 0) {
       stk = push(stk, (make2(claim[no, attacked]) make2(col+1) make2(spc)))
   }
   }
   }
}

function format(a, txt, cols) {
   nowds = split(txt, words, " ")
   wno = 1
   lne = 1
   len = 0
   str = ""
   while (wno <= nowds) {
    if (len + length(words[wno]) <= cols) {
       len += length(words[wno]) + 1
       if (str == "") {
           str = words[wno]
       } else {
           str = str " " words[wno]
       }
       wno++
       if (wno > nowds) {
         a[lne] = str
         lne++
       }
    } else {
       len = 0
       a[lne] = str
       lne++
       str = ""
    }
   }
       a[0] = --lne
}

function read_claims() {
   while(getline) {
       getline
       claim[no_claims, text] = $0
       getline
       claim[no_claims, supports] = $2
       getline
       for(i=2;i<=NF;i++) claim[no_claims, supported, i-1] = $i
       claim[no_claims, supported, 0] = NF - 1
       getline
       claim[no_claims, attacks] = $2
       getline
       claim[no_claims, attacked] = $2
       no_claims++
   }
}

function justify(txt, c) {
       init_len = length(txt)
       for(zz=0;zz<c-init_len;zz++) txt = txt " "
       return txt
}

function pop() {
   popno = split(stk, tmp)
   popped = tmp[1]
   stk = ""
   for (zz=2;zz<=popno;zz++) {
       stk = stk " " tmp[zz]
   }
   return popped
}

function poptop() {
   popno = split(stk, tmp)
   popped = tmp[popno]
   stk = ""
   for (zz=1;zz<popno;zz++) {
       stk = stk " " tmp[zz]
   }
}

function push(stk, ele) {
   stk = ele " " stk
   return stk
}

function pushtop(stk, ele) {
   stk = stk " " ele
   return stk
}

function make2(txt) {
   if (length(txt) < 2) txt = "0" txt
   return txt
}

function get_next_claim()
{
       FS = ":"
       getline
       print $0
       if ($2 == "i") {
           claim[$1, text] = $3
           no_claims++
       } else if ($2 == "s") {
           sup_no = $3
           claim[$1, text] = $4
           if (claim[sup_no, supported, 1] == -1) {
               claim[sup_no, supported, 1] = $1
           } else {
               claim[sup_no, supported, 0]++
               claim[sup_no, supported, claim[sup_no, supported, 0]] = $1
           }
           claim[$1, supports] = sup_no
           no_claims++
       } else if ($2 == "a") {
           att_no = $3
           claim[$1, text] = $4
           claim[$1, attacks] = att_no
           claim[att_no, attacked] = $1
           no_claims++
       } else if ($1 == "c") claim[$2, closed] = 1
       else if ($1 == "o" ) claim[$2, closed] = 0
       else if ($1 == "C" ) closed_col[$2] = 1
       else if ($1 == "O" ) closed_col[$2] = 0
       else if ($1 == "w" ) width = $2
       else if ($1 == "help" ) {
               print "###   Command Summary:"
               print "###   <num>:i:<text>         open initial arg"
               print "###   <num1>:s:<num2>:<text> support num2 with num1"
               print "###   <num1>:a:<num2>:<text> attack num2 with num1"
               print "###   c:<num>                close at arg <num>"
               print "###   o:<num>                open at arg <num>"
               print "###   C:<num>                close column <num> >= 1"
               print "###   O:<num>                open column <num>"
               print "###   w:<num>                set column width to <num>"
               print "###   #                      ignore this line"
               print "###   quit                   signal end of input"
       }
       else if ($0 == "quit") {
           FS = " "
           return 0
       }
       FS = " "
       return 1
}

function get_text() {
       printf("Enter one line of text:\n")
       getline
       return $0
}