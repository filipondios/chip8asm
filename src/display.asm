extern DrawRectangle
extern cpu_display
extern scale

section .data 
  BLACK db 0, 0, 0, 255
  WHITE db 255, 255, 255, 255

section .text
global _draw_display
_draw_display:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  mov dword [rbp-4], 0

loop_start:
  mov eax, dword [rbp-4]
  cmp eax, 2048
  jge loop_end

  movzx eax, byte [cpu_display + rax]
  test al, al
  je next_iteration

  ;; get (it/64)*scale
  mov r10d, dword [scale]
  mov eax, dword [rbp-4]
  mov edx, eax
  shr edx, 6
  imul edx, r10d

  ;; get (it%64)*scale
  mov ecx, eax
  and ecx, 63
  imul ecx, r10d

  movzx eax, byte [cpu_display + rax]
  cmp al, 0
  je pixel_zero
  mov r8d, dword [WHITE]
  jmp draw_pixel
pixel_zero:
  mov r8d, dword [BLACK]

draw_pixel:
  mov edi, ecx
  mov esi, edx
  mov edx, r10d
  mov ecx, r10d
  call DrawRectangle

next_iteration:
  add dword [rbp-4], 1
  jmp loop_start

loop_end:
  leave
  ret
