#
# Copyright (C) 2005, 2006 Stephen Jungels
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.  
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# See COPYING for the full text of the license.


function deregex(str)
{
  gsub ("\\(", "\\(", str);
  gsub ("\\)", "\\)", str);
  gsub ("\\[", "\\[", str);
  gsub ("\\]", "\\]", str);
  gsub ("\\.", "\\.", str);
  gsub ("\\?", "\\?", str);
  gsub ("\\*", "\\*", str);
  gsub ("\\|", "\\|", str);
  gsub ("\\+", "\\+", str);
  return str;
}


{
  if (index ($0, "http://") != 1)
    {
      path = $0;
      d2 = deregex(d);
      sub (d2, "", path);
      n = split (path, subdirs, "/");
      base = subdirs[n];
      b2=deregex(base);
      sub (b2, "", path);

      print "mkdir -p \"" to path "\"";
      print "cp \"" $0 "\" \"" to path "\"";
    }
}
