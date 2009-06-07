#!/usr/bin/nawk -f
# SccsId[] = "@(#)holidays.awk 1.23 10/25/05 (AWK holiday calculation/reporting program)"
#----------------------------------------------------------------------#
#                            holidays.awk                              #
# -------------------------------------------------------------------- #
#                                                                      #
#   Copyright (c) 1995-2005 by Bob Orlando.  All rights reserved.      #
#                                                                      #
#   Permission to use, copy, modify and distribute this software       #
#   and its documentation for any purpose and without fee is hereby    #
#   granted, provided that the above copyright notice appear in all    #
#   copies, and that both the copyright notice and this permission     #
#   notice appear in supporting documentation, and that the name of    #
#   Bob Orlando not be used in advertising or publicity pertaining     #
#   to distribution of the software without specific, written prior    #
#   permission.  Bob Orlando makes no representations about the        #
#   suitability of this software for any purpose.  It is provided      #
#   "as is" without express or implied warranty.                       #
#                                                                      #
#   BOB ORLANDO DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS           #
#   SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY      #
#   AND FITNESS.  IN NO EVENT SHALL BOB ORLANDO BE LIABLE FOR ANY      #
#   SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES          #
#   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER    #
#   IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,     #
#   ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF     #
#   THIS SOFTWARE.                                                     #
#                                                                      #
# -------------------------------------------------------------------- #
#   Program documentation and notes located at the bottom of script.   #
#----------------------------------------------------------------------#
BEGIN \
{
  progname = "holidays.awk"

 "date +\%Y\%m\%d" | getline Ymd # Escapes (\) in "\%Y\%m" prevents %Y
  close("date +\%Y\%m\%d")       # from looking like percentYpercent
  yyyy   = substr(Ymd,1,4)       # (an SCCS keyword)
  mm     = substr(Ymd,5,2)
  today  = substr(Ymd,7,2)
  yyyymm = yyyy""mm

  opt_B = 0
  opt_b = 0
  opt_d = 0
  opt_l = 0
  opt_m = 0
  opt_s = 0
  opt_t = 0
  mutex = 0 # Mutually exclusive options (bdls)
  error = 0

  #--------------------------------------------------------------#
  # Make 0-based weekdays, and 1-based month and julian arrays.  #
  #--------------------------------------------------------------#
  weekdayn["Sun"] = 0; weekdays[0] = "Sun"
  weekdayn["Mon"] = 1; weekdays[1] = "Mon"
  weekdayn["Tue"] = 2; weekdays[2] = "Tue"
  weekdayn["Wed"] = 3; weekdays[3] = "Wed"
  weekdayn["Thu"] = 4; weekdays[4] = "Thu"
  weekdayn["Fri"] = 5; weekdays[5] = "Fri"
  weekdayn["Sat"] = 6; weekdays[6] = "Sat"

  split("January  February March "     \
        "April    May      June "      \
        "July     August   September " \
        "October  November December",  month_names)

  split("0 31 59 90 120 151 181 212 243 273 304 334 365", julian_days)
  split("0 31 60 91 121 152 182 213 244 274 305 335 366", julian_leap)
  split("31 28 31 30 31 30 31 31 30 31 30 31"           , month_days )

  bizdays[0] = 0 # Initialize

  #--------------------------------------------------------------#
  # Validate and process options and optargs.                    #
  #--------------------------------------------------------------#
  if (ARGV[1] == "-H") show_documentation(progname)

  if (ARGV[1] == "-h") exit_usage()
                         #-------------------------------------#
  for (n=1; n<ARGC; n++) # -y = yyyy year (mostly testing)     #
  {                      #-------------------------------------#
    if (ARGV[n] == "-y")
    {
      yyyy = ARGV[n+1]
      if (yyyy !~ /^[0-2][0-9][0-9][0-9]$/)
        exit_usage("Bogus year ("yyyy") in -y optarg!")

      yyyy    = sprintf("%04d",yyyy)
      yyyymm  = yyyy""mm # Use default month
      ARGV[n] = ARGV[n+1] = ""
      break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -m = mm month (mostly testing)      #
  {                      #-------------------------------------#
    if (ARGV[n] == "-m")
    {
      mm = ARGV[n+1]
      if (mm !~ /^[01]?[0-9]$/)
        exit_usage("Bogus month number ("mm") in -m optarg!")

      if (mm < 1 || mm > 12)
        exit_usage("Invalid month number ("mm") in -m optarg!")

      mm = sprintf("%02d",mm)
      yyyymm  = yyyy""mm
      ARGV[n] = ARGV[n+1] = ""
      break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -B = Business day today? (ret 0|1)  #
  {                      #-------------------------------------#
    if (ARGV[n] == "-B")
    {
      opt_B = 1; mutex++; ARGV[n] = ""; break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -b = Business day (ret yyyymmdd)    #
  {                      #-------------------------------------#
    if (ARGV[n] == "-b")
    {
      opt_b = ARGV[n+1]         # Make opt_b the business day
      mutex++
      if (opt_b !~ /^(-?[0-2]?[0-9]|last)$/)
        exit_usage("Bogus business day ("opt_b") in -b optarg!")

      sub(/^-0+$/,"last",opt_b) # In case we get "-0".
      ARGV[n] = ARGV[n+1] = ""
      break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -l = Date list only (ret multiline) #
  {                      #-------------------------------------#
    if (ARGV[n] == "-l")
    {
      opt_l = 1; mutex++; ARGV[n] = ""; break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -s = Date list only (ret one line)  #
  {                      #-------------------------------------#
    if (ARGV[n] == "-s")
    {
      opt_s = 1; mutex++; ARGV[n] = ""; break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -t = Compare with today's date      #
  {                      #-------------------------------------#
    if (ARGV[n] == "-t")
    {
      opt_t = 1; ARGV[n] = ""; break
    }
  }                      #-------------------------------------#
  for (n=1; n<ARGC; n++) # -d = nth weekday (ret yyyymmdd)     #
  {                      #-------------------------------------#
    if (ARGV[n] == "-d")
    {
      mutex++

      nth = weekday = optarg = ARGV[n+1]
      a_cnt = split(optarg,WWOA,".") # WWOA = Nth, Weekday, On/After
      nth         = WWOA[1]
      weekday     = WWOA[2]
      on_or_after = WWOA[3]

      if (nth !~ /^(-?[0-2]?[0-9])|(last)$/)
        exit_usage("Bogus nth day ("nth") in -d optarg ("opt_d")!")

      sub(/^-0+$/,"last",nth) # And just in case we get "-0".

      if (weekday !~ /^(Sun|Mon|Tue|Wed|Thu|Fri|Sat|[0-6])$/)
        exit_usage("Bogus weekday ("weekday") in -d optarg ("opt_d")!")

      if (weekday !~ /^[0-6]$/)
        weekday = weekdayn[weekday]

      if (a_cnt >= 3)
      {
        if (on_or_after !~ /^[0-1]?[0-9]?$/)
          exit_usage("Bogus on_or_after ("on_or_after") in -d optarg ("opt_d")!")
      }
      else
        on_or_after = 1

      if (on_or_after >= (month_days[mm+0] - 7))
        exit_usage("You're kidding, right?  " \
          month_names[mm+0] " only has "month_days[mm+0]"!")

      yyyymmdd = holiday_date(yyyy,mm,nth,weekday,on_or_after)

      opt_d = 1
      exit # Go to END section (skip reading any holiday file).
    }
  }                      #-----------------------------------#
  for (n=1; n<ARGC; n++) # Any other option is invalid.      #
  {                      #-----------------------------------#
    if (ARGV[n] ~ /^-/)
      exit_usage("Invalid option, '"ARGV[n]"'.")
  }

  shift_ARGV() # Drops nulled (blank) ARGV variables

  #----------------------------------------------------------#
  # If the user failed to supply a holidays fileid, push the #
  # following as an argument (and hope the file exists).     #
  #----------------------------------------------------------#
  if (ARGC < 2)
  {
    ARGV[1] = "/usr/local/bin/holidays" # Default to this.
    ARGC    = 2
  }
} # BEGIN {}

#======================================================================#
#                               M A I N                                #
#======================================================================#
{
  sub(/\043.*/ ,"")   # Trash everything after pound sign.
  sub(/^[\t ]+/,"")   # Remove leading and
  sub(/[\t ]+$/,"")   #   trailing whitespace
  if ($0 ~ /^$/) next # Skip essentially blank lines.

  #------------------------------------------------------------#
  # Need New Year holiday for next year for Dec. last bizday.  #
  #------------------------------------------------------------#
  if ($1 ~ /^0?1$/ && $2 ~ /^0?1$/)
  {
    new_years_day = 1
    next_yyyy     = yyyy + 1
    next_yyyymmdd = sprintf("%4d%02d%02d",next_yyyy,$1,$2)
  }
  else
  {
    new_years_day = 0
  }

  on_or_after = 1
  #------------------------------------------------------------#
  # Process month and day.                                     #
  #------------------------------------------------------------#
  if ($1 ~ /^[01]?[0-9]$/ && $2 ~ /^0?[1-5]\.0?[0-6]\.?0?[0-9]?$/)
  { #          m   m                   nth.weekday.on_or_after
    split($2,WWOA,".") # WWOA = Occurrence, Weekday, On/After
    nth         = WWOA[1]
    weekday     = WWOA[2]
    on_or_after = WWOA[3]

    if (on_or_after == "") on_or_after = 1

    if (on_or_after >= (month_days[$1+0] - 7))
    {
      exit_usage("You're kidding, right?  " \
        month_names[$1+0] " only has "month_days[$1+0]"!")
    }
    yyyymmdd = holiday_date(yyyy,$1,nth,weekday,on_or_after)
    $1 = $2 = "" # Null these args
  }
  else if ($1 ~ /^[01]?[0-9]$/ && $2 ~ /^last\.0?[0-6]$/)
  { #               m   m                last.weekday.on_or_after
    nth = weekday = $2
    sub(/\..*/ ,"",nth    )
    sub(/^.*\./,"",weekday)
    yyyymmdd = holiday_date(yyyy,$1,nth,weekday)
    $1 = $2 = "" # Null these args
  }
  else if ($1 ~ /^[01]?[0-9]$/ && $2 ~ /^[0-3]?[0-9]$/)
  { #               m   m                   d   d
    yyyymmdd = sprintf("%4d%02d%02d",yyyy,$1,$2)
    $1 = $2 = "" # Null these args
  }

  #------------------------------------------------------------#
  # If we have an adjustment by itself (i.e. for the day after #
  # Thanksgiving Day, then calculate that date.                #
  #------------------------------------------------------------#
  if ($3 ~ /^[+\-][0-9]+$/)
  {
    yyyymmdd = dateplus(yyyymmdd,$3)
    #----------------------------#
    # Do the same for New Year.  #
    #----------------------------#
    if (new_years_day == 1)
      next_yyyymmdd = dateplus(next_yyyymmdd,$3)
    $3 = "" # Null this arg
  }

  #------------------------------------------------------------#
  # If we have a pattern that looks like [0-6][+\-][0-9]+ then #
  # test yyyymmdd's weekday to see if it matches DoW target.   #
  # If it does, adjust yyyymmdd by the +|- "adj" value and     #
  # recalculate the date.                                      #
  #------------------------------------------------------------#
  if ($3 ~ /0?[0-6]?[+\-][0-9][0-9]?/)
  {     #     target +|- adj
    day = adj = $3
    sub(/[+\-].*/,""  ,day)
    sub(/[+\-].*/,":&",adj) # Negative value returns future date.
    sub(/^.*:/   ,""  ,adj) # Positive returns past date.
    $3 = "" # Null this arg
    if (day_of_week(yyyymmdd) == day)
      yyyymmdd = dateplus(yyyymmdd,adj)
    #----------------------------#
    # Do the same for New Year.  #
    #----------------------------#
    if (new_years_day == 1)
      if (day_of_week(next_yyyymmdd) == day)
        next_yyyymmdd = dateplus(next_yyyymmdd,adj)
  }

  #------------------------------------------------------------#
  # Remove leading whitespace from $0 and store the pertinents #
  # into our hash array (we'll print it in the END section).   #
  #------------------------------------------------------------#
  sub(/^[\t ]+/,"" ,$0) # Leading whitespace
  gsub(/[\t ]+/,"_",$0) # Change intervening whitespace to underscores

  if (holiday_hash[yyyymmdd] ~ /^$/)
      holiday_hash[yyyymmdd] = weekdays[day_of_week(yyyymmdd)]":"$0
  if (new_years_day == 1)
    if (holiday_hash[next_yyyymmdd] ~ /^$/)
        holiday_hash[next_yyyymmdd] = weekdays[day_of_week(next_yyyymmdd)]":"$0
} # End of M A I N

END \
{
  if (error > 0) exit error

  if (mutex > 1)
    print "Options B, b, d, l, and s are mutually exclusive! ",
          "We\047ll give it our best shot." | "cat 1>&2"

  if (opt_d) # Weekday date: give it and adios.
  { #--------------------------------------------------#
    # If testing for "today" and today is the desired  #
    # weekday, then exit 1 (true), printing nothing.   #
    #--------------------------------------------------#
    if (opt_t)
    {
      if (yyyymmdd == Ymd) exit 1
      else                 exit 0
    }

    print yyyymmdd
    exit substr(yyyymmdd,7,2)
  }

  holidays = ""

  #------------------------------------------------------------#
  # Since we already have our holidays in a hash, this is an   #
  # excellent place to get the business day.                   #
  #------------------------------------------------------------#
  if (opt_B) # See if today a business day?
  {
    if (Ymd in holiday_hash) exit 0 # False if found in holiday hash.
    else                     exit 1 # Else True.
  }

  if (opt_b) # Specific business day
  {
    yyyy = substr(yyyymm,1,4)
    if (opt_m) mm = sprintf("%02d",opt_m)
    else       mm = substr(yyyymm,5,2)

    #---------------------------------------------#
    # Zero in on just the holidays for this month #
    #---------------------------------------------#
    for (holiday in holiday_hash)
      if (match(holiday,yyyy""mm))
        holidays = holidays" "holiday # Combine into a scalar list.

    if (opt_b ~ /last|^-[0-2]?[0-9]$/)
      rev_bizday=1
    else
      rev_bizday=0

    mm_days = month_days[mm+0]
    for (i=j=1; i<=mm_days; i++)
    {
      dd  = sprintf("%02d",i)
      dow = day_of_week(yyyy,mm,dd)
      #-----------------------------------------------------------#
      # If day of week ! Sat or Sun and it's not a holiday, then  #
      # if the day (i) is the same as the day we want (opt_b),    #
      # print out the yyyymmdd date and exit with the month day.  #
      # Else increment the business day counter (j) and continue. #
      #-----------------------------------------------------------#
      if (! (dow ~ /[06]/ || match(holidays," "yyyy""mm""dd)))
      {
        if (rev_bizday)
        {
          if (i <= mm_days)
          {
            bizdays[j] = dd # Push the date into bizdays array.
            bizdays[0] = j
            j++
          }
          else
          {
            break
          }
        }
        else if (j == opt_b)
        { #------------------------------------------------------#
          # If testing for "today" and today is the desired      #
          # business day, then exit 1 (true), printing nothing.  #
          #------------------------------------------------------#
          if (opt_t > 0)
          {
            if (yyyy""mm""dd == Ymd) exit 1
            else                     exit 0
          }
          else
          {
            print yyyy""mm""dd
          }
          exit i
        }
        else
        {
          bizdays[0] = j
          j++
        }
      } # if (dow !~ /[06]/ && ! match(holidays," "yyyy""mm""dd))
    } # for (i=j=1; i<month_days[mm+0]; i++)

    #--------------------------------------------------------------#
    # If we want business day counting backward from EOM, do this. #
    #--------------------------------------------------------------#
    if (rev_bizday)
    {
      if (opt_b == "last")
      {
        if (opt_t > 0)
          if (yyyy""mm""bizdays[bizdays[0]] == Ymd) exit 1
            else exit 0

        print yyyy""mm""bizdays[bizdays[0]]
        exit dd
      }

      opt_b = opt_b - opt_b - opt_b # Reverse/remove the sign
      if (opt_b < bizdays[0])
      {
        if (opt_t > 0)
          if (yyyy""mm""(bizdays[bizdays[0] - opt_b]) == Ymd) exit 1
            else exit 0

        print yyyy""mm""bizdays[bizdays[0] - opt_b]
        exit            bizdays[bizdays[0] - opt_b]
      }
      else if (opt_b == bizdays[0])
      {
        if (opt_t > 0)
          if (yyyy""mm""dd == Ymd) exit 1
            else exit 0

        print yyyy""mm""bizdays[1]
        exit            bizdays[1]
      }
    } # if (rev_bizday)

    exit_usage("You're kidding, right?  " \
      month_names[mm+0] " only has "bizdays[0]" business days!")
    exit 0
  } # if (opt_b) # Business day

  #--------------------------------------------------------------------#
  # Display holidays saved in holiday_hash[].                          #
  #--------------------------------------------------------------------#
  for (holiday in holiday_hash)
  {
    if (match(holiday,"^"yyyy))
    {
      if (opt_s)
      {
        holidays = holidays" "holiday # Combine into a scalar.
        sub(/^ +/,"",holidays)        # Trim leading blank
      }
      else if (opt_l)
        print holiday
      else
        print holiday":"holiday_hash[holiday]
    }
  }

  if (opt_s)
    print holidays

  exit 0
} # END {}

#======================================================================#
#                     U S E R    F U N C T I O N S                     #
#                        (in alphabetical order)                       #
#----------------------------------------------------------------------#
function basedate(                                               \
                   YYYY,MM,DD,                                   \
                   yyyy,cc,ddddd,leapdays,cc_leapdays,accum_days \
                 )                                                     #
# -------------------------------------------------------------------- #
# Globals: julian_days[] and julian_leap[]                             #
#   Calls: leap_year()                                                 #
#----------------------------------------------------------------------#
{
  #------------------------------------------------------#
  # First, decrement the year and get the number of days #
  # for all the years preceeding it (in the Common Era). #
  #------------------------------------------------------#
  yyyy = YYYY
  if ((yyyy - 1) > 0)
  {
    yyyy--
    cc          = int(yyyy / 100)
    ddddd       = yyyy * 365
    leapdays    = int(yyyy / 4)
    cc_leapdays = (cc > 0) ? (int(cc / 4)) : 0
    ddddd       = ddddd + leapdays - cc + cc_leapdays
    yyyy++
  }
  ddddd += DD

  #-------------------------------------------------------#
  # Add the previous month YTD days to our ddddd.  If it  #
  # is a leap year, assign julian_leap[] to accum_days[]. #
  # Then add in YTD days for previous months of this year #
  #-------------------------------------------------------#
  if (leap_year(yyyy))
    for (i=0; i<13; i++) accum_days[i] = julian_leap[i]
  else
    for (i=0; i<13; i++) accum_days[i] = julian_days[i]
  ddddd += accum_days[MM += 0] # 'MM += 0' removes leading zero
  return (ddddd)
} # function base_date

#----------------------------------------------------------------------#
function calculate_date(YYYY,MM,DD,ADJ,  adj,yyyymmdd)                 #
# -------------------------------------------------------------------- #
# Calls: leap_year(), ddddd_to_yyyymmdd(), and basedate()              #
#----------------------------------------------------------------------#
{
  adj = ADJ
  if (adj ~ /\\055/)
  {
    sub(/\\055/,"",adj)
    yyyymmdd = ddddd_to_yyyymmdd(basedate(YYYY,MM,DD) - adj)
  }
  else
  {
    sub(/\\053/,"",adj)
    yyyymmdd = ddddd_to_yyyymmdd(basedate(YYYY,MM,DD) + adj)
  }

  return yyyymmdd
} # function calculate_date()

#----------------------------------------------------------------------#
function dateplus(YYYYMMDD,ADJ,  mm,dd,yyyy,mmddyy)                    #
# -------------------------------------------------------------------- #
# Globals: ARGV[], ARGC, julian_days[], julian_leap[]                  #
# Calls:   validate_yyyymmdd(), calculate_date()                       #
# Exits on error.                                                      #
#----------------------------------------------------------------------#
{
  fname = "dateplus"

  #------------------------------------------------------------#
  # If last arg looks like a valid date, parse, validate, and  #
  # use it, else, use the current yyyymmdd.                    #
  #------------------------------------------------------------#
  if (YYYYMMDD ~ /^[0-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9]$/)
  {
    mm   = substr(YYYYMMDD,5,2)
    dd   = substr(YYYYMMDD,7,2)
    yyyy = substr(YYYYMMDD,1,4)
    validate_yyyymmdd(yyyy,mm,dd)
  }

  #------------------------------------------------------------#
  # Positive (or unsigned) integer for adj days next?          #
  #------------------------------------------------------------#
  if (ADJ !~ /^[\+\-]?[0-9]+$/)
  {
    print fname()" adjustment value ("ADJ")",
     "not [+|-]numeric!" | "cat 1>&2"
    exit 1
  }

  #------------------------------------------------------------#
  # Everything looks good, calculate/return new yyyymmdd date. #
  #------------------------------------------------------------#
  return calculate_date(yyyy,mm,dd,ADJ)
} # function dateplus

#----------------------------------------------------------------------#
function day_of_week(YYYY,MM,DD,  adj,yyyy,mm,dow)                     #
#----------------------------------------------------------------------#
{
  if (length(YYYY) == 8)      # User may call us with yyyymmdd
  {                           # instead of yyyy,mm,dd
    DD   = substr(YYYY,7,2)
    MM   = substr(YYYY,5,2)
    YYYY = substr(YYYY,1,4)
  }

  adj  = int((14 - MM) / 12)
  yyyy = YYYY - adj
  mm   = MM + (12 * adj) - 2
  dow  = (DD + yyyy              \
             + int(yyyy/4)       \
             - int(yyyy/100)     \
             + int(yyyy/400)     \
             + int(31 * mm / 12) \
          ) % 7
  return dow
} # function day_of_week()

#----------------------------------------------------------------------#
function ddddd_to_yyyymmdd(                                     \
                            DDDDD,                              \
                            ddddd,yyyy,cc,cc_leapdays,leapdays, \
                            mmdd,julian,i                       \
                          )                                            #
# -------------------------------------------------------------------- #
# Globals: julian_days[] and julian_leap[]                             #
#----------------------------------------------------------------------#
{
  #----------------------------------------------------------#
  # Reduce DDDDD arg to values in yyyy and ddddd variables.  #
  #----------------------------------------------------------#
  for (i=1; ; i++)
  {
    yyyy        = int(DDDDD / 365) - i
    ddddd       = DDDDD - yyyy * 365
    cc          = int(yyyy / 100)
    leapdays    = int(yyyy / 4)
    cc_leapdays = (cc > 0) ? (int(cc / 4)) : 0
    leapdays    = leapdays - cc + cc_leapdays
    ddddd      -= leapdays
    yyyy++
    if (ddddd > 0) break
  }

  if (leap_year(yyyy))
    for (i in julian_leap)
      julian[i] = julian_leap[i]
  else
    for (i in julian_days)
      julian[i] = julian_days[i]

  #----------------------------------------------------------#
  # Reduce ddddd to month and day (we already have the year) #
  #----------------------------------------------------------#
  for (i=13; i>0; i--)
  {
    if (julian[i] < ddddd)
    {
      ddddd -= julian[i]
      mmdd = sprintf("%02d%02d",i,ddddd)
      break
    }
  }

  return (yyyy""mmdd)
} # function ddddd_to_yyyymmdd

#----------------------------------------------------------------------#
function exit_usage(ERRMSG,  opts) # Global vars: progname, error      #
#----------------------------------------------------------------------#
{
  error = 5
  if (ERRMSG != "") print "\n"ERRMSG
  opts="-- -B [-b nn] [-d nn.Www.OnOrA ] -lHhst [-y yyyy] [-m mm]"
  print "\nUsage: [gn]awk -f "prog" "opts" holidayfile"                ,
        "\n     --             = Allows passing script opts and args." ,
        "\n     -B             = Return true if today is a business"   ,
        "\n                      day."                                 ,
        "\n     -b nn          = Return nn business day yyyymmdd date" ,
        "\n                      (nn may also be \047last\047 for the" ,
        "\n                      last business day of the month, and"  ,
        "\n                      -n (minus n) may also be used for the",
        "\n                      nth business day from end of month."  ,
        "\n     -d n.Www[.OoA] = Return nth weekday (Www = Sun-Sat,"   ,
        "\n        n.w[.OoA]     and the alternate, \047.w\047 takes"  ,
        "\n                      0-6).  Optionally, an on-or-after"    ,
        "\n                      (.OoA) day of the month may also be"  ,
        "\n                      provided."                            ,
        "\n     -H             = Full documentation (functions only"   ,
        "\n                      when the current working directory"   ,
        "\n                      is also the program directory)."      ,
        "\n     -h             = Summary help (Usage)."                ,
        "\n     -l             = Return multiline yyyymmdd date list." ,
        "\n     -s             = Return a line of yyyymmdd\047s."      ,
        "\n     -t             = Test resultant date against today"    ,
        "\n                      (works with -b and -d options)."      ,
        "\n     -y yyyy        = Use \047yyyy\047 as the year."        ,
        "\n     -m mm          = Use the mm that follows as the month" ,
        "\n                      (for business day calculations)."     ,
        "\n     holidayfile    = Calculation directives file (not used",
        "\n                      with \047-d\047 option).\n"           ,
        "\n                     "progname" terminated.\n"
  exit error
} # function exit_usage

#----------------------------------------------------------------------#
function holiday_date(                                              \
                       YYYY,MM,NTH,DOW,ON_OR_AFTER,                 \
                       fname,usage,wk,day,dd,mm_days,status,nth,dow \
                     )
# -------------------------------------------------------------------- #
# Globals: month_names[]                                               #
#----------------------------------------------------------------------#
{
  fname = "holiday_date"
  usage = "Usage: "fname"(yyyy,mm, occurrence|'last', day_of_week)\n"

  #----------------------------------------------------------------#
  # Validate incoming args (we can skip yyyy here).                #
  #----------------------------------------------------------------#
  if (! (MM ~ /^[0-1]?[0-9]$/ || MM < 1 || MM > 12))
  {
    print fname"(): Invalid month '"MM"'!\n" | "cat 1>&2"
    exit 2
  }

  if (! (NTH ~ /^0?[1-5]$/ || NTH ~ /^last$/))
  {
    print fname"(): Invalid occurrence, '"NTH"'!\n" | "cat 1>&2"
    exit 3
  }

  if (DOW !~ /^0?[0-6]$/)
  {
    print fname"(): Invalid Day of week '"DOW"'!\n" | "cat 1>&2"
    exit 4
  }

  mm     = MM  + 0 # Assign and lose any leading zero.
  n      = (NTH ~ /^[0-9]$/) ? NTH + 0 : 5
  day    = DOW + 0 # Weekday (0=Sunday, 1=Monday, etc.).
  dd     = ""
  status = ""
  nth    = ""

  #----------------------------------------------------------------#
  # Passed validation, return the day of the month.  If user wants #
  # the last N-day, then get the number of days for that month and #
  # calculate the day using it.                                    #
  #----------------------------------------------------------------#
  if (mm ~ /^(1|3|5|7|8|10|12)$/) mm_days = 31
  else if (mm ~ /^(4|6|9|11)$/)   mm_days = 30
  else                            mm_days = leap_year(YYYY) ? 29 : 28

  #----------------------------------------------------------------#
  # If EOM day of the week is Sunday (0), then use 7 so the modulo #
  # operation (% 7) will work as expected (it doesn't seem to like #
  # negatives--sooooooooo sensative :-))                           #
  #----------------------------------------------------------------#
  dow = day_of_week(YYYY,MM,mm_days)
  if (dow == 0) dow = 7

  #----------------------------------------------------------------#
  # In case last occurrence is wanted, we back up a week at a      #
  # time to see if we can find the day within the number of days   #
  # allowed in our month.                                          #
  #----------------------------------------------------------------#
  for (; n>0; n--) # n already initialized.
  {
    dd = (day - day_of_week(YYYY,MM,ON_OR_AFTER)) % 7
    if (dd < 0) dd += 7
    dd = (7 * n) - 6 + (dd % 7) + (ON_OR_AFTER - 1)
    if (dd <= mm_days) break
  }

  if (dd > mm_days)
  {
    if      (n ~ /1$/) nth = n"st"
    else if (n ~ /2$/) nth = n"nd"
    else if (n ~ /3$/) nth = n"rd"
    else               nth = n"th"

    #--------------------------------------------------#
    # Don't sweat this for business day calculations.  #
    #--------------------------------------------------#
    if (! opt_b)
    {
      print "The "nth" occurrence of day "day" ("dd") exceeds",
            month_names[mm]"\'s "mm_days" days!\n"
      return 99
    }
  }
  return YYYY""MM""sprintf("%02d",dd)
} # function holiday_date

#----------------------------------------------------------------------#
function leap_year(YYYY) # YYYY = year.  Returns true|false (1|0).     #
#----------------------------------------------------------------------#
{
  return (((YYYY%4 == 0 && YYYY%100 != 0) || (YYYY%400 == 0)) ? 1 : 0)
} # function leap_year

#----------------------------------------------------------------------#
function shift_ARGV(i,j,k)                                             #
#----------------------------------------------------------------------#
{
  k = ARGC
  for (i=1; i<=ARGC; i++)
  {
    if (ARGV[i] == "")     # If the argument is empty, see is we
    {                      # can shift the next one down to it.
      for (j=i+1; j<=k; j++)
      {
        if (ARGV[j] == "") # If the next one is empty, try the one
          continue         # following that.
        ARGV[i] = ARGV[j]  # Once we find an argument, move it down,
        ARGV[j] = ""       # null where it was, decrement arg counter,
        break              # can do this with the next argument.
      }
    }
  }

  for (i=1; i<k; i++)      # Adjust ARGC
    if (ARGV[i] == "")     # If the argument is empty,
      ARGC--               # decrement ARGC
  return ARGC
} # function shift_ARGV

#----------------------------------------------------------------------#
function show_documentation(MOI,  n,line)                              #
#----------------------------------------------------------------------#
{
  n = 0
  while (getline <MOI > 0) # Searching ourselves for the doc'n section.
  {
    #------------------------------------------#
    # Until we find the documentation section, #
    # keep looking at each line.               #
    #------------------------------------------#
    if (n == 0)
    {
      if ($0 ~ /^\043 +D O C U M E N T A T I O N/)
      {
        n = 1
        print line
        print $0
      }
      else
      {
        line = $0
      }

      continue
    }
    else print # Once we find it, print until EOF.
  } # while (getline <MOI > 0)

  if (n == 0) # Means we did not find documentation section.
  {
    print "NO DOCUMENTATION section found for "MOI" in the",
          "current directory (cwd).\nTry again after first",
          "changing to the program directory." | "cat 1>&2"
    exit 1 # Exit failure
  }
  exit 1 # Exit failure anyway because we don'y live for this.
} # function show_documentation

#----------------------------------------------------------------------#
function validate_yyyymmdd(                    \
                            YYYY,MM,DD,        \
                            yyyy,mm,dd,mm_days \
                          )                                            #
# -------------------------------------------------------------------- #
# Globals: month_names[]                                               #
# Calls:   leap_year()                                                 #
# Exits on error.                                                      #
#----------------------------------------------------------------------#
{
  yyyy = YYYY
  mm   = MM
  dd   = DD
  mm  += 0

  if (mm==1||mm==3||mm==5||mm==7||mm==8||mm==10||mm==12)
    mm_days=31
  else if (mm==4||mm==6||mm==9||mm==11)
    mm_days=30
  else if (mm==2)
    mm_days = (leap_year(yyyy)) ? 29 : 28
  else
  {
    printf("Month %02d is invalid.\n",mm) | "cat 1>&2"
    exit 6
  }
  if (dd > mm_days)
  {
    printf("%s, %d does not have %d days.\n",
      month_names[mm],yyyy,dd) | "cat 1>&2"
    exit 7
  }
  return 0
} # function validate_yyyymmdd

#======================================================================#
#                       D O C U M E N T A T I O N                      #
#======================================================================#
#                                                                      #
#      Author: Bob Orlando (Bob@OrlandoKuntao.com)                     #
#                                                                      #
#        Date: February 1, 2003                                        #
#                                                                      #
#  Program ID: holidays.awk                                            #
#                                                                      #
#       Usage: [gn]awk -f holidays.awk -- -B [-b nn] [-d n.Www.OoA] \  #
#                      -lHhst [-y yyyy] [-m mm] holidayfile            #
#                                                                      #
#               nawk|gawk      = Program runs with either. (See "Usage #
#                                Note:" below for "#!" operation.)     #
#                 --           = Allows passing script opts and args.  #
#                 -B           = Return true if today is a business    #
#                                day.                                  #
#                 -b nn        = Return nn business day as yyyymmdd    #
#                                (nn may also be specified as "last"   #
#                                for that business day of the month,   #
#                                or -n (minus n) for nth business day  #
#                                from end of the month).               #
#                 -d n.Www.OoA = Return nth weekday (Www = Sun-Sat,    #
#                                and "n" may also be given as "last"   #
#                                for the last "Www" day of the month). #
#                 -d n.w.OoA   = Alternate suntax for the above only   #
#                                the ".w" is 0-6 for Sun-Sat.  The     #
#                                ".OoA" is an optional on-or-after     #
#                                day of the month that says the date   #
#                                want must be on or after the OoA'th   #
#                                day of the month.                     #
#                 -H           = Full formal documentation (functions  #
#                                only when the current working         #
#                                directory is the program directory).  #
#                 -h           = Summary help (Usage).                 #
#                 -l           = Return multiline yyyymmdd date list.  #
#                 -s           = Return a single line of yyyymmdd's.   #
#                 -t           = Test resultant date against today     #
#                                (works with -b and -d options).       #
#                 -y yyyy      = Use yyyy for the year.                #
#                 -m mm        = Use the mm that follows as the month  #
#                                (for business day calculations).      #
#               holidayfile    = Calculation directives file (neither  #
#                                used nor needed with "-d" option).    #
#                                The file lays out as follows:         #
#                                                                      #
#   Data File: holidays                                                #
#                                                                      #
#     > #------------------------------------------------------------# #
#     > #  *  DO NOT REMOVE  *  DO NOT REMOVE  *  DO NOT REMOVE  *   # #
#     > #------------------------------------------------------------# #
#     > # This file contains values that allow any program to        # #
#     > # calculate holidays using either fixed month and day or by  # #
#     > # specifying an occurrence in a month like the 4th Thursday  # #
#     > # in November or "last" Monday in May. Adjustments also are  # #
#     > # permitted for those fixed holiday dates that fall on       # #
#     > # weekends but are observed either the Friday before or the  # #
#     > # Monday after, as well as days like the Friday after the    # #
#     > # Thanksgiving Day observance (U.S.).                        # #
#     > #                                                            # #
#     > # Leading whitespace is ignored, as is everything following  # #
#     > # and including the octothorpe (#-sign).                     # #
#     > #                                                            # #
#     > # Mm N.D.OnOrA Adj Holiday name            # Comments        # #
#     > # -- --------- --- ----------------------- ----------------- # #
#     >   01  1            New Year's              # M-F               #
#     >   01  1        6-1 New Year's (pre-obs)    # Sat? Use Fri      #
#     > # 01  1        6+2 New Year's (post-obs)   # Sat? Or Monday    #
#     >   01  1        0+1 New Year's (post-obs)   # Sun? Use Mon      #
#     >   01  3.1          M.L.King Jr. Birthday   # 3rd Mon in Jan    #
#     >   05  last.1       Memorial Day            # Last Mon in May   #
#     >   07  4            Independence            # M-F               #
#     >   07  4        6-1 Independence (pre-obs)  # Sat? Use Fri      #
#     >   07  4        0+1 Independence (post-obs) # Sun? Use Mon      #
#     >   09  1.1          Labor Day               # 1st Mon in Sep    #
#     >   11  4.4          Thanksgiving (US)       # 4th Thu in Nov    #
#     >   11  4.4       +1 Thanksgiving Day II     # Fri after         #
#     >   12 25            Christmas               # M-F               #
#     >   12 25        6-1 Christmas (pre-obs)     # Sat? Use Fri      #
#     >   12 25        0+1 Christmas (post-obs)    # Sun? Use Mon      #
#     > #------------------------------------------------------------# #
#     > # Unique dates.                                              # #
#     > #------------------------------------------------------------# #
#     > # 04  1.0.6        Falklands ST Beg  # 1st Sun on/after Apr 6  #
#     > # 09  1.0.8        Falklands DST Beg # 1st Sun on/after Sep 8  #
#                                                                      #
#  Usage Note: If your OS recognizes the "#!" (shebang) syntax,        #
#              you can place a "#!/usr/bin/nawk -f" (or gawk)          #
#              at the start of this program (as I have) thereby        #
#              allowing you skip the "[gn]awk -f" during invocation.   #
#                                                                      #
#     Purpose: Return the year's holiday dates and names as calculated #
#              from the values in a holidays file.  A good description #
#              of what this program does is provided in the holiday    #
#              file layout just below.  Optionally (-b), return the    #
#              yyyymmdd date for the nth business day of the month.    #
#                                                                      #
# Description: Although I have Perl modules that do the same thing, I  #
#              wanted an awk program to provide the same information   #
#              so I could use it in my shell scripts.                  #
#                                                                      #
#              The program outputs holidays in three forms:            #
#                                                                      #
#                 1. Dates (yyyymmdd) only with all dates on a         #
#                    single line.                                      #
#                 2. Dates only in a multiline list.                   #
#                 3. yyyymmdd:Day:Holiday_name_as_in_holidays_file     #
#                                                                      #
#              The user can parse or assign the output as needed       #
#              via any number of shell script or other language tools. #
#                                                                      #
#       ------ Here is an example of one such shell script ------      #
#                                                                      #
#       > #!/bin/sh -vx                                                #
#       >   bin=/usr/local/bin                                         #
#       >   holidays_awk=$bin/holidays.awk                             #
#       >   holiday_file=$bin/holidays                                 #
#       >   holiday_cmd="nawk -f $holidays_awk --"                     #
#       >                                                              #
#       >   HOLIDAYS=`$holiday_cmd -s $holiday_file`; export HOLIDAYS  #
#       >                                                              #
#       >   if [ ."`echo $HOLIDAYS | grep \`date +\%Y\%m\%d\``" != . ] #
#       >   then                                                       #
#       >      echo "Today is a holiday.  Hoo-rah! :-)"                #
#       >   fi                                                         #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # Display holidays for this year.                      #   #
#       >   #------------------------------------------------------#   #
#       >   $holiday_cmd $holiday_file | sort \ k -- $holiday_file`    #
#       >     | nawk -v today="$today" \                               #
#       >       '{                                                     #
#       >           gsub(/:/," ",$0)                                   #
#       >           gsub(/_/," ",$0)                                   #
#       >           if (match($0,today))                               #
#       >              $0 = $0"\t  **HOLIDAY**"                        #
#       >           print $0                                           #
#       >        }'                                                    #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # Business day reporting: 1st, next-to-last, and last. #   #
#       >   #------------------------------------------------------#   #
#       >   bizday=`$holiday_cmd -b 1 $holiday_file`                   #
#       >   if [ `date +\%Y\%m\%d` = $bizday ]; then                   #
#       >      echo "Today is the first business day of the month."    #
#       >   fi                                                         #
#       >                                                              #
#       >   bizday=`$holiday_cmd -b -1 $holiday_file`                  #
#       >   if [ `date +\%Y\%m\%d` = $bizday ]; then                   #
#       >      echo "Today is the next-to-last business day."          #
#       >   fi                                                         #
#       >                                                              #
#       >   bizday=`$holiday_cmd -b last $holiday_file`                #
#       >   if [ `date +\%Y\%m\%d` = $bizday ]; then                   #
#       >      echo "Today is the last business day of the month."     #
#       >   fi                                                         #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # See if today is a business day at all.               #   #
#       >   #------------------------------------------------------#   #
#       >   $holiday_cmd -B $holiday_file                              #
#       >   if [ $? -eq 1 ]; then                                      #
#       >      echo "Today is a business day--get crackin'."           #
#       >   else                                                       #
#       >      echo "Today is NOT a business day--have fun."           #
#       >   fi                                                         #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # First Monday and last Sunday of the current month.   #   #
#       >   #------------------------------------------------------#   #
#       >   fst_monday=`$holiday_cmd -d 1.Mon`                         #
#       >   fst_monday=`$holiday_cmd -d 1.1`    # Alternative syntax   #
#       >   lst_sunday=`$holiday_cmd -d last.Sun`                      #
#       >   lst_sunday=`$holiday_cmd -d last.0` # Alternative syntax   #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # Falklands Day Light Savings Dates.                   #   #
#       >   #------------------------------------------------------#   #
#       >   Falk_DST=`$holiday_cmd -d 1.0.8 -m 9` # DST begins         #
#       >   Falk_ST=` $holiday_cmd -d 1.0.6 -m 4` # Return to ST       #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # See if today is the 1st Monday of the month and      #   #
#       >   # if it is the first business day of the month (the    #   #
#       >   # business day example uses the default holidays file, #   #
#       >   # /usr/local/bin/holidays (assuming the file exists).  #   #
#       >   #------------------------------------------------------#   #
#       >   $holiday_cmd -t -d 1.Mon || echo "Today is 1st Monday"     #
#       >   $holiday_cmd -t -b 1 || echo "Today is 1st Business day"   #
#       >                                                              #
#       >   #------------------------------------------------------#   #
#       >   # Find the date range wherein the 5th bizday falls-    #   #
#       >   # --great for setting cron date range, like this.      #   #
#       >   #                                                      #   #
#       >   #   00 01 5-7 * * `/usr/local/bin/holidays.awk -- \    #   #
#       >   #    -b 5 -t` || some_process > some_process.out 2>&1  #   #
#       >   #                                                      #   #
#       >   # Here again, by not specifying a holidays file,       #   #
#       >   # we use the default, /usr/local/bin/holidays.         #   #
#       >   #------------------------------------------------------#   #
#       >   years="00 01 02 03 04 05 06 07 08 09"                      #
#       >   years="$years 10 11 12 13 14 15 16 17 18 19"               #
#       >   years="$years 20 21 22 23 24 25"                           #
#       >   for n in $years                                            #
#       >   do                                                         #
#       >      /usr/local/bin/holidays.awk -- -y 20$n -b 5             #
#       >   done                                                       #
#                                                                      #
#     Credits: 1. The algorithms used here are from Marcos J. Montes   #
#                 (http://www.smart.net/~mmontes/ushols.html#ALG).     #
#                 Montes, in turn, credits Claus Tondering's work      #
#                 (http://www.tondering.dk/claus/calendar.html),       #
#                 for the algorithm and Timothy Barmann and Bobby      #
#                 Cossum for their contributions in simplifying the    #
#                 equations used.  Those gentlemen did the really      #
#                 hard work.                                           #
#                                                                      #
#              2. The On-or-After (OoA) capability available in the    #
#                 holidays file and with the -d option was requested   #
#                 by Kevin Marshall who also provided a critical part  #
#                 of the code to accomplish this.  This he did so he   #
#                 could determine, for example, daylight saving begin  #
#                 and end dates for the Falkland Islands.              #
#                                                                      #
#  Exit Codes: For all except business day (-b) and weekday (-d)       #
#              options...                                              #
#                                                                      #
#                 Zero    = Normal   | Success                         #
#                 Nonzero = Abnormal | Failure                         #
#                                                                      #
#              With business day (-b) and weekday (-d) options ...     #
#                                                                      #
#                 Nonzero = The day of the month on which the weekday  #
#                           weekday business day falls.                #
#                 Zero    = Abnormal | Failure                         #
#                                                                      #
#              With business day (-b) and weekday (-d) options used    #
#              in conjunction with "today is" (-t) ...                 #
#                                                                      #
#                 One |true  = The weekday or business day IS today.   #
#                 Zero|false = The day of the month on which the       #
#                              weekday or business day falls           #
#                              is NOT today.                           #
#                                                                      #
#              In addition to descriptive error messages (something    #
#              rare in AWK) each error exit has a different status     #
#              to assist in locating the source of the error.          #
#                                                                      #
#       Notes: 1. I could have called my dateplus.c to provide the     #
#                 same functionality as dateplus() and day_of_week(),  #
#                 but my intent was to have a single, self-contained   #
#                 piece of code.                                       #
#                                                                      #
#              2. I am no mathematician.  Heck, I'm not even a great   #
#                 an Awk programmer, so there are doubtless, many      #
#                 places where this code can be improved/simplified.   #
#                 Feel free, therefore, to forward comments and        #
#                 suggestions to Bob@OrlandoKuntao.com.  That said,    #
#                 my preference is for readable/understandable code    #
#                 over more efficient, but difficult to follow (read   #
#                 obfuscated) code since readable code (even if less   #
#                 efficient) makes maintenance much less a chore.      #
#                                                                      #
#    Modified: 2005-10-25 Bob Orlando                                  #
#                 v1.23 * Add an "on or after" extension used in our   #
#                         holidays file to the -d option (i.e.         #
#                         -d "N.D.OnOrA") allowing the user to specify #
#                         an occurrence or week number (N) and week    #
#                         day (D) within that week, AND also indicate  #
#                         the date must fall on or after a given day   #
#                         of the month (OnOrA).                        #
#                                                                      #
#----------------------------------------------------------------------#
