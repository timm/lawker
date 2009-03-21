#MAKEFLAGS +=  -s
Doc=$(Lawker)/doc
Gawk=$(Lawker)/gawk
Bash=$(Lawker)/lib/bash
Awklib=$(Lawker)/lib/awk
Fun=$(Lawker)/gawk/fun
Awkwords=$(Bash)/awkwords
Awk2Html=$(Bash)/awkwords $< > $@ 

all : config.xml files zips

commit : 
	cd ../..; pwd; svn commit

config.xml :	tags.txt things.awk tags.awk 	
	(gawk -f ./things.awk config.xml ; gawk -f ./tags.awk tags.txt) > confignew.xml
	mv confignew.xml config.xml
	svn commit -m "tags updated"

files : $(Doc)/dsl/markdown.html \
	    $(Doc)/tools/awkwords.html \
	    $(Doc)/fun/enumerate.html \
	    $(Doc)/dsl/awkplusplus.html\
	    $(Doc)/dsl/graph.html \
	    $(Doc)/gender.html 

zips :  
	cd $(Bash)/awk++ && zip -r awk++.zip *

$(Doc)/gender.html : $(Awklib)/gender.awk
	cd $(Awklib) && $(Awk2Html)


$(Doc)/dsl/awkplusplus.html : $(Bash)/awk++/awk++.html
	cd $(Bash) && $(Awk2Html)

$(Doc)/dsl/graph.html : $(Gawk)/misc/graph.awk     
	cd $(Gawk)/misc && $(Awk2Html)

$(Doc)/dsl/markdown.html : $(Gawk)/text/markdown.awk     
	cd $(Gawk) && $(Awk2Html)
$(Doc)/tools/awkwords.html : $(Bash)/awkwords     
	cd $(Bash) && $(Awk2Html)
$(Doc)/fun/enumerate.html  : $(Fun)/enumerate.awk 
	cd $(Fun) && $(Awk2Html)
