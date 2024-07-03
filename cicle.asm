%include "opcodes.asm"

section .text
global _exec_cicle
_exec_cicle:
  ;; Fetch next instruction
  mov rax, cpu_ram
  movzx rbx, word [cpu_pc]
  add rax, rbx
  movzx rax, word [rax]

  ;; Get first nibble
  mov rbx, rax
  and rbx, 0xF000
  shr rbx, 12

  ;; Big switch statement
  cmp bx, 0x0
  jne maybe_0x1
maybe_00e0:
  cmp rax, 0x00E0
  jne maybe_00ee
  call _cls
  ret
maybe_00ee:
  cmp rax, 0x00EE
  jne opcode_error
  call _ret
  ret

maybe_0x1: 
  cmp bx, 0x1
  jne maybe_0x2
  mov rdi, rax
  and rdi, 0x0FFF
  call _jp_addr
  ret

maybe_0x2:
  cmp bx, 0x2
  jne maybe_0x3
  mov rdi, rax
  and rdi, 0x0FFF
  call _call_addr
  ret

maybe_0x3:
  cmp bx, 0x3
  jne maybe_0x4
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00FF
  call _se_vx_byte
  ret

maybe_0x4:
  cmp bx, 0x4
  jne maybe_0x5
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00FF
  call _sne_vx_byte
  ret

maybe_0x5:
  cmp bx, 0x5
  jne maybe_0x6
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00F0
  shr rsi, 4
  call _se_vx_vy
  ret

maybe_0x6:
  cmp bx, 0x6
  jne maybe_0x7
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00FF
  call _ld_vx_byte
  ret

maybe_0x7:
  cmp bx, 0x7
  jne maybe_0x8
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00FF
  call _add_vx_byte
  ret

maybe_0x8:
  cmp bx, 0x8
  jne maybe_0x9
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00F0
  shr rsi, 4
  mov rbx, rax
  and rbx, 0x000F
maybe_8xy0:
  cmp bl, 0x0
  jne maybe_8xy1
  call _ld_vx_vy
  ret
maybe_8xy1:
  cmp bl, 0x1
  jne maybe_8xy2
  call _or_vx_vy
  ret
maybe_8xy2:
  cmp bl, 0x2
  jne maybe_8xy3
  call _and_vx_vy
  ret
maybe_8xy3:
  cmp bl, 0x3
  jne maybe_8xy4
  call _xor_vx_vy
  ret
maybe_8xy4:
  cmp bl, 0x4
  jne maybe_8xy5
  call _add_vx_vy
  ret
maybe_8xy5:
  cmp bl, 0x5
  jne maybe_8xy6
  call _sub_vx_vy
  ret
maybe_8xy6:
  cmp bl, 0x6
  jne maybe_8xy7
  call _shr_vx
  ret
maybe_8xy7:
  cmp bl, 0x7
  jne maybe_8xye
  call _subn_vx_vy
  ret
maybe_8xye:
  cmp bl, 0xe
  jne opcode_error
  call _shl_vx
  ret

maybe_0x9:
  cmp bx, 0x9
  jne maybe_0xA
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00F0
  shr rsi, 4
  call _sne_vx_vy
  ret

maybe_0xA:
  cmp bx, 0xA
  jne maybe_0xB
  mov rdi, rax
  and rdi, 0x0FFF
  call _ld_i_addr
  ret

maybe_0xB:
  cmp bx, 0xB
  jne maybe_0xC
  mov rdi, rax
  and rdi, 0x0FFF
  call _jp_v0_addr
  ret

maybe_0xC:
  cmp bx, 0xC
  jne maybe_0xD
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00FF
  call _rnd_vx_byte
  ret

maybe_0xD:
  cmp bx, 0xD
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  mov rsi, rax
  and rsi, 0x00F0
  shr rsi, 4
  mov rdx, rax
  and rdx, 0x000F
  call _drw_vx_vy_nibble
  ret

maybe_0xE:
  cmp bx, 0xE
  jne maybe_0xF
  mov rbx, rax
  and rbx, 0x00FF
  cmp bl, 0x9E
  jne maybe_exa1
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  call _skp_vx
  ret
maybe_exa1:
  cmp bl, 0xA1
  jne opcode_error
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  call _sknp_vx
  ret

maybe_0xF:
  cmp bx, 0xF
  jne opcode_error
  mov rbx, rax
  and rbx, 0x00FF
  mov rdi, rax
  and rdi, 0x0F00
  shr rdi, 8
  cmp bl, 0x07
  jne maybe_fx0a
  call _ld_vx_dt
  ret
maybe_fx0a:
  cmp bl, 0x0A
  jne maybe_fx15
  call _ld_vx_k
  ret
maybe_fx15:
  cmp bl, 0x15
  jne maybe_fx18
  call _ld_dt_vx
  ret
maybe_fx18:
  cmp bl, 0x18
  jne maybe_fx1E
  call _ld_st_vx
  ret
maybe_fx1E:
  cmp bl, 0x1E
  jne maybe_fx29  
  call _add_i_vx
  ret
maybe_fx29:
  cmp bl, 0x29
  jne maybe_fx33  
  call _ld_f_vx
  ret
maybe_fx33:
  cmp bl, 0x33
  jne maybe_fx55  
  call _ld_b_vx
  ret
maybe_fx55:
  cmp bl, 0x55
  jne maybe_fx65  
  call _ld_i_vx
  ret
maybe_fx65:
  cmp bl, 0x65
  jne opcode_error
  call _ld_vx_i
  ret

opcode_error:
  ;; Print & exit
  mov rdi, 0
  mov rax, 60
  syscall
