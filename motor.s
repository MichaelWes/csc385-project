.global motors_off
.global motor0_fwd
.global motor0_bwd
.global motor1_fwd
.global motor1_bwd

motors_off:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)
    
    movia r16, ADDR_JP1
    movia r17, 0x7F557FF            # Set direction for motors to all output 
    stwio r17, JP1_DIRREG(r16)

    movia r17, 0xFFFFFFFF           # Turn off all motors.
    stwio r17, JP1_DATA(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
	
    ret
            
motor0_fwd:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, ADDR_JP1
    movia r17, 0x7F557FF            
    stwio r17, JP1_DIRREG(r16)

    movia r17, 0xFFFFFFFC           
    stwio r17, JP1_DATA(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
    
    ret
            
motor0_bwd:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, ADDR_JP1
    movia r17, 0x7F557FF            
    stwio r17, JP1_DIRREG(r16)

    movia r17, 0xFFFFFFFE           
    stwio r17, JP1_DATA(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
	
    ret

motor1_fwd:
    subi sp, sp, 12
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)

    
    ## Check if value of displacement
    ## is at maximum.
    #movi r16, 1
    #movia r17, turnpos
    #ldw r18, 0(r17)
    ## Branch if at max displacement to the right.
    ## Also turn off motors to prevent typematic spam.
    #bne r18, r16, updt_displacement_motor1_fwd
    #call motors_off
    #jmpi motor1_fwd_epilogue
    #updt_displacement_motor1_fwd:    
    ## Otherwise, update displacement.
    #addi r18, r18, 1
    #stw r18, 0(r17)

    movia r16, ADDR_JP1
    movia r17, 0x7F557FF            
    stwio r17, JP1_DIRREG(r16)

    movia r17, 0xFFFFFFF3           
    stwio r17, JP1_DATA(r16)
    
    motor1_fwd_epilogue:   
    ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 12
	
    ret
            
motor1_bwd:
    subi sp, sp, 12
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)

    ## Check if value of displacement
    ## is at maximum.
    #movi r16, -1
    #movia r17, turnpos
    #ldw r18, 0(r17)
    ## Branch if at max displacement to the left.
    ## Also turn off motors to prevent typematic spam.
    #bne r18, r16, updt_displacement_motor1_bwd
    #call motors_off
    #jmpi motor1_bwd_epilogue    
    #updt_displacement_motor1_bwd:
    ## Otherwise, update displacement.
    #addi r18, r18, -1
    #stw r18, 0(r17)

    movia r16, ADDR_JP1
    movia r17, 0x7F557FF            
    stwio r17, JP1_DIRREG(r16)

    movia r17, 0xFFFFFFFB           
    stwio r17, JP1_DATA(r16)
    
    motor1_bwd_epilogue:
    ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 12
	
    ret
