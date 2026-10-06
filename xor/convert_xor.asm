section .data
    input_bin db "bind_shell.asm",0
    input_bin db "bind_shell_xor.asm",0
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

erreur:
    mov rax, 60
    mov rdi, 2
    syscall
