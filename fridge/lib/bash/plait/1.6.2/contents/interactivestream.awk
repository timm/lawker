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
  search = "";
  savesearch = "";
}

state==0 {
  printf \
    ("y: yes\nn: no\nY: yes to all\nN: no to all\n/: search\n") \
    > "/dev/tty";
  state = 1;
}

state==1 { 
  long = $0;
  sub("# ", "", long);
  brief = long;
  brief = substr(brief, 1, 72);
  action = "";
  response = "";

  if (all!="")
    {
      action = all;
    }

  if (action=="" && search!="")
    {
      if (tolower(long) ~ tolower(search))
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
      getline;
      printf ("%s\n", $0);
    }
  else if (action=="n")
    {
      getline;
    }

  # if search and "all" gave no instructions, ask the user

  else if (action=="")
    {
      printf("Play %s (ynYN/)? ", brief) > "/dev/tty";
      getline response < "/dev/tty";

      if (response ~ /Y(es)?/)
	{
	  response = "y";
	  all = "y";
	}
      else if (response ~ /N(o)?/)
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
	  getline;
	  printf ("%s\n", $0);
	}
      else
	{
	  getline;
	}
    }
}
