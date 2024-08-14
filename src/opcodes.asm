;; Extern functions
extern memset
extern memcpy
;; Cpu features
extern cpu_display
extern cpu_memory
extern cpu_stack
extern cpu_v
extern cpu_keypad
extern cpu_i
extern cpu_dt
extern cpu_st
extern cpu_pc
extern cpu_sp
extern cpu_error
;; Errors
extern RETURN_EMPTY_STACK
extern STACK_OVERFLOW
extern ACCESS_PRIV_MEMORY
extern ACCESS_OUTB_MEMORY
extern ACCESS_OUTB_REG

section .data
  PROG_BEGIN   equ 0x200
  PROG_END     equ 0xfff
  STACK_TOP    equ 32
  STACK_BOTTOM equ 0

section .text

;; Increase pc
%macro INC_PC 0
  mov ax, word [cpu_pc]
  add ax, 2
  mov word [cpu_pc], ax
%endmacro

;; 00E0 - CLS
global _cls
_cls:
  push rbp
  mov rbp, rsp                    ;; The cls function must clear all the pixels  
  sub rsp, 16                     ;; display buffer (set a black screen).
  ;; begin                        ;; ==========================================
  mov rdi, cpu_display            ;; rdi = cpu_display
  mov esi, 0                      ;; esi = 0
  mov edx, 2048                   ;; edx = 2048 = sizeof(cpu_display)
  call memset                     ;; memset(cpu_display, 0, 2048)
  INC_PC                          ;; cpu_pc += 2
  ;; end
  leave
  ret


;; 00EE - RET
;; Return from a subroutine.
global _ret
_ret:
  push rbp                        ;; This function recovers an address from 
  mov rbp, rsp                    ;; the stack and sets the pc to that value.
  ;; begin                        ;; ==========================================
  movzx rax, byte [cpu_sp]        ;; rax = cpu_sp
  cmp al, STACK_BOTTOM            ;; cpu_sp == 0? -> exit. Else continue.
  jne cont_00ee                   ;; If zero, exit the program.
  mov byte [cpu_error], RETURN_EMPTY_STACK ;; Save error 
  jmp end_00ee                    ;; just end the function
cont_00ee:                        ;; This will only be executed if cpu_sp != 0
  sub al, 2                       ;; cpu_sp -= 2
  mov dx, word [cpu_stack + rax]  ;; dx = cpu_stack[cpu_sp] = cpu_pc
  add dx, 2                       ;; dx += 2 = cpu_pc += 2
  mov word [cpu_pc], dx           ;; update cpu_pc
  mov byte [cpu_sp], al           ;; update cpu_sp
end_00ee:
  ;; end
  leave
  ret


;; 1nnn - JP addr
;; Jump to location addr.
;; rdi = addr
global _jp_addr
_jp_addr:
  push rbp                        ;; The jump function sets the program counter 
  mov rbp, rsp                    ;; to a specific address (0x0-0xfff).
  ;; begin                        ;; ==========================================
  cmp di, PROG_BEGIN              ;; Ilegal memory access where addr < 0x200?
  jge cont_1nnn                   ;; If not, continue. Else, exit(addr)
  mov byte [cpu_error], ACCESS_PRIV_MEMORY ;; Note a error has occurred
  jmp end_1nnn                    ;; Skip code
cont_1nnn:                        ;; Only if rdi >= 0x200
  mov word [cpu_pc], di           ;; update pc = rdi = addr 
end_1nnn:
  ;; end
  leave
  ret


;; 2nnn - CALL addr
;; Call subroutine at nnn.
;; rdi = nnn
global _call_addr
_call_addr:
  push rbp                        ;; Sets the pc to an address, saving the 
  mov rbp, rsp                    ;; current pc at the top of the stack.
  ;; begin                        ;; ==========================================
  movzx rdx, byte [cpu_sp]        ;; rdx = cpu_sp
  cmp dl, STACK_TOP               ;; Is the sp pointing inside the stack?
  jl cont_2nnn                    ;; If it is, continue. Else stack overflow error 
  mov byte [cpu_error], STACK_OVERFLOW ;; Note the error
  jmp end_2nnn                    ;; end function
cont_2nnn:                        ;; Only if the sp is pointing inside the stack
  cmp di, PROG_BEGIN              ;; nnn < 0x200?
  jge just_2nnn                   ;; If greater or equal continue. Else error.
  mov byte [cpu_error], ACCESS_PRIV_MEMORY ;; Note the error
  jmp end_2nnn                    ;; end function
