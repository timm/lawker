#.h1 Mail Sort
#.h2 Author
#.P
#Arnold Robbins
#.h2 Download
#.P
#Download from
#.URL http://lawker.googlecode.com/svn/fridge/lib/awk/mailsort.awk LAWKER.
#.h2 Description
#.P
#Sorts a Unix style mailbox by "thread", in date+subject order.
#.P
#This is a  script I use quite a lot.  It requires gawk although with some work could
#be ported to standard awk.  The timezone offset from GMT has to be
#adjust to one's local offset, although I could probably eliminate
#that if I wanted to work on it hard enough.
#.P
#This took me a while to write and get right, but it's been working
#flawlessly for a few years now.
#The script uses Message-ID header to detect and remove duplicates.  It requires GNU Awk for
# time/date functions and for efficiency hack in string concatenation but could
# be made to run on a POSIX awk with some work.
#.h2 Code
#.H3 Main
#.PRE
BEGIN {
       TRUE = 1
       FALSE = 0

       split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", months, " ")
       for (i in months)
               Month[months[i]] = i    # map name to number

       MonthDays[1] = 31
       MonthDays[2] = 28       # not used
       MonthDays[3] = 31
       MonthDays[4] = 30
       MonthDays[5] = 31
       MonthDays[6] = 30
       MonthDays[7] = 31
       MonthDays[8] = 31
       MonthDays[9] = 30
       MonthDays[10] = 31
       MonthDays[11] = 30
       MonthDays[12] = 31

       In_header = FALSE
       Body = ""

       LocalOffset = 2 # We are two hours ahead of GMT

       # These keep --lint happier
       Debug = 0
       MessageNum = 0
       Duplicates = FALSE
}

/^From / {
       In_header = TRUE
       if (MessageNum)
               Text[MessageNum] = Body
       MessageNum++
       Body = ""
 # print MessageNum
}

In_header && /^Date: / {
       Date[MessageNum] = compute_date($0)
}

In_header && /^Subject: / {
       Subject[MessageNum] = canonacalize_subject($0)
}

In_header && /^Message-[Ii][Dd]: / {
       if (NF == 1) {
               getline junk
               $0 = $0 RT junk # Preserve original input text!
       }

       # Note: Do not use $0 directly; it's needed as the Body text
       # later on.

       line = tolower($0)
       split(line, linefields)

       message_id = linefields[2]
       Mesg_ID[MessageNum] = message_id        # needed for disambiguating message
       if (message_id in Message_IDs) {
               printf("Message %d is duplicate of %s (%s)\n",
                       MessageNum, Message_IDs[message_id],
                       message_id) > "/dev/stderr"
               Message_IDs[message_id] = (Message_IDs[message_id] ", " MessageNum)
               Duplicates++
       } else {
               Message_IDs[message_id] = MessageNum ""
       }
}


In_header && /^$/ {
       In_header = FALSE
       # map subject and date to index into text

       if (Debug && (Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum]) in SubjectDateId) {
               printf(\
       ("Message %d: Subject <%s> Date <%s> Message-ID <%s> already in" \
       " SubjectDateId (Message %d, s: <%s>, d <%s> i <%s>)!\n"),
               MessageNum, Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum],
               SubjectDateId[Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum]],
               Subject[SubjectDateId[Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum]]],
               Date[SubjectDateId[Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum]]],
               Mesg_ID[SubjectDateId[Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum]]]) \
                       > "/dev/stderr"
       }

       SubjectDateId[Subject[MessageNum], Date[MessageNum], Mesg_ID[MessageNum]] = MessageNum

       if (Debug) {
               printf("\tMessage Num = %d, length(SubjectDateId) = %d\n",
                       MessageNum, length(SubjectDateId)) > "/dev/stderr"
               if (MessageNum != length(SubjectDateId) && ! Printed1) {
                       Printed1++
                       printf("---> Message %d <---\n", MessageNum) > "/dev/stderr"
               }
       }

       # build up mapping of subject to earliest date for that subject
       if (! (Subject[MessageNum] in FirstDates) ||
           FirstDates[Subject[MessageNum]] > Date[MessageNum])
               FirstDates[Subject[MessageNum]] = Date[MessageNum]
}

{
       Body = Body ($0 "\n")
}

