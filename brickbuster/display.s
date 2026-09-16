
                .include "ascii.h.s"
                .include "console.h.s"
                .include "decimal.h.s"
                .include "display.h.s"
                .include "grid.h.s"
                .include "variables.h.s"
                .include "via.h.s"
                

                .segment "CODE"


;-----------------------------------------------------------------------
; ui_init_size:
; Determines the size of the playing field.
;
ui_init_size:
                ldy #3                  ; retry up to 3 times
@again:
        ; try to move cursor to an absurd position
                LDWI _absurd_cursor_position
                jsr console_puts
        
        ; send cursor position request
                LDWI _cursor_position_request
                jsr console_puts
        
        ; allow time for the terminal to respond
                lda #25                 ; delay for 250 milliseconds
                jsr via_t1_delay        

        ; read actual cursor position
                jsr console_getcp
                cmp #ESC
                beq @got_esc
@retry:
                jsr console_drain
                dey
                bne @again
                bra @error
@got_esc:
                jsr console_getcp
                cmp #'['
                bne @retry

        ; read row position
                ldx #0
@row_loop:
                jsr console_getcb
                cmp #';'
                beq @row_finish
                cmp #'0'
                bcc @error
                cmp #('9' + 1)
                bcs @error
                sta _cursor_row,x
                inx
                bra @row_loop
@row_finish:
                stz _cursor_row,x

        ; read column position
                ldx #0
@col_loop:
                jsr console_getcb
                cmp #'R'
                beq @col_finish
                cmp #'0'
                bcc @error
                cmp #('9' + 1)
                bcs @error
                sta _cursor_column,x
                inx
                bra @col_loop
@col_finish:
                stz _cursor_column,x

        ; convert the row number string
                LDVI _cursor_row
                jsr acd_to_bin8

        ; save height in screen and grid rows
                sta screen_height
                dec                     ; lose one in case there's a status line
                sta grid_height

        ; convert the column number string
                LDVI _cursor_column
                jsr acd_to_bin8

        ; save width in screen and grid columns
                sta screen_width
                lsr                     ; two screen columns per grid column
                sta grid_width
                clc
                rts

@error:
                LDWI _setup_error
                jsr console_puts
                sec
                rts


ui_init:
                LDWI _init_display
                jsr console_puts
                
                LDV grid_base
                ldx grid_size+1
                beq @remainder
@next_page:
                ldy #0
@next_page_byte:
                lda (V),y
                jsr _write_cell
                iny
                bne @next_page_byte
                inc VH
                dex
                bne @next_page

@remainder:
                ldx grid_size
                ldy #0
@next_rem_byte:
                lda (V),y
                jsr _write_cell
                iny
                dex
                bne @next_rem_byte
                rts

_write_cell:
                beq @empty
                cmp #GRID_BORDER_TOP
                beq @lower_half
                cmp #GRID_BORDER_BOTTOM
                beq @upper_half
                cmp #GRID_BORDER_LEFT
                beq @right_half
                cmp #GRID_BORDER_RIGHT
                beq @left_half
                cmp #GRID_CORNER_TOP_LEFT
                beq @quad_lower_right
                cmp #GRID_CORNER_TOP_RIGHT
                beq @quad_lower_left
                cmp #GRID_CORNER_BOTTOM_LEFT
                beq @quad_upper_right
                cmp #GRID_CORNER_BOTTOM_RIGHT
                beq @quad_upper_left

@empty:
                lda #' '
                sta CONSOLE_IO
                lda #' '
                sta CONSOLE_IO
                rts

@lower_half:
                lda #$84
                jsr @block_element
                bra @block_element
@upper_half:
                lda #$80
                jsr @block_element
                bra @block_element
@right_half:
                lda #$20
                sta CONSOLE_IO
                lda #$90
                bra @block_element
@left_half:
                lda #$8C
                jsr @block_element
                lda #$20
                sta CONSOLE_IO
                rts 
@quad_lower_right:
                lda #$20
                sta CONSOLE_IO
                lda #$97
                bra @block_element
@quad_lower_left:
                lda #$96
                jsr @block_element
                lda #$20
                sta CONSOLE_IO
                rts
@quad_upper_right:
                lda #$20
                sta CONSOLE_IO
                lda #$9d
                bra @block_element
@quad_upper_left:
                lda #$98
                jsr @block_element
                lda #$20
                sta CONSOLE_IO
                rts
@block_element:
                sta C
                lda #$e2
                sta CONSOLE_IO
                lda #$96
                sta CONSOLE_IO
                lda C
                sta CONSOLE_IO
                rts

ui_cleanup:
                LDWI _restore_display
                jsr console_puts
                rts

ui_advance:
                lda ball_x
                sta E
                lda ball_y
                sta D
                jsr _show_ball
                
                lda ball_prev_x
                sta E
                lda ball_prev_y
                sta D
                jsr _hide_ball
                rts



