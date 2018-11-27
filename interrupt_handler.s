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
    andi r17, et, IRQ_PS2C1		 	# IRQ 7, keyboard
    bne r17, r0, keyboard_handler
    beq r17, r0, interrupt_epilogue

    # Pre-branching loading appropriate addresses into registers
    # and loaded appropriate values into the devices at those addresses

keyboard_handler:
    movia r16, PS2C1_BASE
    ldwio r19, PS2C1_DATA(r16)

    /*
    movi r17, 0x1
    wrctl status, r17				# Re-enable interrupts. CLOBBER WARNING.
    */

parse:
    movi r17, 0xF0					# Break code prefix byte
    andi r18, r19, 0xFF				# Mask the input byte
    beq r18, r17, key_brk			
    
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
    # stwio r0, PS2C1_CTRLSTS(r16) 

    call initialize_timer
    call start_timer_once
    call initialize_timer1
    call start_timer1_continuous
    
    movi r17, 0x1D
    beq r18, r17, key_fwd
    movi r17, 0x1C
    beq r18, r17, key_lft
    movi r17, 0x1B
    beq r18, r16, key_bwd
    movi r17, 0x23
    beq r18, r17, key_rgt
    
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
	ldwio r19, PS2C1_DATA(r16) # Do another read for the make code of 
	                          # the key that we want to break
        call motors_off
        jmpi wait

wait:
    # Is the timer still running? Then wait
    movia r16, TIMER0_BASE
    ldwio r17, TIMER_STATUS(r16)
    andi r17, r17, 0x02
    bne r17, r0, wait
    # If the timer isn't running, then check if more bytes need to be read
    movia r17, 0xFFFF0000
    and r17, r17, r19
    srli r17, r17, 1
    subi r17, r17, 1
    bgt r17, r0, keyboard_handler
    br interrupt_epilogue

	
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


