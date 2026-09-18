        .ifndef VARIABLES_H
                VARIABLES_H = 1

                .globalzp B
                .globalzp C
                .globalzp D
                .globalzp E
                .globalzp V
                .globalzp VL
                .globalzp VH
                .globalzp W
                .globalzp WL
                .globalzp WH

                .globalzp grid_width
                .globalzp grid_height
                .globalzp screen_width
                .globalzp screen_height

                .globalzp ball_addr
                .globalzp ball_dx
                .globalzp ball_dy
                .globalzp ball_x
                .globalzp ball_y
                .globalzp ball_prev_x
                .globalzp ball_prev_y

                .globalzp paddle_addr
                .globalzp paddle_x
                .globalzp paddle_y
                .globalzp paddle_next_x

                .globalzp grid_size
                .globalzp grid_base
                .globalzp grid_y_table

        .macro LDVI addr
                lda #<addr
                sta VL
                lda #>addr
                sta VH
        .endmacro

        .macro LDV addr
                lda addr
                sta VL
                lda addr+1
                sta VH
        .endmacro

        .macro LDWI addr
                lda #<addr
                sta WL
                lda #>addr
                sta WH
        .endmacro

        .macro LDW addr
                lda addr
                sta WL
                lda addr+1
                sta WH
        .endmacro

        
        .endif

