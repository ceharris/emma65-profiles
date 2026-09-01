
                .include "delay.h.s"


                VIA_BASE = $FF80
                VIA_T1CL = VIA_BASE + $4
                VIA_T1CH = VIA_BASE + $5
                VIA_ACR = VIA_BASE + $B
                VIA_IFR = VIA_BASE + $D

                TIMER_PERIOD = 9216

                VIA_IFR_T1 = $40

delay:
                lda #<TIMER_PERIOD
                sta VIA_T1CL
                lda #>TIMER_PERIOD
                sta VIA_T1CH

@loop:
                bit VIA_IFR
                bvc @loop
                rts
