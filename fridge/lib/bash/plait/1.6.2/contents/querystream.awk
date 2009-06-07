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
  interactive = 0;
}

/<tr>/ { 
  record = 1; row = ""; save = 0;
}

{ 
  if (record==1) row = row $0;
}

/playlist.pls/ { 
  save = 1;
}

/<\/tr>/ {
  if (save==1)
    {
      hit = 1;
      nh = split(hints, hint);
      i = 1;
      while (i<=nh)
	{
	  gsub ("_", " ", hint[i]);
	  if (hint[i]=="not" && i < nh)
	    {
	      gsub("_", " ", hint[i+1]);
	      if (match(tolower(row), tolower(hint[i+1])))
		{
		  hit = 0;
		  break;
		}
	      else
		i += 2;
	    }
	  else
	    {
	      if (mix==0 && !match(tolower(row), tolower(hint[i])))
		{
		  hit = 0;
		  break;
		}
	      else
		i++;
	    }
	}
      if (hit==1)
	{
	  if (interactive==1)
	    {
	      if (match(row, \
                /<a id=\"listlinks\" target=\"_scurl\" href=\"[^\"]*\">.*?<\/a>/) > 0)
		{
		  desc = substr(row, RSTART, RLENGTH);
		  sub(/<a id=\"listlinks\" target=\"_scurl\" href=\"[^\"]*\">/, "", desc);
		  gsub("</a>", "", desc);
		  gsub("<[^>]*>", "", desc);
		  if (match(row, /shoutcast-playlist.pls\?rn=[0-9]+&file=filename.pls/) > 0)
		    {
		      a = substr(row, RSTART, RLENGTH);
		      printf("# %s\n", desc);
		      printf "http://www.shoutcast.com/sbin/%s\n", a;
		    }
		}
	    }
	  else
	    {
	      if (match(row, /shoutcast-playlist.pls\?rn=[0-9]+&file=filename.pls/) > 0)
		{
		  a = substr(row, RSTART, RLENGTH);
		  printf "http://www.shoutcast.com/sbin/%s\n", a;
		}
	    }
	}
    }
  save = 0;
  record = 0;
}

