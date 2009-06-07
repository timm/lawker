#!/bin/sh
  #--------------------------------------------------------------------#
  # Assign critical OS-based variables (if anyone knows which [gn]awk  #
  # and where the bin dir is located, please let me know via email to  #
  # Bob@OrlandoKuntao.com, and I'll expand the following tests).       #
  #--------------------------------------------------------------------#
  OZ=`uname -s 2> /dev/null | tr '[a-z]' '[A-Z]' 2> /dev/null`
  if [ `expr "$OZ" : 'WINDOWS'` -ge 7 ]; then
     AWK=awk                             # Running MKS Toolkit's
     holidays_awk=/home/awk/holidays.awk # version of Unix on a PC
     holiday_file=/home/perl/holidays
  elif [ ."$OZ" = ."LINUX" ]; then
     ubin=/usr/local/bin # User bin directory
     AWK=gawk
     holidays_awk=$ubin/holidays.awk
     holiday_file=$ubin/holidays
  elif [ ."$OZ" = ."SUNOS" ]; then
     AWK=nawk
     ubin=/usr/local/bin
     holidays_awk=$ubin/holidays.awk
     holiday_file=$ubin/holidays
  elif [ ."$OZ" = ."HP-UX" ]; then
     AWK=awk
     ubin=/usr/local/bin
  fi
  holiday_cmd="$AWK -f $holidays_awk --" # Reduce potential typos

  #------------------#
  # Process options. #
  #------------------#
  opts=""
