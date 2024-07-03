extern DrawRectangle
extern cpu_display

section .data
  color_white	db 255,255,255,255

section .text
global _draw_display
_draw_display:
    ; Guardar los registros que usaremos
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    xor rcx, rcx              ; rcx = it = 0
loop_it:
    cmp rcx, 2048             ; it < 2048 ?
    jge end_loop_it

    movzx rax, byte [cpu_display + rcx] ; rax = display[it]
    test rax, rax             ; verificar si display[it] == 1
    jz skip_draw

    ; Calcular las coordenadas x e y
    mov rax, rcx
    mov rbx, 64
    xor rdx, rdx
    div rbx                   ; div(rax, 64), resultado en rax, resto en rdx

    ; rdx ahora tiene el valor de x = it % 64
    ; rax ahora tiene el valor de y = it / 64

    ; Multiplicar x y y por 30
    mov rbx, rdx              ; rbx = x
    mov rsi, 30
    imul rbx, rsi             ; rbx = x * 30
    mov rdx, rax              ; rdx = y
    imul rdx, rsi             ; rdx = y * 30

    ; Llamar a DrawRectangle(x*30, y*30, 30, 30, WHITE)
    mov rdi, rbx              ; rdi = x * 30
    mov rsi, rdx              ; rsi = y * 30
    mov rdx, 30               ; rdx = width = 30
    mov rcx, 30               ; rcx = height = 30
    mov r8d, color_white      ; r8d = color = WHITE
    call DrawRectangle

skip_draw:
    inc rcx                   ; it++
    jmp loop_it

end_loop_it:
    ; Restaurar los registros
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret
