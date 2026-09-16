                .global main
                .global isr
                .global nmi

                .segment "MACHVECS"
                .word nmi
                .word main
                .word isr