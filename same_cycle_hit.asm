# org 0x0000
#     sw 0(t0), 0x100
#     lw t1, 0(t0) // load data into dcache

#     loop:
#     lw t2, 0(t0) // d-cache hit
#     addi t1, t1, 1 // i-cache hit since we'll repeat this instruction
#     addi t1, t1, 1 // i-cache hit since we'll repeat this instruction
#     addi t1, t1, 1 // i-cache hit since we'll repeat this instruction
#     addi t1, t1, 1 // i-cache hit since we'll repeat this instruction

#     bnez t1, loop

    halt


