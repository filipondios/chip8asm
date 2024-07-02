extern IsKeyDown
extern cpu_keypad
extern printf

section .data
  ;; Keypad mapping to QWERTY
  keys: dw  88, 321, 322, 323
        dw  81,  87,  69,  65
        dw  83,  68,  90,  67
        dw 324,  82,  70,  86
  format: db "%d",0
  endline: db "\n",0 

section .text
global _get_keys
_get_keys:
  ;mov rsi, cpu_keypad
  xor rdx, rdx
loop_get_keys:
  movzx rdi, word [keys + rdx]
  call IsKeyDown
  mov [cpu_keypad + rdx], byte al
  inc dl
  cmp dl, 0xF
  jle loop_get_keys
  ret
