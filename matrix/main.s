                .include "colors.h.s"
                .include "display.h.s"
                .include "matrix.h.s"
                .include "variables.h.s"

                .segment "CODE"

                .global main
main:
                ldx #$ff
                txs

                jsr colors_init
                jsr matrix_init
@loop:
                jsr matrix_update
                lda KEYBOARD_IN
                beq @loop
                cmp #3
                bne @loop
                stp
