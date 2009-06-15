# needs: 
#   $Dir: where to find source code
#   $Files: list of awk files
# sets
#   $Com: an awk command lne
#   $Head: somthing to print before each test

Com=	$(shell which gawk) -f $(Dir)$(subst awk ,awk -f $(Dir),$(Files))

Head=	printf "\n---| example '$@'] |---------------------------------\n\n"

show :
	@echo $(Com)
