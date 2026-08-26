
                .include "rand.h.s"
                .include "variables.h.s"

                ASCII_PRINTABLES = 128 - 32 - 2
                ASCII_START = 33

                LATIN_PRINTABLES = 128
                LATIN_START = 128


;-----------------------------------------------------------------------
; rand_flip:
; A random coin flip.
;
; On return:
;   carry flag randomly set
;
rand_flip:
                lda LFSR_LO
                lda LFSR_HI
                asl
                rts


;-----------------------------------------------------------------------
; rand_range:
; Gets a random integer value on the interval [0, A).
;
; On return:
;   A = random integer value; 0 <= A < A
;   B, C clobbered
;
rand_range:
                phx
                sta C                   ; C = upper bound
                lda LFSR_LO             ; random sample LSB
                eor LFSR_HI             ; fold in random sample MSB
                sta B                   ; B = 8-bit random value

                lda #0
                ldx #8                  ; loop count
@loop:
                lsr B
                bcc @skip
                clc
                adc C
@skip:
                ror
                dex
                bne @loop
                plx
                rts


;-----------------------------------------------------------------------
; rand_cmp:
; Compares a random integer value to a threshold given in BC.
;
; On entry:
;   BC = threshold value
;
; On return:
;   carry clear if the random sample was less than the threshold
;   A clobbered
;
rand_cmp:
                sec
                lda LFSR_LO
                sbc C
                lda LFSR_HI
                sbc B
                rts


;-----------------------------------------------------------------------
; rand_printable:
; Gets a random printable character.
;
; On return:
;   A = random printable character code
;   B, C clobbered
;
rand_printable:
                jsr rand_flip
                bcs @rand_latin

                lda #ASCII_PRINTABLES
                jsr rand_range
                clc
                adc #ASCII_START
                rts
@rand_latin:
                lda #LATIN_PRINTABLES
                jsr rand_range
                clc
                adc #LATIN_START
                rts

