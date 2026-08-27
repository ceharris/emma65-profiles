        .ifndef CONSOLE_H
                CONSOLE_H = 1

                CONSOLE_IO = $FFF8
                CONSOLE_LATCH = CONSOLE_IO + 1

                .global console_puts

        .endif