;----------------------------------------------------------------------
; _hide_ball:
; Hides the ball by displaying two spaces at it's screen position
;
; On entry:
;       D = y-coordinate
;       E = x-coordinate
;
_hide_ball:
                jsr _move_to_ball
                jsr _reset_attrs
                lda #' '
                sta CONSOLE_IO
                sta CONSOLE_IO
                rts


;----------------------------------------------------------------------
; _show_ball:
; Displays the ball as a sequence of two full block characters
;
; On entry:
;       D = y-coordinate
;       E = x-coordinate
;
_show_ball:
                jsr _move_to_ball
                jsr _reset_attrs
                jsr @block_char

@block_char:
                lda #$e2
                sta CONSOLE_IO
                lda #$96
                sta CONSOLE_IO
                lda #$88
                sta CONSOLE_IO
                rts

    

;-----------------------------------------------------------------------
; _move_to_ball:
; Move the cursor to the ball's position on screen.
;
; On entry:
; On entry:
;       D = y-coordinate
;       E = x-coordinate
;
_move_to_ball:
        ; send CSI
                lda #ESC
                sta CONSOLE_IO
                lda #'['
                sta CONSOLE_IO
        ; send ASCII decimal row position
                lda D
                inc
                jsr bin8_to_bcd
                lda VL
                jsr _pbcd8n
        ; send separator
                lda #';'
                sta CONSOLE_IO
        ; send ASCII decimal column position
                lda E
                asl
                inc
                jsr bin8_to_bcd
                lda VL
                jsr _pbcd8n
        ; send ANSI cursor position (CUP) command
                lda #'H'
                sta CONSOLE_IO
                rts


;-----------------------------------------------------------------------
; _reset_attrs:
; Sends the ANSI sequence needed to reset all display attributes
;
_reset_attrs:
                lda #ESC
                sta CONSOLE_IO
                lda #'['
                sta CONSOLE_IO
        ; send attribute 0 (all attributes off)
                lda #'0'
                sta CONSOLE_IO
        ; send ANSI Set Graphic Rendition (SGR) command
                lda #'m'
                sta CONSOLE_IO
                rts


;-----------------------------------------------------------------------
; _pbcd16:
; Prints a 16-bit BCD value.
;
; On entry:
;       V = 16-bit BCD value to print
;
_pbcd16:
                lda VH
                cmp #0                  ; is MSB zero?
                bne @print_msb          ; go print it
                lda #SPC                ; print spaces
                sta CONSOLE_IO          ; instead of
                sta CONSOLE_IO          ; leading zeros
                bra @print_lsb
@print_msb:
                jsr _pbcd8              ; print MSB
                lda VH
                jsr _pbcd8u             ; print LSB
                rts
@print_lsb:
                txa
                jsr _pbcd8              ; print LSB
                rts

;-----------------------------------------------------------------------
; _pbcd8:
; Prints an 8-bit BCD value.
;
; On entry:
;       A = 8-bit BCD value to print
;
                ; ====== This entry point prints a leading space
                ; when leading digit is zero.
_pbcd8:
                pha
                and #$f0                ; is upper nibble non-zero?
                bne _pbcd_upper         ; go print it
                lda #SPC                ; print space instead
                sta CONSOLE_IO          ; of leading zero
                bra _pbcd_lower

                ; ====== This entry point skips the leading space
                ; when leading digit is zero.
_pbcd8n:
                pha
                and #$f0                ; is upper nibble non-zero?
                bne _pbcd_upper         ; go print it
                bra _pbcd_lower

                ; ====== This entry point prints a leading zero
                ; when leading digit is zero.
_pbcd8u:
                pha
_pbcd_upper:
                ; move upper nibble to lower nibble
                lsr
                lsr
                lsr
                lsr
                ; convert to ASCII digit
                clc
                adc #'0'
                sta CONSOLE_IO
_pbcd_lower:
                pla                     ; recover arg to print
                and #$0f                ; discard upper nibble
                ; convert to ASCII digit
                clc
                adc #'0'
                sta CONSOLE_IO
                rts

                
                .segment "BSS"
_cursor_row:
                .res 4
_cursor_column:
                .res 4


                .segment "RODATA"

_init_display:
                .byte ESC, "[0m"        ; reset all attributes
                .byte ESC, "[?7h"       ; enable auto wrap
                .byte ESC, "[?25l"      ; hide cursor
                .byte ESC, "[H"         ; move cursor to top corner
                .byte ESC, "[J"         ; erase display
                .byte 0

_restore_display:
                .byte ESC, "[0m"        ; reset all attributes
                .byte ESC, "[?7l"       ; disable auto wrap
                .byte ESC, "[?25h"      ; show cursor
                .byte ESC, "[H"         ; move cursor to top corner
                .byte ESC, "[J"         ; erase display
                .byte 0

_absurd_cursor_position:
                .byte CR, LF
                .byte ESC, "[999;999H"
                .byte 0

_cursor_position_request:
                .byte ESC, "[6n"
                .byte 0

_setup_error:
                .byte "Cannot determine screen dimensions", CR, LF, 0
        



