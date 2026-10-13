all:
	nasm -f bin $(PAYLOAD).asm -o $(PAYLOAD).bin
	nasm -f elf64 $(FILE).asm -o $(FILE).o ld --build-id $(FILE).o -o $(FILE)
	nasm -f elf64 ge_elf.asm -o ge_elf.o ld ge_elf.o -o ge_elf
	./ge_elf $(FILE) $(PAYLOAD) $(XOR) $(KEY)
	./$(FILE)