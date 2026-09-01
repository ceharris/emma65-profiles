                .include "variables.h.s"

                .segment "ZEROPAGE"

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

surface_type:   .res 1


                .segment "BSS"

row_0:          .res WIDTH
                .align 16
row_i:          .res WIDTH + 2
                .align 16
row_j:          .res WIDTH + 2
                .align 16
row_k:          .res WIDTH + 2