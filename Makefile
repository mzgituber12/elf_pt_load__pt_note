all:
	nasm -f bin bind_shell.asm -o bind_shell.bin
	nasm -f elf64 simple.asm -o simple.o ld --build-id simple.o -o simple
	nasm -f elf64 ge_elf.asm -o ge_elf.o ld ge_elf.o -o ge_elf
	./ge_elf $(FILE) $(PAYLOAD) $(XOR) $(KEY)
	./simple