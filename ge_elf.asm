section .data
	vmagicnum db 0x7f, 0x45, 0x4c, 0x46
section .bss
	nomelf resb 20
	elfheader resb 64
section .text

global _start

_start:	

	mov rax, 0 
	mov rdi, 0  
	mov rsi, nomelf
	mov rdx, 20
	syscall ; lis la console et récupère le nom du fichier elf
	
	mov rax, 2
	mov rdi, nomelf
	mov rsi, 2
	mov rdx, 0
	syscall ; ouvre le fichier

	mov r8, rax
	
	mov rax, 0
	mov rdi, r8
	mov rsi, elfheader
	mov rdx, 64
	syscall ; recupere lenombre magic 
	
	mov eax, [magicnum]
	cmp vmagicnum, eax
	jne erreur ; verifie si c'est un fichier elf
	
	

	mov rax, 60
	mov rdi, 0
	syscall

erreur:
	mov rax, 60
	mov rdi, 2
	syscall