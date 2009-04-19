#    ___         
#  _/ oo\     An evil notion offers
# ( \  -/__   the Evil Makefile, (c) 2009 
#  \    \__)  by Tim Menzies, GPL 3.0
#  /     \    http://www.gnu.org/licenses/gpl.txt
# /      _\
# `"""""``  jgs

Evilrc ?= etc/dotevilrc#
include $(Evilrc)

Awk  := $(shell which gawk)#
Awks := $(shell find $(Write) -name "*.awk")#
Stem := $(subst .awk,,$(File))#
Uses  = $(Awk) -f $(Base)/uses.awk -u -f#

Dirs  = $(Work) $(Evil) $(Write) $(Read) $(Test) $(Run)#
Dirp  = if [ ! -d "$D" ]; then echo "making $D"; mkdir $D; fi#

all : dirs
	echo "[$(Write)]"

dirs :
	@$(foreach D, $(Dirs), $(Dirp); )

weaves :
	$(foreach One, $(Awks), make Path="$(One)" weaveOne; )

weaveOne : 
	make Path="$(One)" File="`basename $(One)`" weaveTwo

weaveTwo :  $(Test)/$(Stem).awk $(Read)/$(Stem).html

$(Test)/$(Stem).awk : $(shell cat $(Write)/$Path) | $(Uses) )  
	cat $?                     |\
	gawk -f $(Base)/xpand.awk   |\
	gawk -f $(Base)/unpre.awk     > $@

$(Read)/$(Stem).html : $(Write)/$(Path)
	cat $<                       |\
	gawk -f $(Base)/markdown.awk  |\
	gawk -f $(Base)/pres.awk       |\
	gawk -f $(base)/toc.awk         > $@
