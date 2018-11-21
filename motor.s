.equ ADDR_JP1, 0xFF200060 
.equ JP1_DATA, 0x00
.equ JP1_DIRREG, 0x04

.global motors_off
.global motor0_fwd
.global motor0_bwd

motors_off:
    movia r8, ADDR_JP1
    movia r10, 0x7F557FF            # Set direction for motors to all output 
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFFF           # Turn off all motors.
    stwio r10, JP1_DATA(r8)
    ret
            
motor0_fwd:
    movia r8, ADDR_JP1
    movia r10, 0x7F557FF            
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFFC           
    stwio r10, JP1_DATA(r8)
    ret
            
motor0_bwd:
    movia r8, ADDR_JP1
    movia r10, 0x7F557FF            
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFFE           
    stwio r10, JP1_DATA(r8)
    ret

motor1_fwd:
    movia r8, ADDR_JP1
    movia r10, 0x7F557FF            
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFF3           
    stwio r10, JP1_DATA(r8)
    ret
            
motor1_bwd:
    movia r8, ADDR_JP1
    movia r10, 0x7F557FF            
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFFB           
    stwio r10, JP1_DATA(r8)
    ret
