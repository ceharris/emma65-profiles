                .include "lcd8.h.s"
                .include "variables.h.s"
                .include "via.h.s"

                LCD_COMMAND = $FFF2
                LCD_DATA = LCD_COMMAND + 1

        ; Command bit masks
                LCD_CLEAR_DISPLAY  = %00000001
                LCD_RETURN_HOME    = %00000010
                LCD_ENTRY_MODE_SET = %00000100
                LCD_DISPLAY_CTRL   = %00001000
                LCD_DISPLAY_SHIFT  = %00010000
                LCD_FUNCTION_SET   = %00100000
                LCD_CGRAM_ADDRESS  = %01000000
                LCD_DDRAM_ADDRESS  = %10000000

                LCD_BUSY           = %10000000
            
                LCD_4BIT           = 0
                LCD_8BIT           = %00010000

                LCD_DDRAM_MASK     = %01111111
                LCD_CGRAM_MASK     = %00111111

        .macro _await_not_busy
                .local @wait
@wait:
                lda LCD_COMMAND
                bmi @wait
        .endmacro


                .segment "CODE"


;-----------------------------------------------------------------------
; lcd8_init:
; Initializes the display controller using the procedure outlined in the
; HD44780 datasheet section "Initializing by Instruction", figure "8-Bit
; Interface".
;
; On entry:
;       A = bit mask with any of the following bits set:
;           LCD_5X10, LCD_INCREMENT, LCD_WITH_SHIFT
;
; On return:
;       Y clobbered
;
lcd8_init:
                tay                     ; preserve config bits

                lda #10                 ; delay time 100 ms
                jsr via_t1_delay

                lda #(LCD_FUNCTION_SET | LCD_8BIT)
                sta LCD_COMMAND

                lda #1                  ; delay time 10 ms
                jsr via_t1_delay

                lda #(LCD_FUNCTION_SET | LCD_8BIT)
                sta LCD_COMMAND

                lda #1                  ; delay time 10 ms
                jsr via_t1_delay

                lda #(LCD_FUNCTION_SET | LCD_8BIT)
                sta LCD_COMMAND

                _await_not_busy

        ; function set: interface width and font selection
                tya                     ; recover config bits
                and #(LCD_FUNCTION_SET | LCD_8BIT | LCD_5X10)
                ora #(LCD_FUNCTION_SET | LCD_8BIT)
                sta LCD_COMMAND

        ; display control: display off
                _await_not_busy
                lda #(LCD_DISPLAY_CTRL)
                sta LCD_COMMAND
    
        ; clear display
                _await_not_busy
                lda #LCD_CLEAR_DISPLAY
                sta LCD_COMMAND

        ; entry mode set: direction and auto-shift
                _await_not_busy
                tya                     ; recover config bits
                and #(LCD_ENTRY_MODE_SET | LCD_INCREMENT | LCD_WITH_SHIFT)
                ora #LCD_ENTRY_MODE_SET
                sta LCD_COMMAND

                rts


;-----------------------------------------------------------------------
; lcd8_on:
; Turns on the LCD display.
;
; On entry:
;       A = bit mask with either of LCD_CURSOR_ON and LCD_BLINK_ON set
;
lcd8_on:
                _await_not_busy
                and #(LCD_DISPLAY_CTRL | LCD_DISPLAY_ON | LCD_CURSOR_ON | LCD_BLINK_ON)
                ora #(LCD_DISPLAY_CTRL | LCD_DISPLAY_ON)
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_off:
; Turns off the LCD display.
;
lcd8_off:
                _await_not_busy
                lda #LCD_DISPLAY_CTRL
                sta LCD_COMMAND
                rts



;-----------------------------------------------------------------------
; lcd8_clear:
; Clears the LCD display.
;
lcd8_clear:
                _await_not_busy
                lda #LCD_CLEAR_DISPLAY
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_home:
; Returns the LCD cursor to the home position.
;
lcd8_home:
                _await_not_busy
                lda #LCD_RETURN_HOME
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_lmove:
; Moves the cursor left by one position.
;
lcd8_lmove:
                _await_not_busy
                lda #(LCD_DISPLAY_SHIFT | LCD_MOVE_CURSOR | LCD_LEFT)
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_rmove:
; Moves the cursor right by one position.
;
lcd8_rmove:
                _await_not_busy
                lda #(LCD_DISPLAY_SHIFT | LCD_MOVE_CURSOR | LCD_RIGHT)
                sta LCD_COMMAND
                rts



;-----------------------------------------------------------------------
; lcd8_moveto:
; Sets the DDRAM address to the specified value.
;
; On entry:
;       A = DDRAM address
;
lcd8_moveto:
                pha
                _await_not_busy
                pla
                ora #LCD_DDRAM_ADDRESS
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_lshift:
; Shifts the display left by one position.
;
lcd8_lshift:
                _await_not_busy
                lda #(LCD_DISPLAY_SHIFT | LCD_SHIFT_DISPLAY | LCD_LEFT)
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_rshift:
; Shifts the display right by one position.
;
lcd8_rshift:
                _await_not_busy
                lda #(LCD_DISPLAY_SHIFT | LCD_SHIFT_DISPLAY | LCD_RIGHT)
                sta LCD_COMMAND
                rts


;-----------------------------------------------------------------------
; lcd8_glyph_5x8:
; Writes a 5x8 glyph to CGRAM. Saves and restores the current DDRAM
; address.
;
; On entry:
;       A = CGRAM address
;       V = pointer to 8-byte glyph pattern
;       X, Y clobbered
;
lcd8_glyph_5x8:
                and #LCD_CGRAM_MASK                
                tay                     ; preserve CGRAM address

                lda LCD_COMMAND         ; fetch DDRAM address
                and #LCD_DDRAM_MASK
                pha                     ; preserve DDRAM address

                _await_not_busy
                tya                     ; recover CGRAM address
                ora #LCD_CGRAM_ADDRESS
                sta LCD_COMMAND         ; set CGRAM address

                ldx #8
                ldy #0
@loop:
                _await_not_busy
                lda (V),y               ; get glyph bits
                sta LCD_DATA            ; write to CGRAM
                iny
                dex
                bne @loop               ; until all eight rows written

                _await_not_busy
                pla                     ; recover DDRAM address
                ora #LCD_DDRAM_ADDRESS
                sta LCD_COMMAND         ; set DDRAM address

                rts


;-----------------------------------------------------------------------
; lcd8_putc:
; Writes a character to DDRAM at the current address. Assumes that the
; the address counter is currently addressing DDRAM.
;
; On entry:
;       A = the character to write
;
lcd8_putc:
                pha
                _await_not_busy
                pla
                sta LCD_DATA
                rts


;-----------------------------------------------------------------------
; lcd8_puts:
; Writes a null-terminated string to DDRAM starting at the current 
; address. Assumes that the the address counter is currently addressing
; DDRAM.
;
; On entry:
;       V = pointer to a null-terminated string
;
lcd8_puts:
                phy
                ldy #0
@loop:
                lda (V),y
                beq @done

                _await_not_busy
                lda (V),y
                sta LCD_DATA
                iny
                bra @loop
@done:
                ply
                rts

