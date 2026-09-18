                .include "display.h.s"
                .include "grid.h.s"
                .include "heap.h.s"
                .include "variables.h.s"
                .include "via.h.s"

                .segment "CODE"

                .global main
main:
                jsr ui_init_size
                jsr heap_init
                jsr grid_alloc
                jsr grid_init
                jsr ui_init
@loop:
                jsr grid_advance
                bcs @done
                jsr ui_advance
                lda #10
                jsr via_t1_delay
                bra @loop


@done:
                jsr ui_advance
                stp

