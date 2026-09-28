section .data
	vmagicnum db 0x7f, 0x45, 0x4c, 0x46
	nomelf db "simple", 0

section .bss
	elfheader resb 64

	recup_e_entry resq 1
	recup_e_phoff resq 1
	recup_e_phentsize resw 1
	recup_phnum resw 1

	elfdata resb 4096
	pt_note_sav resq 1
	pt_load_sav resq 1

	p_flags resd 1
	p_offset resq 1
	p_vaddr resq 1
	p_filesz resq 1
	p_memsz resq 1
	p_align resq 1

section .text

global _start

_start:
	mov rax, 2
	mov rdi, nomelf
	mov rsi, 2
	mov rdx, 0
	syscall 	; ouvrir ELF en lecture écriture

	mov r8, rax

	mov rax, 0
	mov rdi, r8
	mov rsi, elfheader
	mov rdx, 64
	syscall 	; lire ELF Header

	mov eax, [elfheader]
	cmp eax, [vmagicnum]
	jne erreur 	; vérifier magic

	mov rax, [elfheader + 0x18]
	mov [recup_e_entry], rax 	; récupérer e_entry

	mov rax, [elfheader + 0x20]
	mov [recup_e_phoff], rax 	; récupérer e_phoff

	mov ax, [elfheader + 0x36]
	mov [recup_e_phentsize], ax 	; récupérer e_phentsize

	mov ax, [elfheader + 0x38]
	mov [recup_phnum], ax 	; récupérer e_phnum

	mov rax, 0
	mov rdi, r8
	mov rsi, elfdata
	mov rdx, 4096
	syscall 	; lire la suite du fichier

	mov rcx, 0 	; i = 0
boucle_proghead:

	cmp rcx, [recup_phnum] 	; i >= e_phnum ?
	jae fin_recherche

	mov rax, [recup_e_phoff] 	; RAX = e_phoff

	movzx rdx, word [recup_e_phentsize]	; RDX = e_phentsize

	imul rdx, rcx 	; RDX = i * e_phentsize

	add rax, rdx 	; RAX = e_phoff + i * e_phentsize
	sub rax, 64 	; elfdata commence à l'offset 64
	mov edx, [elfdata + rax]	; récupérer p_type

	cmp edx, 4	; PT_NOTE = 4
	je pt_note_trouve

	cmp edx, 1	; PT_LOAD = 1
	je pt_load_trouve

	inc rcx 	; i++
	jmp boucle_proghead


pt_note_trouve:

	mov [pt_note_sav], rax 	; RAX = position du ph dans elfdata

	jmp suite_boucle


pt_load_trouve:

	mov [pt_load_sav], rax 	; RAX = position du dernier PT_LOAD dans elfdata

	mov edx, [elfdata + rax + 4]     ; p_flags   offset +4
	mov [p_flags], edx

	mov rdx, [elfdata + rax + 8]     ; p_offset  offset +8
	mov [p_offset], rdx

	mov rdx, [elfdata + rax + 16]     ; p_vaddr   offset +16
	mov [p_vaddr], rdx

	mov rdx, [elfdata + rax + 32]     ; p_filesz  offset +32
	mov [p_filesz], rdx

	mov rdx, [elfdata + rax + 40]     ; p_memsz   offset +40
	mov [p_memsz], rdx

	mov rdx, [elfdata + rax + 48]    ; p_align   offset +48
	mov [p_align], rdx

	jmp suite_boucle


suite_boucle:

	inc rcx 	; i++
	jmp boucle_proghead


fin_recherche:

	mov rax, 3
	mov rdi, r8
	syscall

	mov rax, 60
	mov rdi, 0
	syscall


erreur:
	mov rax, 60
	mov rdi, 2
	syscall