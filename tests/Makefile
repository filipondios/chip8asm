all: readfile readfileParam
	# Print some help
	@echo ""
	@echo "You can select one specific target:"
	@echo "readfile:      Reads 2048 bytes from 'testfile'"
	@echo "readfileParam: Reads 2048 bytes from a file given as a parameter"
	
readfile:
	# Read file test
	nasm -felf64 readfile.asm	
	ld -o readfile readfile.o
	rm readfile.o

readfileParam:
	# Read parameter file test
	nasm -felf64 readfileParam.asm	
	ld -o readfileParam readfileParam.o
	rm readfileParam.o
