        .ifndef GRID_H
                GRID_H = 1

                GRID_BORDER              = %0100
                GRID_BORDER_TOP          = %0100
                GRID_BORDER_LEFT         = %0101
                GRID_BORDER_RIGHT        = %0110
                GRID_BORDER_BOTTOM       = %0111
                GRID_CORNER              = %1000
                GRID_CORNER_TOP_LEFT     = %1000
                GRID_CORNER_TOP_RIGHT    = %1001
                GRID_CORNER_BOTTOM_LEFT  = %1010
                GRID_CORNER_BOTTOM_RIGHT = %1011

                .global grid_alloc
                .global grid_init
                .global grid_advance
        
        .endif

