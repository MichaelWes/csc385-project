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

    /* Request interrupts from keyboard controller */
    movia r2, PS2C1_BASE
    movi r3, 0x1
    stwio r3, PS2C1_CTRLSTS(r2)		# Interrupt enable is bit 0 of control register.
    ldwio r0, PS2C1_DATA(r2)		# Read data to acknowledge the interrupt. Throw it away.

    /* Enable specific interrupt lines on processor */
    movia r2, IRQ_PUSHBUTTONS
    ori r2, r2, IRQ_TIMER0
    ori r2, r2, IRQ_TIMER1
    ori r2, r2, IRQ_PS2C1
    wrctl ienable, r2				# Enable bit 1 - Pushbuttons use IRQ 1

    movi r2, 0x1
    wrctl ctl0, r2					# Enable global Interrupts on Processor 
    ret

