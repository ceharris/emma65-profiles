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
                jsr _grid_paddle

                
        ; ; set initial X, Y to middle of screen
        ;         lda grid_width
        ;         lsr                     ; half of grid width
        ;         sta ball_x
                
        ;         lda grid_height
        ;         lsr                     ; half of grid height
        ;         sta ball_y

                lda #3
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

                lda #$1
                sta ball_dx
                sta ball_dy
                rts


;-----------------------------------------------------------------------
; grid_advance:
; Advances the game grid by one frame.
;
grid_advance:
        ; transfer current ball location detail to previous
                lda ball_x
                sta ball_prev_x
                lda ball_y
                sta ball_prev_y
            
        ; look ahead at horizontal and vertical neighbors of current position

                jsr _grid_x_neighbor    ; V = horizontal neighbor address
                lda (V)
                sta B                   ; B = horizontal neighbor

                jsr _grid_y_neighbor    ; W = vertical neighbor address
                lda (W)
                sta C                   ; C = vertical neighbor

        ; check for edge of playing area
                bpl @live_ball          ; go if still alive

        ; bottom edge: dead ball
                sec                     ; indicate ball is dead
                rts

        ; ball still live: determine how ball advances
@live_ball:
                bne @has_y_neighbor
                lda B                   ; fetch horizontal neighbor
                bne @side_border
        
        ; no neighbor in either direction: no change in direction
                bra @advance            ; advance as normal

        ; has a vertical neighbor: negate vertical direction component
@has_y_neighbor:
                lda ball_dy
                NEG
                sta ball_dy
                jsr _grid_y_neighbor    ; W = new vertical neighbor address

        ; what did the ball strike?
                lda C                   ; fetch vertical neighbor
                cmp #GRID_BORDER_TOP    
                beq @top_border         ; go if top border
                and #GRID_PADDLE_RIGHT
                bne @paddle_right       ; go if right side of paddle

        ; left side of paddle: horizontal component of direction is now west
                lda #$ff    
                sta ball_dx             ; ball_dx = -1
                lda C                   ; fetch vertical neighbor
                cmp #GRID_PADDLE_LEFT   ; left edge of paddle?
                beq @advance            ; advance as normal
        ; middle-left of paddle: advance Y only so all bricks can be struck
                bra @advance_y_only

        ; right side of paddle: horizontal component of direction is now east
@paddle_right:
                lda #1
                sta ball_dx             ; ball_dx = +1
                lda C                   ; fetch vertical neighbor
                cmp #GRID_PADDLE_RIGHT  ; right edge of paddle?
                beq @advance            ; advance as normal
        ; middle-right of paddle: advance Y only so all bricks can be struck
                bra @advance_y_only
    
        ; vertical neighbor is top border: check for corner
@top_border:
                lda B                   ; fetch horizontal neighbor           
                and #GRID_BORDER        ; check for border bit
                beq @advance            ; not a corner
                ; hit corner: negate horizontal component of direction, too

        ; side border: negate horizontal direction component
@side_border:
                lda ball_dx
                NEG
                sta ball_dx

        ; advance to new position according to (dx, dy)
@advance:
                lda ball_dx
                bmi @advance_west
        
        ; advance east
                inc ball_x              ; increment X coordinate
        ; new ball address is vertical neighbor address + 1
                inc WL
                bne @advance_y_only
                inc WH
                bra @advance_y_only

        ; advance west
@advance_west:
                dec ball_x              ; decrement X coordinate
        ; new ball address is vertical neighbor address - 1
                lda WL
                bne @no_borrow
                dec WH
@no_borrow:
                dec WL

        ; update Y coordinate and new ball address
@advance_y_only:
                clc
                lda ball_y              ; ball's current Y coordinate
                adc ball_dy             ; two's complement addition
                sta ball_y              ; store new Y coordinate
        ; ball_addr = W
                lda WL                 
                sta ball_addr
                lda WH
                sta ball_addr+1

                clc                     ; indicate ball is live
                rts    