just_2nnn:                        ;; Only if the call is legal
  mov ax, word [cpu_pc]           ;; ax = pc
  mov word [cpu_stack + rdx], ax  ;; stack[sp] = ax = pc
  add dl, 2                       ;; sp++
  mov byte [cpu_sp], dl           ;; update sp
  mov word [cpu_pc], di           ;; update pc
end_2nnn:
  ;; end
  leave
  ret


;; 3xkk - SE Vx, byte
;; Skip next instruction if Vx = kk.
;; rdi = x
;; rsi = byte
global _se_vx_byte
_se_vx_byte:
  push rbp                        ;; This function skips the next instruction
  mov rbp, rsp                    ;; (pc += 4) if v[x] == byte. Else (pc += 2).
  ;; begin                        ;; ==========================================
  mov al, byte [cpu_v + rdi]      ;; al = v[x]
  mov dx, word [cpu_pc]           ;; dx = pc
  cmp al, sil                     ;; v[x] == byte?
  jne end_3xkk                    ;; if it is, do pc += 2 now.
  add dx, 2                       ;; pc += 2
end_3xkk:                         ;; Inconditional
  add dx, 2                       ;; pc += 2
  mov word [cpu_pc], dx           ;; update pc
  ;; end
  leave
  ret


;; 4xkk - SNE Vx, byte
;; Skip next instruction if Vx != kk.
;; rdi = x
;; rsi = byte
global _sne_vx_byte
_sne_vx_byte:
  push rbp                        ;; This function skips the next instruction
  mov rbp, rsp                    ;; (pc += 4) if v[x] != byte. Else (pc += 2).
  ;; begin                        ;; ==========================================
  mov al, byte [cpu_v + rdi]      ;; al = v[x]
  mov dx, word [cpu_pc]           ;; dx = pc
  cmp al, sil                     ;; v[x] != byte?
  je end_4xkk                     ;; if it is, do pc += 2 now
  add dx, 2                       ;; pc += 2
end_4xkk:                         ;; Inconditional
  add dx, 2                       ;; pc += 2
  mov word [cpu_pc], dx           ;; update pc
  ;; end
  leave
  ret


;; 5xy0 - SE Vx, Vy
;; Skip next instruction if Vx = Vy.
;; rdi = x
;; rsi = y
global _se_vx_vy
_se_vx_vy:
  push rbp                        ;; This function skips the next instruction 
  mov rbp, rsp                    ;; (pc += 4) if v[x] == v[y]. Else (pc += 2).
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  mov bx, word [cpu_pc]           ;; bx = pc
  cmp dl, al                      ;; v[x] == v[y]?
  jne end_5xy0                    ;; if it is, do pc += 2 now
  add bx, 2                       ;; pc += 2
end_5xy0:                         ;; Inconditional 
  add bx, 2                       ;; pc += 2
  mov word [cpu_pc], bx           ;; update pc
  ;; end
  leave
  ret


;; 6xkk - LD Vx, byte
;; Set Vx = kk.
;; rdi = x
;; rsi = byte
global _ld_vx_byte
_ld_vx_byte:
  push rbp                        ;; Basically this function sets a register 
  mov rbp, rsp                    ;; v[x] to a value (byte).
  ;; begin                        ;; ==========================================
  mov byte [cpu_v + rdi], sil     ;; v[x] = sil = byte
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 7xkk - ADD Vx, byte
;; Set Vx = Vx + kk.
;; rdi = x
;; rsi = byte
global _add_vx_byte;
_add_vx_byte:
  push rbp                        ;; This function sets the a register v[x] =
  mov rbp, rsp                    ;; v[x] + byte, ignoring overflow.
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  add dl, sil                     ;; dl = v[x] += byte
  mov byte [cpu_v + rdi], dl      ;; update v[x]
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 8xy0 - LD Vx, Vy
;; Set Vx = Vy.
;; rdi = x
;; rsi = y
global _ld_vx_vy:
_ld_vx_vy:
  push rbp                        ;; This function simply sets a register v[x]
  mov rbp, rsp                    ;; the value of other register v[y].
  ;; begin                        ;; ==========================================
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  mov byte [cpu_v + rdi], al      ;; update v[x] = al = v[y]
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 8xy1 - OR Vx, Vy
;; Set Vx = Vx OR Vy.
;; rdi = x
;; rsi = y
global _or_vx_vy
_or_vx_vy:
  push rbp                        ;; Just sets a register v[x] the value 
  mov rbp, rsp                    ;; v[x] | v[y].
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  or  al, dl                      ;; al = v[x] | v[y]
  mov byte [cpu_v + rdi], al      ;; update v[x] to the new value
  mov byte [cpu_v + 0xF], 0       ;; set v[0xf] to 0
  INC_PC                          ;; pc += 2
  ;; end 
  leave
  ret


