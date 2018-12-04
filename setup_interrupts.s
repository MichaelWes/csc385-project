.text

.global setup_interrupts

setup_interrupts:
    /* Turn everything off*/
    movia r11, ADDR_JP1

    movia r10, 0x7F557FF			# Set direction for motors to all output 
    stwio r10, JP1_DIRREG(r11)

    movia r10, 0xFFFFFFFF			# Turn off all motors.
    stwio r10, JP1_DATA(r11)


    # Load threshold values for sensor0.
    # Load threshold value A for sensor0.
    movia r10, 0xFDBFFBFF
    stwio r10, JP1_DATA(r11)

    #  tell the Lego controller the threshold value has been loaded by 
    # disabling all sensors and setting Load Threshold to "Don't Load".
    movia r10, 0xFD7FFFFF
    stwio r10, JP1_DATA(r11)

    # Load threshold values for sensor1.
    # Load threshold value A for sensor1.
    movia r10, 0xFDBFEFFF
    stwio r10, JP1_DATA(r11)

    #  tell the Lego controller the threshold value has been loaded by 
    # disabling all sensors and setting Load Threshold to "Don't Load".
    movia r10, 0xFD7FFFFF
    stwio r10, JP1_DATA(r11)

    # set to State mode by writing 0 to bit 21.
    movia r10, 0xFFDFFFFF
    stwio r10, JP1_DATA(r11)

    /* Request interrupts from timer0, timer1 */
    movia r8, TIMER0_BASE
    movia r9, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
    stwio r9, TIMER_CONTROL(r8)		# Request interrupts from timer0
    stwio r0, TIMER_STATUS(r8)		# Clear interrupt bit for timers.
    
    movia r8, TIMER1_BASE
    movia r9, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
    stwio r9, TIMER_CONTROL(r8)		# Request interrupts from timer0
    stwio r0, TIMER_STATUS(r8)		# Clear interrupt bit for timers.

    /* Request interrupts from sensors 0 and 1: write to IMR */
    movia r10, 0x18000000
    stwio r10, 8(r11)

    /* Enable IRQ lines on processor */
    add r8, r0, r0
    ori r8, r8, IRQ_TIMER0
    ori r8, r8, IRQ_TIMER1
    ori r8, r8, IRQ_JP1
    wrctl ienable, r8				

    movi r8, 0x1
    wrctl ctl0, r8					# Enable interrupts on Processor 
    ret

