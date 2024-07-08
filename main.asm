extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern EndDrawing
extern CloseWindow
extern memcpy

extern _load
extern _exec_cicle
extern _get_keys
extern _draw_display
extern cpu_ram
extern sprites
extern cpu_dt
extern cpu_st

section .data
  ;; 'Macros'
  SYS_WRITE  equ 1
  SYS_EXIT   equ 60
  STD_OUT    equ 1

  ;; System variables
  win_width  dd 1920
  win_height dd 960
  win_fps    dd 60
  arg_msg    db "Error: Incorrect number of arguments",10,0

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

;; Main loop:
;; - Fetches, decodes and executes 
;;   the next instruction
;; - Gets the pressed keys
;; - Updates the timers (DT and ST)
;; - Draws the display buffer in 
;;   the window
main_loop:
  call WindowShouldClose
  cmp eax, 0
  jne main_loop_end

  call _exec_cicle
  call _get_keys

  ;; Update delay timer
  movzx rdi, byte [cpu_dt]
  cmp dil, 0
  je update_st
  dec dil
  mov byte [cpu_dt], dil

update_st:
  ;; Update sound timer
  movzx rdi, byte [cpu_st]
  cmp dil, 0
  je main_loop_draw
  dec dil
  mov byte [cpu_st], dil

main_loop_draw:
  call BeginDrawing
  call _draw_display
  call EndDrawing
  jmp main_loop

main_loop_end:
  call CloseWindow
  leave
  ret


arg_error:
  mov rdi, STD_OUT
  mov rsi, arg_msg
  mov rdx, 38
  mov rax, SYS_WRITE
  syscall

  mov rax, SYS_EXIT
  mov rdi, 1
  syscall
