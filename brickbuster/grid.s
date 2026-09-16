                .include "grid.h.s"
                .include "heap.h.s"
                .include "rand.h.s"
                .include "variables.h.s"

        .macro NEG
                eor #$ff
                inc
        .endmacro

                .segment "CODE"


;-----------------------------------------------------------------------
; grid_alloc:
; Allocate memory for the grid and for the table of Y offset addresses.
;
grid_alloc:
        
        ; determine size of Y offset table
                lda grid_height         ; number of grid rows
                asl                     ; numbef of Y-offset addresses
        
        ; set V = number of bytes to allocate
                sta VL
                stz VH
                jsr heap_alloc
    
        ; save pointer to Y offset table on heap
                sty grid_y_table
                sta grid_y_table+1

        ; zero the grid size variable
                stz grid_size
                stz grid_size+1

        ; initialize the table of Y offsets
                ldx grid_height         ; number of grid rows
                ldy #0                  ; table index
@loop1:
                lda grid_size           ; A = LSB of grid size
                sta (grid_y_table),y    ; store it is as Y offset LSB
                iny                     ; next table index
                clc 
                adc grid_width          ; increase by grid width
                sta grid_size           ; save LSB of updated size
                lda grid_size+1         ; A = MSB of grid size
                sta (grid_y_table),y    ; store it as Y offset MSB
                iny                     ; next table index
                adc #0                  ; fold in carry
                sta grid_size+1         ; save LSB of updated size
                dex                     ; decrement row count
                bne @loop1              ; go if more rows

        ; grid_size is now grid_height * grid_width
        ; allocate space for the grid
                LDV grid_size
                jsr heap_alloc

        ; save address of grid on heap
                sty grid_base                           
                sta grid_base+1         

        ; add the base address of the grid to every Y offset
                ldx grid_height         ; row count
                ldy #0                  ; table index
@loop2:
                lda (grid_y_table),y    ; A = LSB of Y offset
                clc 
                adc grid_base           ; add grid_base LSB
                sta (grid_y_table),y    ; store result LSB
                iny                     ; next table index
                lda (grid_y_table),y    ; A = MSB of Y offset
                adc grid_base+1         ; add grid_base MSB
                sta (grid_y_table),y    ; store result MSB
                iny                     ; next table index
                dex                     ; decrement row count
                bne @loop2              ; go if more rows
                rts


;-----------------------------------------------------------------------
; grid_init:
; Initializes the grid.
;
grid_init:
                jsr _grid_zero
                jsr _grid_borders

                
        ; ; set initial X, Y to middle of screen
        ;         lda grid_width
        ;         lsr                     ; half of grid width
        ;         sta ball_x
                
        ;         lda grid_height
        ;         lsr                     ; half of grid height
        ;         sta ball_y

                lda #4
                sta ball_x
                lda #4
                sta ball_y

                asl                     ; two bytes per table entry
                tay                     ; table index
                LDV grid_y_table
                lda (V),y               ; get LSB of row address
                sta ball_addr           ; save LSB
                iny
                lda (V),y               ; get MSB of row address
                sta ball_addr+1         ; save MSB
            
                clc 
                lda ball_x        
                adc ball_addr           ; add column offset to row address
                sta ball_addr           ; store LSB of ball address
                lda ball_addr+1 
                adc #0                  ; fold carry into address MSB
                sta ball_addr+1         ; store MSB of ball address

                lda #$ff
                sta ball_vec_x
                sta ball_vec_y
                rts


;-----------------------------------------------------------------------
; grid_advance:
; Advances the game grid by one frame.
;
grid_advance:
                lda ball_x
                sta ball_prev_x
                lda ball_y
                sta ball_prev_y
                lda ball_addr
                sta ball_prev_addr
                lda ball_addr+1
                sta ball_prev_addr+1
@again:
                jsr _grid_ball_next
                lda (ball_addr)
                beq @done
                and #GRID_BORDER
                bne @border
                lda (ball_addr)
                and #GRID_CORNER
                bne @ricochet_reverse
@done:
                rts

