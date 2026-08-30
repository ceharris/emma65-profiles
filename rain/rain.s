                .include "display.h.s"
                .include "rain.h.s"
                .include "rand.h.s"
                .include "variables.h.s"

                .segment "CODE"

;-----------------------------------------------------------------------
; The matrix consists of a 40x25 grid stored in display memory. 
; 
; A cell in the matrix consists of two bytes; one byte in character RAM
; and one byte in color RAM. The byte in character RAM holds a randomly
; selected printable character. The byte in color RAM is an index into
; a palette consisting of black plus 13 gradually brighter green hues.
;-----------------------------------------------------------------------

                PROB_CHAR = 62258       ; 62258/65535 = 0.95
                PROB_DRIP = 42598       ; 42598/65535 = 0.65
                PROB_DIM = 36044        ; 36044/65535 = 0.55

                DRIP_LIVE = $80         ; drip live flag
                DRIP_BRIGHT = $40       ; drip bright flag

                DRIP_FLAGS = 0          ; drip flags field
                DRIP_CELL = 1           ; drip cell address field
                DRIPS_ROW = 3           ; drip row field

                BRIGHT_INTENSITY = 13
                NORMAL_INTENSITY = 4


;-----------------------------------------------------------------------
; rain_init:
; Initializes the matrix used to simulate digital rain.
;
rain_init:
                jsr cells_init
                jsr drips_init
                rts


;-----------------------------------------------------------------------
; rain_update:
; Updates the matrix used to simulate digital rain.
;
rain_update:
                lda #<PROB_DRIP
                sta C
                lda #>PROB_DRIP
                sta B
                jsr rand_cmp
                bcs @no_add_drip
                jsr drips_add  
@no_add_drip:
                jsr drips_update
                jsr cells_fade

                lda #1
                sta DISPLAY_CONTROL
                rts


;-----------------------------------------------------------------------
; cells_init:
; Initialize every cell of the matrix setting the character and palette
; index to zero.
;
cells_init:
                lda #<DISPLAY_CHAR_RAM
                sta W
                lda #>DISPLAY_CHAR_RAM
                sta W+1
        
                ldx #>(2*DISPLAY_SIZE)  ; number of whole pages
                ldy #0
                lda #0
@fill_page:
                sta (W),y
                iny
                bne @fill_page
                inc W+1                 ; next page address
                dex
                bne @fill_page
                ldy #<(2*DISPLAY_SIZE)  ; bytes in last page
                beq @done
@fill_rem:
                sta (W),y
                dey
                cpy #0
                bne @fill_rem
@done:
                rts


;-----------------------------------------------------------------------
; cells_fade:
; Update every cell of the matrix.
;
; On return:
;   B, C, V, W clobbered
;
cells_fade:
        ; set V to the start of character RAM
                lda #<DISPLAY_CHAR_RAM
                sta V
                lda #>DISPLAY_CHAR_RAM
                sta V+1
        ; set W to the start of color RAM
                lda #<DISPLAY_COLOR_RAM
                sta W
                lda #>DISPLAY_COLOR_RAM
                sta W+1

                ldx #>DISPLAY_SIZE
                ldy #0
@fade_page:
                jsr cell_fade
                iny
                bne @fade_page
                inc V+1
                inc W+1
                dex
                bne @fade_page
                ldy #<DISPLAY_SIZE
@fade_rem:
                dey
                jsr cell_fade
                cpy #0
                bne @fade_rem

                rts

;-----------------------------------------------------------------------
; cell_fade:
; Fades a cell.
;
; On entry:
;   (V),y = cell character
;   (W),y = cell intensity
;

cell_fade:
                lda (V),y               ; get cell character
                beq @choose_char    

        ; test threshold for choosing a different character
                lda #<PROB_CHAR
                sta C
                lda #>PROB_CHAR
                sta B
                jsr rand_cmp
                bcs @test_intensity     ; go if above threshold