;; 8xy2 - AND Vx, Vy
;; Set Vx = Vx AND Vy.
;; rdi = x
;; rsi = y
global _and_vx_vy
_and_vx_vy:
  push rbp                        ;; Just sets a register v[x] the value  
  mov rbp, rsp                    ;; v[x] & v[y].
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  and al, dl                      ;; al = v[x] & v[y]
  mov byte [cpu_v + rdi], al      ;; update v[x] to the new value
  mov byte [cpu_v + 0xF], 0       ;; set v[0xf] to 0
  INC_PC                          ;; pc += 2
  ;; end 
  leave
  ret


;; 8xy3 - XOR Vx, Vy
;; Set Vx = Vx XOR Vy.
;; rdi = x
;; rsi = y
global _xor_vx_vy
_xor_vx_vy:
  push rbp                        ;; This function sets a register v[x] the   
  mov rbp, rsp                    ;; value v[x] ^ v[y].
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  xor al, dl                      ;; al = v[x] ^ v[y]
  mov byte [cpu_v + rdi], al      ;; update v[x] to the new value
  mov byte [cpu_v + 0xF], 0       ;; set v[0xf] to 0
  INC_PC                          ;; pc += 2
  ;; end 
  leave
  ret


;; 8xy4 - ADD Vx, Vy
;; Set Vx = Vx + Vy, set VF = carry.
;; rdi = x
;; rsi = y
global _add_vx_vy
_add_vx_vy:
  push rbp                        ;; Basically sets v[x] to v[x] + v[y], 
  mov rbp, rsp                    ;; considering carry (result >255).
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  add dl, al                      ;; dl = v[x] + v[y]
  jnc ncarry_8xy4                 ;; If not carry, jump to v[0xf] = 0.
  mov byte [cpu_v + rdi], dl      ;; set v[x] = v[x] + v[y]
  mov byte [cpu_v + 0xF], 1       ;; set v[0xf] = 1
  jmp end_8xy4                    ;; jump to the update
ncarry_8xy4:                      ;; Only if there is no carry
  mov byte [cpu_v + rdi], dl      ;; set v[x] = v[x] + v[y]
  mov byte [cpu_v + 0xF], 0       ;; set v[0xf] = 0
end_8xy4:                         ;; Inconditional
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 8xy5 - SUB Vx, Vy
;; Set Vx = Vx - Vy, set VF = NOT borrow.
;; rdi = x
;; rsi = y
global _sub_vx_vy
_sub_vx_vy:
  push rbp                        ;; This instruction sets the register v[x] to
  mov rbp, rsp                    ;; the value v[x] - v[y], considering carry.
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  sub dl, al                      ;; dl = v[x] - v[y]
  jnc ncarry_8xy5                 ;; If not carry, jump to v[0xf] = 1
  mov byte [cpu_v + rdi], dl      ;; update v[x] to v[x] - v[y]
  mov byte [cpu_v + 0xF], 0       ;; set v[0xf] = 0
  jmp end_8xy5                    ;; jump to update v[x]
ncarry_8xy5:                      ;; Only if there is no carry
  mov byte [cpu_v + rdi], dl      ;; update v[x] to v[x] - v[y]
  mov byte [cpu_v + 0xF], 1       ;; set v[0xf] = 1
end_8xy5:                         ;; Inconditional
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 8xy6 - SHR Vx {, Vy}
;; Set Vx = Vy SHR 1.
;; rdi = x
;; rsi = y
global _shr_vx_vy
_shr_vx_vy:
  push rbp                        ;; This function just sets a register v[x]
  mov rbp, rsp                    ;; the value v[y] >> 1.
  ;; begin                        ;; ==========================================
  mov sil, byte [cpu_v + rsi]     ;; sil = v[y]
  shr sil, 1                      ;; sil = v[y] >> 1
  jnc noverflow_8xy6              ;; If no overflow, jump to v[0xf] = 0
  mov [cpu_v + rdi], byte sil     ;; v[x] = (v[y] >> 1)
  mov byte [cpu_v + 0xF], 1       ;; v[0xf] = 1
  jmp end_8xy6                    ;; Just skip v[0xf] = 0
