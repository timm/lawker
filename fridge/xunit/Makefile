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

# Makefile for an unit test system by tim@menzies.us (http://menzies.us)

egs=eg
tmp=$(HOME)/tmp
do=1

##### run lots of tests

tests:; @$(MAKE) watch |gawk '/^(PASS|FAIL)/{print $$1}' |sort |uniq -c 
watch:  setup dowatch teardown

dowatch:  
	@-$(foreach x, $(shell cd $(egs); ls  |egrep '^[0-9]+$$' |sort -n  ), \
		$(MAKE) do=$x dotest;)

#### run one test, compare its output to some eg/*.want entr
test    : setup dotest teardown 
setup   :; @ if [ -f "$(egs)/$@" ]; then cd $(egs) ; ./$@; fi
teardown:; @ if [ -f "$(egs)/$@" ]; then cd $(egs) ; ./$@; fi

dotest : $(tmp)   $(egs)/$(do).want
	@$(MAKE) run | tee $(tmp)/$(do).got 
	@if diff -s $(tmp)/$(do).got $(egs)/$(do).want > /dev/null;  \
        then echo PASS $(do) ; \
        else echo FAIL $(do),  got $(tmp)/$(do).got; \
        fi

# build a new test, cache the result as a eg/*.want file
cache : $(egs)/$(do)
	@$(MAKE) run  | tee $(egs)/$(do).want
	@echo new test result cached to $(egs)/$(do).want

# low level workers
run : $(egs)/$(do)	
	@printf "\n---| $(do) |-----------------------------------------\n\n"	
	@cd $(egs) ; ./$(do)

$(egs): ; echo 1; @- [ ! -d "$@" ] && mkdir -p "$@"
$(tmp): ; echo 2; @- [ ! -d "$@" ] && mkdir -p "$@"

