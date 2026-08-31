                .include "display.h.s"
                .include "life.h.s"
                .include "variables.h.s"

                CELLS = PIXEL_MEM
                LIVE_CELL = 11

                .segment "CODE"


;-----------------------------------------------------------------------
; life_init:
; Initializes state for the game-of-life simulation. Call this once
; at startup.
;
; On entry:
;       V = address of an initialization vector, consisting of
;           a one-byte unsigned pair count N, followed by N pairs 
;           of signed bytes. Each pair contains an X coordinate, 
;           followed by a Y-coordinate, in a cartesian coordinate 
;           system whose center is the midpoint of the width and 
;           height of the cell array.
;
life_init:
                jsr _init_cells
                jsr _init_for_rect_space
                jsr _init_using_vector
                rts


;-----------------------------------------------------------------------
; life_update:
; Executes the game-of-life algorithm on the current state of the cell
; array, producing the next generation.
; 
life_update:
        ; preserve state of row 0
                jsr _copy_0_to_row_0
      
        ; copy row N-1 into row_i buffer 
                jsr _copy_N_1_to_row_i

        ; copy row 0 into row_j buffer
                lda #<CELLS
                sta VL
                sta WL                  ; also set W to start of cell array
                lda #>CELLS
                sta VH
                sta WH                  ; also set W to start of cell array
                jsr _copy_to_row_j

        ; init row counter
                lda #(HEIGHT - 1)
                sta C
 
 @loop:               
        ; copy row k (k = j + 1) into row_k buffer
                clc
                lda VL
                adc #WIDTH
                sta VL
                lda VH
                adc #0
                sta VH
                jsr _copy_to_row_k

        ; evaluate cells of row j
                jsr _eval_cells
        
        ; copy buffers up
                jsr _copy_row_j_to_i
                jsr _copy_row_k_to_j

                dec C
                bne @loop

                jsr _copy_row_0_to_k
        
        ; evaluate cells of row N - 1
                jsr _eval_cells

                rts


;-----------------------------------------------------------------------
; _eval_cells:
; Evaluates the row of cells represented by evaluation buffer `row_j`
; with neighbor buffers `row_i` and `row_k`. The first column to
; evaluate is at index 1 and runs through WIDTH (inclusive). The
; margins of each row, at index 0 and index WIDTH+1 are assumed to 
; contain appropriate neighbor values for the selected plane type.
;
; On return:
;       cells in the cell array corresponding to those in the evaluation
;       buffer are modified according to the Game of Life algorithm.
;
_eval_cells:
        ; X = index of column 0 in evaluation buffer
                ldx #1                  ; start at the first column
        ; Y = index relative to address of cell array row in W
                ldy #0

@loop:
        ; determine new state of cell
                jsr _eval_cell

        ; store new cell state
                sta (W),y
                iny
                inx

        ; check for end of row
                cpy #WIDTH
                bne @loop
 
        ; W = address of next row
                clc
                lda WL
                adc #WIDTH
                sta WL
                lda WH
                adc #0
                sta WH
        
                rts


;-----------------------------------------------------------------------
; _eval_cell:
; Evaluates the cell in `row_j` at index X with neighbor buffers 
; `row_i` and `row_k`. The margins of each row, at index 0 and index 
; WIDTH+1 are assumed to  contain appropriate neighbor values for the 
; selected plane type.
;
; On entry:
;       X = index into row for the current column
;
; On return:
;       A is non-zero if cell is live
;
_eval_cell:
                sty B                   ; preserve Y
                ldy #0                  ; init sum of living cells        

        ; cell (X - 1, Y - 1)
                lda row_i-1,x
                beq @cell_x_y_m1        ; go if not live
                iny                     ; count live cell

        ; cell (X, Y - 1)
@cell_x_y_m1:
                lda row_i,x
                beq @cell_x_p1_y_m1     ; go if not live
                iny                     ; count live cell

        ; cell (X + 1, Y - 1)
@cell_x_p1_y_m1:
                lda row_i+1,x
                beq @cell_x_m1_y        ; go if not live
                iny                     ; count live cell

        ; cell (X - 1, Y)
@cell_x_m1_y:
                lda row_j-1,x
                beq @cell_x_y           ; go if not live
                iny                     ; count live cell

        ; cell (X, Y)
