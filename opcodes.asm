extern memset
extern cpu_v
extern cpu_display
extern cpu_sp
extern cpu_pc
extern cpu_draw
extern cpu_stack

section .text

;; Increase pc
%macro INC_PC 0
  mov r8, [cpu_pc]
  add r8, 2
  mov [cpu_pc], word r8w
%endmacro

;; 00E0 - CLS
global _cls
_cls:
  ;; memset(display, 0)
  mov rdi, cpu_display
  mov rsi, 0
  mov rdx, 2048
  call memset
  mov [cpu_draw], 1
  INC_PC
  ret


;; 00EE - RET
;; Return from a subroutine.
global _ret
_ret:
  ;; sp --
  mov rax, [cpu_sp]
  sub rax, 2
  mov [cpu_sp], byte al
  ;; pc = stack[sp]
  mov rdi, cpu_stack
  add rdi, rax
  mov rdx, [rdi]
  ;; pc += 2
  add rdx, 2
  mov [cpu_pc], word dx
  ret


;; 1nnn - JP addr
;; Jump to location nnn.
global _jp_addr
_jp_addr:
  mov [cpu_pc], word di
  ret

;; 2nnn - CALL addr
;; Call subroutine at nnn.
;; rdi = nnn
global _call_addr
_call_addr:
  ;; stack[sp] = pc
  mov rsi, cpu_stack
  mov rdx, [cpu_sp]
  add rsi, rdx
  mov rax, [cpu_pc]
  mov [rsi], word ax
  ;; pc = nnn
  mov [cpu_pc], rdi
  ret


;; 3xkk - SE Vx, byte
;; Skip next instruction if Vx = kk.
;; rdi = x
;; rsi = byte
global _se_vx_byte
_se_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  mov rdx, [rdx]
  mov rax, [cpu_pc]
  cmp rdx, rsi
  jne end
  add rax, 2
end:
  add rax, 2
  mov [cpu_pc], word ax
  ret


;; 4xkk - SNE Vx, byte
;; Skip next instruction if Vx != kk.
;; rdi = x
;; rsi = byte
global _sne_vx_byte
_sne_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  mov rdx, [rdx]
  mov rax, [cpu_pc]
  cmp rdx, rsi
  je  end
  add rax, 2
end:
  add rax, 2
  mov [cpu_pc], word ax
  ret


;; 5xy0 - SE Vx, Vy
;; Skip next instruction if Vx = Vy.
;; rdi = x
;; rsi = y
global _se_vx_xy
_se_vx_vy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  mov rdx, [rdx]
  add rax, rsi
  mov rax, [rax]
  mov rbx, [cpu_pc]
  cmp rdx, rax
  jne end
  add rdx, 2
end:
  add rdx, 2
  mov [cpu_pc], word dx
  ret


;; 6xkk - LD Vx, byte
;; Set Vx = kk.
;; rdi = x
;; rsi = byte
global _ld_vx_byte
_ld_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  mov [rdx], byte sil
  INC_PC
  ret


;; 7xkk - ADD Vx, byte
;; Set Vx = Vx + kk.
;; rdi = x
;; rsi = byte
global _add_vx_byte;
_add_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  mov rax, [rdx]
  add rax, rsi
  mov [rdx], byte al
  INC_PC
  ret


;; 8xy0 - LD Vx, Vy
;; Set Vx = Vy.
;; rdi = x
;; rsi = y
global _ld_vx_vy:
_ld_vx_vy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rax, [rax]
  mov rdx, byte al
  INC_PC
  ret


;; 8xy1 - OR Vx, Vy
;; Set Vx = Vx OR Vy.
;; rdi = x
;; rsi = y
global _or_vx_xy
_or_vx_xy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rbx, [rdx]
  mov rax, [rax]
  or  bl, al
  mov [rdx], byte bl
  INC_PC
  ret


;; 8xy2 - AND Vx, Vy
;; Set Vx = Vx AND Vy.
;; rdi = x
;; rsi = y
global _and_vx_xy
_and_vx_xy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rbx, [rdx]
  mov rax, [rax]
  and bl, al
  mov [rdx], byte bl 
  INC_PC
  ret


