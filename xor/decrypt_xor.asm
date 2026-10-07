section .data
    input_bin db "bind_shell_xor.bin",0
    output_bin db "bind_shell_decrypted.bin",0
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
    syscall             ; Ouverture du fichier

    cmp rax, 0
    jl erreur

    mov r12, rax

    mov rax, 2
    mov rdi, output_bin
    mov rsi, 1 | 64 | 512
    mov rdx, 0o644          ; ouverture du fichier source
    syscall

    cmp rax, 0
    jl erreur

    mov r13, rax

read_loop:

    mov rax, 0             
    mov rdi, r12            
    mov rsi, buffer
    mov rdx, 4096
    syscall             ; mettre le fichier xor dan sun buffer

    cmp rax, 0
    jl erreur
    jz close_file

    mov r14, rax

    xor rcx, rcx

decrypt_loop:

    cmp rcx, r14        ; Condition de la fin de la boucle
    jge write_output

    xor byte [buffer + rcx], xor_key
    inc rcx

    jmp decrypt_loop

write_output:

    mov rax, 1              
    mov rdi, r13         
    mov rsi, buffer
    mov rdx, r14
    syscall             ; Ecrire dans le fichier aprés déchiffrement

    cmp rax, 0
    jl erreur

    jmp read_loop



close_file:
    mov rax, 3
    mov rdi, r12
    syscall

    mov rax, 3
    mov rdi, r13
    syscall

    mov rax, 60
    mov rdi, 0
    syscall


erreur:
    mov rax, 60
    mov rdi, 2
    syscall