#CC    = gcc
#COPTS = -g -O3 -Wall -Wstrict-prototypes # -DNDEBUG

CC    = g++
#COPTS = -O3
COPTS = -g
LIBS = -lpcap -lpthread
rsetest: rsetest.c rse.h rse.o Makefile
	 $(CC) $(COPTS) -o rsetest rsetest.c rse.o $(LIBS)

rse.o:	 rse.c rse.h Makefile
	 $(CC) $(COPTS) -c rse.c

tar:
	 tar -cf rse.tar Makefile README.txt rse.c rse.h rsetest.c
	 tar -czf rse.tar.gz Makefile README.txt rse.c rse.h rsetest.c

clean:
	 rm -f *.s *.o *.tar *~ rsetest core
