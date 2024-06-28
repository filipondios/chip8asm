extern InitWindow
extern SetTargetFPS
extern WindowShouldClose
extern BeginDrawing
extern ClearBackground
extern EndDrawing
extern CloseWindow

section .data
  win_title  db "Window Title"
  win_width  dd 800
  win_height dd 800
  win_fps    dd 10
  color_black	db 0,0,0,255

section .text
global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 16

  mov edi, [win_width]
  mov esi, [win_height]
  mov rdx, win_title
  call InitWindow

  mov edi, [win_fps]
  call SetTargetFPS

loop_begin:
  call WindowShouldClose
  cmp eax, 0
  jne loop_end

  call BeginDrawing
  mov edi, [color_black]
  call ClearBackground
  call EndDrawing
  jmp loop_begin

loop_end:
  call CloseWindow
  add rsp, 16
  mov rsp, rbp
  pop rbp
  ret
