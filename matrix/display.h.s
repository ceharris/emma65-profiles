        .ifndef DISPLAY_H
                DISPLAY_H = 1

                DISPLAY_ROWS = 25
                DISPLAY_COLUMNS = 40
                DISPLAY_SIZE = DISPLAY_ROWS * DISPLAY_COLUMNS

                DISPLAY_BASE = $C000

                DISPLAY_CHAR_RAM = DISPLAY_BASE
                DISPLAY_COLOR_RAM = DISPLAY_BASE + DISPLAY_SIZE
                DISPLAY_CONTROL = DISPLAY_BASE + 2*DISPLAY_SIZE
                DISPLAY_STATUS = DISPLAY_BASE + 2*DISPLAY_SIZE + 1
                DISPLAY_CONTROL_DATA = DISPLAY_STATUS

                DISPLAY_SWAP = $1
                DISPLAY_SET_COLOR = $8

        .endif