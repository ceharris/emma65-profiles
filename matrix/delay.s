                .include "delay.h.s"


                VIA_BASE = $FF80
                VIA_T1CL = VIA_BASE + $4
                VIA_T1CH = VIA_BASE + $5
                VIA_ACR = VIA_BASE + $B
                VIA_IFR = VIA_BASE + $D

                TIMER_PERIOD = 18432

;-----------------------------------------------------------------------
; delay:
; Pauses execution for approximate 10*A milliseconds.
; 
; On entry:
;   A = delay period divided by 10
;
delay:
                phx
                tax
                beq @done
                lda #0
                sta VIA_ACR
@period_loop:
                lda #<TIMER_PERIOD
                sta VIA_T1CL
                lda #>TIMER_PERIOD
                sta VIA_T1CH 
@expiry_loop:
                bit VIA_IFR
                bvc @expiry_loop
                dex
                bne @period_loop
@done:
                plx
                rts
