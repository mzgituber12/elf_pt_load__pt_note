section .data
	vmagicnum db 0x7f, 0x45, 0x4c, 0x46
	nomelf db "/bin/ls", 0

section .bss
	elfheader resb 64

	recup_e_entry resq 1
	recup_e_phoff resq 1
	recup_e_phentsize resw 1
	recup_phnum resw 1

	elfdata resb 4096
	pt_note_sav resq 1

section .text

global _start

_start:

	; ouvrir ELF en lecture seule
	mov rax, 2
	mov rdi, nomelf
	mov rsi, 0
	mov rdx, 0
	syscall

	mov r8, rax

	; lire ELF Header
	mov rax, 0
	mov rdi, r8
	mov rsi, elfheader
	mov rdx, 64
	syscall

	; vérifier magic
	mov eax, [elfheader]
	cmp eax, [vmagicnum]
	jne erreur

	; récupérer e_entry
	mov rax, [elfheader + 0x18]
	mov [recup_e_entry], rax

	; récupérer e_phoff
	mov rax, [elfheader + 0x20]
	mov [recup_e_phoff], rax

	; récupérer e_phentsize
	mov ax, [elfheader + 0x36]
	mov [recup_e_phentsize], ax

	; récupérer e_phnum
	mov ax, [elfheader + 0x38]
	mov [recup_phnum], ax

	; lire la suite du fichier
	mov rax, 0
	mov rdi, r8
	mov rsi, elfdata
	mov rdx, 4096
	syscall

	; i = 0
	mov rcx, 0

boucle_proghead:

	; i >= e_phnum ?
	cmp rcx, [recup_phnum]
	jae pas_de_pt_note

	; RAX = e_phoff
	mov rax, [recup_e_phoff]

	; RDX = e_phentsize
	movzx rdx, word [recup_e_phentsize]

	; RDX = i * e_phentsize
	imul rdx, rcx

	; RAX = e_phoff + i * e_phentsize
	add rax, rdx

	; elfdata commence à l'offset 64
	sub rax, 64

	; récupérer p_type
	mov edx, [elfdata + rax]

	; PT_NOTE = 4
	cmp edx, 4
	je pt_note_trouve

	; i++
	inc rcx
	jmp boucle_proghead


pt_note_trouve:

	; RAX = position du Program Header dans elfdata
	mov [pt_note_sav], rax

	jmp fin


pas_de_pt_note:

	jmp erreur


erreur:

	mov rax, 60
	mov rdi, 2
	syscall


fin:

	mov rax, 60
	mov rdi, 0
	syscall