#    ___         
#  _/ oo\     An evil idea: 
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

Stem := $(subst .awk,,$(File))#
Uses  = $(Awk) -f $(Base)/uses.awk -u -f#

# standard util
Dirp  = if [ ! -d "$D" ]; then echo "making $D"; mkdir $D; fi#

all : dirs

dirs     : ; @$(foreach D, $(Dirs), $(Dirp); )
dirsTest : ; @find $(Dirs) -type d | egrep -v 'tmp|svn'

weaves :
	$(foreach One, $(Awks), make Path="$(One)" weaveOne; )

weaveOne : 
	make Path="$(One)" File="`basename $(One)`" weaveTwo

weaveTwo :  $(Test)/$(Stem).awk $(Read)/$(Stem).html

#$(Test)/$(Stem).awk : $(shell cat $(Write)/$(Path)) | $(Uses) )  
#	cat $?                     |\
#	gawk -f $(Base)/xpand.awk   |\
#	gawk -f $(Base)/unpre.awk     > $@

#$(Read)/$(Stem).html : $(Write)/$(Path)
#	cat $<                       |\
#	gawk -f $(Base)/markdown.awk  |\
#	gawk -f $(Base)/pres.awk       |\
#	gawk -f $(base)/toc.awk         > $@
