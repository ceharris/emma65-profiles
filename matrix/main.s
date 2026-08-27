                .include "colors.h.s"
                .include "matrix.h.s"
                .include "variables.h.s"

                .global main
main:
                ldx #$ff
                txs

                jsr colors_init
                jsr matrix_init
@loop:
                jsr matrix_update
                lda #5
                bra @loop
