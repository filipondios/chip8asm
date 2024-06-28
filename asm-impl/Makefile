ASMC=nasm
CC=gcc
ASMFLAGS=-f elf64
CFLAGS=-no-pie -m64
CXTRAFLAGS=-lraylib -lGL -lm -lpthread -ldl -lrt -lX11 -lc
SRCS=file.asm
OBJS = $(SRCS:.asm=.o)
TARGET=exec

all: 
	$(ASMC) $(ASMFLAGS) $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) $(CXTRAFLAGS)
	rm $(OBJS)
