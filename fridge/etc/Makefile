#MAKEFLAGS +=  -s

all : config.xml

config.xml :	tags.txt things.awk tags.awk 	
	(gawk -f ./things.awk config.xml ; gawk -f ./tags.awk tags.txt) > confignew.xml
	mv confignew.xml config.xml
	svn commit -m "tags updated"
