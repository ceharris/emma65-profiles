        .ifndef LCD8_H
                LCD8_H = 1

                LCD_WITHOUT_SHIFT  = 0
                LCD_WITH_SHIFT     = %00000001
                LCD_DECREMENT      = 0
                LCD_INCREMENT      = %00000010
                LCD_BLINK_OFF      = 0
                LCD_BLINK_ON       = %00000001
                LCD_CURSOR_OFF     = 0
                LCD_CURSOR_ON      = %00000010
                LCD_DISPLAY_OFF    = 0
                LCD_DISPLAY_ON     = %00000100
                LCD_LEFT           = 0
                LCD_RIGHT          = %00000100
                LCD_MOVE_CURSOR    = 0
                LCD_SHIFT_DISPLAY  = %00001000
                LCD_5X8            = 0 
                LCD_5X10           = %00000100
                LCD_1LINE          = 0
                LCD_2LINE          = %00001000

                .global lcd8_init
                .global lcd8_on
                .global lcd8_off
                .global lcd8_clear
                .global lcd8_home
                .global lcd8_lmove
                .global lcd8_rmove
                .global lcd8_moveto
                .global lcd8_lshift
                .global lcd8_rshift
                .global lcd8_glyph_5x8
                .global lcd8_putc
                .global lcd8_puts
                
        .endif