global NO_ERROR
global RETURN_EMPTY_STACK
global STACK_OVERFLOW
global ACCESS_PRIV_MEMORY
global ACCESS_OUTB_MEMORY
global ACCESS_OUTB_REG
global UNKNOWN_OPCODE
extern printf

section .data
  NO_ERROR           equ 0x0 ;; There is no error
  RETURN_EMPTY_STACK equ 0x1 ;; Subroutine return with sp = 0
  STACK_OVERFLOW     equ 0x2 ;; Too much subroutine calls
  ACCESS_PRIV_MEMORY equ 0x3 ;; Access insterpreter memory
  ACCESS_OUTB_MEMORY equ 0x4 ;; Access out of bounds memory
  ACCESS_OUTB_REG    equ 0x5 ;; Access out of bounds V register
  UNKNOWN_OPCODE     equ 0x6 ;; Produced when decoding a instruction

  rerturn_empty_msg:   db "Attempt to return from subroutine with the stack empty.",10,0
  stack_overflow_msg:  db "Stack overflow caused by many calls.",10,0
  access_priv_mem_msg: db "Attempt to access interpreter memory section (< 0x200).",10,0
  access_outb_mem_msg: db "Attempt to access out of bounds memory (> 0xfff).",10,0
  access_outb_reg_msg: db "Attempt to access out of bounds V register (> 0xf).",10,0
  unknown_opcode_msg:  db "Unknown opcode",10,0
  unknown_error_msg:   db "Unknown error",10,0
  error_format:        db "%04x: %s",0 

section .text

;; rdi = errCode
;; rsi = opcode
global _decode_error
_decode_error:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  ;; start
  ;; We basically want to get the error code, print
  ;; the opcode that caused it, and print some 
  ;; information about how that error happened. We 
  ;; assume that this function is called only when the
  ;; field 'cpu_error' is not 'NO_ERROR'.
  ;; =================================================
  cmp dil, RETURN_EMPTY_STACK
  jne maybe_stack_overflow
  mov rdx, rerturn_empty_msg
  jmp decode_end
maybe_stack_overflow:
  cmp dil, STACK_OVERFLOW
  jne maybe_access_priv
  mov rdx, stack_overflow_msg
  jmp decode_end
maybe_access_priv:
  cmp dil, ACCESS_PRIV_MEMORY
  jne maybe_access_outb_mem
  mov rdx, access_priv_mem_msg
  jmp decode_end
maybe_access_outb_mem:
  cmp dil, ACCESS_OUTB_MEMORY
  jne maybe_access_outb_reg
  mov rdx, access_outb_mem_msg
  jmp decode_end
maybe_access_outb_reg:
  cmp dil, ACCESS_OUTB_REG
  jne maybe_unknown_opcode
  mov rdx, access_outb_reg_msg
  jmp decode_end
maybe_unknown_opcode:
  cmp dil, UNKNOWN_OPCODE
  jne just_unknown_error
  mov rdx, unknown_opcode_msg
  jmp decode_end
just_unknown_error:  
  mov rdx, unknown_error_msg
decode_end:
  ;; We use the following printf call
  ;; printf("%04x: %s", opcode, msg)
  mov rdi, error_format
  call printf
  ;; end
  leave
  ret
