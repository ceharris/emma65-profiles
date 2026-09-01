
                .include "delay.h.s"
                .include "display.h.s"
                .include "life.h.s"
                .include "variables.h.s"

                .segment "CODE"

                .global main
main:
                ldx #$ff
                txs
        
                jsr display_init
                
                lda #SURFACE_TOROID
                sta surface_type
                lda #<L_heptomino
                sta VL
                lda #>L_heptomino
                sta VH
                jsr life_init

@loop:
                jsr display_flip
                jsr delay
                jsr life_update
                bra @loop

                stp
