section .data
extern memset
extern cpu_display
extern cpu_ram
extern cpu_stack
extern cpu_v
extern cpu_keypad
extern cpu_i
extern cpu_dt
extern cpu_st
extern cpu_pc
extern cpu_sp
extern cpu_draw

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
;; rdi = x
;; rsi = y
global _sne_vx_vy
_sne_vx_vy:
  mov rdx, cpu_v
  mov rax, cpu_v
  add rdx, rdi
  add rax, rsi
  movzx rdx, byte [rdx]
  movzx rax, byte [rax]
  movzx rbx, word [cpu_pc]
  cmp rdx, rax 
  je end_9xy0
  add bx, 2
end_9xy0:
  add bx, 2
  mov [cpu_pc], bx
  ret


;; Annn - LD I, addr
;; Set I = nnn.
;; rdi = addr
global _ld_i_addr
_ld_i_addr:
  mov [cpu_i], word di
  INC_PC
  ret


;; Bnnn - JP V0, addr
;; Jump to location nnn + V0.
;; rdi = addr
global _jp_v0_addr
_jp_v0_addr:
  mov rsi, cpu_v
  movzx rsi, byte [rsi]
  add si, di
  mov [cpu_pc], word si
  ret


;; Cxkk - RND Vx, byte
;; Set Vx = random byte AND kk.
;; rdi = x
;; rsi = y
global _rnd_vx_byte
_rnd_vx_byte:
  mov rdx, cpu_v
  add rdx, rdi
  rdrand ax
  and al, sil
  mov [rdx], byte al
  INC_PC
  ret


;; TODO ;; TODO !!
;; Dxyn - DRW Vx, Vy, nibble
;; Display n-byte sprite
global _drw_vx_vy_nibble
_drw_vx_vy_nibble:
  ret


;; Ex9E - SKP Vx
;; Skip next instruction if key Vx is pressed.
;; rdi = x
global _skp_vx:
_skp_vx:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rsi, byte [rsi] ;; vx
  mov rax, cpu_keypad
  add rax, rsi
  movzx rax, byte [rax]
  movzx rdx, word [cpu_pc]
  cmp rax, 1
  jne end_ex9e
  add dx, 2
end_ex9e:
  add dx, 2
  mov [cpu_pc], word dx
  ret


;; ExA1 - SKNP Vx
;; Skip next instruction if key Vx is not pressed.
;; rdi = x
global _sknp_vx:
_sknp_vx:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rsi, byte [rsi]
  mov rax, cpu_keypad
  add rax, rsi
  movzx rax, byte [rax]
  movzx rdx, word [cpu_pc]
  cmp rax, 1
  je end_exa1
  add dx, 2
end_exa1:
  add dx, 2
  mov [cpu_pc], word dx
  ret


;; Fx07 - LD Vx, DT
;; Set Vx = delay timer value.
;; rdi = x
global _ld_vx_dt
_ld_vx_dt:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rdx, byte [cpu_dt]
  mov [rsi], dl
  INC_PC
  ret


;; Fx0A - LD Vx, K
;; Wait for a key press, store key in Vx.
;; rdi = x
global _ld_vx_k
_ld_vx_k:
  mov rsi, cpu_keypad
  xor rax, rax
loop_fx0a:
  movzx rdx, byte [rsi + rax]
  cmp dl, 0
  jne keyp_fx0a
  inc al
  cmp al, 0x10
  jl loop_fx0a
  jmp end_fx0a
keyp_fx0a:
  mov rsi, cpu_v
  add rsi, rdi
  mov [rsi], al
  INC_PC
end_fx0a:
  ret


;; Fx15 - LD DT, Vx
;; Set delay timer = Vx.
;; rdi = x
global _ld_dt_vx
_ld_dt_vx:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rdx, byte [rsi]
  mov [cpu_dt], dl
  INC_PC
  ret


;; Fx18 - LD ST, Vx
;; Set sound timer = Vx.
;; rdi = x
global _ld_st_vx
_ld_st_vx:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rdx, byte [rsi]
  mov [cpu_st], dl
  INC_PC
  ret


;; Fx1E - ADD I, Vx
;; Set I = I + Vx.
;; rdi = x
global _add_i_vx
_add_i_vx:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rsi, byte [rsi]
  movzx rdx, word [cpu_i]
  mov rax, cpu_v
  add rax, 0xF 
  add dx, si
  cmp dx, 0xFFF
  jg  outaddr_fx1e
  mov [rax], byte 0
  jmp end_fx1e 
outaddr_fx1e:
  mov [rax], byte 1
end_fx1e:
  mov [cpu_i], word dx
  INC_PC
  ret


;; Fx29 - LD F, Vx
;; Set I = location of sprite for digit Vx.
;; rdi = x
global _ld_f_vx
_ld_f_vx:
  mov rsi, cpu_v
  add rsi, rdi
  movzx rsi, byte [rsi]
  mov rax, rsi
  shl sil, 2
  add sil, al
  mov [cpu_i], word si
  INC_PC
  ret


;; TODO
;; Fx33 - LD B, Vx
;; Store BCD representation of Vx at I, I+1, and I+2.
global _ld_b_vx
_ld_b_vx:
  ret


;; TODO
;; Fx55 - LD [I], Vx
;; Store registers V0 through Vx at I.
global _ld_i_vx
_ld_i_vx:
  ret


;; TODO
;; Fx65 - LD Vx, [I]
;; Read registers V0 through Vx from I.
global _ld_vx_i
_ld_vx_i:
  ret
