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


# setup: get and optionally shuffle the hints

state==0 {
  srand();
  numhints = split (hints, hint, "::");
  for (i=1; i<=numhints; i++)
  {
    hintindex[i] = i;
    if (order=="stripe2")
    {
      j = int (rand() * numhints) + 1;
      k = hint[i];
      hint[i] = hint[j];
      hint[j] = k;
    }
  }
  state=1;
}


# first pass: gather hint statistics

state==1 {
  for (i=1; i<=numhints; i++) 
  {
    if (tolower($0) ~ tolower(hint[i]))
    {
      hintmatches[i] += 1;
    }
  }
}


# end of first pass: calculate summary statistics
# and probability factors

state==2 {
  min=999999;
  max=0;
  total=0;
  goodhints=0;

  for (i=1; i<=numhints; i++)
  {
    if (hintmatches[i] < min && hintmatches[i] > 0)
    {
      min = hintmatches[i];
    }
    if (hintmatches[i] > max)
    {
      max = hintmatches[i];
    }
    total += hintmatches[i];
    if (hintmatches[i] > 0) goodhints++;
  }
  if (min==999999) min = 0;
  if (goodhints==0) goodhints=1;
  avg = total / goodhints;

  if (tracks==-1) mma = avg;
  else if (tracks==-2) mma = min;
  else if (tracks==-3) mma = max;
  else if (tracks==-4) mma = min;
  else mma = (tracks / goodhints);
  for (i=1; i<=numhints; i++)
  {
    if (hintmatches[i] > 0)
      hintfactors[i] = (mma / hintmatches[i]);
    else
      hintfactors[i] = 0;
    hintattempts[i] = 1;
    hintprints[i] = hintfactors[i];
  }

  if (order=="stripe2")
  {
    for (i=0; i<mma; i++) pos[i] = i;
    for (i=0; i<mma; i++)
    {
      j = int (rand() * mma);
      k = pos[i];
      pos[i] = pos[j];
      pos[j] = k;
    }
    for (i=1; i<=numhints; i++) posindex[i]=0;
  }

  state=3;
}


# generate a normally distributed random number

function boxmuller(x1, x2, w)
{
  if (gaussindex==1)
  {
    gaussindex = 0;
    return gauss1;
  }
  else
  {
    w = 1.0;
    while (w >= 1.0) 
    {
      x1 = 2.0 * rand() - 1.0;
      x2 = 2.0 * rand() - 1.0;
      w = x1 * x1 + x2 * x2;
    } 
    w = sqrt((-2.0 * log(w)) / w );
    gauss1 = x1 * w;
    gaussindex = 1;
    return (x2 * w);
  }
}


# print a track with a leading index such that the
# tracks will be ordered properly when the list is
# sorted

function printtrack(track, i, songindex, n, tries)
{
  if (order=="stripe")
  {
    songindex = hintindex[i];
    hintindex[i] += numhints;
    print songindex "\t" track;
  }
  else if (order=="stripe2")
  {
    if (posindex[i]<mma)
      songindex = pos[posindex[i]];
    else 
      songindex = posindex[i];
    posindex[i] += 1;
    songindex += (i / numhints);
    print songindex "\t" track;
  }
  else if (order=="stripe3")
  {
    n = int (rand() * mma);
    tries = 0;
    while (slots[n,i]==1 && tries < 40)
    {
      n = int (rand() * mma);
      printf "." > "/dev/stderr";
      tries++;
    } 
    tries = 0;
    while (slots[n,i]==1 && tries < 40)
    {
      n = int (rand() * max);
      printf "." > "/dev/stderr";
      tries++;
    } 
    if (slots[n,i]==1)
    {
      for (n=0; n<=max; n++)
      {
        if (slots[n,i]==0) break;
        printf "." > "/dev/stderr";
      } 
    }
    slots[n,i] = 1;
    songindex = n + (i / numhints);
    print songindex "\t" track;
  }
  else if (order=="fade")
  {
    songindex = boxmuller() + (1.2 * i);
    print songindex "\t" track;
  }
  else if (order=="random")
  {
    songindex = rand();
    print songindex "\t" track;
  }
  else if (order=="sort")
  {
    print track;
  }
  else if (order=="group")
  {
    songindex = rand() + i;
    print songindex "\t" track;
  }
}


# second pass: use statistics and random fudge
# to decide whether to print each track

state==3 {
  for (i=1; i<=numhints; i++)
  {
    if (tolower($0) ~ tolower(hint[i]))
    {
      if (tracks==-4)
      {
        printtrack($0, i);
        break;
      }
      else
      {
        hf = (2 * hintfactors[i] - (hintprints[i] / hintattempts[i]));
        hintattempts[i]++;
        r = rand();
        if (hf > r)
        {
          while (hf > r)
          {
            hintprints[i]++;
            printtrack($0, i);
            hf--;
          }
	  break;
        }
      }
    }
  }
}
