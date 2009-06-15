Dir=	../#
Files=	lib.awk ok.awk options.awk hello.awk

include lib.mk

debug :
	@echo "files : [$(Files)]"
	@echo "com   : [$(Com)]"

egs : eg1 eg2 eg3 eg4 eg5 eg6

eg1 : ; @$(Head); $(Com) 
eg2 : ; @$(Head); $(Com) -h
eg3 : ; @$(Head); $(Com) -a
eg4 : ; @$(Head); $(Com) -P timm
eg5 : ; @$(Head); cat Makefile | $(Com) -f $(Dir)/echo.awk  -P ken
eg6 : ; @$(Head); $(Com) -f $(Dir)/echo.awk  Makefile Makefile
