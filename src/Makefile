ASMC=nasm
CC=gcc
ASMFLAGS=-f elf64
CFLAGS=-no-pie -m64
CXTRAFLAGS=-lraylib -lGL -lm -lpthread -ldl -lrt -lX11 -lc
SRCS=main.asm load.asm memory.asm keys.asm cicle.asm display.asm
OBJS = $(SRCS:.asm=.o)
TARGET=chip8asm
TARGET_DEBUG=$(TARGET)-debug

# Usual compilation
all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ extern.c $^ $(CXTRAFLAGS)

%.o: %.asm
	$(ASMC) $(ASMFLAGS) $< -o $@

# Debug Compilation
DEBUG_OBJS = $(patsubst %.asm,%.debug.o,$(SRCS))

%.debug.o: %.asm
	$(ASMC) $(ASMFLAGS) -DDEBUG $< -o $@

debug: $(DEBUG_OBJS)
	$(CC) $(CFLAGS) -g -o $(TARGET_DEBUG) extern.c $^ $(CXTRAFLAGS) -DDEBUG

# Clean compilation files
clean:
	rm -f $(OBJS) $(TARGET) $(DEBUG_OBJS) $(TARGET_DEBUG)

.PHONY: all clean debug