# opt_n=0 # No holidays file gives--use default
  opt_v=0 # Verbose
  while getopts nv opt 2> /dev/null
  do
     case $opt in
        n ) holiday_file="";; # No holidays file gives--use default
        v ) opt_v=1;;
        * ) echo "Passing along $opt"
            opts="$opts -$opt" # All other opts are saved and passed
            ;;                 # on through 'set "$opts" $*' below.
     esac
  done

  #--------------------------------------------------------------------#
  # Load space-delimited holiday yyyymmdd dates into $HOLIDAYS env var.#
  #--------------------------------------------------------------------#
  echo     "$holiday_cmd -s $holiday_file;  export HOLIDAYS"
  HOLIDAYS=`$holiday_cmd -s $holiday_file`; export HOLIDAYS

  #--------------------------------------------------------------------#
  # To see if today is a holiday, simply test $HOLIDAYS (the simple    #
  # list) as follows (most of the time, this is all you want or need): #
  #--------------------------------------------------------------------#
  today=`date +%Y""%m""%d`
  if [ ."`echo $HOLIDAYS | grep \`date +%Y%m%d\``" != . ]; then
     echo "Today is a holiday.  Hoo-rah! Semper Fi.  Carry on. :-)"
  else
     echo "Today's no holiday, get busy. :-(("
  fi

  #--------------------------------------------#
  # First Monday and last Sunday of the        #
  # current month (you can specify year        #
  # and month via -y and -m options).          #
  #--------------------------------------------#
  echo "`$holiday_cmd -d 1.Mon            $holiday_file` First Monday (Mon) this month."
  echo "`$holiday_cmd -d last.Sun         $holiday_file` Last  Sunday (Sun) this month."
  echo "`$holiday_cmd -d 1.1              $holiday_file` First Monday (1)   this month."
  echo "`$holiday_cmd -d last.0           $holiday_file` Last  Sunday (0)   this month."
  echo "`$holiday_cmd -y 2025 -m 2 -d 5.1 $holiday_file` Last  Monday (1)  in Feb. 2025"

  #--------------------------------------------#
  # Falklands Day Light Savings Dates.         #
  #--------------------------------------------#
  echo "`$holiday_cmd -d 1.0.8 -m 9` Daylight Savings Time begins"
  echo "`$holiday_cmd -d 1.0.6 -m 4` Return to Standard Time"

  #--------------------------------------------#
  # You can really get fancy by adding the     #
  # holiday name with this.                    #
  #--------------------------------------------#
  $holiday_cmd $holiday_file | $AWK -v today=$today \
     'BEGIN {holiday=0}
      match($0,today) \
      {
        holiday=1
        sub(/^.*:/,"",$0)
        sub(/_/  ," ",$0)
        print "Today is "$0".  Hoo-rah! :-)"
        exit 1
      }
      END {
            if (! holiday) print "Today is no holiday, get busy. :-(("
            exit 0
          }'

  #--------------------------------------------#
  # For complete holiday list (date, weekday,  #
  # and holiday name), try this.               #
  #--------------------------------------------#
  $holiday_cmd $holiday_file | sort \
   | $AWK -v today="$today" \
     '{
        gsub(/:/," ",$0)
        gsub(/_/," ",$0)
        if (match($0,today)) $0 = $0"\t  **HOLIDAY**"
        print $0
      }'

  #--------------------------------------------#
  # To see if today is the 2nd business day of #
  # the month, you can do this.                #
  #--------------------------------------------#
  bizday=`$holiday_cmd -b 2 $holiday_file`
  if [ `date "+%Y%m%d"` = $bizday ]; then
     echo "Today is the 2nd business day ($bizday) of the month."
  else
     echo "Today is NOT the 2nd business day ($bizday) of the month."
  fi

  #--------------------------------------------#
  # To see if today is the last business day   #
  # of the month, you can do this.             #
  #--------------------------------------------#
  bizday=`$holiday_cmd -b last $holiday_file`
  if [ `date "+%Y%m%d"` = $bizday ]; then
     echo "Today is the last business day ($bizday) of the month."
  else
     echo "Today is NOT the last business day ($bizday) of the month."
  fi

  #--------------------------------------------#
  # An easier way to see if today is this      #
  # month's last business day (or any day)     #
  # is to use the test or -t option.           #
  #--------------------------------------------#
  $holiday_cmd -t -b "last" $holiday_file > /dev/null 2>&1
  if [ $? -eq 1 ]; then
     echo "Completion status indicates today is"     \
       "the last business day ($bizday) of the month."
  else
     echo "Completion status indicates today is NOT" \
       "the last business day ($bizday) of the month."
  fi

  #--------------------------------------------#
  # To see if today is the next to the last    #
  # business day of the month, do this (you    #
  # can also use the -t here option as well).  #
  #--------------------------------------------#
  bizday=`$holiday_cmd -b -1 $holiday_file`
  if [ `date "+%Y%m%d"` = $bizday ]; then
     echo "Today is "  "the next-to-the-last business day" \
       "($bizday) of the month."
  else
     echo "Today is NOT the next-to-the-last business day" \
       "($bizday) of the month."
  fi

  #--------------------------------------------#
  # See if today is a business day at all.     #
  #--------------------------------------------#
  $holiday_cmd -B $holiday_file
  if [ $? -eq 1 ]; then
     echo "Today is a business day--get crackin'."
  else
     echo "Today is NOT a business day--have fun."
  fi

  #--------------------------------------------#
  # Display the day range for the 25 years in  #
  # which the 5th business day might fall.     #
  #--------------------------------------------#
  yys="_BEGIN_ 00 01 02 03 04 05 06 07 08 09"
  yys="$yys 10 11 12 13 14 15 16 17 18 19"
  yys="$yys 20 21 22 23 24 25 _END_"
  echo "\nFifth Business day falls on and between the following dates:"
  for yy in $yys
  do
     if [ $yy = "_BEGIN_" ]; then
        echo "$holiday_cmd -y 20yy -b 5 $holiday_file"
        days=" "
     elif [ $yy = "_END_" ]; then
        # Double echo removes newlines
        range=`echo \`echo $days|$AWK 'BEGIN {RS=" "}{print}'|sort\``
        r1=`expr ".$range" : '\.\(..\)'.*` # First
        r2=`expr "$range." : '.*\(..\)\.'` # Last
        echo "\n5th business day falls within days $r1-$r2."
     else
        for mm in 01 02 03 04 05 06 07 08 09 10 11 12
        do
           bizday=`$holiday_cmd -y 20$yy -m $mm -b 5 $holiday_file`
           echo "\r$bizday\c" # This is cool.
           day=`expr "$bizday" : '.*\(..\)'`
           if [ 0`expr " $days " : ".* $day \.*"` -eq 0 ]; then
              days="${days}$day "
           fi
        done
     fi
  done

  #--------------------------------------------#
  # Report first and second business days of   #
  # every month during our test year range.    #
  #--------------------------------------------#
  echo
  echo " First    Second"
  echo "-------- --------"
  for yy in 00 01 02 03 04 05 06 07 08 09 # Years
  do
     for mm in 1 2 3 4 5 6 7 8 9 10 11 12 # Months
     do
        fst=`$holiday_cmd -y 20$yy -m $mm -b 1 $holiday_file`
        snd=`$holiday_cmd -y 20$yy -m $mm -b 2 $holiday_file`
        echo "$fst $snd"
     done
  done

  #--------------------------------------------#
  # Report next-to-last and last business days #
  # of every month during our test year range. #
  #--------------------------------------------#
  echo
  echo "Next-to    Last"
  echo "-------- --------"
  for yy in 00 01 02 03 04 05 06 07 08 09 # Years
  do
     for mm in 1 2 3 4 5 6 7 8 9 10 11 12 # Months
     do
        n2l=`$holiday_cmd -y 20$yy -m $mm -b  -1  $holiday_file`
        lst=`$holiday_cmd -y 20$yy -m $mm -b last $holiday_file`
        echo "$n2l $lst"
     done
  done

  #--------------------------------------------#
  # For a test that'll put hair on your chest, #
  # report all holidays for the 21st century.  #
  #--------------------------------------------#

  if [ $opt_v -eq 1 ]; then
     echo
     for d in 0 1 2 3 4 5 6 7 8 9 # Decade
     do
        for y in 0 1 2 3 4 5 6 7 8 9 # Years
        do
                             cal 20${d}${y}
           echo "$holiday_cmd -y 20${d}${y} 2005 -m 2 -d last.5 $holiday_file"
                 $holiday_cmd -y 20${d}${y} 2005 -m 2 -d last.5 $holiday_file
           echo "$holiday_cmd -y 20${d}${y} $holiday_file | sort"
                 $holiday_cmd -y 20${d}${y} $holiday_file | sort
           echo
        done
     done
  fi
