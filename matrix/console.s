
                .include "console.h.s"
                .include "variables.h.s"


;-----------------------------------------------------------------------
; console_puts:
; Prints a null-terminated an embedded string constant on the console.
;
; On entry:
;   W = address of the string to print
; 
console_puts:
                phy
                ldy #0                  ; will use indirect-indexed mode
@loop:
                lda (W),y               ; fetch string character
                beq @done               ; go if terminator
                sta CONSOLE_IO          ; send the character to the console
                iny                     ; next string character
                bra @loop
@done:
                ply
                rts
