This repository is organized as follows.

--| TOP LEVEL |-----------------------------------------------

block   # place to chop up code. use for branches
freezer # frozen code. place to store tags
fridge  # fresh code. for the current trunk
wiki    # google wiki pages

--| INSIDE "block" |-----------------------------------------------

block/
   timm  # playpen sub-directory for person "timm"
   todo  # stuff to be imported into the "fridge" structure

--| INSIDE "freezer" |-----------------------------------------------

freezer/
   thing/1.1/       # e.g.
         thing.awk  # one combined file for "thing"
         doc/       # documentation of v1.1 of thing
 
--| INSDE "fridge" |-----------------------------------------------

fridge/
     doc/               # awk.info stuff
     etc/               # config files
     lib/
        gawk/           # stuff for posix standard awk
        lawker/         # lawker utlities
            builder/    # software to build packages ??? (name TBD)
            interface/  # software that provides the search, download and install interface to the
                        # repository, similar to 'dpkg', CPAN, PEAR, etc. (name TBD)
        xgawk           # code for the xgawk branch 
        otherawk        # code for other gawk variants
     share/
        img/
     var/               # long live temporaries
        share/          # auto generated stuff

--| INSIDE "gawk", "xgawk", "other gawk" |-----------------

(Note: all the .awk files in this sub-directory must have unique names)

gawk/   # (e.g.)
    c/
    sh/                   # code that combined gawk scripts with bash
    share/ 
        fun/              # stuff that is stand alone files (see "fun" notes, below)
           doc/           # notes on the functions
           test/          # test suite (see "test" notes, below)
        pkg/              # stuff where one file depends on another (see "pkg" notes, below)
        prep/             # pre-processor stuff
          awk++           # e.g.
          runkawk++       # e.g.
 
---| INSIDE "pkg" |-----------------------------------------

pkg/
   pkg1/      # example package. repeats the following structure
       src/   # code
       doc/   # notes
       test/  # test suite

--| INSIDE "test" |----------------------------------------
 
test/
   1         # test 1
   1.want    # expected output from test 1
   2
   2.want
   3
   3.want
   etc
 
