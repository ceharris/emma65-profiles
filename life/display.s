                .include "display.h.s"

                CMD_SWAP = 0
                CMD_SET_AUTOREFRESH = 1
                CMD_SET_POWER = 2
                CMD_SET_BRIGHTNESS = 3
            
;-----------------------------------------------------------------------
; display_init:
; Initializes the LED matrix display
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
                rts


;-----------------------------------------------------------------------
; display_init:
; Flips all configured matrices the LED matrix display, transferring
; the contents of pixel memory to the on-screen refresh buffer.
;
display_flip:
                lda #CMD_SWAP
                sta COMMAND_REGISTER
                lda #$FF
                sta DATA_REGISTER
                rts