END {
       Text[MessageNum] = Body # get last message

       if (Debug) {
               printf("length(SubjectDateId) = %d, length(Subject) = %d, length(Date) = %d\n",
                       length(SubjectDateId), length(Subject), length(Date))
               printf("length(FirstDates) = %d\n", length(FirstDates))
       }

       # Create new array to sort by thread. Subscript is
       # earliest date, subject, actual date
       for (i in SubjectDateId) {
               n = split(i, t, SUBSEP)
               if (n != 3) {
                       printf("yowsa! n != 3 (n == %d)\n", n) > "/dev/stderr"
                       exit 1
               }
               # now have subject, date, message-id in t
               # create index into Text
               Thread[FirstDates[t[1]], i] = SubjectDateId[i]
       }

       n = asorti(Thread, SortedThread)        # Shazzam!

       if (Debug) {
               printf("length(Thread) = %d, length(SortedThread) = %d\n",
                       length(Thread), length(SortedThread))
       }
       if (n != MessageNum && ! Duplicates) {
               printf("yowsa! n != MessageNum (n == %d, MessageNum == %d)\n",
                       n, MessageNum) > "/dev/stderr"
	#               exit 1
       }

       if (Debug) {
               for (i = 1; i <= n; i++)
                       printf("SortedThread[%d] = %s, Thread[SortedThread[%d]] = %d\n",
                               i, SortedThread[i], i, Thread[SortedThread[i]]) > "DUMP1"
               close("DUMP1")
               if (Debug ~ /exit/)
                       exit 0
       }

       for (i = 1; i <= MessageNum; i++) {
               if (Debug) {
                       printf("Date[%d] = %s\n",
                               i, strftime("%c", Date[i]))
                       printf("Subject[%d] = %s\n", i, Subject[i])
               }

               printf("%s", Text[Thread[SortedThread[i]]]) > "OUTPUT"
       }
       close("OUTPUT")

       close("/dev/stderr")    # shuts up --lint
}
#./PRE
#.H2 compute_date 
#.P
# Pull apart a date string and convert to timestamp.
#.PRE
function compute_date(date_rec,         fields, year, month, day,
                                       hour, min, sec, tzoff, timestamp)
{
       split(date_rec, fields, "[:, ]+")
       if ($2 ~ /Sun|Mon|Tue|Wed|Thu|Fri|Sat/) {
               # Date: Thu, 05 Jan 2006 17:11:26 -0500
               year = fields[5]
               month = Month[fields[4]]
               day = fields[3] + 0
               hour = fields[6]
               min = fields[7]
               sec = fields[8]
               tzoff = fields[9] + 0
       } else {
               # Date: 05 Jan 2006 17:11:26 -0500
               year = fields[4]
               month = Month[fields[3]]
               day = fields[2] + 0
               hour = fields[5]
               min = fields[6]
               sec = fields[7]
               tzoff = fields[8] + 0
       }
       if (tzoff == "GMT" || tzoff == "gmt")
               tzoff = 0
       tzoff /= 100    # assume offsets are in whole hours
       tzoff = -tzoff

       # crude compensation for timezone
       # mktime() wants a local time:
       #       hour + tzoff yields GMT
       #       GMT + LocalOffset yields local time
       hour += tzoff + LocalOffset

       # if moved into next day, reset other values
       if (hour > 23) {
               hour %= 24
               day++
               if (day > days_in_month(month, year)) {
                       day = 1
                       month++
                       if (month > 12) {
                               month = 1
                               year++
                       }
               }
       }

       timestamp = mktime(sprintf("%d %d %d %d %d %d -1",
                               year, month, day, hour, min, sec))

       # timestamps can be 9 or 10 digits.
       # canonicalize them into 11 digits with leading zeros
       return sprintf("%011d", timestamp)
}
#./PRE
#.H3  days_in_month 
#.P
# How many days in the given month?

function days_in_month(month, year)
{
       if (month != 2)
               return MonthDays[month]

       if (year % 4 == 0 && year % 400 != 0)
               return 29

       return 28
}
#./PRE
#.H3 canonacalize_subject 
#.P
#Trim out "Re:", white space.
#.PRE
function canonacalize_subject(subj_line)
{
       subj_line = tolower(subj_line)
       sub(/^subject: +/, "", subj_line)
       sub(/^(re: *)+/, "", subj_line)
       sub(/[[:space:]]+$/, "", subj_line)
       gsub(/[[:space:]]+/, " ", subj_line)

       return subj_line
}
#./PRE
#.H2 Copyright
#.P
# Copyright 2007, 2008, Arnold David Robbins
# arnold@skeeve.com
