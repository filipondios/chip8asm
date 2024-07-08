
extern IsKeyDown
extern cpu_keypad

section .data
  ; Keypad mappings to QWERTY
  keys  dd  88, 321, 322, 323
        dd  81,  87,  69,  65
        dd  83,  68,  90,  67
        dd 324,  82,  70,  86

section .text
global _get_keys
_get_keys:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  xor rcx, rcx
loop_keys:
  lea rdx, [rcx*4]
  mov edi, dword [keys + rdx]
  call IsKeyDown
  mov edx, eax

  mov byte [cpu_keypad + rcx], dl
  add cl, 1

  cmp cl, 0xF
  jle loop_keys
  leave
  ret
