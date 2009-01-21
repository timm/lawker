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

# use.awk by tim@menzies.us (http://menzies.us)
$1=="#use" {use($2)}

function use(f) {
        gsub(/[\"']/,"",f)
        if (++Seen[f]==1) { # loop detection trick
          while((getline < f)>0)  if ($1 =="#use") use($2)
          print f 
          close(f) }
}
