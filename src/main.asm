;; Library C functions
extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern EndDrawing
extern CloseWindow
extern memcpy
;; Custom C functions
extern loadBeepSound
extern unloadBeepSound
extern updateST
extern updateDT
%ifdef DEBUG
extern printMemory
%endif
;; Custom asm functions
extern _load
extern _exec_cicle
extern _get_keys
extern _draw_display
extern _decode_error
;; System variables
extern cpu_memory
extern cpu_error
extern sprites
extern cpu_dt
extern cpu_st
extern cpu_pc
;; Errors
extern NO_ERROR


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
  BLACK db 0, 0, 0, 255

section .text
global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  ;; begin
  ;; Args count
  cmp rdi, 2
  jne arg_error
  mov rbx, rsi
  ;; Load ROM
  xor rdi, rdi
  mov rdi, [rsi + 8]
  call _load
  ;; Init RAM
  mov rdi, cpu_memory
  mov rsi, sprites
  mov rdx, 80
  call memcpy
  ;; Create window
  mov edi, [win_width]
  mov esi, [win_height]
  mov rdx, [rbx + 8]
  call InitWindow
  ;; Set FPS and 
  ;; load Audio
  mov edi, [win_fps]
  call SetTargetFPS
  call loadBeepSound
main_loop:
  ;; Window should close?
  ;; Raylib call
  call WindowShouldClose
  cmp eax, 0
  jne main_loop_end
  ;; Only if debug is 
  ;; active, print the
  ;; cpu registers
  %ifdef DEBUG
  call printMemory
  %endif
  ;; Check if there was an 
  ;; error in the last cicle
  mov dil, byte [cpu_error]
  cmp dil, NO_ERROR
  je continue_loop
  movzx rbx, word [cpu_pc]
  movzx si, byte [cpu_memory + rbx]
  shl si, 8
  inc rbx
  movzx bx, byte [cpu_memory + rbx]
  or si, bx
  call _decode_error
  jmp main_loop_end
continue_loop:
  ;; Only if there are
  ;; no errors
  call _exec_cicle
  call _get_keys
	call updateDT
	call updateST
main_loop_draw:
  ;; Draw the display
  ;; at the window
  call BeginDrawing
  mov edi, dword [BLACK]
  call ClearBackground
  call _draw_display
  call EndDrawing
  jmp main_loop
main_loop_end:
  call unloadBeepSound
  call CloseWindow
  ;; end
  leave
  ret


arg_error:
  ;; This will be only
  ;; executed if the 
  ;; number of arguments
  ;; is incorrect
  mov rdi, STD_OUT
  mov rsi, arg_msg
  mov rdx, 38
  mov rax, SYS_WRITE
  syscall
  mov rax, SYS_EXIT
  mov rdi, 1
  syscall
