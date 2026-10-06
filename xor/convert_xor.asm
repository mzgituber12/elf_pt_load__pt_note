section .data
    input_bin db "bind_shell.asm",0
    output_bin db "bind_shell_xor.asm",0
    xor_key equ 0x5A
section .bss
    buffer resb 4096
section .text
global _start
_start:
    mov rax, 2
    mov rdi, input_bin
    mov rsi, 0
    mov rdx, 0
    syscall

    cmp rax, 0
    jl erreur

    mov r12, rax

    mov     rax, 2
    mov     rdi, output_bin
    mov     rsi, 1 | 64 | 512
    mov     rdx, 0o644
    syscall

    cmp rax, 0
    jl erreur

    mov r13, rax

read_loop:

    mov     rax, 0              
    mov     rdi, r12           
    mov     rsi, buffer
    mov     rdx, 4096       ; lecture de l'input
    syscall

    cmp rax, 0
    jl erreur
    jz close_file       ; Si vide quitter

    mov r14, rax

    xor rcx, rcx            ; met rcx à 0

xor_loop:

    cmp rcx, r14
    jge write_output

    xor byte [buffer + rcx], xor_key        ; Modifie avec xor octet par octet

    inc rcx
    jmp xor_loop

    write_output:

    mov     rax, 1              ; Ecrire dans output_bin
    mov     rdi, r13
    mov     rsi, buffer
    mov     rdx, r14
    syscall

    cmp rax, 0
    jl erreur

    jmp read_loop


close_file:
    mov     rax, 3
    mov     rdi, r12
    syscall             ; Fermer le fichier d'entré

    mov     rax, 3
    mov     rdi, r13
    syscall             ; Fermer le fichier de sortie

    mov rax, 60
    mov rdi, 0
    syscall


erreur:
    mov rax, 60
    mov rdi, 2
    syscall
