.data
USER_PROMPT:     .asciz "Enter a 4-bit word (0-15) for decoding: "
ERROR_MESSAGE:   .asciz "No matching codeword found.\n"
DECODED_MSG:     .asciz "Decoded codeword: "
CYCLES_MSG:      .asciz "Clock cycles: "
NEWLINE:         .asciz "\n"

stage1_reg:      .word 0
stage2_reg:      .word 0
stage3_reg:      .word 0
stage4_reg:      .word 0
received_c:      .word 0
cycle_count:     .word 0

conf_vec:        .word 2, 0, 3, 1

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

    li      t0, 0
    la      t1, cycle_count
    sw      t0, 0(t1)

    la      t0, stage1_reg
    sw      zero, 0(t0)
    la      t0, stage2_reg
    sw      zero, 0(t0)
    la      t0, stage3_reg
    sw      zero, 0(t0)
    la      t0, stage4_reg
    sw      zero, 0(t0)

    li      t2, 0      
    li      t3, 5      
    li      t4, 0    

pipeline_loop:
    li      t5, 0     

    beqz    t2, skip_noise
    li      t6, 0     
gen_noise:
    bge     t6, t2, noise_done
    la      t0, conf_vec
    slli    t1, t6, 2
    add     t1, t0, t1
    lw      t0, 0(t1)
    li      t1, 1
    sll     t1, t1, t0
    or      t5, t5, t1
    addi    t6, t6, 1
    j       gen_noise
noise_done:
skip_noise:
    la      t0, stage1_reg
    sw      t5, 0(t0)
    addi    t2, t2, 1

    la      t0, received_c
    lw      t1, 0(t0)
    la      t0, stage1_reg
    lw      t5, 0(t0)
    xor     t1, t1, t5
    la      t0, stage2_reg
    sw      t1, 0(t0)

    la      t0, stage2_reg
    lw      t1, 0(t0)
    li      t5, 3
    li      t6, 5
    li      t0, 0
    beq     t1, t5, codeword_valid
    beq     t1, t6, codeword_valid
    j       codeword_invalid

codeword_valid:
    li      t0, 1
codeword_invalid:
    la      t1, stage3_reg
    sw      t0, 0(t1)

    la      t0, stage3_reg
    lw      t1, 0(t0)
    la      t0, stage4_reg
    sw      t1, 0(t0)
    beqz    t1, pipeline_continue
    li      t4, 1

pipeline_continue:
    la      t0, cycle_count
    lw      t1, 0(t0)
    addi    t1, t1, 1
    sw      t1, 0(t0)

    bnez    t4, output_result

    li      t0, 5
    blt     t2, t0, pipeline_loop

    la      a0, ERROR_MESSAGE
    li      a7, 4
    ecall
    j       show_cycles

output_result:
    la      a0, DECODED_MSG
    li      a7, 4
    ecall

    la      t0, stage2_reg
    lw      a0, 0(t0)
    li      a7, 1
    ecall

    la      a0, NEWLINE
    li      a7, 4
    ecall

show_cycles:
    la      a0, CYCLES_MSG
    li      a7, 4
    ecall
    la      t0, cycle_count
    lw      a0, 0(t0)
    li      a7, 1
    ecall
    la      a0, NEWLINE
    li      a7, 4
    ecall

    li      a7, 10
    ecall
