#MAKEFLAGS +=  -s
Doc=../doc
Bash=../lib/bash
Fun=../gawk/fun
Awkwords=$(Bash)/awkwords
Awk2Html=$(Bash)/awkwords $< > $@; svn add $@ 

all : config.xml files

commit : 
	cd ../..; pwd; svn commit

config.xml :	tags.txt things.awk tags.awk 	
	(gawk -f ./things.awk config.xml ; gawk -f ./tags.awk tags.txt) > confignew.xml
	mv confignew.xml config.xml
	svn commit -m "tags updated"

files : $(Doc)/tools/awkwords.html $(Doc)/fun/enumerate.html

$(Doc)/tools/awkwords.html : $(Awkwords) $(Bash)/awkwords     ; $(Awk2Html)
$(Doc)/fun/enumerate.html  : $(Awkwords) $(Fun)/enumerate.awk ; $(Awk2Html)
