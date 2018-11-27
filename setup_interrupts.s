.text

.global setup_interrupts

setup_interrupts:
    /* Turn everything off*/
    movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 

    movia r10, 0x7F557FF			# Set direction for motors to all output 
    stwio r10, JP1_DIRREG(r8)

    movia r10, 0xFFFFFFFF			# Turn off all motors.
    stwio r10, JP1_DATA(r8)

    /* Request interrupts from timer0, timer1 */
    movia r2, TIMER0_BASE
    movia r3, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
    stwio r3, TIMER_CONTROL(r2)		# Enable interrupts on timer0
    stwio r0, TIMER_STATUS(r2)		# Clear interrupt bit for timers.
    
    movia r2, TIMER1_BASE
    movia r3, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
    stwio r3, TIMER_CONTROL(r2)		# Enable interrupts on timer0
    stwio r0, TIMER_STATUS(r2)		# Clear interrupt bit for timers.

    /* Enable specific interrupt lines on processor */
    movia r2, IRQ_PUSHBUTTONS
    ori r2, r2, IRQ_TIMER0
    ori r2, r2, IRQ_TIMER1
    wrctl ienable, r2				

    movi r2, 0x1
    wrctl ctl0, r2					# Enable global Interrupts on Processor 
    ret

