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
  all = "";
  search = "";
  levelsep = "/";
  skipindex = 0;
  playindex = 0;
}

state==0 {
  printf \
    ("y: yes\nn: no\nY: yes to all\nN: no to all\n") > "/dev/tty";
  printf \
    ("u: up a level\nd: down a level\n/: search\n") > "/dev/tty";
  state = 1;
}


state==1 { 
  brief = $0;
  sub(prefix, "", brief);
  action = "";
  response = "";
  len = 0;

  # take the advice of the longest (most specific) hint

  for (i=1; i<=skipindex; i++)
    {
      if (index(tolower(brief), tolower(skiphints[i])) > 0 && length(skiphints[i]) > len)
	{
	  action = "n";
	  len = length(skiphints[i]);
	}
    }

  for (i=1; i<=playindex; i++)
    {
      if (index(tolower(brief), tolower(playhints[i])) > 0 && length(playhints[i]) > len)
	{
	  action = "y";
	  break;
	}
    }

  if (action=="" && all!="")
    {
      action = all;
    }

  if (action=="" && search!="")
    {
      if (tolower(brief) ~ tolower(search))
	{
	  search = "";
	}
      else
	{
	  action = "n";
	}
    }

  if (action=="y")
    {
      printf ("%s\n", $0);
    }

  # if hints and "all" gave no instructions, ask the user

  else if (action=="")
    {
      levels = split(brief, briefparts, levelsep);
      if (levels + levelindex < 1)
	{
	  levelindex = 1 - levels;
	}
      for (i=1; i<=levels; i++)
	{
	  # escape regex special chars that might appear in a filename
	  briefparts2[i] = briefparts[i];
	  # gsub("\\(", "\\(", briefparts2[i]);
	  # gsub("\\)", "\\)", briefparts2[i]);
	  # gsub("\\+", "\\+", briefparts2[i]);
	  # gsub("\\[", "\\[", briefparts2[i]);
	  # gsub("\\]", "\\]", briefparts2[i]);
	  # gsub("\\|", "\\|", briefparts2[i]);
	  # gsub("\\*", "\\*", briefparts2[i]);
	}
      cont = 1;
      while (cont==1)
	{
	  cont = 0;
	  str = "";
	  str2 = "";
	  sep = "";
	  sep2 = "";
	  for (i=1; i<=levels+levelindex; i++)
	    {
	      str = str sep briefparts2[i];
	      str2 = str2 sep2 briefparts[i];
	      sep = levelsep;
	      sep2 = "/";
	    }
	  printf("Play %s (ynYNud/)? ", str2) > "/dev/tty";
	  getline response < "/dev/tty";
	  if (response ~ /^u(p)?/)
	    {
	      cont = 1;
	      levelindex -= 1;
	      if (levels + levelindex < 1)
		{
		  levelindex = 1 - levels;
		}
	    }
	  if (response ~ /^d(own)?/)
	    {
	      cont = 1;
	      levelindex += 1;
	      if (levelindex > 0)
		{
		  levelindex = 0;
		}
	    }
	}

      if (response ~ /^Y(es)?/)
	{
	  response = "y";
	  all = "y";
	}
      else if (response ~ /^N(o)?/)
	{
	  response = "n";
	  all = "n";
	}
      else if (response ~ /^\//)
	{
	  search = substr(response, 2);
	  if (search=="")
	    {
	      search = savesearch;
	    }
	  if (search=="")
	    {
	      printf("Search string: ") > "/dev/tty";
	      getline search < "/dev/tty";
	    }
	  savesearch = search;
	  response = "n";
	}
      if (response ~ /y(es)?/ || response=="")
	{
	  printf("%s\n", $0);

	  # if we're above track level, this may match more than one track, so save it
	  if (levelindex < 0)
	    {
	      playhints[++playindex] = str;
	    }
	}
      else if (response ~ /n(o)?/)
	{
	  if (levelindex < 0)
	    {
	      skiphints[++skipindex] = str;
	    }
	}
    }
}
