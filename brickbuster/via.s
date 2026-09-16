                .include "via.h.s"

                VIA_BASE = $FF80
                VIA_T1CL = VIA_BASE + $4
                VIA_T1CH = VIA_BASE + $5
                VIA_ACR  = VIA_BASE + $B
                VIA_IFR  = VIA_BASE + $D

                VIA_T1_IRQ = $40

                TIMER_PERIOD = 18432    ; PHI2 clock rate / 100



;----------------------------------------------------------------------
; via_t1_delay:
; Uses VIA Timer 1 to delay for a period of at least A * 10 ms.
;
; On entry:
;       A = delay time in tens of milliseconds
;
via_t1_delay:
                phx
                tax
                stz VIA_ACR
@outer:
                lda #<TIMER_PERIOD
                sta VIA_T1CL
                lda #>TIMER_PERIOD
                sta VIA_T1CH
@inner:
                lda VIA_IFR
                and #VIA_T1_IRQ
                beq @inner

                dex
                bne @outer
                plx
                rts