@choose_char:        
                jsr rand_printable      ; A = random printable character
                sta (V),y               ; cell[x][y].c = A

@test_intensity:
                lda (W),y               ; get cell intensity
                beq @done               ; go if intensity is already zero
        
        ; test threshold for dimming the cell
                lda #<PROB_DIM
                sta C
                lda #>PROB_DIM
                sta B
                jsr rand_cmp
                bcs @done               ; go if above threshold

        ; decrement cell intensity
                lda (W),y
                dec
                sta (W),y
@done:
                rts

;
;-----------------------------------------------------------------------
; drips_init:
; Initialize the drip structs
;
; On return:
;   X, Y clobbered
;
drips_init:
                ldy #NUM_DRIPS * DRIP_SIZE
                ldx #0
                lda #0
@loop:
                sta drips_table,x
                inx
                dey
                bne @loop
                rts


;-----------------------------------------------------------------------
; drips_add:
; Adds a drip if possible.
;
; On return:
;   B, C clobbered
;
drips_add:
                ldy #NUM_DRIPS
                ldx #0

@test_drip:
                lda drips_table,x       ; load drip flags            
                bmi @skip_drip          ; go if drip live

        ; coin flip to determine if it's a bright drip
                rand_flip
                lda #DRIP_LIVE
                bcc @not_bright
                ora #DRIP_BRIGHT
@not_bright:
                sta drips_table,x       ; drips[i].flags = A

        ; randomly choose a column
                lda #DISPLAY_COLUMNS
                jsr rand_range          ; A = random column
        ; store address of cell color in drip struct
                clc
                adc #<DISPLAY_COLOR_RAM
                inx                     ; X = DRIP_CELL (lower)
                sta drips_table,x       ; drips[i].cell (lower) = column offset
                lda #>DISPLAY_COLOR_RAM
                adc #0
                inx                     ; X = DRIP_CELL (upper)
                sta drips_table,x       ; drips[i].cell (upper) = column offset
        ; set number of rows to visit
                inx                     ; X = DRIP_ROW
                lda #DISPLAY_ROWS
                sta drips_table,x       ; drips[i].row = DISPLAY_ROWS
                rts

@skip_drip:
        ; set X to start of next drip struct
                txa
                clc
                adc #DRIP_SIZE
                tax
        ; check drip count
                dey
                bne @test_drip
                rts
                

;-----------------------------------------------------------------------
; drips_update:
; Updates all live drips.
;
drips_update:
                ldy #NUM_DRIPS
                ldx #0
@test_drip:
                lda drips_table,x       ; A = drip flags
                bpl @skip_drip          ; go if drip not live

                and #DRIP_BRIGHT
                beq @not_bright
                lda #BRIGHT_INTENSITY
                bra @store_intensity
@not_bright:
                lda #NORMAL_INTENSITY
@store_intensity:
                sta B
        
        ; transfer cell color address to W
                inx
                lda drips_table,x
                sta W
                inx 
                lda drips_table,x
                sta W+1
        ; copy color to color RAM at cell offset
                sty C
                lda B
                ldy #0
                sta (W),y
                ldy C
        ; compute cell color address in next row
                dex                     ; X = DRIP_CELL (lower)
                clc
                lda W
                adc #<DISPLAY_COLUMNS
                sta drips_table,x
                inx
                lda W+1
                adc #>DISPLAY_COLUMNS
                sta drips_table,x
        ; has the drip moved past end of screen?
                inx                     ; X = DRIP_ROW
                lda drips_table,x
                dec
                sta drips_table,x
                bne @next_drip
                inx

        ; clear drip flags so it is no longer live
                dex
                dex
                dex
                dex
                lda #0
                sta drips_table,x

@skip_drip:
        ; set Y to start of next drip struct
                inx
                inx
                inx
@next_drip:
                inx
        ; check drip count
                dey
                bne @test_drip

@done:
                rts

