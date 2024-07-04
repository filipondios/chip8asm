ASMC=nasm
CC=gcc
ASMFLAGS=-f elf64
CFLAGS=-no-pie -m64
CXTRAFLAGS=-lraylib -lGL -lm -lpthread -ldl -lrt -lX11 -lc
SRCS=main.asm load.asm memory.asm keys.asm cicle.asm
OBJS = $(SRCS:.asm=.o)
TARGET=exec

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -g $(CFLAGS) -o $@ extern.c $^ $(CXTRAFLAGS)

%.o: %.asm
	$(ASMC) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
