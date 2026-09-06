                .include "lcd8.h.s"
                .include "variables.h.s"
                .include "via.h.s"

                WIDTH = 16
                TAB_WIDTH = 20

                .segment "CODE"

                .global main
main:
                lda #(LCD_INCREMENT | LCD_5X10)
                jsr lcd8_init
                lda #(LCD_CURSOR_ON | LCD_BLINK_ON)
                jsr lcd8_on
                
                lda #((WIDTH - MSG1_LEN) >> 1)
                jsr lcd8_moveto
                lda #<msg1
                sta VL
                lda #>msg1
                sta VH
                jsr lcd8_puts

                lda #((WIDTH - MSG2_LEN) >> 1 + TAB_WIDTH)
                jsr lcd8_moveto
                lda #<msg2
                sta VL
                lda #>msg2
                sta VH
                jsr lcd8_puts

                lda #((WIDTH - MSG3_LEN) >> 1 + 2*TAB_WIDTH)
                jsr lcd8_moveto
                lda #<msg3
                sta VL
                lda #>msg3
                sta VH
                jsr lcd8_puts

                lda #((WIDTH - MSG4_LEN) >> 1 + 3*TAB_WIDTH)
                jsr lcd8_moveto
                lda #<msg4
                sta VL
                lda #>msg4
                sta VH
                jsr lcd8_puts

@again:
                lda #100
                jsr via_t1_delay
                ldx #TAB_WIDTH
@right:
                jsr lcd8_rshift
                lda #10
                jsr via_t1_delay
                dex
                bne @right
                bra @again
@done:
                bra @done


                .segment "RODATA"

msg1:
                .byte $A5, $A5, $A5, " Emma65 ", $A5, $A5, $A5, 0
                MSG1_LEN = * - msg1 - 1
msg2:
                .byte "65c02 emulator", 0
                MSG2_LEN = * - msg2 - 1
msg3:
                .byte 'p' + $80, "eri", 'p' + $80, "herals", 0
                MSG3_LEN = * - msg3 - 1
msg4:
                .byte "and debu", 'g' + $80, 'g' + $80, "er!", 0
                MSG4_LEN = * - msg4 - 1
    

; Right-pointing arrow, 5x8 font, one row per byte (low 5 bits, MSB left).
arrow_glyph:
                .byte %00000
                .byte %00100
                .byte %00110
                .byte %11111
                .byte %00110
                .byte %00100
                .byte %00000
                .byte %00000
