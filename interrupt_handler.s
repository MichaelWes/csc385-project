.section .exceptions, "ax"
    /* Prologue */
    subi sp, sp, 16
    /* Prologue -- nested interrupts */
    stw ea, 0(sp)
    rdctl r16, estatus
    stw r16, 4(sp)
    rdctl r17, ienable
    stw r17, 8(sp)
    /* Prologue -- end nested interrupts portion */
    stw ra, 12(sp)

    /* TODO: Priority scheme for interrupts. */
        /* Basically, only interrupts with bit number higher */
        /* than the current IRQ can interrupt it. */
    /* TODO: Re-enable interrupts: PIE. */

    # Check if interrupt was caused by a device
    rdctl et, ipending
    beq et, r0, interrupt_epilogue

    subi ea, ea, 4					# Interrupt was caused by a device, make sure we re-execute the interrupted instruction.

    # Check which device caused the interrupt
    andi r17, et, IRQ_TIMER0			# IRQ 0, timer 0
    bne r17, r0, TIMER0_handler
    andi r17, et, IRQ_TIMER1			# IRQ 2, timer1 
    bne r17, r0, TIMER1_handler
    beq r17, r0, interrupt_epilogue

TIMER0_handler:
    call motors_off
    # Re-enable keyboard interrupts
    movia r16, PS2C1_BASE
    movia r17, 0x1
    stwio r17, PS2C1_CTRLSTS(r16)

    movia r16, TIMER0_BASE
    stwio r0, TIMER_STATUS(r16)

    jmpi interrupt_epilogue 

TIMER1_handler:
    movia r16, L
    ldw r17, 0(r16)
    movia r18, sigma
    ldw r19, 0(r18)

    /*
    movia r16, TIMER0_BASE
    ldwio r18, TIMER_STATUS(r16)
    andi r18, r18, 0x2   # Run bit set?
    beq r18, r0, TIMER1_DONE
    */

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
    ldw ra, 0(sp)
    /* Epilogue for nested interrupts. */
    ldw r19, 4(sp)
    wrctl ienable, r19
    ldw r18, 8(sp)
    wrctl estatus, r18
    ldw ea, 12(sp)
    /* End nested interrupt portion of epilogue. */
    addi sp, sp, 16
    
    eret
