#######################################################################
# This file is part of AWK-LIBRARY.
#
# AWK-LIBRARY is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# AWK-LIBRARY is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY# without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with AWK-LIBRARY.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################

# Makefile by  tim@menzies.us (http://menzies.us)
it=  main
run= gawk
args=
tmp=$(HOME)/tmp
vars= pgawk --dump-variables=$(tmp)/vars.out 
profile= pgawk --profile=$(tmp)/profile.out     

files=  $(shell  gawk -f slurp.awk $(it).awk; echo $(it).awk)
com= -f $(subst awk ,awk -f ,$(files)) 

execute : $(files)        ; $(run) $(com) $(args)
profile : $(files) $(tmp) ; @$(MAKE) run="$(profile)" execute
vars    : $(files) $(tmp) ; @$(MAKE) run="$(vars)"    execute
build   : $(files)        ; (echo "#`which $(run)` -f "; cat $(files)) >$(it)

$(tmp) : 
	@mkdir -p $(tmp)
