section .data
  ;; 'Macros'
  SYS_READ   equ 0
  SYS_WRITE  equ 1
  SYS_OPEN   equ 2
  SYS_CLOSE  equ 3
  SYS_EXIT   equ 60
  STD_OUT    equ 1
  S_IRUSR    equ 400
  READ_BYTES equ 2048 
  
  ;; Constant string messages
  argerror_msg: db "Bad arguments count",0
  fderror_msg:  db "Error opening the file",0
  fdopen_msg:   db "File opened",0

  ;; Read 2048 byte buffer
  buffer: times READ_BYTES db 0

section .text
global _start
_start:
  
  ;; Get file path from 
  ;; the program parameters
  pop rdi
  cmp rdi, 2
  jne _argc_error

  add rsp, 8
  pop rdi
  jmp _open_file

_argc_error:
  ;; Print error
  ;; write syscall(1)
  mov rdi, STD_OUT
  mov rsi, argerror_msg
  mov rdx, 20 ; msg len
  mov rax, SYS_WRITE
  syscall
  jmp _exit

_open_file:
  ;; open syscall(2)
  mov rsi, S_IRUSR
  mov rax, SYS_OPEN
  syscall 

  ;; error if fd < 0
  cmp rax, 0
  jl _fderror
  jmp _fdopen

_fderror:
  ;; Print error
  ;; write syscall(1)
  mov rdi, STD_OUT
  mov rsi, fderror_msg
  mov rdx, 23 ; msg len
  mov rax, SYS_WRITE
  syscall
  jmp _exit

_fdopen:
  ;; rax = fd
  ;; read syscall(0)
  mov rdi, rax
  mov rsi, buffer
  mov rdx, READ_BYTES
  mov rax, SYS_READ
  syscall

  ;; Print content
  ;; rax = byte count
  ;; rsi = buffer
  ;; write syscall(1)
  mov rdi, STD_OUT 
  mov rdx, rax
  mov rax, SYS_WRITE
  syscall

  ;; close syscall(3)
  mov rdi, rax
  mov rax, SYS_CLOSE
  syscall

_exit:
  ;; exit syscall(60)
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall
