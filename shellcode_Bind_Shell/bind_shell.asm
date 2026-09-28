section .data

section .text

global _start
_start:

mov rax, 0x29
mov rdi, 2 
mov rsi, 1
mov rdx, 0
syscall

mov rax,60
mov rdi,0
syscall