noverflow_8xy6:                   ;; Only if no overflow
  mov [cpu_v + rdi], byte sil     ;; v[x] = (v[y] >> 1)
  mov byte [cpu_v + 0xF], 0       ;; v[0xf] = 0
end_8xy6:                         ;; Inconditional
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 8xy7 - SUBN Vx, Vy
;; Set Vx = Vy - Vx, set VF = NOT borrow.
;; rdi = x
;; rsi = y
global _subn_vx_vy
_subn_vx_vy:
  push rbp                        ;; This operation sets v[x] to the result of
  mov rbp, rsp                    ;; v[y] - v[x], considering carry.
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  sub al, dl                      ;; al = v[y] -= v[x]
  jnc ncarry_8xy7                 ;; If no carry, jump to v[0xf] = 1
  mov [cpu_v + rdi], byte al      ;; update v[x] to v[y] - v[x]
  mov byte [cpu_v + 0xF], 0       ;; v[0xf] = 0
  jmp end_8xy7                    ;; Skip v[0xf] = 1
ncarry_8xy7:                      ;; Only if no carry
  mov [cpu_v + rdi], byte al      ;; update v[x] to v[y] - v[x]
  mov byte [cpu_v + 0xF], 1       ;; v[0xf] = 1  
end_8xy7:                         ;; Inconditional
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 8xyE - SHL Vx {, Vy}
;; Set Vx = Vy SHL 1.
;; rdi = x
;; rsi = y
global _shl_vx_vy
_shl_vx_vy:
  push rbp                        ;; This function sets a register v[x] to the 
  mov rbp, rsp                    ;; result of v[y] << 1.
  ;; begin                        ;; ==========================================
  mov sil, byte [cpu_v + rsi]     ;; sil = v[y] 
  shl sil, 1                      ;; sil = v[y] << 1
  jnc noverflow_9xy6              ;; If no overflow, jump to v[0xf] = 0
  mov [cpu_v + rdi], byte sil     ;; update v[x] to v[y] << 1
  mov byte [cpu_v + 0xF], 1       ;; v[0xf] = 1
  jmp end_9xy6                    ;; Skip v[0xf] = 0
noverflow_9xy6:                   ;; Only if no carry
  mov [cpu_v + rdi], byte sil     ;; update v[x] to v[y] << 1
  mov byte [cpu_v + 0xF], 0       ;; v[0xf] = 0
end_9xy6:                         ;; Inconditional
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; 9xy0 - SNE Vx, Vy
;; Skip next instruction if Vx != Vy.
;; rdi = x
;; rsi = y
global _sne_vx_vy
_sne_vx_vy:
  push rbp                        ;; This function skips the next instruction
  mov rbp, rsp                    ;; (pc += 4) if v[x] != v[y].
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov al, byte [cpu_v + rsi]      ;; al = v[y]
  mov bx, word [cpu_pc]           ;; bx = pc
  cmp dl, al                      ;; v[x] == v[y]? Then pc += 2 now
  je end_9xy0                     ;; Skip one pc += 2
  add bx, 2                       ;; pc += 2
end_9xy0:                         ;; Inconditional
  add bx, 2                       ;; pc += 2
  mov word [cpu_pc], bx           ;; update pc
  ;; end
  leave
  ret


;; Annn - LD I, addr
;; Set I = nnn.
;; rdi = addr
global _ld_i_addr
_ld_i_addr:
  push rbp                        ;; This procedure only sets the I register
  mov rbp, rsp                    ;; to a 16 bit value (chip8 address).
  ;; begin                        ;; ==========================================
  mov word [cpu_i], di            ;; update I to the address
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Bnnn - JP V0, addr
;; Jump to location nnn + V0.
;; rdi = addr
global _jp_v0_addr
_jp_v0_addr:
  push rbp                        ;; This function must set the pc to the value
  mov rbp, rsp                    ;; of v[0] + addr.
  ;; begin                        ;; ==========================================
  movzx ax, byte [cpu_v]          ;; ax = v[0]
  add ax, di                      ;; ax = v[0] += addr 
  cmp ax, PROG_BEGIN              ;; ax >= 0x200? Then continue. Else error.
  jge cont_bnnn                   ;; Skip error if ax >= 0x200
  mov byte [cpu_error], ACCESS_PRIV_MEMORY ;; Note error
  jmp end_bnnn                    ;; End function
