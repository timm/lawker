#    ___         
#  _/ oo\     Evil ideas: 
# ( \  -/__   the Evil Makefile 
#  \    \__)  
#  /     \    by Tim Menzies, (c) 2009, GPL 3.0 
# /      _\   http://www.gnu.org/licenses/gpl.txt
# `"""""``  jgs

Evilrc  ?= etc/dotevilrc#
include $(Evilrc)

Awk     := $(shell which gawk)#
Debug   := $(shell which pgawk) --dump-variables=$(Tmp)/vars.out#
Profile := $(shell which pgawk) --profile=$(Tmp)/profile.out#  

Stem  = $(subst .awk,,$(Src))#
Uses  = $(Awk) -f $(Base)/uses.awk -u -f#

# standard util
Dirp  = if [ ! -d "$D" ]; then echo "making $D"; mkdir $D; fi#

ready : dirs norepeats
	@echo "Ready for evil.">&2

dirs     : ; @$(foreach D, $(Dirs), $(Dirp); )
dirsTest : ; @find $(Dirs) -type d | egrep -v 'tmp|svn'

norepeats :
	 bash $(Base)/awkcopies $(Lib)

weaves : ready $(Src) 
	echo $(shell $(Uses) $(Src))
	$(foreach F,$(shell $(Uses) $(Src)), $(MAKE) Src=$F weave;)

weave : 
	echo $(Src)

#weaveTwo :  $(Test)/$(Stem).awk $(Read)/$(Stem).html

#$(Test)/$(Stem).awk : $(shell cat $(Write)/$(Path)) | $(Uses) )  
#	cat $?                     |\
#	gawk -f $(Base)/xpand.awk   |\
#	gawk -f $(Base)/unpre.awk     > $@

#$(Read)/$(Stem).html : $(Write)/$(Path)
#	cat $<                       |\
#	gawk -f $(Base)/markdown.awk  |\
#	gawk -f $(Base)/pres.awk       |\
#	gawk -f $(base)/toc.awk         > $@

#add comments to markdown files and move them into test
# need to specifty root
