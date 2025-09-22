.data
USER_PROMPT:     .asciz "Enter a 4-bit word (0-15) for decoding: "
ERROR_MESSAGE:   .asciz "No matching codeword found.\n"
DECODED_MSG:     .asciz "Decoded codeword: "
OUTPUT_RESULT:   .asciz "Output: "
REGISTER_MSG:    .asciz "Current register value: "
TRACE_MSG:       .asciz "DEBUG: Entering code section...\n"
CYCLES_MSG:      .asciz "Clock cycles: "
NEWLINE:         .asciz "\n"

stage1_reg:      .word 0
stage2_reg:      .word 0
stage3_reg:      .word 0
stage4_reg:      .word 0
received_c:      .word 0
cycle_count:     .word 0

.text
    .globl _start
_start:
    la      a0, USER_PROMPT
    li      a7, 4
    ecall

    li      a7, 5
    ecall
    la      t0, received_c
    sw      a0, 0(t0)

    li      t1, 0
    la      t2, cycle_count
    sw      t1, 0(t2)

    la      t3, stage1_reg
    sw      zero, 0(t3)
    la      t3, stage2_reg
    sw      zero, 0(t3)
    la      t3, stage3_reg
    sw      zero, 0(t3)
    la      t3, stage4_reg
    sw      zero, 0(t3)

    li      t4, 0
    li      t5, 8
    li      t6, 0

pipeline_loop:
    la      t3, stage1_reg
    sw      t4, 0(t3)
    addi    t4, t4, 1

    la      t3, received_c
    lw      t0, 0(t3)
    la      t3, stage1_reg
    lw      t1, 0(t3)
    xor     t2, t0, t1
    la      t3, stage2_reg
    sw      t2, 0(t3)

    la      t3, stage2_reg
    lw      t0, 0(t3)
    li      t1, 3
    li      t2, 5
    li      t3, 0
    beq     t0, t1, codeword_valid
    beq     t0, t2, codeword_valid
    j       codeword_invalid

codeword_valid:
    li      t3, 1
codeword_invalid:
    la      t1, stage3_reg
    sw      t3, 0(t1)

    la      t2, stage3_reg
    lw      t0, 0(t2)
    la      t1, stage4_reg
    sw      t0, 0(t1)
    beqz    t0, pipeline_continue
    li      t6, 1

pipeline_continue:
    la      t2, cycle_count
    lw      t0, 0(t2)
    addi    t0, t0, 1
    sw      t0, 0(t2)

    bnez    t6, output_result

    li      t1, 8 
    blt     t0, t1, pipeline_loop

    la      a0, ERROR_MESSAGE
    li      a7, 4
    ecall
    j       show_cycles

output_result:
    la      a0, DECODED_MSG
    li      a7, 4
    ecall

    la      t1, stage2_reg
    lw      a0, 0(t1)
    li      a7, 1
    ecall

    la      a0, NEWLINE
    li      a7, 4
    ecall

show_cycles:
    la      a0, CYCLES_MSG
    li      a7, 4
    ecall
    la      t1, cycle_count
    lw      a0, 0(t1)
    li      a7, 1
    ecall
    la      a0, NEWLINE
    li      a7, 4
    ecall

    li      a7, 10
    ecall