cont_bnnn:                        ;; Only if (v[0] + addr) >= 0x200
  cmp ax, PROG_END                ;; ax <= 0xfff? Then continue. Else error.
  jle just_bnnn                   ;; Jump to update pc if ax <= 0xfff
  mov byte [cpu_error], ACCESS_OUTB_MEMORY ;; Note error
  jmp end_bnnn                    ;; End function
just_bnnn:                        ;; Only if (v[0] + addr) and (v[0] + addr) < 0xfff
  mov word [cpu_pc], ax           ;; pc += (v[0] + addr)
end_bnnn:                         ;; Inconditional end
  ;; end
  leave
  ret


;; Cxkk - RND Vx, byte
;; Set Vx = random byte AND kk.
;; rdi = x
;; rsi = kk
global _rnd_vx_byte
_rnd_vx_byte:
  push rbp                        ;; Generates a random number and does the  
  mov rbp, rsp                    ;; bitwise 'and' operation with a byte.
  ;; begin                        ;; ==========================================
  rdrand ax                       ;; generate a 16 bit random
  and al, sil                     ;; Only use 8 bits and do bitwise 'and'
  mov byte [cpu_v + rdi], al      ;; update v[x] to (random & byte)
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret

;; Dxyn - DRW Vx, Vy, nibble
;; Display n-byte sprite
;; rdi = vx
;; rsi = vy
;; rdx = nibble
global _drw_vx_vy_nibble
_drw_vx_vy_nibble:
  push rbp                        ;; Complex function that draws a sprite from
  mov rbp, rsp                    ;; mem[I] 
  sub rsp, 16               
  ;; begin                        ;; ==========================================
  mov byte [rbp-8], dl            ;; [rbp-8] = nibble
  movzx rax, byte [cpu_v + rdi]   ;; rax = v[vx]
  mov byte [rbp-1], al            ;; [rbp-1] = x = v[vx]
  movzx rax, byte [cpu_v + rsi]   ;; rax = v[vy]
  mov byte [rbp-2], al            ;; [rbp-2] = y = v[vy]
  mov byte [rbp-3], 0             ;; [rbp-3] = it = 0
  mov byte [cpu_v + 0xF], 0       ;; v[0xf] = 0 
drw_it_loop:                      ;; loop it = 0; it < nibble; it++
  movzx rdi, byte [rbp-3]         ;; rdi = it
  movzx rsi, word [cpu_i]         ;; rsi = I
  movzx rsi, byte [rsi + rdi + cpu_memory] ;; rsi = memory[I+it] = sprite
  mov byte [rbp-4], sil           ;; [rbp-4] = sprite
  movzx rax, byte [rbp-2]         ;; rax = y
  movzx rdi, byte [rbp-3]         ;; rdi = it
  add ax, di                      ;; ax = y + it 
  and ax, 31                      ;; ax = (y + it)%32
  shl ax, 6                       ;; ax = ((y + it)%32)*64 = y_wrap coordinate
  mov word [rbp-6], ax            ;; [rbp-6] = y_wrap coordinate
  mov byte [rbp-7], 0             ;; [rbp-7] = jt = 0
drw_jt_loop:                      ;; loop jt = 0; jt < 8; jt++
  mov rdi, 0x80                   ;; rdi = 0x80 = 0b10000000
  movzx rcx, byte [rbp-7]         ;; rcx = jt
  shr di, cl                      ;; di = (0x80 << jt) = sprite bit
  movzx rax, byte [rbp-4]         ;; rax = sprite
  and di, ax                      ;; di = (0x80 << jt) & sprite
  cmp di, 0                       ;; is 'jt' bit in sprite 1?
  je drw_jt_loop_end              ;; If is 0, skip to next bit
  movzx rdi, byte [rbp-1]         ;; rdi = x
  movzx rsi, byte [rbp-7]         ;; rsi = jt
  add di, si                      ;; di = (x + jt)
  and di, 63                      ;; di = (x + jt)%64 = x_wrap coordinate
  movzx rsi, word [rbp-6]         ;; rsi = y_wrap
  add di, si                      ;; di = x_wrap + y_wrap = final index
  movzx rax, byte [cpu_display + rdi] ;; rax = display[index]
  cmp al, 1                       ;; al == 1? Then its a overwrite
  jne drw_no_overwrite            ;; If not, dont do v[0xf] = 1
  mov byte [cpu_v + 0xF], 1       ;; v[0xf] = 1
drw_no_overwrite:                 ;; Inconditional
  xor al, 1                       ;; display[index] ^= 1
  mov byte [cpu_display + rdi], al ;; update display[index]
drw_jt_loop_end:                  ;; End of jt loop?
  movzx rdi, byte [rbp-7]         ;; rdi = jt
  inc dil                         ;; jt++
  mov byte [rbp-7], dil           ;; update jt
  cmp dil, 8                      ;; jt < 8? Then continue jt, else break loop
  jl drw_jt_loop                  ;; Only if jt < 8 loop again
  movzx rdi, byte [rbp-3]         ;; rdi = it 
  movzx rsi, byte [rbp-8]         ;; rsi = nibble
  inc dil                         ;; it++
  mov byte [rbp-3], dil           ;; update it
  cmp dil, sil                    ;; it < nibble? Then continue it, else break loop
  jl drw_it_loop                  ;; Only if it < nibble loop again
drw_end:                          ;; Only when it == nibble
  INC_PC                          ;; pc += 2
  ;; hell end
  leave
  ret


;; Ex9E - SKP Vx
;; Skip next instruction if key Vx is pressed.
;; rdi = x
global _skp_vx:
_skp_vx:
  push rbp                        ;; This function gets the keypad key number
  mov rbp, rsp                    ;; v[x] and skips next instruction if its 1
  ;; begin                        ;; ==========================================
  movzx rsi, byte [cpu_v + rdi]   ;; rsi = v[x]
  mov al, byte [cpu_keypad + rsi] ;; al = keypad[v[x]]
  mov dx, word [cpu_pc]           ;; dx = pc
  cmp al, 1                       ;; keypad[v[x]] == 1? Then do pc += 2 now
  jne end_ex9e                    ;; If its not 1, skip next instruction
  add dx, 2                       ;; pc += 2
end_ex9e:                         ;; Inconditional
  add dx, 2                       ;; pc += 2
  mov word [cpu_pc], dx           ;; update pc
  ;; end
  leave
  ret


;; ExA1 - SKNP Vx
;; Skip next instruction if key Vx is not pressed.
;; rdi = x
global _sknp_vx:
_sknp_vx:
  push rbp                        ;; This function gets the keypad key number
  mov rbp, rsp                    ;; v[x] and skips next instruction if its 0
  ;; begin                        ;; ==========================================
  movzx rsi, byte [cpu_v + rdi]   ;; rsi = v[x]
  mov al, byte [cpu_keypad + rsi] ;; al = keypad[v[x]]
  mov dx, word [cpu_pc]           ;; dx = pc
  cmp al, 1                       ;; keypad[v[x]] != 1? Then do pc += 2 now 
  je end_exa1                     ;; If it is, skip next instruction
  add dx, 2                       ;; pc += 2
end_exa1:                         ;; Inconditional
  add dx, 2                       ;; pc += 2
  mov word [cpu_pc], dx           ;; update pc
  ;; end
  leave
  ret


;; Fx07 - LD Vx, DT
;; Set Vx = delay timer value.
;; rdi = x
global _ld_vx_dt
_ld_vx_dt:
  push rbp                        ;; This procedure sets a register v[x] to
  mov rbp, rsp                    ;; the value of the delay timer
  ;; begin                        ;; ==========================================
  mov sil, byte [cpu_dt]          ;; sil = dt
  mov byte [cpu_v + rdi], sil     ;; update v[x] = dt 
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Fx0A - LD Vx, K
;; Wait for a key press, store key in Vx.
;; rdi = x
global _ld_vx_k
_ld_vx_k:
  push rbp                        ;; This function iterates all keypad keys and 
  mov rbp, rsp                    ;; only increments the pc if some is 1.
  ;; begin                        ;; ==========================================
  xor rsi, rsi                    ;; rsi = i = 0
loop_fx0a:                        ;; loop i=0; i <= 0xf; i++
  mov dl, byte [cpu_keypad + rsi] ;; dl = keypad[i]
  cmp dl, 0                       ;; keypad[i] == 0? Then skip to next key
  jne keyp_fx0a                   ;; If not, jump to key pressed
  inc sil                         ;; i++
  cmp sil, 0xF                    ;; i <= 0xf? If greater, break loop
  jle loop_fx0a                   ;; If i <= 0xf, then next loop iteration
  jmp end_fx0a                    ;; Else, there are no more keys, so must end
