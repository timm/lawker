gawk -f push.awk --source 'BEGIN {
      empty(a)
      push1(a,"thing")     
      #push2(a,"thing")
'}
