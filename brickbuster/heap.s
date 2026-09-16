                .include "heap.h.s"
                .include "variables.h.s"


                .segment "HEAP"
heap_end:       .res 2


                .segment "CODE"

;-----------------------------------------------------------------------
; heap_init:
; Initializes the heap bump allocator.
;
heap_init:
                lda #<(heap_end + 2)
                sta heap_end
                lda #>(heap_end + 2)
                sta heap_end+1
                rts


;-----------------------------------------------------------------------
; heap_alloc:
; Allocates memory via the heap's bump allocator.
;
; On entry:
;       V = number of bytes to allocate
;
; On return:
;       AY = address of the allocation
;
heap_alloc:
                lda heap_end
                pha
                clc
                adc V
                sta heap_end
                lda heap_end+1
                pha
                adc V+1
                sta heap_end+1
                pla
                ply
                rts





