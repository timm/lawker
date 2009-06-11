Files=lib.awk ok.awk options.awk hello.awk
Awks=$(subst awk ,awk -f ../,$(Files))
Com=gawk -f ../$(Awks)
Head=echo "";echo "---| $@ |---------------------------------"

egs : eg1 eg2 eg3 eg4 eg5 eg6

eg1 : ; @$(Head); $(Com) 
eg2 : ; @$(Head); $(Com) -h
eg3 : ; @$(Head); $(Com) -a
eg4 : ; @$(Head); $(Com) -P timm
eg5 : ; @$(Head); cat Makefile | $(Com) -f ../echo.awk 
eg6 : ; @$(Head); $(Com) -f ../echo.awk  Makefile Makefile