@cell_x_y:
                lda row_j,x
                beq @cell_x_p1_y        ; go if not live
                iny                     ; count live cell

        ; cell (X + 1, Y)
@cell_x_p1_y:
                lda row_j+1,x
                beq @cell_x_m1_y_p1     ; go if not live
                iny                     ; count live cell

        ; cell (X - 1, Y + 1)
@cell_x_m1_y_p1:
                lda row_k-1,x
                beq @cell_x_y_p1        ; go if not live
                iny                     ; count live cell

        ; cell (X, Y + 1)
@cell_x_y_p1:
                lda row_k,x
                beq @cell_x_p1_y_p1     ; go if not live
                iny                     ; count live cell

        ; cell (X + 1, Y + 1)
@cell_x_p1_y_p1:
                lda row_k+1,x
                beq @sum_done           ; go if not live
                iny                     ; count live cell

@sum_done:
                tya
                ldy B                   ; recover Y
                cmp #3
                bcc @death
                beq @life
                cmp #4
                bne @death

        ; cell state is unchanged
                lda row_j,x
                rts

        ; cell is now dead
@death:
                lda #0
                rts
        ; cell is now live
@life:
                lda #LIVE_CELL
                rts


;-----------------------------------------------------------------------
; _copy_0_to_row_0:
; Copies row zero of the cell matrix to a buffer `row_0`, such that 
; its pristine state can be used with evaluating row N-1.
;
; On return:
;       row_0[0..WIDTH) = CELLS[0..WIDTH)
;       X clobbered
;
_copy_0_to_row_0:
                ldx #0
@loop:
                lda CELLS,x
                sta row_0,x
                inx
                cpx #WIDTH
                bne @loop
                rts


;-----------------------------------------------------------------------
; _copy_row_0_to_k:
; Copies buffer `row_0` to `row_k`. The copy is performed such that the
; first and last bytes of buffer `row_k` are undisturbed.
;
; On return:
;       row_i[1..WIDTH+1) = row_0[0..WIDTH)
;       X clobbered
;
_copy_row_0_to_k:
                ldx #0
@loop:
                lda row_0,x
                inx
                sta row_k,x
                cpx #WIDTH
                bne @loop
                rts


;-----------------------------------------------------------------------
; _copy_to_row_j:
; Copies the row whose first cell is addressed by V to evaluation buffer
; `row_j`. The copy is performed such that the first and last bytes of
; buffer `row_j` are undisturbed.
;
; On return:
;       row_j[1..WIDTH+1) = V[0..WIDTH)
;       X, Y clobbered
;
_copy_to_row_j:
                ldx #1
                ldy #0
@loop:
                lda (V),y
                sta row_j,x
                inx
                iny
                cpy #WIDTH
                bne @loop
                rts


;-----------------------------------------------------------------------
; _copy_to_row_k: 
; Copies the row whose first cell is addressed by V to evaluation buffer
; `row_k`. The copy is performed such that the first and last bytes of
; buffer `row_k` are undisturbed.
;
; On return:
;       row_k[1..WIDTH+1) = V[0..WIDTH)
;       X, Y clobbered
;
_copy_to_row_k:
                ldx #1
                ldy #0
@loop:
                lda (V),y
                sta row_k,x
                inx
                iny
                cpy #WIDTH
                bne @loop
                rts


;-----------------------------------------------------------------------
; _copy_row_j_to_i:
; Copies evaluation buffer `row_j` to `row_i`.
;
; On return:
;       row_i[0..WIDTH+2) = row_j[0..WIDTH+2)
;       X clobbered
;
_copy_row_j_to_i:
                ldx #0
@loop:
                lda row_j,x
                sta row_i,x
                inx
                cpx #WIDTH+2
                bne @loop
                rts


;-----------------------------------------------------------------------
; _copy_row_k_to_j:
; Copies evaluation buffer `row_k` to `row_j`.
;
; On return:
;       row_j[0..WIDTH+2) = row_k[0..WIDTH+2)
;       X clobbered
;
_copy_row_k_to_j:
                ldx #0
@loop:
                lda row_k,x
                sta row_j,x
                inx
                cpx #WIDTH+2
                bne @loop
                rts


