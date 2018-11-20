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

	/* Request interrupts from HEX */
	movia r2, ADDR_PUSHB
	movi r3, PUSHB_INTM				# Enable interrrupt mask = 1111
	stwio r3, PUSHB_IMR(r2)			# Enable interrupts on pushbuttons 1, 2, 3, and 4
	stwio r10, PUSHB_ECR(r2)		# Clear edge capture register (write all 1's) for HEX keypad.  
  
	/* Request interrupts from timer0, timer1 */
	movia r2, TIMER0_BASE
	movia r3, TIMER_INTM			# Enable interrrupt mask = 1001, stop timer  
	stwio r3, TIMER_CONTROL(r2)		# Enable interrupts on timer0
	stwio r0, TIMER_STATUS(r2)		# Clear interrupt bit for timers.
	
	movia r2, IRQ_PUSHBUTTONS
	ori r2, r2, IRQ_TIMER0
	ori r2, r2, IRQ_TIMER1
	ori r2, r2, IRQ_PS2C1
	wrctl ctl3, r2					# Enable interrupts for timer0, timer1, pushbuttons/keyboard

	movi r2, 0x1
	wrctl ctl0, r2					# Enable global Interrupts on Processor 
	ret

.section .exceptions, "ax"
	/* Prologue */
    subi sp, sp, 24
    stw r8, 0(sp)
    stw r9, 4(sp)
    stw r10, 8(sp)
    stw r11, 12(sp)
	stw ea, 16(sp)
	rdctl r9, ctl1
	stw r9, 20(sp)

	# Check if interrupt was caused by a device
    rdctl et, ipending
    beq et, r0, interrupt_epilogue
	
	# Interrupt was caused by a device, make sure we
	# re-execute the interrupted instruction
    subi ea, ea, 4
    
	# Check which device caused the interrupt
	andi r9, et, IRQ_TIMER0			# IRQ 0, timer 0
	bne r9, r0, TIMER0_handler
	andi r9, et, IRQ_TIMER1			# IRQ 2, timer 1
	bne r9, r0, TIMER1_handler
	andi r9, et, IRQ_PS2C1		 	# IRQ 7, keyboard
	bne r9, r0, keyboard_handler
	andi r9, et, IRQ_PUSHBUTTONS 	# IRQ 1, pushbuttons
    beq r9, r0, interrupt_epilogue

keyboard_handler:
	/* Keyboard protocol 

	movia r9, PS2C1_BASE
	W -> 1D
	A -> 1C
	S -> 1B
	D -> 23
	
	*/

HEX_interrupt:
	# If we get here, a HEX keypad button was pushed for sure.
	# Determine which HEX keypad button was pushed, and branch to its handler.
    movia r9, ADDR_PUSHB 
    ldwio r10, PUSHB_ECR(r9)		# Load edge capture register
    addi r11, r0, 1

	# Pre-branching loading appropriate addresses into registers
	# and loaded appropriate values into the devices at those addresses
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB			# Do we need this?
	
	movia r10, 0x7F557FF			# Set direction for motors to all output 
    stwio r10, JP1_DIRREG(r8)
	
    # bit n set -> HEXn
    beq r10, r11, HEX0_handler
    slli r11, r11, 1
    beq r10, r11, HEX1_handler
    slli r11, r11, 1
    beq r10, r11, HEX2_handler
	slli r11, r11, 1
	beq r10, r11, HEX3_handler

HEX0_handler:
  
	call initialize_timer
	movia r10, 0xFFFFFFFC			# motor0 enabled (bit0=0), direction set to clockwise (bit1=0)
	stwio r10, JP1_DATA(r8)
	call start_timer_once	

    # Timer has started and will interrupt when done, turning off the motor
	jmpi interrupt_epilogue  

HEX1_handler:
  	
	call initialize_timer
	movia r10, 0xFFFFFFFE			# motor0 enabled (bit0=0), direction set to clockwise (bit1=1)
	stwio r10, JP1_DATA(r8)
	call start_timer_once	

	# Timer has started and will interrupt when done, turning off the motor
    jmpi interrupt_epilogue  

HEX2_handler:

	# ...

    movia r10, 0xFFFFFFF3			# make it go right (clockwise)
    stwio r10, JP1_DATA(r8)
    
	jmpi interrupt_epilogue
	
HEX3_handler:

	# ...

    movia r10, 0xFFFFFFFB			# make it go left (counter-clockwise)
    stwio r10, JP1_DATA(r8)
    
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
	

/* The second timer has sent an interrupt, therefore we need to turn off
	the motor and go back into the TIMER0 handler */
TIMER1_handler:
	...
	
    
interrupt_epilogue:
    movia et, ADDR_PUSHB
    movia r11, 0xFFFFFFFF
    stwio r11, 12(et)				# clear HEX edge capture registers by write.
									# TODO: clear interrupt bit on timer0, timer1
	ldw r9, 20(sp)
	wrctl ctl1, r9
	ldw ea, 16(sp)
    ldw r11, 12(sp)
    ldw r10, 8(sp)
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 16
	
    eret
