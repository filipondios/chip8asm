readfile: 
	# Read file test
	nasm -felf64 readfile.asm	
	ld -o readfile readfile.o
	rm readfile.o
	@echo "---- READ FILE TEST ----"
	./readfile

all: readfile

