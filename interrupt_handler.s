.section .exceptions, "ax"
    /* Prologue */
    subi sp, sp, 32
    stw r8, 0(sp)
    stw r9, 4(sp)
    stw r10, 8(sp)
    stw r11, 12(sp)
    /* Prologue -- nested interrupts */
    stw ea, 16(sp)
    rdctl r8, estatus
    stw r8, 20(sp)
    rdctl r9, ienable
    stw r9, 24(sp)
    /* Prologue -- end nested interrupts portion */
    stw ra, 28(sp)

    /* TODO: Priority scheme for interrupts. */
        /* Basically, only interrupts with bit number higher */
        /* than the current IRQ can interrupt it. */
    /* TODO: Re-enable interrupts: PIE. */

    # Check if interrupt was caused by a device
    rdctl et, ipending
    beq et, r0, interrupt_epilogue

    # Check which device caused the interrupt
    andi r9, et, IRQ_TIMER0			# IRQ 0, timer 0
    bne r9, r0, TIMER0_handler
    andi r9, et, IRQ_TIMER1			# IRQ 2, timer1 
    bne r9, r0, TIMER1_handler
    andi r9, et, IRQ_PS2C1		 	# IRQ 7, keyboard
    bne r9, r0, keyboard_handler
    beq r9, r0, interrupt_epilogue

    # Pre-branching loading appropriate addresses into registers
    # and loaded appropriate values into the devices at those addresses

keyboard_handler:
    movia r8, PS2C1_BASE
    ldwio r11, PS2C1_DATA(r8)		# Reading clears the keyboard interrupt.

    /*
    movi r9, 0x1
    wrctl status, r9				# Re-enable interrupts. CLOBBER WARNING.
    */

    movi r9, 0xF0					# Break code prefix byte
    andi r10, r11, 0xFF				# Mask the input byte
    beq r10, r9, key_brk			
    key_mk:
    call initialize_timer
    call start_timer_once
    call initialize_timer1
    call start_timer1_continuous
    movi r9, 0x1d
    movi r8, 0x1b
    beq r10, r8, key_bwd
    beq r10, r9, key_fwd
    movi r9, 0x1c
    movi r8, 0x23
    beq r10, r8, key_lft			
    beq r10, r9, key_rgt			
    jmpi interrupt_epilogue			# didn't match; do nothing
    key_fwd:    
    call motor0_fwd
    jmpi interrupt_epilogue
    key_bwd:
    call motor0_bwd
    jmpi interrupt_epilogue
    key_lft:
    call motor1_fwd
    jmpi interrupt_epilogue
    key_rgt:
    call motor1_bwd
    jmpi interrupt_epilogue    
    key_brk:
    call motors_off 
    jmpi interrupt_epilogue
	
TIMER0_handler:
    call motors_off

    movia r8, TIMER0_BASE

    stwio r0, TIMER_STATUS(r8)

    jmpi interrupt_epilogue 

TIMER1_handler:
    movia r8, L
    ldw r9, 0(r8)
    movia r10, sigma
    ldw r11, 0(r10)

    /*
    movia r8, TIMER0_BASE
    ldwio r10, TIMER_STATUS(r8)
    andi r10, r10, 0x2   # Run bit set?
    beq r10, r0, TIMER1_DONE
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
    ldw ra, 28(sp)
    /* Epilogue for nested interrupts. */
    ldw r11, 24(sp)
    wrctl ienable, r11
    ldw r10, 20(sp)
    wrctl estatus, r10
    ldw ea, 16(sp)
    /* End nested interrupt portion of epilogue. */
    ldw r11, 12(sp)
    ldw r10, 8(sp)
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 32

    subi ea, ea, 4					# Interrupt was caused by a device, make sure we re-execute the interrupted instruction.

    eret


