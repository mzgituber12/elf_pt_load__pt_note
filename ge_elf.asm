section .data
	vmagicnum db 0x7f, 0x45, 0x4c, 0x46
section .bss
	nomelf resb 20
	elfheader resb 64
    recup_e_entry resq 1
    recup_e_phoff resq 1
    recup_e_phentsize resw 1
    recup_phnum resw 1
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
	
	mov eax, [elfheader]
	cmp [vmagicnum], eax
	jne erreur ; verifie si c'est un fichier elf
	
	mov rax, [elfheader+0x18]
    mov [recup_e_entry], rax

    mov rax, [elfheader+0x20]
    mov [recup_e_phoff], rax

    mov ax, [elfheader+0x36]
    mov [recup_e_phentsize], ax

    mov ax, [elfheader+0x38]
    mov [recup_phnum], ax

	mov rax, 60
	mov rdi, 0
	syscall

erreur:
	mov rax, 60
	mov rdi, 2
	syscall