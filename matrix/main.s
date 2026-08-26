                .include "delay.h.s"
                .include "matrix.h.s"

                .global main
main:
                ldx #$ff
                txs

                jsr matrix_init
@loop:
                jsr matrix_update
                lda #5
                jsr delay
                bra @loop

            