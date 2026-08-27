                .include "colors.h.s"
                .include "console.h.s"
                .include "matrix.h.s"
                .include "variables.h.s"

                .segment "CODE"

                .global main
main:
                ldx #$ff
                txs

                lda #<welcome_message
                sta W
                lda #>welcome_message
                sta W+1
                jsr console_puts

                jsr colors_init
                jsr matrix_init
@loop:
                jsr matrix_update
                bra @loop

                .segment "RODATA"
welcome_message:
                .byte $1b, "[0m"
                .byte $1b, "[H"
                .byte $1b, "[J"
                .byte $1b, "[4;11H"
                .byte $1b, "[32m"
                .byte "Take the "
                .byte $1b, "[1;37;41m"
                .byte "red pill"
                .byte $1b, "[0m"
                .byte $1b, "[32m"
                .byte ", then select "
                .byte $1b, "[1m"
                .byte "View > Display"
                .byte $1b, "[22m"
                .byte " from the menu."
                .byte $1b, "[0m"
                .byte 0