#.h1 s2a: sed to Awk
#.H2 Download
#.P
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/s2a.awk LAWKER.
#.h2 Description
#.P
#The s2a project is a sed to awk conversion utility written in awk. As input it takes sed scripts, and it outputs an equivalent awk script.
#.P
#This version should be fully functional as far as the following sed commands are concerned: a,d,s,p,q,c,i,n.
#Commands to be implemented in the future: {},=,h,g,N,P,r,x,y,l,H,G,D,b,t,:

#.H2 Bugs
#.P
#$ is not a valid line address.
#Also, line continuation with '\' is not implemented.

#.h2 Author
#.P
#James Lyons, Feb 2008.
#.P
#For more excellent awk code, visit Lyon's <a href="http://awk.dsplabs.com.au">awk.dsplab 
#web site</a>.
#.H2 Code
#.PRE
BEGIN{RS=";|\n"; FS=""; var=1;}
{
    i=1; case1=""; case2="";
    while($i==" ")i++;
    if($i=="\\"||$i=="/"||$i~/[0-9]/) case1=matchaddr();
    if($i==","){i++; case2=matchaddr()};
# handle sed commands
#####################################################################################################
    if($i == "d"){ a1=a2="next;";
    }else if($i == "p"){ a1=a2="print;";
    }else if($i == "a"){ rest="";
        for(c=i+2;c<=NF;c++) rest=rest$c;
        a1=a2="$0=$0\"\\n"rest"\";"; 
    }else if($i == "q"){ a1=a2="print; exit;"; 
    }else if($i == "n"){ a1=a2="print; if(getline <= 0) next;"
    }else if($i == "s"){
        re=substr($0, i); p=substr(re,2,1); match(re,"s"p"((\\"p"|.)*)"p"((\\"p"|.)*)"p"([a-zA-Z])?",tmp);
        tmp[3]=gensub(/\\[0-9]/,"\\\\&","g",tmp[3]); 
        tmp[1]=gensub(/\\\(/,"(","g",tmp[1]); tmp[1]=gensub(/\\\)/,")","g",tmp[1]);
        if(tmp[3]=="") a1=a2="$0=gensub(/"tmp[1]"/,\""tmp[3]"\",1);";
        else a1=a2="$0=gensub(/"tmp[1]"/,\""tmp[3]"\",\""tmp[5]"\");";
    }else if($i == "c"){ rest="";
        for(c=i+2;c<=NF;c++) rest=rest$c;
        a1="$0=\""rest"\";"; 
        a2="next;";
    }else if($i == "i"){ rest="";
        for(c=i+2;c<=NF;c++) rest=rest$c;
        a1=a2="$0=\""rest"\\n\"$0;"; 
    }else{
        print "ERROR: invalid syntax. Unkown command in expression "$0" (expr number "NR")"; exit;
    }
#####################################################################################################
# output awk commands
    if(case1=="" && case2=="") print "{"a1"}";
    else if(case1~/^[0-9]/ && case2=="") print "NR=="case1"{"a1"}";
    else if(case2 == "") print "/"case1"/{"a1"}";
    else if(case1~/^[0-9]/ && case2~/^[0-9]/) print "temp"var"==1&&NR=="case2"{temp"var"=0;"a2"}temp"var"==1{"a2"}NR=="case1"{temp"var"=1;"a1"}";
    else if(case1~/^[0-9]/)  print "temp"var"==1&&/"case2"/{temp"var"=0;"a2"}temp"var"==1{"a2"}NR=="case1"{temp"var"=1;"a1"}";
    else if(case2~/^[0-9]/)  print "temp"var"==1&&NR=="case2"{temp"var"=0;"a2"}temp"var"==1{"a2"}/"case1"/{temp"var"=1;"a1"}";
    else print "temp"var"==1&&/"case2"/{temp"var++"=0;"a2"}temp"var"==1{"a2"}/"case1"/{temp"var"=1;"a1"}";
    var++;
}

function matchaddr(){
    str=substr($0, i); p=1;
    if($i == "\\"){ p=substr(str,2,1); match(str,p"([^"p"]*)"p,arr); i++}
    else if($i == "/"){ p=substr(str,1,1); match(str,p"([^"p"]*)"p,arr); }
    else { match(str,/^([0-9]*)/,arr) };
    i += RLENGTH;
    return arr[1];
}
END{print "{print}";}
#./PRE