;-----------------------------------------------------------------------
; _copy_N_1_to_row_i:
; Copies the last row of the cell array to evaluation buffer `row_i`.
; The copy is performed such that the first and last bytes of buffer 
; `row_i` are undisturbed.
;
; On return:
;       row_i[1..WIDTH+2) = CELLS[WIDTH*(HEIGHT -1)..WIDTH*HEIGHT)
;       X clobbered
;
_copy_N_1_to_row_i:
                ldx #0
@loop:
                lda CELLS + WIDTH*(HEIGHT -1),x
                inx
                sta row_i,x
                cpx #WIDTH+1
                bne @loop
                rts


;-----------------------------------------------------------------------
; _init_cells:
; Initialize all cells to zero.
;
; On return:
;       X, Y clobbered
;       W clobbered
;
_init_cells:
        ; V = start of the cell array
                lda #<CELLS
                sta WL
                lda #>CELLS
                sta WH

                ldx #HEIGHT             ; number of rows to init
@fill_row:
                ldy #0                  ; start in column 0
@fill_cell:
                lda #0                  
                sta (W),y               ; zero out cell
                iny                     ; next column
                cpy #WIDTH              ; past end of row?
                bne @fill_cell          ; go if still within row

        ; V = start of the next row
                clc             
                lda WL
                adc #WIDTH
                sta WL
                bcc @next_row
                inc WH

        ; check whether all rows have been initialized
@next_row:
                dex                     
                bne @fill_row           ; go if still more rows

                rts


;-----------------------------------------------------------------------
; _init_for_rect_space:
; Initializes the evaluation buffers for a rectangular space, in which
; the peripheral edges of the space are invariably lifeless.
;
; On return:
;       X clobbered
;
_init_for_rect_space:
                stz row_i
                stz row_i + WIDTH + 1
                stz row_j
                stz row_j + WIDTH + 1
                stz row_k
                stz row_k + WIDTH + 1
                rts
 
;-----------------------------------------------------------------------
; _init_using_vector:
; Initializes live cells using the state vector addressed by V.
;
; On entry:
;       V = address of state vector as described for `life_init`.
;
; On return:
;      cells address by each pair in the vector are live
;       X, Y, B, W clobbered
;
 _init_using_vector:
        ; X = the number of pairs in the vector
                ldy #0
                lda (V),y
                tax

        ; Y = index of X-coordinate in first pair
                iny                   
@loop:
                jsr _init_using_pair
        ; Y = index of next pair
                iny
                iny             
        ; decrement remaining pair count
                dex
                bne @loop
                rts


;-----------------------------------------------------------------------
; _init_using_pair:
; Initialize a live cell addressed by the coordinate pair addressed 
; by (V),y
;
; On entry:
;       V = address of pair table
;       Y = offset to the subject X-coordinate
;
; On return:
;       (V),y is a live cell
;       B, W clobbered
;
_init_using_pair:
        ; W = address of top-left grid corner
                lda #<CELLS
                sta WL
                lda #>CELLS
                sta WH

        ; A = Y-coordinate relative to origin at top-left corner
                iny
                lda (V),y
                eor #$ff                ; complement and
                inc                     ;   add one to negate
                clc
                adc #(HEIGHT / 2)

        ; W += Y-coordinate multiplied by WIDTH
                beq @x_offset
                stx B                   ; preserve X
                tax                     ; X = multiplier
@y_multiply:
                clc
                lda WL
                adc #WIDTH
                sta WL
                lda WH
                adc #0
                sta WH
                dex
                bne @y_multiply
                ldx B                   ; recover X
@x_offset:
        ; A = X-coordinate relative to origin at midpoint
                dey
                lda (V),y               ; get X-coordinate
                clc
                adc #(WIDTH / 2)

                sty B                   ; preserve Y
                tay                     ; Y = offset for X-coordinate

        ; make cell addressed by (W),y live
                lda #LIVE_CELL
                sta (W),y
                ldy B                   ; recover Y
                rts


                .segment "RODATA"

L_heptomino:
                .feature force_range
                .byte 7                 ; Number of pairs
                .byte 0, 0              ; Each pair gives an XY-coordinate
                .byte -1, 0             ; with the origin assumed to be at
                .byte -1, -1            ; the center point of the grid.
                .byte -1, -2
                .byte -2, -2
                .byte 0, 1
                .byte 1, 1