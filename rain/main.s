                .include "colors.h.s"
                .include "display.h.s"
                .include "rain.h.s"
                .include "variables.h.s"

                .segment "CODE"

                .global main
main:
                ldx #$ff
                txs

                jsr colors_init
                jsr rain_init
@loop:
                jsr rain_update
                jsr check_quit
                bcc @loop

                stp

;-----------------------------------------------------------------------
; check_quit:
; Checks for a "quit" key press.
;
; On return:
;   Z if a "quit" key was pressed
;
check_quit:
                lda KEYBOARD_IN
                beq @done               ; no key waiting

        ; if there's no input device mapped at KEYBOARD_IN
        ; could be reading from ROM.
                cmp #$ff                ; common unused ROM cell content
                beq @done
                cmp #$ea                ; ROM cell with a NOP instruction in it
                beq @done

        ; check for input the user is likely to use to exit the demo
                cmp #3                  ; Ctrl+C?
                beq @quit
                cmp #$1b                ; Escape?
                beq @quit
                cmp #'Q'                ; (Q)uit?
                beq @quit
                cmp #'q'                ; (q)uit?
                beq @quit
                
        ; go back and check again to ensure input ring buffer is fully drained
                bra check_quit

@quit:
                sec                     ; set carry to indicate quit
                rts
@done:
                clc                     ; clear carry to indicate continue
                rts
