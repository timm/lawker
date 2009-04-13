Evilrc ?= dotevilrc
include $(Evilrc)

Awk  := $(shell which gawk)#
Awks := $(shell find $(Write) -name "*.awk")#
Stem := $(subst .awk,,$(File))#

Dirs  = $(Work) $(Evil) $(Write) $(Read) $(Test) $(Run)#
Dirp  = if [ ! -d "$D" ]; then echo "making $D"; mkdir $D; fi#

all : dirs
	echo "[$(Write)]"

dirs :
	@$(foreach D, $(Dirs), $(Dirp); )

weaves :
	$(foreach One, $(Awks), \
		make Path="$(One)" File="`basename $(One)`" weave; )

weave : $(Test)/$(Stem).awk $(Read)/$(Stem).html

$(Test)/$(Stem).awk : $(Write)/$(Path)
	cat $<                       |\
	gawk -f $(Base)/nohash.awk    |\
	gawk -f $(Base)/markdownh.awk  |\
	gawk -f $(Base)/nopres.awk       > $@

$(Read)/$(Stem).html : $(Write)/$(Path)
	cat $<                     |\
	gawk -f $(Base)/xpand.awk   |\
	gawk -f $(Base)/nohash.awk   |\
	gawk -f $(Base)/pres.awk      |\
	gawk -f $(base)/toc.awk         > $@
