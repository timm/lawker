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
Go      = $(Awk)

Fs    = $(subst .awk ,.awk -f ,$?)#
App   = $(shell dirname $(Src))#
Where = $(Test):$(AWKPATH)# 
Uses  = $(Awk) -f $(Base)/uses.awk -u -f -R $(Test) #
Awks  = bash $(Base)/awkFiles.sh $(Lib)#

# standard util
Dirp  = if [ ! -d "$D" ]; then echo "making $D"; mkdir $D; fi#

ready : dirs noRepeats copies awkPath
	@echo "Ready for evil.">&2

dirs     : ; @$(foreach D, $(Dirs), $(Dirp); )
dirsTest : ; @find $(Dirs) -type d | egrep -v 'tmp|svn'

noRepeats : 
	@$(Awks) | bash $(Base)/fileCopies.sh

copies : $(shell $(Awks))
	@cp  $? $(Test) 

awkPath : 
	@export AWKPATH=`echo $(Where) | $(Awk) -f $(Base)/prunePath.awk` 

run : $(shell $(Uses) $(Src))#
	$(Go) -f $(Fs)

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
