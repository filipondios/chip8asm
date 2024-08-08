ASM=nasm
ASMFLAGS=-f elf64
LD=ld
LDFLAGS=-no-pie
CC=gcc
CFLAGS=-c
OBJ_FILES=*.o
TARGETS=readfile.test readfileParam.test opcodes.test

all: $(TARGETS)
	@echo ""
	@echo "You can also select one specific target:"
	@echo "make readfile:      Reads 2048 bytes from 'testfile'"
	@echo "make readfileParam: Reads 2048 bytes from a file given as a parameter"
	@echo "make opcodes        Tests for the implementes opcodes"
	@echo "Type 'make help' to see more information about those comands."

# Read file test
# nasm -f elf64 readfile.asm	
# ld -o readfile readfile.o
# rm *.o

readfile.test: readfile.o
	$(LD) -o $@ $<
	rm $(OBJ_FILES)

readfile.o: readfile.asm
	$(ASM) $(ASMFLAGS) $<


# Read parameter file test
# nasm -f elf64 readfileParam.asm	
# ld -o readfileParam readfileParam.o
# rm *.o

readfileParam.test: readfileParam.o
	$(LD) -o $@ $<
	rm $(OBJ_FILES)

readfileParam.o: readfileParam.asm
	$(ASM) $(ASMFLAGS) $<


# Opcodes tests
# gcc -c opcodesTests.c -o opcodesTests.o
# nasm -f elf64 ../opcodes.asm -o ./opcodes.o
# gcc -no-pie ./opcodes.o opcodesTests.o -o opcodesTests
#rm *.o

opcodes.test: opcodesTests.o opcodes.o errors.o
	$(CC) -g $(LDFLAGS) -o $@ $^
	rm $(OBJ_FILES)

opcodesTests.o: opcodesTests.c
	$(CC) $(CFLAGS) -o $@ $<

opcodes.o: ../opcodes.asm 
	$(ASM) $(ASMFLAGS) $< -o $@

errors.o: ../errors.asm 
	$(ASM) $(ASMFLAGS) $< -o $@

clean: 
	rm -f $(TARGETS)

help: 
	@echo ""
	@echo "Available targets:"
	@echo -e "readfile:\n"\
			"    Reads 2048 bytes from 'testfile'. If the file 'testfile'\n"\
			"    somehow does not exist or you dont have the necessary\n"\
			"    permissions, a error will be printed. If the file was\n"\
			"    successfully opened, its first 2048 bytes will be printed."
	@echo ""
	@echo -e "readfileParam:\n"\
			"    Same as 'readfile' but this time you can specify the path to the\n"\
			"    file to read as a parameter to the test."
	@echo ""
	@echo -e "opcodes:\n"\
			"    Tests the implemented opcodes at the file opcodes.asm (located at\n"\
			"    the parent directory). To do so, it compiles the opcodesTests.c file\n"\
			"    wich uses the assert.h library. That means that if the program exits\n"\
			"    without a IOT instruction message, every test was passed."

.PHONY: clean help
