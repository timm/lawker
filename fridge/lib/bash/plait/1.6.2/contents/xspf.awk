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
  title = toupper (substr (title, 1, 1)) substr (title, 2);
  print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
  print "<playlist version=\"0\" xmlns = \"http://xspf.org/ns/0/\">";
  print "  <title>" title "</title>";
  print "  <trackList>";
}


function myurlencode(str)
{
  gsub (" ", "%20", str);
  gsub ("'", "%27", str);
  gsub ("&", "and", str);
  gsub (";", "%3b", str);
  gsub ("/", "%2f", str);
  gsub ("\\?", "%3f", str);
  gsub (":", "%3a", str);
  gsub ("@", "%40", str);
  gsub ("=", "%3d", str);
  return str;
}

{
  p2 = plait "/art.url";
  s = $0;
  sub (d "/", "", s);
  split (s, fields, sep);
  artist = fields[ar];
  album = fields[al];
  song = fields[so];
  split (song, f2, "[.]");
  song = f2[1];
  gsub ("_", " ", song);
  sub ("[0-9][0-9]? ?- ?", "", song);
  song = toupper (substr (song, 1, 1)) substr (song, 2);
  album = toupper (substr (album, 1, 1)) substr (album, 2);
  artist = toupper (substr (artist, 1, 1)) substr (artist, 2);

  if (index(s, "http://") != 1)
    {
      print "    <track>";
      print "      <creator>" artist "</creator>";
      print "      <album>" album "</album>";
      print "      <title>" song "</title>";
      print "      <location>" url s "</location>";
      if (art==1)
	{
	  ar2 = myurlencode(artist);
	  al2 = myurlencode(album);
	  url2 = "http://ws.audioscrobbler.com/1.0/album/" ar2 "/" al2 "/info.xml";
	  if (url2 in images)
	    {
	      image = images[url2];
	    }
	  else
	    {
	      if (mustdelay==1)
		{
		  system ("sleep 1");
		}
	      system ("wget > /dev/null 2>&1 -O \"$HOME/.plait/art.xml\" " url2);
	      mustdelay = 1;
	      system ("awk -f " coverprog " \"$HOME/.plait/art.xml\" > \"$HOME/.plait/art.url\"");
	      close (p2);
	      getline image < p2;
	      images[url2] = image;
	    }

	  if (image != "No art available")
	    {
	      print "      <image>" image "</image>";
	    }
	}
      print "    </track>";
    }
  else
    {
      print "    <track>";
      print "      <annotation>" s "</annotation>";
      print "      <location>" s "</location>";
      print "    </track>";
    }
}


END {
  print "  </trackList>";
  print "</playlist>";
}
