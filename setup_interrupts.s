/* GPIO JP1 addresses and byte offsets */
.equ ADDR_JP1, 0xFF200060 
.equ JP1_DATA, 0x00
.equ JP1_DIRREG, 0x04
.equ JP1_IMR, 0x08
.equ JP1_ECR, 0x0C

/* Pushbutton addresses and byte offsets */
.equ ADDR_PUSHB, 0xFF200050
.equ PUSHB_DATA, 0x00
.equ PUSHB_NA, 0x04
.equ PUSHB_IMR, 0x08
.equ PUSHB_ECR, 0x0C
.equ PUSHB_INTM, 0x0F

/* Timer addresses and byte offsets */
.equ TIMER0_BASE, 0xFF202000
.equ TIMER1_BASE, 0xFF202020
.equ TIMER_STATUS, 0x00
.equ TIMER_CONTROL, 0x04
.equ TIMER_PERIODL, 0x08
.equ TIMER_PERIODH, 0x0C
.equ TIMER_SNAPL, 0x10
.equ TIMER_SNAPH, 0x14
.equ TIMER_INTM, 0x09

/* PS2 Controller addresses and byte offsets */
.equ PS2C1_BASE, 0xFF200100
.equ PS2C1_DATA, 0x00
.equ PS2C1_CTRLSTS, 0x04

/* IRQs for different devices */
.equ IRQ_PUSHBUTTONS, 0x02
.equ IRQ_TIMER0, 0x01
.equ IRQ_TIMER1, 0x04
.equ IRQ_PS2C1, 0x80

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

.section .exceptions, "ax"
    /* Prologue */
    subi sp, sp, 28
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
	andi r9, et, IRQ_TIMER1			# IRQ 2, timer 1
	bne r9, r0, TIMER1_handler
	andi r9, et, IRQ_PS2C1		 	# IRQ 7, keyboard
	bne r9, r0, keyboard_handler
    beq r9, r0, interrupt_epilogue

	# Pre-branching loading appropriate addresses into registers
	# and loaded appropriate values into the devices at those addresses
	
PS2_handler:
	# TODO: handle specific keys.
	/* Keyboard protocol 

	movia r9, PS2C1_BASE
	W -> 1D
	A -> 1C
	S -> 1B
	D -> 23
	
	*/
	
	movia r8, PS2C1_BASE
	ldwio r11, PS2C1_DATA(r8)		# Reading clears the keyboard interrupt.
	
	movi r9, 0x1
	wrctl status, r9				# Re-enable interrupts.

    call initialize_timer
    call start_timer_once

	jmpi interrupt_epilogue

/* The first timer has sent an interrupt, therefore we need to stop
	PWM and return to normal state looking out for regular interrupts */
TIMER0_handler:
	movia r8, ADDR_JP1

	movia r10, 0x7F557FF			# Set direction for motors to all output 
    stwio r10, JP1_DIRREG(r8)

	movia r10, 0xFFFFFFFF			# Turn off all motors.
	stwio r10, JP1_DATA(r8)

	movia r8, TIMER0_BASE
	
	stwio r0, TIMER_STATUS(r8)
	
    jmpi interrupt_epilogue 
	

interrupt_epilogue:
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
    addi sp, sp, 28

    subi ea, ea, 4					# Interrupt was caused by a device, make sure we re-execute the interrupted instruction.
	
    eret
