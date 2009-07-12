# Build a sample example executable 
#
cfiles := fsm.c fsm_test.c test_actions.c test_driver.c
ofiles := $(patsubst %.c,%.o,$(cfiles))
hfiles := $(wildcard *.h)
fsmfiles := $(wildcard fsm_*.c) $(wildcard fsm_*.h) 


all: $(cfiles) $(ofiles) 
	gcc -g $(ofiles) -o test

fsm.o : fsm.c fsm.h utils.h
	gcc -g -Wall -c   -finline-functions -Winline  -o fsm.o  fsm.c

fsm_test.o : fsm_test.c
	gcc -g -c -Wall   -finline-functions -Winline  -o fsm_test.o  fsm_test.c

test_driver.o : test_driver.c
	gcc -g -c -Wall   -finline-functions -Winline  -o test_driver.o  test_driver.c

test_actions.o : test_actions.c utils.h fsm.h fsm_test.h
	gcc -g -c -Wall   -finline-functions -Winline  -o test_actions.o  test_actions.c


clean:
	rm *.o test






