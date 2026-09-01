                .include "display.h.s"
                .include "variables.h.s"

                CMD_SWAP = 0
                CMD_SET_AUTOREFRESH = 1
                CMD_SET_POWER = 2
                CMD_SET_BRIGHTNESS = 3
                CMD_PALETTE_WRITE = 4
            
                .segment "CODE"

;-----------------------------------------------------------------------
; display_init:
; Initializes the LED matrix display.
;
; On return:
;       X, Y, W clobbered
;
display_init:
        ; disable autorefresh in all panels
                lda #CMD_SET_AUTOREFRESH
                sta COMMAND_REGISTER
                stz DATA_REGISTER
        ; power on all matrices in the display
                lda #CMD_SET_POWER
                sta COMMAND_REGISTER
                lda #$FF
                sta DATA_REGISTER
        ; maximum brightness
                lda #CMD_SET_BRIGHTNESS
                sta COMMAND_REGISTER
                lda #$FF
                sta DATA_REGISTER
        ; set up palette colors
                lda #<colors
                sta WL
                lda #>colors
                sta WH
                lda colors              ; A = number of colors to set
                lda C
                ldy #1
@loop:
                jsr _write_color
                dec C
                bne @loop
                rts

;-----------------------------------------------------------------------
; display_flip:
; Flips all configured matrices the LED matrix display, transferring
; the contents of pixel memory to the on-screen refresh buffer.
;
display_flip:
                lda #CMD_SWAP
                sta COMMAND_REGISTER
                lda #$FF
                sta DATA_REGISTER
                rts


;-----------------------------------------------------------------------
; _write_color:
; Write a palette color to the display
; 
; On entry:
;       (W),y = 4-byte color tuple (index, red, green, blue)
;
; On return:
;       X = 0
;       Y += 4
;
_write_color:
                lda #CMD_PALETTE_WRITE
                sta COMMAND_REGISTER
                ldx #4
@loop:
                lda (W),y
                sta DATA_REGISTER
                iny
                dex
                bne @loop
                rts

                .segment "RODATA"
colors:
                .byte 16
                .byte  0, $28, $28, $28
                .byte  1, $29, $29, $29
                .byte  2, $2A, $2A, $2A
                .byte  3, $2C, $2C, $2C
                .byte  4, $30, $30, $30
                .byte  5, $34, $34, $34
                .byte  6, $38, $38, $38
                .byte  7, $48, $48, $48
                .byte  8, $A5, $DB, $30
                .byte  9, $A5, $DB, $70
                .byte 10, $DB, $E0, $80
                .byte 11, $D8, $E0, $90
                .byte 12, $E2, $FF, $40
                .byte 13, $E7, $FF, $60
                .byte 14, $EC, $FF, $80
                .byte 15, $ED, $F8, $B0
