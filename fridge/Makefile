#MAKEFLAGS +=  -s
Doc=$(Lawker)/doc
Gawk=$(Lawker)/gawk
Bash=$(Lawker)/lib/bash
Config=$(Lawker)/etc
Awklib=$(Lawker)/lib/awk
Fun=$(Lawker)/gawk/fun
Awkwords=$(Bash)/awkwords
Awk2Html=$(Bash)/awkwords $< > $@ 

all : config.xml files  commit

commit : 
	cd $(Lawker); pwd; svn commit

config.xml :	$(Config)/tags.txt $(Config)/things.awk $(Config)/tags.awk 	
	cd $(Config); \
	(gawk -f things.awk config.xml ;\
     gawk -f tags.awk tags.txt) > confignew.xml; \
	mv confignew.xml config.xml

files : $(Doc)/dsl/markdown.html \
	    $(Doc)/tools/awkwords.html \
	    $(Doc)/tools/m1.html \
	    $(Doc)/fun/enumerate.html \
	    $(Doc)/dsl/awkplusplus.html\
	    $(Doc)/dsl/graph.html \
	    $(Doc)/gender.html \
    	$(Doc)/awk100/spell.html \
    	$(Doc)/story.html 

awkpp :  
	cd $(Bash)/awk++ && zip -r awk++.zip *
    	
$(Doc)/story.html : $(Awklib)/grammar/story.awk 
	cd $(Awklib)/grammar && $(Awk2Html)
	    
$(Doc)/tools/m1.html : $(Awklib)/m1.awk
	cd $(Awklib) && $(Awk2Html)

$(Doc)/awk100/spell.html : $(Awklib)/spell.awk
	cd $(Awklib) && $(Awk2Html)

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
