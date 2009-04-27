#.H1 Hiding Email Address
#.H2 Synopsis
#.P   gawk -f cryptosig.awk tim@menzies.us
#.H2 Download
#.P 
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/cryptosig.awk LAWKER.
#.H2 Description
#.P 
#Generates a one-line Awk program that can print your email, from a seemingly jumbled string.
#This program can then become your email sig and only the Awk cognoscente can generate a reply.
#.P Example
#.PRE
#% gawk -f cryptosig.awk tim@menzies.us
#BEGIN{a="7059631863556476595569007169";while(a){printf("%c",46+substr(a,1,2));a=substr(a,3)}}
#./PRE
#.P
#This
# can be tested as follows:
#.PRE
#echo 'BEGIN{a="7059631863556476595569007169";while(a){printf("%c",46+substr(a,1,2));a=substr(a,3)}}' | gawk -f -
#./PRE
#.P or
#.PRE
#gawk -f crypotsig.awk tim@menzies.us | gawk -f -
#./PRE
#.P
# both of which should print "tim@menzies.us".
#.H2 Code
#.PRE
BEGIN {
  for (i=0; i<=255; i++) {           # build table of char=value pairs
    ord_arr[sprintf("%c",i)] = i     # character = ordinal value
  }
  for (i=1; i<=ARGC-1; i++) {
    str = ""
    for (j=1; j<=length(ARGV[i]); j++) {
      str = sprintf("%s%02d",str,ord_arr[substr(ARGV[i],j,1)]-46)
    }
    printf("BEGIN{a=\"%s\";while(a){printf(\"%%c\",46+substr(a,1,2));a=substr(a,3)}}\n",str)
  }
  exit(0)
}
#./PRE
#.H2 Author
#.PRE
#BEGIN{a="535170696159626207061118755158656500536563";
#      while(a){
#          printf("%c",46+substr(a,1,2));a=substr(a,3)};
#      print("")
#}
#./PRE
