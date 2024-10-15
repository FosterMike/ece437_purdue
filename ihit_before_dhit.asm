.section .text
.global _start
_start:
    # Load data into D-Cache first
    la t0, data2
    lw t1, 0(t0)        # Load data into cache (Cache miss -> Cache fill)

    # Simulate IHIT followed by DHIT
    la t0, data2
    loop2:
    lw t1, 0(t0)        # Instruction hit (instruction loop), data hit for lw
    sw t1, 4(t0)        # Store word to data2 (should hit D-Cache on subsequent iterations)
    bnez t1, loop2      # Continue loop if t1 is non-zero

    # End program
    li a7, 93           # Syscall to exit
    ecall

.section .data
    data2: .word 0x4321  # Test data for D-Cache
