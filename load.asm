section .data
  extern cpu_ram
  extern printf

  ;; 'Macros'
  SYS_READ   equ 0
  SYS_WRITE  equ 1
  SYS_OPEN   equ 2
  SYS_CLOSE  equ 3
  SYS_STAT   equ 4
  SYS_EXIT   equ 60
  STD_OUT    equ 1
  S_IRUSR    equ 400
  READ_BYTES equ 0xE00
  PROG_BEGIN equ 0x200 
  
  ;; Stat structure
  statbuff times 144 db 0

  ;; Constant string messages
  stat_msg: db "Error: Unable to stat ROM file",10,0
  open_msg: db "Error: Unable to open ROM file",10,0
  size_msg: db "Error: ROM file is too large",10,0

section .text
;; Tries to read a ROM file and
;; write it to the chip RAM
;; rdi = rom path
global _load
_load:
  push rsi
  push rax
  push rdi
  push rdx
  ;; begin
  ;; stat syscall (4)
  mov rsi, statbuff 
  mov rax, SYS_STAT
  syscall
  cmp rax, 0 
  jne stat_error

  ;; Check if the file size
  ;; is too large
  xor rax, rax
  mov rax, [statbuff + 48]
  cmp rax, READ_BYTES  
  jg  size_error

  ;; open syscall(2)
  mov rsi, S_IRUSR
  mov rax, SYS_OPEN
  syscall 
  cmp rax, 0
  jl open_error

  ;; read syscall(0)
  mov rdi, rax
  mov rsi, cpu_ram
  add rsi, PROG_BEGIN
  mov rdx, READ_BYTES
  mov rax, SYS_READ
  syscall

  ;; close syscall(3)
  mov rdi, rax
  mov rax, SYS_CLOSE
  syscall
  ;; end
  pop rdx
  pop rdi
  pop rax
  pop rsi
  ret

stat_error:
  ;; write syscall(1)
  mov rdi, STD_OUT
  mov rsi, stat_msg
  mov rdx, 32 ; msg len
  mov rax, SYS_WRITE
  syscall
  jmp exit_error

open_error:
  ;; Print error
  ;; write syscall(1)
  mov rdi, STD_OUT
  mov rsi, open_msg
  mov rdx, 32 ; msg len
  mov rax, SYS_WRITE
  syscall
  jmp exit_error

size_error:
  ;; Print error
  ;; write syscall(1)
  mov rdi, STD_OUT
  mov rsi, size_msg
  mov rdx, 30 ; msg len
  mov rax, SYS_WRITE
  syscall
  jmp exit_error

exit_error:
  ;; exit syscall(60)
  mov rax, SYS_EXIT
  mov rdi, 1
  syscall
