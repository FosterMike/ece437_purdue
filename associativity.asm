.section .data
    array1: .word 0x100, 0x200, 0x300, 0x400  # Some sample data for test
    array2: .word 0x500, 0x600, 0x700, 0x800

.section .text
.global _start
_start:
    # Load array1 data into the D-Cache
    la t0, array1
    lw t1, 0(t0)        # Load 0x100 (Cache miss -> Cache fill)
    lw t2, 4(t0)        # Load 0x200 (Another miss, different index)

    # Access array2 which may map to the same cache index
    la t0, array2
    lw t3, 0(t0)        # Load 0x500 (Tests set associativity, should not evict array1 data)
    lw t4, 4(t0)        # Load 0x600 (Ensures array1 isn't evicted yet)

    # End program
    li a7, 93           # Syscall to exit
    ecall
