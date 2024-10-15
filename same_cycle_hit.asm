.section .text
.global _start
_start:
    # Load data into D-Cache
    la t0, data1
    lw t1, 0(t0)        # Load from data1 (Cache miss -> Cache fill)

    loop:
    # Instruction fetches happen, I-Cache is hit as the loop repeats
    addi t1, t1, 1      # Modify register, this will be an I-Cache hit on the 2nd+ iterations

    # D-Cache hit (data1 already cached)
    lw t2, 0(t0)        # Load from data1 again (D-Cache hit)

    # Continue looping
    bnez t1, loop       # If t1 is non-zero, continue looping

    # End program
    li a7, 93           # Syscall to exit
    ecall

.section .data
    data1: .word 0x1234  # Some sample data
