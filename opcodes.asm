section .data
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
  movzx r8, word [cpu_pc]
  add r8w, 2
  mov [cpu_pc], word r8w
%endmacro

;; 00E0 - CLS
global _cls
_cls:
  mov rdi, cpu_display
  mov rsi, 0
  mov rdx, 2048
  call memset
  mov rdi, cpu_draw
  mov [rdi], byte 1
  INC_PC
  ret


;; 00EE - RET
;; Return from a subroutine.
global _ret
_ret:
  mov rax, [cpu_sp]
  sub rax, 1
  mov [cpu_sp], byte al
  mov rdi, cpu_stack
  add rdi, rax
  mov rdx, [rdi]
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
  movzx rdx, byte [cpu_sp]
  mov rsi, cpu_stack
  add rsi, rdx
  mov ax, [cpu_pc]
  mov [rsi], ax
  add rdx, 2
  mov [cpu_sp], dl
  mov [cpu_pc], di
  ret


;; 3xkk - SE Vx, byte
;; Skip next instruction if Vx = kk.
;; rdi = x
;; rsi = byte
global _se_vx_byte
_se_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  movzx rax, byte [rdx]
  movzx rdx, word [cpu_pc]
  cmp al, sil
  jne end_3xkk 
  add dx, 2
end_3xkk:
  add dx, 2
  mov [cpu_pc], dx
  ret


;; 4xkk - SNE Vx, byte
;; Skip next instruction if Vx != kk.
;; rdi = x
;; rsi = byte
global _sne_vx_byte
_sne_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  movzx rax, byte [rdx]
  movzx rdx, word [cpu_pc]
  cmp al, sil
  je end_4xkk 
  add dx, 2
end_4xkk:
  add dx, 2
  mov [cpu_pc], dx
  ret


;; 5xy0 - SE Vx, Vy
;; Skip next instruction if Vx = Vy.
;; rdi = x
;; rsi = y
global _se_vx_vy
_se_vx_vy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  movzx rbx, word [cpu_pc]
  cmp rdx, rax 
  jne end_5xy0
  add bx, 2
end_5xy0:
  add bx, 2
  mov [cpu_pc], bx
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
  mov al, byte [rdx]
  add al, sil
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
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  movzx rax, byte [rax]
  mov [rdx], byte al
  INC_PC
  ret


;; 8xy1 - OR Vx, Vy
;; Set Vx = Vx OR Vy.
;; rdi = x
;; rsi = y
global _or_vx_xy
_or_vx_xy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  mov rbx, rdx
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  or  al, dl
  mov [rbx], byte al
  mov rdx, cpu_v
  add rdx, 0xF
  mov [rdx], byte 0
  INC_PC
  ret


;; 8xy2 - AND Vx, Vy
;; Set Vx = Vx AND Vy.
;; rdi = x
;; rsi = y
global _and_vx_xy
_and_vx_xy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  mov rbx, rdx
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  and al, dl
  mov [rbx], byte al
  mov rdx, cpu_v
  add rdx, 0xF
  mov [rdx], byte 0
  INC_PC
  ret


;; 8xy3 - XOR Vx, Vy
;; Set Vx = Vx XOR Vy.
;; rdi = x
;; rsi = y
global _xor_vx_xy
_xor_vx_xy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  mov rbx, rdx
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  xor al, dl
  mov [rbx], byte al
  mov rdx, cpu_v
  add rdx, 0xF
  mov [rdx], byte 0
  INC_PC
  ret


;; 8xy4 - ADD Vx, Vy
;; Set Vx = Vx + Vy, set VF = carry.
;; rdi = x
;; rsi = y
global _add_vx_vy
_add_vx_vy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  mov rbx, rdx
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  mov rcx, cpu_v
  add rcx, 0xF
  add dl, al
  jnc ncarry_8xy4
  mov [rcx], byte 1
  jmp end_8xy4
ncarry_8xy4:
  mov [rcx], byte 0
end_8xy4: 
  mov [rbx], byte dl  
  INC_PC
  ret


;; 8xy5 - SUB Vx, Vy
;; Set Vx = Vx - Vy, set VF = NOT borrow.
;; rdi = x
;; rsi = y
global _sub_vx_vy
_sub_vx_vy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  mov rbx, rdx
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  mov rcx, cpu_v
  add rcx, 0xF
  sub dl, al
  jnc ncarry_8xy5
  mov [rcx], byte 0
  jmp end_8xy5
ncarry_8xy5:
  mov [rcx], byte 1
end_8xy5: 
  mov [rbx], byte dl  
  INC_PC
  ret


;; 8xy6 - SHR Vx {, Vy}
;; Set Vx = Vx SHR 1.
;; rdi = x
global _shr_vx
_shr_vx:
  mov rsi, cpu_v
  add rsi, rdi
  mov rax, rsi
  mov rbx, cpu_v
  add rbx, 0xF
  movzx rsi, byte [rsi]
  shr sil, 1
  jnc noverflow_8xy6
  mov [rbx], byte 1  
  jmp end_8xy6
noverflow_8xy6:
  mov [rbx], byte 0
end_8xy6:
  mov [rax], byte sil
  INC_PC
  ret


;; 8xy7 - SUBN Vx, Vy
;; Set Vx = Vy - Vx, set VF = NOT borrow.
;; rdi = x
;; rsi = y
global _subn_vx_vy
_subn_vx_vy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  mov rbx, rdx
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  mov rcx, cpu_v
  add rcx, 0xF
  sub al, dl
  jnc ncarry_8xy7
  mov [rcx], byte 0
  jmp end_8xy7
ncarry_8xy7:
  mov [rcx], byte 1
end_8xy7: 
  mov [rbx], byte al  
  INC_PC
  ret


;; 8xyE - SHL Vx {, Vy}
;; Set Vx = Vx SHL 1.
;; rdi = x
global _shl_vx
_shl_vx:
  mov rsi, cpu_v
  add rsi, rdi
  mov rax, rsi
  mov rbx, cpu_v
  add rbx, 0xF
  movzx rsi, byte [rsi]
  shl sil, 1
  jnc noverflow_9xy6
  mov [rbx], byte 1  
  jmp end_9xy6
noverflow_9xy6:
  mov [rbx], byte 0
end_9xy6:
  mov [rax], byte sil
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
