 This repository is organized as follows.

--| TOP LEVEL |-----------------------------------------------

block   # place to chop up code. use for branches
freezer # frozen code. place to store tags
fridge  # fresh code. for the current trunk
wiki    # google wiki pages

--| INSIDE "block" |-----------------------------------------------

block/
   timm  # play pen sub-directory for person "timm"
   fred   # etc
   your name 
   ...

--| INSIDE "freezer" |-----------------------------------------------

freezer/
   thing/
       /latest        # e.g. copy of the 1.1 directory
       /1.1          # e.g.
         thing.awk  # one combined file for "thing"
         doc/       # documentation of v1.1 of thing
	     otherstuff/
 
--| INSIDE "fridge" |-----------------------------------------------

fridge/
     doc/               # awk.info stuff (see "doc" below)
     etc/               # config files
     gawk/              # gawk code
     xgawk/             # xgawk code
     share/
        img/
     var/               # long live temporaries
        share/          # auto generated stuff

--| INSIDE ".awk" files |-----------------------------------------
 
The following standard is optional. 

 The code that renders the awk.info web site can "pretty print" awk code stored
in lawker.  For example, http://awk.info/?gawk/array/join.awk is a pretty
print of http://lawker.googlecode.com/svn/fridge/gawk/array/join.awk.

To enable that pretty print, please see the instructions in 
http://awk.info/?prettyprint .
