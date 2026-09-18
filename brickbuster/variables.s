                .include "variables.h.s"

                .segment "ZEROPAGE"

; Additional general purpose registers
B:              .res 1
C:              .res 1
D:              .res 1
E:              .res 1
V:
VL:             .res 1
VH:             .res 1
W:
WL:             .res 1
WH:             .res 1

; Grid width and height in cells
grid_width:     .res 1
grid_height:    .res 1

; Screen width and height in characters
screen_height:  .res 1
screen_width:   .res 1

; Address of the ball within the grid
ball_addr:      .res 2

; Components of a unit vector that defines ball direction 
ball_dx:        .res 1
ball_dy:        .res 1

; Grid coordinates of the ball
ball_x:         .res 1
ball_y:         .res 1

; Grid coordinates of ball's previous position
ball_prev_x:    .res 1
ball_prev_y:    .res 1

; Address of paddle row in grid
paddle_addr:    .res 2
; Grid X coordinate of paddle's left edge
paddle_x:       .res 1
paddle_y:       .res 1
; Grid X coordinate of paddle's next left edge position
paddle_next_x:  .res 1

grid_size:      .res 2
grid_base:      .res 2
grid_y_table:   .res 2
