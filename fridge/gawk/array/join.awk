# This code is part of LAWKER: the AWK code locker
# Copyright (C) 2009 Arnold Robbins arnold@gnu.org, Public Domain
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.


# <h1><join>Join.awk</join></h1>
#<p> Returns a string containing all contents of an array.
#<p>Arguments:
#<dl>
#<dt>array</dt>
#<dd>Input array.
#<dt>start,end
#<dd>Indexes for where to start/stop in the array.
#<dt>sep
#<dd>what to write between each item. Defaults to blank space. If set to the magic value
#<tt>SUBSEP</tt>
#then internally, <tt>join</tt> adds nothing between the items. 
#</dl>
function join(array, start, end, sep,    result, i)
{
    if (sep == "")
       sep = " "
    else if (sep == SUBSEP) # magic value
       sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}
