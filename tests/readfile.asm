
section .data
pathname: db "testfile",0
fderror_msg: db "Error opening the file",0
fdopen_msg: db "File opened",0
buffer: times 2048 db 0

section .text
global _start
_start:
  
  ;; open syscall(2)
  mov rdi, pathname ;; file path
  mov rsi, 00400    ;; open flag: S_IRUSR 
  mov rax, 2
  syscall

  ;; error if fd < 0
  cmp rax, 0
  jl _fderror
  jmp _fdopen

_fderror:
  ;; Print error
  ;; write syscall(1)
  mov rdi, 1
  mov rsi, fderror_msg
  mov rdx, 23
  mov rax, 1
  syscall
  jmp _exit

_fdopen:
  ;; rax = fd
  ;; read syscall(0)
  mov rdi, rax
  mov rsi, buffer
  mov rdx, 2048
  mov rax, 0
  syscall

  ;; Print content
  ;; rax = byte count
  ;; rsi = buffer
  ;; write syscall(1)
  mov rdi, 1 
  mov rdx, rax
  mov rax, 1
  syscall

  ;; close syscall(3)
  mov rdi, rax
  mov rax, 3
  syscall

_exit:
  ;; exit syscall(60)
  mov rax, 60
  mov rdi, 0
  syscall