;; 8xy3 - XOR Vx, Vy
;; Set Vx = Vx XOR Vy.
;; rdi = x
;; rsi = y
global _xor_vx_xy
_xor_vx_xy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rbx, [rdx]
  mov rax, [rax]
  xor bl, al
  mov [rdx], byte bl  
  INC_PC
  ret

;; 8xy4 - ADD Vx, Vy
;; Set Vx = Vx + Vy, set VF = carry.
;; rdi = x
;; rsi = y
global _add_vx_vy
_add_vx_vy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rbx, [rdx]
  mov rax, [rax]
  mov rcx, cpu_v
  add rcx, 0xF
  add bl, al
  jnc ncarry
  mov [rcx], 1
  jmp end
ncarry:
  mov [rcx], 0
end: 
  mov [rdx], byte bl  
  INC_PC
  ret


;; 8xy5 - SUB Vx, Vy
;; Set Vx = Vx - Vy, set VF = NOT borrow.
;; rdi = x
;; rsi = y
global _sub_vx_vy
_sub_vx_vy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rbx, [rdx]
  mov rax, [rax]
  mov rcx, cpu_v
  add rcx, 0xF
  sub bl, al
  jnc ncarry
  mov [rcx], 0
  jmp end
ncarry:
  mov [rcx], 1
end: 
  mov [rdx], byte bl  
  INC_PC
  ret


;; 8xy6 - SHR Vx {, Vy}
;; Set Vx = Vx SHR 1.
;; rdi = x
global _shr_vx
_shr_vx:
  mov rsi, cpu_v
  mov rax, rsi
  add rax, 0xF
  add rsi, rdi
  mov rdx, [rsi]
  shr dl, 1
  jnc ncarry
  mov [rax], 1  
  jmp end
ncarry:
  mov [rax], 0
end:
  mov [rsi], byte dl
  INC_PC
  ret


;; 8xy7 - SUBN Vx, Vy
;; Set Vx = Vy - Vx, set VF = NOT borrow.
;; rdi = x
;; rsi = y
global _subn_vx_vy
_subn_vx_vy:
  mov rdx, cpu_v
  mov rax, rdx
  add rdx, rdi
  add rax, rsi
  mov rbx, [rdx]
  mov rax, [rax]
  mov rcx, cpu_v
  add rcx, 0xF
  sub al, bl
  jnc ncarry
  mov [rcx], 0
  jmp end
ncarry:
  mov [rcx], 1
end: 
  mov [rdx], byte al  
  INC_PC
  ret


;; 8xyE - SHL Vx {, Vy}
;; Set Vx = Vx SHL 1.
;; rdi = x
global _shl_vx
_shl_vx:
  mov rsi, cpu_v
  mov rax, rsi
  add rax, 0xF
  add rsi, rdi
  mov rdx, [rsi]
  shl dl, 1
  jnc ncarry
  mov [rax], 1  
  jmp end
ncarry:
  mov [rax], 0
end:
  mov [rsi], byte dl
  INC_PC
  ret


;; 9xy0 - SNE Vx, Vy
;; Skip next instruction if Vx != Vy.

;; Annn - LD I, addr
;; Set I = nnn.

;; Bnnn - JP V0, addr
;; Jump to location nnn + V0.

;; Cxkk - RND Vx, byte
;; Set Vx = random byte AND kk.

;; Dxyn - DRW Vx, Vy, nibble
;; Display n-byte sprite

;; Ex9E - SKP Vx
;; Skip next instruction if key Vx is pressed.

;; ExA1 - SKNP Vx
;; Opposite to Ex9E

;; Fx07 - LD Vx, DT
;; Set Vx = delay timer value.

;; Fx0A - LD Vx, K
;; Wait for a key press, store key in Vx.

;; Fx15 - LD DT, Vx
;; Set delay timer = Vx.

;; Fx18 - LD ST, Vx
;; Set sound timer = Vx.

;; Fx1E - ADD I, Vx
;; Set I = I + Vx.

;; Fx29 - LD F, Vx
;; Set I = location of sprite for digit Vx.

;; Fx33 - LD B, Vx
;; Store BCD representation of Vx at I, I+1, and I+2.

;; Fx55 - LD [I], Vx
;; Store registers V0 through Vx at I.

;; Fx65 - LD Vx, [I]
;; Read registers V0 through Vx from I.
