        .ifndef VARIABLES_H
                VARIABLES_H = 1

                .include "display.h.s"
                WIDTH = DISPLAY_WIDTH
                HEIGHT = DISPLAY_HEIGHT

                .globalzp B
                .globalzp C
                .globalzp D
                .globalzp E
                .globalzp V
                .globalzp VL
                .globalzp VH
                .globalzp W
                .globalzp WL
                .globalzp WH
        
                .global row_0
                .global row_i
                .global row_j
                .global row_k

        .endif