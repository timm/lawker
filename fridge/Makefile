#MAKEFLAGS +=  -s
Lawker ?= $(shell pwd)

Doc=$(Lawker)/doc
Gawk=$(Lawker)/gawk
Bash=$(Lawker)/lib/bash
Cee=$(Lawker)/c
Ksh=$(Lawker)/lib/ksh
Config=$(Lawker)/etc
Awklib=$(Lawker)/lib/awk
Fun=$(Lawker)/gawk/fun
Awkwords=$(Bash)/awkwords
Awk2Html=$(Bash)/awkwords $< > $@ ; svn add $@

all : config.xml files  meta commit

meta : doc/var/tags.html doc/var/toc.html

commit : 
	@cd $(Lawker); svn commit

config.xml :	$(Config)/tags.txt $(Config)/things.awk $(Config)/tags.awk 	
	@cd $(Config); \
	(gawk -f things.awk config.xml ;\
     gawk -f tags.awk tags.txt) > confignew.xml; \
	mv confignew.xml config.xml

doc/var/toc.html : etc/tags.txt etc/toc.awk 
	@(cd etc; gawk -f toc.awk tags.txt ) >  $@

doc/var/tags.html : etc/tags.txt etc/taglist.awk 
	@ make taglist > $@

taglist :
	@ cd etc; \
	echo "<h1><join>Page Tags</join></h1>";           \
	echo "<center><table>";                             \
	echo "<tr><td>Number</td><td>Tag</td></tr>"  ;       \
	gawk -f taglist.awk tags.txt | sort -r -n -k 3  -k 5;  \
	echo "</table></center>" 

files : $(Doc)/dsl/markdown.html \
	    $(Doc)/tools/nbc.html \
	    $(Doc)/tools/awkwords.html \
	    $(Doc)/tools/correlate.html \
	    $(Doc)/tools/indent.html \
	    $(Doc)/tools/psrev.html \
	    $(Doc)/tools/pschoose.html \
	    $(Doc)/tools/xmlparse.html \
	    $(Doc)/tools/cryptosig.html \
	    $(Doc)/tools/sigs.html \
	    $(Doc)/tools/fsm.html \
	    $(Doc)/tools/m1.html \
	    $(Doc)/fun/enumerate.html \
	    $(Doc)/dsl/awkplusplus.html\
	    $(Doc)/dsl/ooc.html \
	    $(Doc)/dsl/uml.html \
	    $(Doc)/dsl/graph.html \
	    $(Doc)/gender.html \
    	$(Doc)/awk100/spell.html \
    	$(Doc)/awk100/aaa.html \
    	$(Doc)/hanoi.html \
    	$(Doc)/story.html \
    	$(Doc)/mailsort.html\
    	$(Doc)/readminds.html\
    	$(Doc)/s2a.html\
		$(Doc)/tools/shuffle.html\
    	$(Doc)/spam.html\
    	$(Doc)/dumpxml.html\
    	$(Doc)/getxml.html\
    	$(Doc)/quicksort.html\
    	$(Doc)/quicksort2.html\
    	$(Doc)/eliza.html\
    	$(Doc)/tictactoe.html\
    	$(Doc)/mastermind2.html\
    	$(Doc)/mastermind.html \
		$(Doc)/tip/awk4db.html

awkpp :  
	cd $(Bash)/awk++ && zip -r awk++.zip *
    

$(Doc)/dsl/ooc.html  :  $(Bash)/ooc/ooc.html
	cp $< $@

$(Doc)/spam.html       		: $(Ksh)/spam.ksh             ; cd $(Ksh) && $(Awk2Html)
$(Doc)/dumpxml.html    		: $(Ksh)/dumpxml.ksh          ; cd $(Ksh) && $(Awk2Html)
$(Doc)/tools/correlate.html : $(Awklib)/correlate.awk 	  ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tools/fsm.html : $(Cee)/fsm/contents/readme.html 	  ; cd $> && $(Awk2Html)
#$(Doc)/tools/options.html : $(Awklib)/optionsDemo.awk 	  ; cd $(Awklib) && $(Awk2Html)