;-----------------------------------------------------------------------
; _grid_x_neighbor:
; Determine address of ball's horizontal neighbor given current
; horizontal direction.
;
; On entry:
;       ball_dx = horizontal direction component
;       ball_addr = current address of ball in grid
;
; On return:
;       V = horizontal neighbor address
;
_grid_x_neighbor:
                lda ball_addr           ; fetch current ball address LSB
                sta VL                  ; store current LSB
                lda ball_addr+1         ; fetch current ball address MSB
                sta VH                  ; store current MSB

                lda ball_dx             ; fetch horizontal direction
                bmi @moving_west
        
        ; moving east -- lookahead one column to the right
                inc VL                  ; increment for cell to the right
                bne @done               ; go if no carry
                inc VH
                bra @done

        ; moving west -- lookahead one column to the left
@moving_west:
                lda VL                  ; fetch current ball address LSB
                bne @no_borrow          ; go if no need to borrow from MSB
                dec VH                  ; borrow from MSB
@no_borrow:
                dec VL                  ; decrement for cell to the left
@done:
                rts


;-----------------------------------------------------------------------
; _grid_y_neighbor:
; Determine address of ball's vertical neighbor given current vertical
; direction.
;
; On entry:
;       ball_dy = vertical direction component
;       ball_addr = current address of ball in grid
;
; On return:
;       W = vertical neighbor address
;
_grid_y_neighbor:
                lda ball_dy             ; fetch vertical direction
                bmi @moving_north

        ; moving south -- lookahead one row down
                clc             
                lda ball_addr           ; fetch current ball addr LSB
                adc grid_width          ; add width of row
                sta WL                  ; store LSB oflookahead address
                lda ball_addr+1         ; fetch current ball addr MSB    
                adc #0                  ; fold in carry from prev add
                sta WH                  ; store MSB of lookahead address
                rts
        
        ; moving north -- lookahead one row up
@moving_north:
                sec
                lda ball_addr           ; fetch current ball addr LSB
                sbc grid_width          ; subtract width of row
                sta WL                  ; store LSB of lookahead address
                lda ball_addr+1         ; fetch current ball addr MSB
                sbc #0                  ; fold in borrow from prev subtract
                sta WH                  ; store MSB of lookahead address

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
        
                lda #GRID_EDGE
                ldx grid_width
                ldy #0
@fill_bottom:
                sta (V),y
                iny
                dex
                bne @fill_bottom

                rts


;-----------------------------------------------------------------------
; _grid_paddle:
; Puts paddle segments in the center of the bottom edge of the grid.
;
_grid_paddle:
                lda grid_height         ; grid height in cells
                dec                     ; index of last row
                sta paddle_y            ; y-coordinate of paddle
                asl                     ; 2-bytes per table entry
                tay                     ; table index
        ; V = address of the last row
                lda (grid_y_table),y    ; row address LSB
                sta VL
                iny
                lda (grid_y_table),y    ; row address MSB
                sta VH
        ; V = address of left edge of paddle
                lda grid_width          ; grid width in cells
                lsr                     ; midpoint of screen
                dec                     ; less paddle middle left
                dec                     ; less paddle left
                sta paddle_x            ; x-coordinate of paddle
                clc                         
                adc VL                  ; add offset to row address LSB
                sta VL                  ; save paddle address LSB
                lda VH                  ; fetch row address MSB
                adc# 0                  ; fold in carry
                sta VH                  ; save paddle address MSB
        ; put paddle segments into last row
                ldy #0
                lda #GRID_PADDLE_LEFT
                sta (V),y
                iny
                lda #GRID_PADDLE_MID_LEFT
                sta (V),y
                iny
                lda #GRID_PADDLE_MID_RIGHT
                sta (V),y
                iny
                lda #GRID_PADDLE_RIGHT
                sta (V),y

        ; save address of paddle
                lda VL
                sta paddle_addr
                lda VH
                sta paddle_addr+1

                rts