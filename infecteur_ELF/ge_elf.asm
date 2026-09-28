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
	last_load_end resq 1

	p_flags resd 1
	p_offset resq 1
	p_vaddr resq 1
	p_filesz resq 1
	p_memsz resq 1
	p_align resq 1

	espace_disponible resq 1

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

	movzx rdx, word [recup_phnum]
	cmp rcx, rdx 	; i >= e_phnum ?
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

	cmp qword [pt_note_sav], 0	
	jne suite_boucle			; empecher d'écraser si il existe déjà un PT_NOTE trouvé

	mov [pt_note_sav], rax		; sauvegarder le premier PT_NOTE

	jmp suite_boucle


pt_load_trouve:

	mov [pt_load_sav], rax 	; RAX = position du PT_LOAD dans elfdata

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

	mov rdx, [elfdata + rax + 48]     ; p_align   offset +48
	mov [p_align], rdx

	mov rax, [p_memsz]
	sub rax, [p_filesz]
	mov [espace_disponible], rax	 ; espace mémoire potentiellement libre

	mov rax, [p_vaddr]
	add rax, [p_filesz]
	add rax, 0x1000			; prépare l'alignement
	and rax, ~0xFFF			; alignement sur 0x1000

	cmp rax, [last_load_end]
	jle suite_boucle

	mov [last_load_end], rax		; conserver la plus grande adresse

	jmp suite_boucle


suite_boucle:

	inc rcx 	; i++
	jmp boucle_proghead


fin_recherche:
	mov r13, [last_load_end]        ; nouvelle adresse virtuelle
	add r13, 0x1000
	and r13, ~0xFFF

	mov rax, 8
	mov rdi, r8
	mov rsi, 0
	mov rdx, 2		; SEEK_END = 2
	syscall 		; rechercher la fin du ELF

	mov r12, rax		; r12 = offset de fin du fichier

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