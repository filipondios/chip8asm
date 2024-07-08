extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern EndDrawing
extern CloseWindow

extern _load
extern _exec_cicle
extern _get_keys
extern _draw_display
extern memcpy
extern cpu_ram
extern sprites

section .data
  ;; 'Macros'
  SYS_WRITE  equ 1
  SYS_EXIT   equ 60
  STD_OUT    equ 1

  ;; System variables
  win_width  dd 1920
  win_height dd 960
  win_fps    dd 60
  color_black	db 0,0,0,255
  arg_error_msg db "Error: Incorrect number of arguments",10,0

section .text
global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  
  ;; Args count
  cmp rdi, 2
  jne arg_error
  mov rbx, rsi

  ;; Load ROM
  xor rdi, rdi
  mov rdi, [rsi + 8]
  call _load

  ;; Init RAM
  mov rdi, cpu_ram
  mov rsi, sprites
  mov rdx, 80
  call memcpy

  ;; Create window
  mov edi, [win_width]
  mov esi, [win_height]
  mov rdx, [rbx + 8]
  call InitWindow

  mov edi, [win_fps]
  call SetTargetFPS

loop_begin:
  call WindowShouldClose
  cmp eax, 0
  jne loop_end

  call _exec_cicle
  call _get_keys

  call BeginDrawing
  call _draw_display
  call EndDrawing
  jmp loop_begin

loop_end:
  call CloseWindow
  leave
  ret

arg_error:
  mov rdi, STD_OUT
  mov rsi, arg_error_msg
  mov rdx, 38
  mov rax, SYS_WRITE
  syscall

  mov rax, SYS_EXIT
  mov rdi, 1
  syscall
