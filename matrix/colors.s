                .include "colors.h.s"
                .include "display.h.s"
                NUM_COLORS = 16

                .segment "CODE"

;-----------------------------------------------------------------------
; colors_init:
; Configures the display color palette.
;
colors_init:
                ldx #0
                ldy #0
@loop:        
                ; signal set color
                lda #DISPLAY_SET_COLOR
                sta DISPLAY_CONTROL
                ; send palette index
                txa
                sta DISPLAY_CONTROL_DATA
                ; send red component
                lda colors,y
                sta DISPLAY_CONTROL_DATA
                iny
                ; send green component
                lda colors,y
                sta DISPLAY_CONTROL_DATA
                iny
                ; send blue component
                lda colors,y
                sta DISPLAY_CONTROL_DATA
                iny
                ;
                inx
                cpx #NUM_COLORS
                bne @loop

                rts


                .segment "RODATA"

colors:
                .byte $00, $00, $00
                .byte $00, $33, $00
                .byte $00, $33, $00
                .byte $00, $66, $00
                .byte $00, $66, $00
                .byte $00, $66, $00
                .byte $00, $99, $00
                .byte $00, $99, $00
                .byte $00, $99, $00
                .byte $00, $99, $00
                .byte $00, $99, $00
                .byte $00, $CC, $00
                .byte $00, $66, $00
                .byte $CC, $FF, $CC
                .byte $AA, $00, $00
                .byte $AA, $00, $00
