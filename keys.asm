extern IsKeyDown
extern cpu_keypad

section .data
  ; Keypad mappings to QWERTY
  keys  dd 88, 321, 322, 323
        dd 81, 87, 69, 65
        dd 83, 68, 90, 67
        dd 324, 82, 70, 86

section .text
global _get_keys
_get_keys:
  push rbp
  mov rbp, rsp
  sub rsp, 1
  mov byte [rbp-1], 0

loop_keys:
  movzx rax, byte [rbp-1]
  lea rdx, [rax*4]
  mov edi, dword [keys + rdx]
  call IsKeyDown
  mov edx, eax

  movzx rax, byte [rbp-1]
  mov byte [cpu_keypad + rax], dl
  add al, 1
  mov byte [rbp-1], al

  cmp eax, 0xF
  jbe loop_keys
  leave
  ret
