                .include "matrix.h.s"
                .include "variables.h.s"

                .global main
main:
                ldx #$ff
                txs

                jsr matrix_init
@loop:
                jsr matrix_update
                lda #5
                bra @loop

            