        .ifndef DISPLAY_H
                DISPLAY_H = 1

                PIXEL_MEM = $C000
                COMMAND_REGISTER = $FFF4
                DATA_REGISTER = $FFF5

                DISPLAY_WIDTH = 32
                DISPLAY_HEIGHT = 32

                MATRIX_COUNT = 1

                .global display_init
                .global display_flip

        .endif