.section .exceptions, "ax"
    /* Prologue */
    subi sp, sp, 36
    stw r8, 0(sp)
    stw r9, 4(sp)
    stw r10, 8(sp)
    stw r11, 12(sp)
    stw r12, 16(sp)
    /* Prologue -- nested interrupts */
    stw ea, 20(sp)
    rdctl r8, estatus
    stw r8, 24(sp)
    rdctl r9, ienable
    stw r9, 28(sp)
    /* Prologue -- end nested interrupts portion */
    stw ra, 32(sp)

    /* TODO: Priority scheme for interrupts. */
        /* Basically, only interrupts with bit number higher */
        /* than the current IRQ can interrupt it. */
    /* TODO: Re-enable interrupts: PIE. */

    # Check if interrupt was caused by a device
    rdctl et, ipending
    beq et, r0, interrupt_epilogue

	
    subi ea, ea, 4					# Interrupt was caused by a device, make sure we re-execute the interrupted instruction.

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
    ldwio r11, PS2C1_DATA(r8)

    /*
    movi r9, 0x1
    wrctl status, r9				# Re-enable interrupts. CLOBBER WARNING.
    */

parse:
    movi r9, 0xF0					# Break code prefix byte
    andi r10, r11, 0xFF				# Mask the input byte
    beq r10, r9, key_brk			
    
    key_mk:
    # Mask interrupts from the keyboard (IRQ7) for 100ms
    # For PWM.
    # It might not be correct to write to the status/control register of the 
    # PS2 controller. The reason for this is because the PS2 only interrupts once a 
    # "stream" of bytes is sent to the FIFO buffer. The code assumes that once a byte
    # has been read there is nothing else to do, but this assumption is incorrect.
    # Therefore what we can do is, read a byte and call a waiting function for the 
    # PS2 controller to wait for the timer to timeout, once the timer interrupt is handled
    # we will come to the wait "area" and check what other bytes need to be read from the
    # PS2 controller. This will also tell us when to turn off the motors since those
    # bytes will be sent/read seperately. 
    
    # The below has been commented out, refer to explanation above as to why this might
    # not be correct.
    # stwio r0, PS2C1_CTRLSTS(r8) 

    call initialize_timer
    call start_timer_once
    call initialize_timer1
    call start_timer1_continuous
    
    movi r9, 0x1D
    beq r10, r9, key_fwd
    movi r9, 0x1C
    beq r10, r9, key_lft
    movi r9, 0x1B
    beq r10, r8, key_bwd
    movi r9, 0x23
    beq r10, r9, key_rgt
    
    jmpi interrupt_epilogue			# didn't match; do nothing
    
    key_fwd:    
        call motor0_fwd
        jmpi wait
    key_bwd:
        call motor0_bwd
        jmpi wait
    key_lft:
        call motor1_fwd
        jmpi wait
    key_rgt:
        call motor1_bwd
        jmpi wait
    key_brk:
	ldwio r11, PS2C1_DATA(r8) # Do another read for the make code of 
	                          # the key that we want to break
        call motors_off
	jmpi wait

wait:
    # Is the timer still running? Then wait
    movia r8, TIMER0_BASE
    lwdio r9, TIMER_STATUS(r8)
    andi r9, r9, 0x02
    bne r9, r0, wait
    # If the timer isn't running, then check if more bytes need to be read
    movia r9, 0xFFFF0000
    and r9, r9, r11
    srli r9, r9, 1
    subi r9, r9, 1
    bgt keyboard_handler
    br interrupt_epilogue

	
TIMER0_handler:
    call motors_off
    # Re-enable keyboard interrupts
    movia r8, PS2C1_BASE
    movia r9, 0x1
    stwio r9, PS2C1_CTRLSTS(r8)

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
    ldw ra, 32(sp)
    /* Epilogue for nested interrupts. */
    ldw r11, 28(sp)
    wrctl ienable, r11
    ldw r10, 24(sp)
    wrctl estatus, r10
    ldw ea, 20(sp)
    /* End nested interrupt portion of epilogue. */
    ldw r12, 16(sp)
    ldw r11, 12(sp)
    ldw r10, 8(sp)
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 36


    eret