@border:
                lda (ball_addr)
                cmp #GRID_BORDER_TOP
                beq @ricochet_horiz
                cmp #GRID_BORDER_LEFT
                beq @ricochet_vert
                cmp #GRID_BORDER_RIGHT
                beq @ricochet_vert
                
@ricochet_horiz:
                lda ball_vec_y
                NEG
                sta ball_vec_y
                bra @again

@ricochet_vert:
                lda ball_vec_x
                NEG
                sta ball_vec_x
                bra @again

@ricochet_reverse:
                lda ball_vec_x
                NEG
                sta ball_vec_x
                lda ball_vec_y
                NEG
                sta ball_vec_y
                bra @again


_grid_ball_next:
                lda ball_vec_y
                bpl @move_south

        ; move north
                lda ball_prev_y
                dec
                sta ball_y
                sec                
                lda ball_prev_addr
                sbc grid_width
                sta ball_addr
                lda ball_prev_addr+1
                sbc #0
                sta ball_addr+1
                bra @check_x

        ; move south
@move_south:
                lda ball_prev_y
                inc
                sta ball_y
                clc
                lda ball_prev_addr
                adc grid_width
                sta ball_addr
                lda ball_prev_addr+1
                adc #0
                sta ball_addr+1

@check_x:
                lda ball_vec_x
                bpl @move_right

        ; move left
                lda ball_prev_x
                dec
                sta ball_x
                lda ball_addr
                bne @no_borrow
                dec ball_addr+1
@no_borrow:
                dec ball_addr
                bra @done

        ; move right
@move_right:
                lda ball_prev_x
                inc
                sta ball_x
                inc ball_addr
                bne @done
                inc ball_addr+1

@done:
                rts


;-----------------------------------------------------------------------
; _grid_zero: 
; Zeroes out every cell of the grid
;
_grid_zero:
                LDV grid_base           ; V = grid base address
                lda #0                  ; fill value
                ldx grid_size+1         ; number of whole pages
                beq @remainder          ; go if MSB is zero
@next_page:
                ldy #0
@next_page_byte:
                sta (V),y
                iny
                bne @next_page_byte
                inc VH
                dex
                bne @next_page
@remainder:
                ldx grid_size           ; number of remainder bytes
                ldy #0
@next_remaining_byte:
                sta (V),y
                iny
                dex
                bne @next_remaining_byte

                rts            


;-----------------------------------------------------------------------
; _grid_borders:
; Marks the borders of the grid.
;
_grid_borders:
        ; fill top border
                ldy #0
                lda (grid_y_table),y
                sta VL
                iny
                lda (grid_y_table),y
                sta VH
            
                ldy #0
                lda #GRID_CORNER_TOP_LEFT
                sta (V),y
                iny

                ldx grid_width          ; X = column count
                dex                     ; less left corner
                dex                     ; less right corner
        
                lda #GRID_BORDER_TOP
@fill_top:
                sta (V),y
                iny
                dex
                bne @fill_top

                lda #GRID_CORNER_TOP_RIGHT
                sta (V),y

        ; fill side borders
                lda grid_height
                dec
                dec
                sta C                   ; C = number of side borders

                ldy #2                  ; Y = table index
 @fill_sides:
                lda (grid_y_table),y
                sta VL
                iny
                lda (grid_y_table),y
                sta VH
                iny

                sty B
                lda #GRID_BORDER_LEFT
                ldy #0
                sta (V),y
                ldy grid_width
                dey
                lda #GRID_BORDER_RIGHT
                sta (V),y
                
                ldy B
                dec C
                bne @fill_sides

        ; fill bottom border
                lda (grid_y_table),y
                sta VL
                iny
                lda (grid_y_table),y
                sta VH
                iny
        
                ldy #0
                lda #GRID_CORNER_BOTTOM_LEFT
                sta (V),y
                iny

                lda #GRID_BORDER_BOTTOM
                ldx grid_width
                dex                     ; less left corner
                dex                     ; less right corner
@fill_bottom:
                sta (V),y
                iny
                dex
                bne @fill_bottom

                lda #GRID_CORNER_BOTTOM_RIGHT
                sta (V),y
                rts
