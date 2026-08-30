        .ifndef VARIABLES_H
                VARIABLES_H = 1

                NUM_DRIPS = 48          ; maximum number of drips
                DRIP_SIZE = 4           ; number of bytes in each drip

                .globalzp B
                .globalzp C
                .globalzp V
                .globalzp W

                .globalzp drips_table                

        .endif