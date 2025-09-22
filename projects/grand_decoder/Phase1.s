.text
    .globl _start
_start:

    la      a0, USER_PROMPT
    li      a7, 4
    ecall


    li      a7, 5
    ecall
    mv      t0, a0             


    la      a0, TRACE_MSG
    li      a7, 4
    ecall


    jal     ra, generate_noise_sequence


    jal     ra, check_codebook_membership


    la      a0, ERROR_MESSAGE
    li      a7, 4
    ecall
    j       EXIT


generate_noise_sequence:
    li      t1, 1               
    mv      a0, t1         
    la      a0, TRACE_MSG       
    li      a7, 4
    ecall
    ret


check_codebook_membership:
    li      t2, 3              
    beq     t0, t2, MATCH_FOUND 


    la      a0, TRACE_MSG
    li      a7, 4
    ecall
    ret


MATCH_FOUND:
    la      a0, DECODED_MSG
    li      a7, 4
    ecall

    la      a0, OUTPUT_RESULT
    li      a7, 4
    ecall

    mv      a0, t0            
    li      a7, 1
    ecall

    j       EXIT


EXIT:
    li      a7, 10           
    ecall
.data
USER_PROMPT:     .asciz "Enter a 4-bit word (0-15) for decoding: "
ERROR_MESSAGE:   .asciz "No matching codeword found.\n"
DECODED_MSG:     .asciz "Decoded codeword: "
OUTPUT_RESULT:    .asciz "Output: "
REGISTER_MSG:     .asciz "Current register value: "
TRACE_MSG:        .asciz "DEBUG: Entering code section...\n"