$(Doc)/tools/xmlparse.html      : $(Awklib)/xmlparse.awk   ; cd $(Awklib)/grammar && $(Awk2Html)
$(Doc)/story.html      : $(Awklib)/grammar/story.awk  ; cd $(Awklib)/grammar && $(Awk2Html)
$(Doc)/eliza.html      : $(Awklib)/eliza.awk          ; cd $(Awklib) && $(Awk2Html)
$(Doc)/mastermind2.html : $(Awklib)/mastermind2.awk   ; cd $(Awklib) && $(Awk2Html)
$(Doc)/mastermind.html : $(Awklib)/mastermind.awk     ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tictactoe.html : $(Awklib)/tictactoe.awk       ; cd $(Awklib) && $(Awk2Html)
$(Doc)/s2a.html        : $(Awklib)/s2a.awk            ; cd $(Awklib) && $(Awk2Html)
$(Doc)/readminds.html  : $(Awklib)/readminds.awk      ; cd $(Awklib) && $(Awk2Html)
$(Doc)/hanoi.html      : $(Awklib)/hanoi.awk          ; cd $(Awklib) && $(Awk2Html)
$(Doc)/quicksort.html  : $(Awklib)/quicksort.awk      ; cd $(Awklib) && $(Awk2Html)
$(Doc)/quicksort2.html : $(Awklib)/quicksort2.awk     ; cd $(Awklib) && $(Awk2Html)
$(Doc)/getxml.html     : $(Awklib)/getxml.awk         ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tools/m1.html   : $(Awklib)/m1.awk             ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tools/shuffle.html   : $(Awklib)/shuffle.awk   ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tools/cryptosig.html : $(Awklib)/cryptosig.awk ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tools/sigs.html : $(Bash)/sigs                 ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tools/nbc.html : $(Bash)/nbc/contents/nbc      ; cd $(Awklib) && $(Awk2Html)
$(Doc)/tip/awk4db.html : $(Awklib)/awk4db/contents/readme.awk
	 cd $(Awklib)/awk4db && zip -u contents.zip && cd contents && $(Awk2Html)

$(Doc)/mailsort.html : $(Awklib)/mailsort.awk
	cd $(Awklib) && $(Awk2Html)

$(Doc)/awk100/spell.html : $(Awklib)/spell.awk
	cd $(Awklib) && $(Awk2Html)

$(Doc)/awk100/aaa.html : $(Bash)/aaa/contents/aaa.html
	cp $< $@

$(Doc)/gender.html : $(Awklib)/gender.awk
	cd $(Awklib) && $(Awk2Html)


$(Doc)/dsl/awkplusplus.html : $(Bash)/awk++/awk++.html;  cd $(Bash) && $(Awk2Html)
$(Doc)/dsl/uml.html : $(Bash)/uml.sh ;  cd $(Bash) && $(Awk2Html)

$(Doc)/dsl/graph.html : $(Gawk)/misc/graph.awk     
	cd $(Gawk)/misc && $(Awk2Html)

$(Doc)/tools/indent.html : $(Awklib)/indent.awk     
	cd $(Awklib) && $(Awk2Html)

$(Doc)/tools/pschoose.html : $(Awklib)/pschoose.awk     
	cd $(Awklib) && $(Awk2Html)

$(Doc)/tools/psrev.html : $(Awklib)/psrev.awk     
	cd $(Awklib) && $(Awk2Html)

$(Doc)/dsl/markdown.html : $(Gawk)/text/markdown.awk     
	cd $(Gawk) && $(Awk2Html)
$(Doc)/tools/awkwords.html : $(Bash)/awkwords     
	cd $(Bash) && $(Awk2Html)
$(Doc)/fun/enumerate.html  : $(Fun)/enumerate.awk 
	cd $(Fun) && $(Awk2Html)
