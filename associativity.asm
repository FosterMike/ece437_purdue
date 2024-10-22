    # org 0x0000
    
    # # Load data into the dcache
    # sw 0(t0), 0x100
    # sw 4(t0), 0x200  
    # // t0 = [0x100, 0x200]
    # lw t2, 0(t0) 
    # lw t3, 4(t0)


    # sw 0(t0), 0x300
    # sw 4(t0), 0x400
    # // t0 = [0x300, 0x400]
    # lw t4, 0(t0)
    # lw t5, 4(t0)

    // Since the d-cache is two way associative, the values from
    // The first set of loads should not be evicted

    halt