keyp_fx0a:                        ;; Only if key pressed
  mov byte [cpu_v + rdi], sil     ;; v[x] = i = key
  INC_PC                          ;; pc += 2
end_fx0a:                         ;; Inconditional
  ;; end
  leave
  ret


;; Fx15 - LD DT, Vx
;; Set delay timer = Vx.
;; rdi = x
global _ld_dt_vx
_ld_dt_vx:
  push rbp                        ;; This procedure sets the delay timer to the
  mov rbp, rsp                    ;; value of a register v[x]
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov byte [cpu_dt], dl           ;; update dt to v[x]
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Fx18 - LD ST, Vx
;; Set sound timer = Vx.
;; rdi = x
global _ld_st_vx
_ld_st_vx:
  push rbp                        ;; This procedure sets the sound timer to the
  mov rbp, rsp                    ;; value of a register v[x]
  ;; begin                        ;; ==========================================
  mov dl, byte [cpu_v + rdi]      ;; dl = v[x]
  mov byte [cpu_st], dl           ;; update st to v[x]
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Fx1E - ADD I, Vx
;; Set I = I + Vx.
;; rdi = x
global _add_i_vx
_add_i_vx:
  push rbp                        ;; This function sets the register I to the
  mov rbp, rsp                    ;; value I + v[x] 
  ;; begin                        ;; ==========================================
  movzx si, byte [cpu_v + rdi]    ;; si = v[x]
  mov dx, word [cpu_i]            ;; dx = I
  add dx, si                      ;; dx = I + v[x] 
  cmp dx, 0xFFF                   ;; (I + v[x]) > 0xfff?
  jg  outaddr_fx1e                ;; If it is, go to v[0xf] = 1
  mov byte [cpu_v + 0xF], 0       ;; v[0xf] = 0
  jmp end_fx1e                    ;; Go to update I
outaddr_fx1e:                     ;; Only if (I + v[x]) > 0xfff
  mov byte [cpu_v + 0xF], 1       ;; v[0xf] = 1
end_fx1e:                         ;; Inconditional
  mov word [cpu_i], dx            ;; update I = (I + v[x]) 
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Fx29 - LD F, Vx
;; Set I = location of sprite for digit Vx.
;; rdi = x
global _ld_f_vx
_ld_f_vx:
  push rbp                        ;; This function sets the register I to the 
  mov rbp, rsp                    ;; memory address of the sprite v[x]
  ;; begin                        ;; ==========================================
  movzx si, byte [cpu_v + rdi]    ;; si = v[x]
  mov ax, 5                       ;; prepare for v[x] * Fx55
  mul si                          ;; ax = v[x] * 5
  mov [cpu_i], word ax            ;; update I to v[x] * 5
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Fx33 - LD B, Vx
;; Store BCD representation of Vx at I, I+1, and I+2.
;; rdi = x
global _ld_b_vx
_ld_b_vx:
  push rbp                        ;; This procedure basically stores the digits
  mov rbp, rsp                    ;; of the value v[x] in memory from I to I+2
  ;; begin                        ;; ==========================================
  movzx rsi, byte [cpu_v + rdi]   ;; rsi = v[x]
  mov rax, rsi                    ;; rax = v[x]
  mov rcx, 100                    ;; prepare for v[x]/100
  div cl                          ;; do rax = v[x]/100
  movzx rbx, word [cpu_i]         ;; rbx = I
  mov [cpu_memory + rbx], al      ;; memory[I] = al = v[x]/100 = Hundreds
  mov rax, rsi                    ;; rax = v[x]
  mov rcx, 10                     ;; prepare for v[x]/10
  div cl                          ;; rax = v[x]/10 (8 last bits contains result)
  and rax, 0xFF                   ;; (v[x]/10) & 0xff -> Save only last 8 bits
  div cl                          ;; rax = (v[x]/10)/10 (8 first bits are the reminder)
  add rbx, 1                      ;; do I++
  mov [cpu_memory + rbx], ah      ;; memory[I+1] = ah = (v[x]/10)%10 = Tens
  mov rax, rsi                    ;; rax = v[x]
  mov rcx, 100                    ;; prepare to v[x]/100
  div cl                          ;; do rax = v[x]/100 (we want to save the reminder)
  shr rax, 8                      ;; set al to ah (move 8 highest bits to lowest)
  and rax, 0xFF                   ;; Ensure we save only the last 8 bits
  mov rcx, 10                     ;; prepare to do (reminder(v[x]/100))/10
  div cl                          ;; rax = (reminder(v[x]/100))/10. We want the reminder
  add rbx, 1                      ;; do I++
  mov [cpu_memory + rbx], ah      ;; memory[I+2] = ah = (v[x]%100)%10 = Units
  INC_PC                          ;; pc += 2
  ;; end
  leave
  ret


