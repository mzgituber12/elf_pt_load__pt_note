section .data
    input_bin db "bind_shell.asm",0
    output_bin db "bind_shell_xor.asm",0
section .bss
    buffer resb 4096
section .text
global _start
_start:
    mov rax, 2
    mov rdi, input_bin
    mov rsi, 0
    mov rdx, 0

    cmp rax, 0
    jl erreur

    mov r12, rax

    mov rax, 60
    mov rdi, 0
    syscall

    mov     rax, 2
    mov     rdi, output_bin
    mov     rsi, 1 | 64 | 512
    mov     rdx, 0o644
    syscall

    cmp rax, 0
    jl erreur

    mov r13, rax


erreur:
    mov rax, 60
    mov rdi, 2
    syscall
