.section .exceptions, "ax"
    subi sp, sp, 20
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw r19, 12(sp)
    stw ra, 16(sp)

    # Check if interrupt was caused by a device
    rdctl et, ipending
    beq et, r0, interrupt_epilogue

    # Interrupt was caused by a device,
    # Make sure we re-execute the interrupted instruction.
    subi ea, ea, 4	

    # Check which device caused the interrupt
    andi r17, et, IRQ_TIMER0			# IRQ 0, timer 0
    bne r17, r0, TIMER0_handler
    andi r17, et, IRQ_TIMER1			# IRQ 2, timer1 
    bne r17, r0, TIMER1_handler
    andi r17, et, IRQ_JP1               # IRQ 11, JP1
    beq r17, r0, interrupt_epilogue

JP1_handler:
    # Which sensor was it? Check the edge capture register if necessary.
    movia r17, ADDR_JP1
    ldwio r16, 12(r17)

    # Turn off motors.
    call motors_off
    # Disable keyboard interface by writing 0xAD to the PS2 data register.
    # TODO: This command does not seem to work.

    # movia r16, PS2C1_BASE
    # addi r17, r0, 0xAD
    # stwio r17, PS2C1_DATA(r16)

    # call start_timer_once



    # Swap the mode bit for JP1 to 1 (value).
    # Main control loop will swap it back to 0 (state) once we're far enough.
    
    # This makes the controller go crazy. Find out if it's even feasible to do this?
    #movia r18, 0x00200000
    #ldwio r16, 0(r17)
    #or r16, r16, r18
    #stwio r18, JP1_DATA(r17)



    # Write a 1 to the bit(s) in the edge capture to acknowledge the interrupt
    movia r19, ADDR_JP1
    movia r18, 0xFFFFFFFF
    stwio r18, 12(r19)

    jmpi interrupt_epilogue

TIMER0_handler:
    # Acknowledge timer 0 interrupt by writing 0 to status register.
    movia r16, TIMER0_BASE
    stwio r0, TIMER_STATUS(r16) 

    # Re-enable keyboard by writing 0xAE to the PS2 data register.
    movia r16, PS2C1_BASE
    addi r17, r0, 0xAE
    stwio r17, PS2C1_DATA(r16)

    jmpi interrupt_epilogue 

TIMER1_handler:
    # movia r16, L
    # ldw r17, 0(r16)
    # movia r18, sigma
    # ldw r19, 0(r18)

    # Acknowledge timer 1 interrupt by writing 0 to status register.
    movia r16, TIMER1_BASE
    stwio r0, TIMER_STATUS(r16)
    
    # movia r16, TIMER0_BASE
    # ldwio r18, TIMER_STATUS(r16)
    # andi r18, r18, 0x2   # Run bit set?
    # beq r18, r0, TIMER1_DONE
    

    # outer pre-condition: TIMER0 is running.

    # while *L >= *counter > *sigma,
    # do nothing
    # when *counter == *sigma
    # toggle off
    # when *counter == 0, 
    # toggle on
    TIMER1_DONE:
    jmpi interrupt_epilogue

interrupt_epilogue:
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    ldw r19, 12(sp)
    ldw ra, 16(sp)
    addi sp, sp, 20
    eret
