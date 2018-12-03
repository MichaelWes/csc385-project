.text

.global setup_interrupts

setup_interrupts:
    /* Turn everything off*/
    movia r8, ADDR_JP1

    movia r10, 0x7F557FF			# Set direction for motors to all output 
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFFF			# Turn off all motors.
    stwio r10, JP1_DATA(r8)

    /* Request interrupts from timer0, timer1 */
    movia r2, TIMER0_BASE
    movia r3, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
    stwio r3, TIMER_CONTROL(r2)		# Request interrupts from timer0
    stwio r0, TIMER_STATUS(r2)		# Clear interrupt bit for timers.
    
    movia r2, TIMER1_BASE
    movia r3, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
    stwio r3, TIMER_CONTROL(r2)		# Request interrupts from timer0
    stwio r0, TIMER_STATUS(r2)		# Clear interrupt bit for timers.

    /* Enable IRQ lines on processor */
    add r2, r0, r0
    ori r2, r2, IRQ_TIMER0
    ori r2, r2, IRQ_TIMER1
    wrctl ienable, r2				

    movi r2, 0x1
    wrctl ctl0, r2					# Enable interrupts on Processor 
    ret

