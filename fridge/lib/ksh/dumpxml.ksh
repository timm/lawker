#.H1 xmldump
#.P
#Displays components within a set of named XML files.
#With no options, displays the XML files much like that cat command.
#When options are supplied, displays only the selected components.
#.P
#.EM
#Editor's note: for those who do not want to take the plunge into <a href="http://awk.info/?Xgawk">xgawk</a>, dumpxml
#shows that shows standard Awk supports XML. For a discussion of this file, see
#.URL http://groups.google.com/group/comp.lang.awk/browse_thread/thread/1311a8b04a802265/f5a7d1d714297f00?lnk=gst&q=xml#f5a7d1d714297f00 comp.lang.awk.
#./em
#.H2 Synopsis
#.P xmldump -[cdit] file
#.H2   Download
#.P        This code requires awk and ksh. To download:
#.PRE
#wget  http://lawker.googlecode.com/svn/fridge/lib/ksh/dumpxml
#chmod +x dumpxml
#./PRE
#.H2 Description
#.P
#One reason I have a distinct loathing for XML, esp. in configuration
#files, is it's very difficult to parse (with line-based editors) and
#it's not very readable either.  In my book, this breaks both of the
#fundamental tests for a useable configuration standard .... whoever
#first thought XML was a good idea for anything except document mark-up
#should be shot (steps off soap box before he gets lynched for posting
#off-topic).
#.P
#Anyway, personal grievances aside, here's a script I was forced to
#write, unhappy and at gun-point, to try and make some XML files I was
#dealing with more readable.  This demonstrates how much work it takes
#in AWK just to parse the structure alone.  This doesn't even take into
#consideration reading attribute values or parsing DTDs.
#.P
#The next person who thinks it's a good idea to write a configuration
#file in XML will have to personally answer to my wrath ........
#perhaps I should set-up a new website banxml.org or xmlboycott.com
#with the sole intent to make the world see reason.  Anyone with me?
#:-)
#.H2 Code
#.H3 Set up
#.PRE
##!/bin/ksh
CALL=$(basename $0)
USAGE="Syntax: $CALL [-cdit] xmlfile ..."
#./PRE
#.H3 DisplayXML() 
#.P Displays selected components of a named XML file. Arguments:
#.DL
#.DT    arg 1 
#.DD  0 no doc content, 1 display doc content
#.DT     arg 2 
#.DD  0 no tags, 1 display tags
#.DT     arg 3 
#.DD  0 no comments, 1 display comments
#.DT     arg 4 
#.DD  0 do not change indentation, 1 recalculate indents
#.DT     arg 5 
#.DD  filename
#./DL
#.PRE
DisplayXML()
{
    nawk -v shdoc=$1 -v shtags=$2 -v shcomm=$3 -v indent=$4 '
    {
        pushline=levhigh=0

        ### If indenting strip any leading blanks from input
        CloseFlags()
        if (indent && !comment) sub("^[    ][      ]*","")

        ### Strip carriage returns
        gsub("\\r","")

        ### Scan line one character at a time
        for (c=1;c<=length($0);c++)
        {
            CloseFlags()
            ReadChars()
            DisplayChars()
        }

        if (newline)
        {
            print ""
            newline=0
        }
    }

    function CloseFlags()
    {
        if (comment==2) comment=0       # close comment
        if (tag==2) tag=0               # close tag
        if (quotes==2) quotes=0         # close quote
    }

    function ReadChars()
    {
        ch=substr($0,c,1)

        if (!comment)
        {
            if (ch=="<" && substr($0,c,4)=="<!--")
            {
                comment=1                       # opening comment
                ch=substr($0,c,4)               # stretch chars
                c+=3
            }
            else if (!tag && ch=="<")
            {
                tag=1                            # opening tag

                ### Increase or decrease indent depending
                ### on tag style <tag> or </tag> 
                ### but not <?tag?> or <!tag>
                ch2=substr($0,c,2)
                if (ch2=="</") level--
                else if (ch2!="<?" && ch2!="<!")
                {
                    level++
                    levhigh=1
                }
            }
            else if (tag)
            {
                if (!quotes && ch=="\"") quotes=1 # opening quote
                else if (quotes && ch=="\"") quotes=2   # closing 
                else if (!quotes && ch==">")
                {
                    tag=2                   # closing tag

                    ### Catch <tag/> style where
                    ### indent level should not change
                    if (c>1 && substr($0,c-1,2)=="/>") level--
                }
            }
        }
        else
        {
            if (ch=="-" && substr($0,c,3)=="-->")
            {
                comment=2                 # closing comment
                ch=substr($0,c,3)         # stretch chars
                c+=2
            }
        }
    }

    function DisplayChars()
    {
        ### Work out whether to display this character or not
        dispch=0
        if (comment && shcomm) dispch=1
        if (tag && shtags) dispch=1
        if (!comment && !tag && shdoc) dispch=1
        if (dispch)
        {
            if (indent) IndentLine()
            printf("%s",ch)
            if (!newline) newline=1
        }
    }

    function IndentLine()
    {
        if (pushline || comment) return
        pushline=1

        ### Have begun processing first tag so indent level
        ### may already be one level too high
        if ((thislevel=(levhigh?level-1:level))<0) thislevel=0
        for (lev=0;lev<thislevel;lev++) printf("  ")
    }' "$5"

}
#./PRE
#.H3 Start Up
#.PRE
comments=0
doc=0
indent=0
tags=0
help=0

while getopts cdit c
do
    case $c in
        c) comments=1;;
        d) doc=1;;
        i) indent=1;;
        t) tags=1;;
        ?) help=1;;
    esac
done
shift $(($OPTIND - 1))
#./PRE
#.P
#Display help message
#.PRE
if [ $help -eq 1 -o $# -eq 0 ]; then
    cat << EOF

Displays components within a set of named XML files.
With no options, displays the XML files much like that cat command.
When options are supplied, displays only the selected components.

$USAGE

where   -c      displays comments
        -d      displays document contents
        -i      indent properly
        -t      displays tags

EOF
    exit 2
fi
#./PRE
#.P If no options supplied, then display entire XML files
#.PRE
if [ $comments -eq 0 -a $doc -eq 0 -a $tags -eq 0 ]; then
    comments=1
    doc=1
    tags=1
fi

first=1
while [ $# -gt 0 ]
do
    if [ $first -eq 1 ]; then
         first=0
    else echo " "  ### this should be Ctrl+L for a form-feed
    fi

    echo "<!-- --- $1 --- -->"
    DisplayXML $doc $tags $comments $indent "$1"
    shift
done 
#./PRE
#.H2 Author
#.P Mark R.Bannister &lt;markb at freedomware.co.uk>. 
