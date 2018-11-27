.global motors_off
.global motor0_fwd
.global motor0_bwd

motors_off:
    subi sp, sp, 8
    stw r8, 0(sp)
    stw r9, 4(sp)
    
    movia r8, ADDR_JP1
    movia r9, 0x7F557FF            # Set direction for motors to all output 
    stwio r9, JP1_DIRREG(r8)

    movia r9, 0xFFFFFFFF           # Turn off all motors.
    stwio r9, JP1_DATA(r8)
    
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 8
	
    ret
            
motor0_fwd:
    subi sp, sp, 8
    stw r8, 0(sp)
    stw r9, 4(sp)

    movia r8, ADDR_JP1
    movia r9, 0x7F557FF            
    stwio r9, JP1_DIRREG(r8)

    movia r9, 0xFFFFFFFC           
    stwio r9, JP1_DATA(r8)
    
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 8
    
    ret
            
motor0_bwd:
    subi sp, sp, 8
    stw r8, 0(sp)
    stw r9, 4(sp)

    movia r8, ADDR_JP1
    movia r9, 0x7F557FF            
    stwio r9, JP1_DIRREG(r8)

    movia r9, 0xFFFFFFFE           
    stwio r9, JP1_DATA(r8)
    
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 8
	
    ret

motor1_fwd:
    subi sp, sp, 8
    stw r8, 0(sp)
    stw r9, 4(sp)

    movia r8, ADDR_JP1
    movia r9, 0x7F557FF            
    stwio r9, JP1_DIRREG(r8)

    movia r9, 0xFFFFFFF3           
    stwio r9, JP1_DATA(r8)
    
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 8
	
    ret
            
motor1_bwd:
    subi sp, sp, 8
    stw r8, 0(sp)
    stw r9, 4(sp)

    movia r8, ADDR_JP1
    movia r9, 0x7F557FF            
    stwio r9, JP1_DIRREG(r8)

    movia r9, 0xFFFFFFFB           
    stwio r9, JP1_DATA(r8)
    
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 8
	
    ret
