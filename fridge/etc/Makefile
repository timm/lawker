#MAKEFLAGS +=  -s
Doc=../doc
Bash=../lib/bash
Awkwords=$(Bash)/awkwords

all : config.xml files


config.xml :	tags.txt things.awk tags.awk 	
	(gawk -f ./things.awk config.xml ; gawk -f ./tags.awk tags.txt) > confignew.xml
	mv confignew.xml config.xml
	svn commit -m "tags updated"

files : $(Doc)/tools/awkwords.html

$(Doc)/tools/awkwords.html : $(Awkwords) $(Bash)/awkwords; $(Bash)/awkwords $< > $@
