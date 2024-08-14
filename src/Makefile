# chip8asm version
VERSION = 3.0

# Paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

# Flags
LIBS = -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
CFLAGS = -std=c99 -no-pie -m64 -Wall
ASMFLAGS = -felf64
CC = gcc

# Compilation objects
SRCS = main.asm load.asm memory.asm keys.asm cicle.asm display.asm errors.asm
OBJS = $(SRCS:.asm=.o)


# Compile everything
all: target debug
	
# Usual compilation
target: $(OBJS)
	$(CC) $(CFLAGS) -Os -o chip8asm.target extern.c $^ $(LIBS)

%.o: %.asm
	nasm $(ASMFLAGS) $< -o $@


# Debug Compilation
DEBUG_OBJS = $(patsubst %.asm,%.debug.o,$(SRCS))

%.debug.o: %.asm
	nasm $(ASMFLAGS) -DDEBUG $< -o $@

debug: $(DEBUG_OBJS)
	$(CC) $(CFLAGS) -g -o chip8asm.debug extern.c $^ $(LIBS) -DDEBUG


# Install program
target-install: $(OBJS)
	$(CC) $(CFLAGS) -Os -o chip8asm.target extern.c $^ $(LIBS) -DINSTALL

install: target-install
	mkdir -p $(PREFIX)/bin/
	cp -f chip8asm.target $(PREFIX)/bin/chip8asm
	chmod 755 $(PREFIX)/bin/chip8asm
	mkdir -p /usr/share/chip8asm
	cp -f resources/beep.wav /usr/share/chip8asm
	sed "s/VERSION/$(VERSION)/g" < chip8asm.1 > $(MANPREFIX)/man1/chip8asm.1
	chmod 644 $(MANPREFIX)/man1/chip8asm.1

# Uninstall program
uninstall:
	rm -f $(PREFIX)/bin/chip8asm


# Clean compilation files
clean:
	rm -f $(OBJS) chip8asm.target $(DEBUG_OBJS) chip8asm.debug chip8asm

.PHONY: all clean debug install uninstall
