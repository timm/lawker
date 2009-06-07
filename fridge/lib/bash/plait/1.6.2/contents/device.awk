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


# setup: get the list of preferred formats

state==0 {
  numtypes = split (types, type, " ");
  lasttrack = "";
  state = 1;
}


# get file extension

function typename(track, n, fields)
{
  n = split (track, fields, ".");
  return fields[n];
}


# get file path minus extension

function basename(track, j, n, fields, str, dot)
{
  n = split (track, fields, ".");
  str = "";
  dot = "";
  for (j=1; j<n; j++)
  {
    str = str dot fields[j];
    dot = ".";
  }
  return str;
}


# if a sequence of identical tracks in different
# formats has just ended, print the track in the
# preferred format.

function maybeprint(track, i, str)
{
  str = basename(track);
  if (lasttrack != str)
  {
    if (lasttrack != "")
    {
      for (i=1; i<=numtypes; i++)
      {
        if (tracktypes ~ type[i])
	{
          print lasttrack "." type[i];
          break;
        }
      }
    }
    lasttrack = str;
    tracktypes = typename(track);
  }
  else
  {
    tracktypes = tracktypes " " typename(track);
  }
}


# process each input line

state==1 {
  maybeprint($0);
}


END {
  maybeprint("");
}
