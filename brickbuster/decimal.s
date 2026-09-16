
                .include "decimal.h.s"
                .include "variables.h.s"


;-----------------------------------------------------------------------
; bin8_to_bcd:
; Converts an 8-bit binary value in A to a BCD value in V.
;
; On entry:
;       A = the value to convert
;
; On return:
;       B clobbered
;       V = BCD value with leading zeros
;
bin8_to_bcd:
                phx

                sta B                   ; preserve value to convert
                stz VL                  ; zero output buffer
                stz VH 
            
                ldx #8                  ; number of bits
                sed
@loop:
                asl B                   ; high order bit of arg to carry
                lda VL
                adc VL                  ; double LSB + carry
                sta VL
                lda VH
                adc VH                  ; double LSB + carry
                sta VH
                dex
                bne @loop

                cld
                plx
                rts
                

;-----------------------------------------------------------------------
; acd_to_bin8:
; Converts a null-terminated ASCII-coded decimal value in (V) to an 
; 8-bit binary value.
;
; On entry:
;       V = pointer to the buffer to convert
;
; On return:
;       A = converted value
;       B, C clobbered
;
acd_to_bin8:
                stz C                   ; zero the result
                ldy #0
@loop:
                lda (V),y               ; get digit to convert
                beq @done               ; no more digits
                sec
                sbc #'0'                ; convert ASCII digit to binary
                clc
                adc C                   ; fold in ones place value
                iny
                sta C                   ; save result
@next:
                lda (V),y               ; get digit to convert
                beq @done               ; no more digits

                ; shift result left by one digit position
                lda C                   ; fetch result
                asl                     ; A' = 2*A
                sta B                   ; B = A'
                asl                     ; A' = 4*A
                asl                     ; A' = 8*A
                clc
                adc B                   ; A' = 8*A + 2*A = (8 + 2)*A = 10*A
                sta C                   ; store result
                bra @loop
@done:
                lda C
                rts
