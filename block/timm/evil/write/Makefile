include .evilrc

Dirs=$(Evil) $(Write) $(Read) $(Test) $(Run)
Dirp=if [ ! -d "$D" ]; then echo "making $D"; mkdir $D; fi

all : dirs
	echo "[$(Write)]"

dirs :
	@$(foreach D, $(Dirs), $(Dirp); )

$(Write)/$F.html :  $F.awk
	gawk -f $(Base)/nohash.awk $< | gawk -f $(Base)/pres.awk > $@
