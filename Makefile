ASMC=nasm
CC=gcc
ASMFLAGS=-f elf64
CFLAGS=-no-pie -m64
CXTRAFLAGS=-lraylib -lGL -lm -lpthread -ldl -lrt -lX11 -lc
SRCS=main.asm load.asm memory.asm get_keys.asm
OBJS = $(SRCS:.asm=.o)
TARGET=exec

#all: $(OBJS)
#	$(ASMC) $(ASMFLAGS) $(SRCS)
#	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) $(CXTRAFLAGS)
#	rm $(OBJS)

# Default target
all: $(TARGET)

# Rule to create the target executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(CXTRAFLAGS)

# Rule to compile .asm files to .o files
%.o: %.asm
	$(ASMC) $(ASMFLAGS) $< -o $@

# Clean up generated files
clean:
	rm -f $(OBJS) $(TARGET)
