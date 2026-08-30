                .include "variables.h.s"

                .segment "ZEROPAGE"


B:              .res 1
C:              .res 1
V:              .res 2
W:              .res 2

drips_table:    .res NUM_DRIPS*DRIP_SIZE
