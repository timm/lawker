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


BEGIN {
  ok = 1;
  check = 0;
}

/^User-agent:/ { 
  check = 0;
}

/^User-agent: \* *(#.*)?$/ { 
  check = 1;
}

/^User-agent: Plait *(#.*)?$/ { 
  check = 1;
}

/^Disallow: ?\/ *(#.*)?$/ {
  if (check==1) ok = 0;
}

/^Disallow: ?\/directory/ {
  if (check==1) ok = 0;
}

/^Allow: ?\/directory/ {
  if (check==1) ok = 1;
}

END {
  if (ok==1)
    print("OK");
  else 
    print("NOT OK");
}
