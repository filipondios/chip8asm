section .data
  ;; Processor features
  display: times 2048 db 0 ;; Display Buffer
  ram:     times 4096 db 0 ;; Chip8 Memory
  stack:   times 16   dw 0 ;; Processor stack
  vx:      times 16   db 0 ;; Vx Registers (x[0..f])
  i:  dw 0                 ;; I register
  dt: db 0                 ;; Delay Timer
  st: db 0                 ;; Sound Timer
  pc: dw 0                 ;; Program counter
  sptr: db 0               ;; Stack pointer (sp is a keyword)

section .text
;; CLS
;; ---
;; Clears the screen
;; buffer
global _cls
_cls:
  ret
 
;; RET
;; ---
;; Returns from a
;; subroutine
global _ret
_ret:
  ret

;; JP
;; Jump to location
;; 0xnnn (rdi)
global _jp
_jp:
  ret
