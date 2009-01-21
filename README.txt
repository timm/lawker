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
   thing/1.1/       # e.g.
         thing.awk  # one combined file for "thing"
         doc/       # documentation of v1.1 of thing
 
--| INSIDE "fridge" |-----------------------------------------------

fridge/
     doc/               # awk.info stuff (see "doc" below)
     etc/               # config files
     gawk/               # gawk code
     xgawk/            # xgawk code
     share/
        img/
     var/               # long live temporaries
        share/          # auto generated stuff

--| INSIDE ".awk" files |-----------------------------------------
 
The following standard is optional. 

 The code that renders the awk.info web site can "pretty print" awk code stored
in lawker.  For example, http://awk.info/?gawk/array/join.awk is a pretty
print of http://lawker.googlecode.com/svn/fridge/gawk/array/join.awk.

To enable that pretty print, add some html syntax inside your
code and apply the following convetions:

1) The first paragraph of the file will be ignored. Use this first para
for copyright notices or comments about down-in-the weeds trivia. Note: the
first para ends with one blank line.

2) The next paragraph should start with "#<h1><join>Title</join></h1>".

3) The code could should be topped and tailed as follows:

#<pre>
code
#</pre>

4) All other comment lines should start with a single "#" at front-of-line.
These comment characters will be stripped away by the awk.info renderer.

That's it. Now you can pretty print your code on the web just be adding
a little html in the comments. 

Note that this imposes a few constraints on your code; e.g. try and
keep the line widths to less than 60 characters and favor lots of short
functions with comments in between them, rather than larger ones- it
will be easier on the eye.
