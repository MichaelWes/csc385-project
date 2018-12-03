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
    beq r17, r0, interrupt_epilogue

TIMER0_handler:
    # Turn off motor1
    call motors_off
    # Acknowledge timer 0 interrupt
    movia r16, TIMER0_BASE
    stwio r0, TIMER_STATUS(r16)
    # Start timer 1 in continuous mode


    jmpi interrupt_epilogue 

TIMER1_handler:
    # movia r16, L
    # ldw r17, 0(r16)
    # movia r18, sigma
    # ldw r19, 0(r18)

    # Acknowledge timer 1 interrupt
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
