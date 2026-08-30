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
                bne @loop

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
                beq @done


        ; if there's no input device mapped at KEYBOARD_IN
        ; could be reading from ROM.
                cmp #$ff                ; common unused ROM cell content
                beq @done
                cmp #$ea                ; ROM cell with a NOP instruction in it
                beq @done

        ; check for input the user is likely to use to exit the demo
                cmp #3                  ; Ctrl+C?
                beq @done
                cmp #$1b                ; Escape?
                beq @done
                cmp #'Q'                ; (Q)uit?
                beq @done
                cmp #'q'                ; (q)uit?
                beq @done
                
        ; go back and check again to ensure input ring buffer is fully drained
                bra check_quit

@done:
                rts
