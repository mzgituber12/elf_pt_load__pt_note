section .data
    input_bin db "bind_shell.bin",0
    output_bin db "bind_shell_xor.bin",0
    xor_key equ 0x5A
section .bss
    buffer resb 4096
section .text
global _start
_start:

    mov rax, 60
    mov rdi, 0
    syscall

erreur:
    mov rax, 60
    mov rdi, 2
    syscall