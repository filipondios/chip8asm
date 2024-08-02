extern DrawRectangle
extern cpu_display

section .data 
  BLACK db 0, 0, 0, 255
  WHITE db 255, 255, 255, 255

section .text
global _draw_display
_draw_display:
  push rbp
  mov rbp, rsp
  sub rsp, 16

  mov r10, 0
  mov dword [rbp-4], 0

loop_start:
  mov eax, dword [rbp-4]
  cmp eax, 2048
  jge loop_end

  movzx eax, byte [cpu_display + rax]
  test al, al
  je next_iteration

  ;; get (it/64)*30
  mov eax, dword [rbp-4]
  mov edx, eax
  shr edx, 6        
  imul edx, edx, 30

  ;; get (it%64)*30
  mov ecx, eax
  and ecx, 63
  imul ecx, ecx, 30

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
  mov edx, 30
  mov ecx, 30
  call DrawRectangle

next_iteration:
  add dword [rbp-4], 1
  jmp loop_start

loop_end:
  leave
  ret
