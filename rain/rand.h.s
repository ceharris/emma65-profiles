        .ifndef RAND_H
                RAND_H = 1

                LFSR_LO = $FFF6
                LFSR_HI = LFSR_LO + 1


        .macro rand_flip
                lda LFSR_LO
                lda LFSR_HI
                asl
        .endmacro

                .global rand_range
                .global rand_cmp
                .global rand_printable

        .endif