;; Fx55 - LD [I], Vx
;; Store registers V0 through Vx at I.
;; rdi = x
global _ld_i_vx
_ld_i_vx:
  push rbp                        ;; This procedure stores the registers v[0]
  mov rbp, rsp                    ;; to v[x] in memory from I to I+x
  sub rsp, 16
  ;; begin                        ;; ==========================================
  cmp dil, 0xf                    ;; x > 0xf ? 
  jle maybe_outb_mem_fx55         ;; If its not, continue. Else error
  mov byte [cpu_error], ACCESS_OUTB_REG ;; Note the error
  jmp end_fx55                    ;; End the function
maybe_outb_mem_fx55:              ;; Only if x <= 0xf
  mov si, word [cpu_i]            ;; si = I 
  movzx ax, dil                   ;; ax = x
  add ax, si                      ;; ax = x + I
  cmp ax, PROG_END                ;; (x + I) > 0xfff?
  jle maybe_priv_mem_fx55         ;; If its not, continue. Else error
  mov byte [cpu_error], ACCESS_OUTB_MEMORY ;; Note the error
  jmp end_fx55                    ;; End function
maybe_priv_mem_fx55:              ;; Only if (x + I) <= 0xfff
  cmp si, PROG_BEGIN              ;; I < 0x200?
  jge just_fx55                   ;; If its not continue. Else error 
  mov byte [cpu_error], ACCESS_PRIV_MEMORY ;; Note the error
  jmp end_fx55                    ;; End function
just_fx55:                        ;; Usual procedure
  inc ax                          ;; ax++ = (x + I) + 1
  mov word [cpu_i], ax            ;; update I to (x + I) + 1
  mov rdx, rdi                    ;; rdx = x
  inc rdx                         ;; rdx++ = x + 1
  mov rdi, cpu_memory             ;; rdi = cpu_memory
  add rdi, rsi                    ;; rdi = address of memory[I]
  mov rsi, cpu_v                  ;; rsi = address of v[0]
  call memcpy                     ;; memcpy(memory+I, v, x+1)
  INC_PC                          ;; pc += 2
end_fx55:
  ;; end
  leave
  ret


;; Fx65 - LD Vx, [I]
;; Read registers V0 through Vx from I.
;; rdi = x
global _ld_vx_i
_ld_vx_i:
  push rbp                        ;; This function tries to store the memory 
  mov rbp, rsp                    ;; addresses I to I+x in v[0] to v[x]
  sub rsp, 16
  ;; begin                        ;; ==========================================
  cmp dil, 0xf                    ;; x > 0xf ? 
  jle maybe_outb_mem_fx65         ;; If its not, continue. Else error
  mov byte [cpu_error], ACCESS_OUTB_REG ;; Note the error
  jmp end_fx65                    ;; End the function
maybe_outb_mem_fx65:              ;; Only if x <= 0xf
  movzx rsi, word [cpu_i]         ;; rsi = I 
  movzx ax, dil                   ;; ax = x
  add ax, si                      ;; ax = x + I
  cmp ax, PROG_END                ;; (x + I) > 0xfff?
  jle just_fx65                   ;; If its not, continue. Else error
  mov byte [cpu_error], ACCESS_OUTB_MEMORY ;; Note the error
  jmp end_fx65                    ;; End function
just_fx65:                        ;; Usual procedure
  inc ax                          ;; ax++ = (x + I) + 1
  mov word [cpu_i], ax            ;; update I to (x + I) + 1
  mov rdx, rdi                    ;; rdx = x
  inc rdx                         ;; rdx++ = x + 1
  add rsi, cpu_memory             ;; rsi = address of memory[I]
  mov rdi, cpu_v                  ;; rdi = address of v[0]
  call memcpy                     ;; memcpy(v, memory+I, x+1)
  INC_PC                          ;; pc += 2
end_fx65:
  ;; end
  leave
  ret
