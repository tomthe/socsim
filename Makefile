#SVNDEF = -D'SVN_REV="$(shell svnversion -n .)"'
#COMPDATE = -D'COMP_DATE="$(shell date)"'
CFLAGS        =  -O1 -Wuninitialized -g
CFLAGS9        =  -O9 -Wuninitialized 
CFLAGS-testsim        =  -g -pg
CC            = gcc
OBJS	      = events.o \
		io.o \
		load.o \
		random.o \
		utils.o \
		census.o \
		xevents.o \
		enhancement.o
SRCS	      = ./src/events.c \
		./src/io.c \
		./src/load.c \
		./src/random.c \
		./src/utils.c \
		./src/census.c \
		./src/xevents.c 

##		./src/enhancement.c
LIBS	      = -lm
HDRS	      = defs.h \
		enhancement.h

all: $(OBJS) $(HDRS)
	$(CC) $(CFLAGS-testsim) $(LDFLAGS) -o testsim $(SRCS) $(LIBS)


testsim: $(SRCS) $(HDRS)
	$(CC) $(CFLAGS-testsim) $(LDFLAGS) -o testsim $(SRCS) $(LIBS)

socsim: $(SRCS) $(HDRS)
	$(CC) $(CFLAGS9) $(LDFLAGS)  -o socsim $(SRCS) $(LIBS)

socsim-enhanced: $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) $(LDFLAGS) -D ENHANCED  -o socsim-enhanced $(SRCS) ./src/enhancement.c $(LIBS)

socsim-enhanced9: $(SRCS) $(HDRS)
	$(CC) $(CFLAGS9) $(LDFLAGS) -D ENHANCED  -o socsim-enhanced9 $(SRCS) ./src/enhancement.c $(LIBS)


static: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o socstatic -static $(SRCS) $(LIBS)


tags:           $(HDRS) $(SRCS); @ctags $(HDRS) $(SRCS)

saber:           $(HDRS) $(SRCS); @$(SABER) $(SRCS) -lm

xsaber:           $(HDRS) $(SRCS); @$(XSABER) $(SRCS) -lm

census.o:./src/census.c ./src/defs.h ./src/enhancement.h
	gcc -c $(CFLAGS) ./src/census.c

events.o:./src/events.c ./src/defs.h
	gcc -c $(CFLAGS) ./src/events.c

io.o:./src/io.c ./src/defs.h 
	gcc -c $(CFLAGS) ./src/io.c

load.o:./src/load.c ./src/defs.h 
	gcc -c $(CFLAGS) ./src/load.c

random.o:./src/random.c ./src/defs.h 
	gcc -c $(CFLAGS) ./src/random.c

utils.o:./src/utils.c ./src/defs.h
	gcc -c $(CFLAGS) ./src/utils.c

xevents.o:./src/xevents.c ./src/defs.h 
	gcc -c $(CFLAGS) ./src/xevents.c

enhancement.o:./src/enhancement.c ./src/defs.h
	gcc -c $(CFLAGS) ./src/enhancement.c

defs.h: ./src/defs.h

enhancement.h: ./src/enhancement.h
 
clean:
	\rm *.o socsim

