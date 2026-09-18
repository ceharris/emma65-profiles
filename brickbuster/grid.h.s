        .ifndef GRID_H
                GRID_H = 1

                GRID_BORDER              = %100
                GRID_BORDER_TOP          = %100
                GRID_BORDER_LEFT         = %101
                GRID_BORDER_RIGHT        = %110
                GRID_CORNER              = %1000
                GRID_CORNER_TOP_LEFT     = %1000
                GRID_CORNER_TOP_RIGHT    = %1001

                GRID_PADDLE              = %10000
                GRID_PADDLE_LEFT         = %10000
                GRID_PADDLE_MID_LEFT     = %10001
                GRID_PADDLE_RIGHT        = %10010
                GRID_PADDLE_MID_RIGHT    = %10011

                GRID_EDGE                = %11111111

                .global grid_alloc
                .global grid_init
                .global grid_advance
        
        .endif

