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
  state = 0;
}


{
  if (state==0 && $0 ~ /<coverart>/) state = 1;
  if (state==1 && $0 ~ /<medium>/)
    {
      state = 2;
      art = "";
    }
  if (state==2)
    {
      art = art $0;
    }
  if (state==2 && $0 ~ /<\/medium>/)
    {
      state = 3;
      sub (".*<medium>[ \t]*", "", art);
      sub ("[ \t]*</medium>.*", "", art);
    }
}


END {
  if (state==3)
    print art;
  else
    print "No art available";
}
