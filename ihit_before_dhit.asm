# org 0x0000
# sw 0(t0), 0x100
# sw 4(t0), 0x200

# lw t1, 0(t0) // Loads data into dcache

# loop:
# lw t1, 0(t0)
# sw t1, 4(t0)
# bnez t1, loop

halt
