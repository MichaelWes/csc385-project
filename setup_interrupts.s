/* GPIO JP1 addresses and byte offsets */
.equ ADDR_JP1, 0xFF200060 
.equ JP1_DATA, 0x00
.equ JP1_DIRREG, 0x04
.equ JP1_IMR, 0x08
.equ JP1_ECR, 0x0c

/* Pushbutton addresses and byte offsets */
.equ ADDR_PUSHB, 0xFF200050
.equ PUSHB_DATA, 0x00
.equ PUSHB_NA, 0x04
.equ PUSHB_IMR, 0x08
.equ PUSHB_ECR, 0x0c
.equ PUSHB_INTM, 0x07

/* Timer addresses and byte offsets */
.equ TIMER0_BASE, 0xFF202000
.equ TIMER1_BASE, 0xFF202020
.equ TIMER_STATUS, 0x00
.equ TIMER_CONTROL, 0x04
.equ TIMER_PERIODL, 0x08
.equ TIMER_PERIODH, 0x0c
.equ TIMER_SNAPL, 0x10
.equ TIMER_SNAPH, 0x14
.equ TIMER_INTM, 0x01

/* PS2 Controller addresses and byte offsets */
.equ PS2C1_BASE, 0xFF200100
.equ PS2C1_DATA, 0x00
.equ PS2C1_CTRLSTS, 0x04

/* IRQs for different devices */
.equ IRQ_PUSHBUTTONS, 0x02
.equ IRQ_TIMER0, 0x01
.equ IRQ_TIMER1, 0x04
.equ IRQ_PS2C, 0x80

.text

.global setup_interrupts

setup_interrupts:
	/* Turn everything off*/
	movia r8, ADDR_JP1
    	movia r9, ADDR_PUSHB 
    
	movia r10, 0x7F557FF			# set direction for motors to all output 
	stwio r10, JP1_DIRREG(r8)
  
	movia r10, 0xFFFFFFFF			# turn off all motors.
	stwio r10, JP1_DATA(r8)

	/* Request interrupts from HEX */
	movia r2, ADDR_PUSHB
	movia r3, PUSHB_INTM			# Enable interrupt mask = 0111
	stwio r3, PUSHB_IMR(r2)			# Enable interrupts on pushbuttons 1,2, and 3
	stwio r10, PUSHB_ECR(r2)		# Clear edge capture register (write all 1's) for HEX keypad.  
  
	/* Request interrupts from timer0 */
	movia r2, TIMER0_BASE
	movia r3, TIMER_INTM			# Interrupt enable for timeouts = 0001  
	stwio r3, TIMER_CONTROL(r2)		
	stwio r0, TIMER_STATUS(r2)		# Clear interrupt bit for timers.
	
	/* Request interrupts from keyboard controller */
	movia r2, PS2C1_BASE
	movi r3, 0x1
	stwio r3, PS2C1_CTRLSTS(r2)		# Interrupt enable is bit 0 of control register.
	ldwio r0, PS2C1_DATA(r2)		# Read data to acknowledge the interrupt. Throw it away.
	
	/* Enable specific interrupt lines on processor */
	movia r2, IRQ_PUSHBUTTONS
	ori r2, r2, IRQ_TIMER0
	ori r2, r2, IRQ_PS2C
	wrctl ienable, r2			# Enable bit 1 - Pushbuttons use IRQ 1

	movia r2, 1
	wrctl status, r2			# Enable global Interrupts on Processor 
	ret

.section .exceptions, "ax"
    	/* Prologue */
    	subi sp, sp, 16
    	stw r8, 0(sp)
    	stw r9, 4(sp)
    	stw r10, 8(sp)
   	 stw r11, 12(sp)

	# Check if interrupt was caused by a device
    	rdctl et, ipending
    	beq et, r0, interrupt_epilogue
	
	# Interrupt was caused by a device, make sure we
	# re-execute the interrupted instruction
    	subi ea, ea, 4
    
	# Check if interrupt was caused by the HEX keypad
    	andi r9, et, IRQ_PUSHBUTTONS 		# IRQ 1
    	bne r9, r0, HEX_MUX
	# Check if interrupt was caused by the keyboard
	andi r9, et, IRQ_PS2C
	beq r9, r0, interrupt_epilogue
	bne r9, r0, PS2_handler

HEX_MUX:
	# If we get here, a HEX keypad button was pushed for sure.
	# Determine which HEX keypad button was pushed, and branch to its handler.
    	movia r9, ADDR_PUSHB 
    	ldwio r10, PUSHB_ECR(r9)		# load edge capture register
    	addi r11, r0, 1
	
	# ... and branch to its handler.
    	# bit 0 set -> HEX0
    	beq r10, r11, HEX0_handler
    	slli r11, r11, 1
    	beq r10, r11, HEX1_handler
    	slli r11, r11, 1
    	beq r10, r11, HEX2_handler
	
	# Load addresses into registers commonly used in subsequent branches.
	movia r8, ADDR_JP1

HEX0_handler:
	movia r10, 0xFFFFFFFC			# motor0 enabled (bit0=0), direction set to forward (bit1=0) 
	stwio r10, JP1_DATA(r8)
    	jmpi interrupt_epilogue  

HEX1_handler:
	movia r10, 0xFFFFFFFF			# Turn off all motors.
	stwio r10, JP1_DATA(r8)
    	jmpi interrupt_epilogue  

HEX2_handler:
   	movia r10, 0xFFFFFFF3			# Go left (or right?!)
    	stwio r10, JP1_DATA(r8)
	jmpi interrupt_epilogue

PS2_handler:
						# TODO: handle specific keys.
	movia r8, PS2C1_BASE
	ldwio r11, PS2C1_DATA(r8)		# Reading clears the keyboard interrupt.
	jmpi interrupt_epilogue
    
interrupt_epilogue:
    	movia et, ADDR_PUSHB
    	movia r11, 0xFFFFFFFF
    	stwio r11, 12(et)			# Clear HEX edge capture registers by write.
						# TODO: clear interrupt bit on timer0
    	ldw r11, 12(sp)
    	ldw r10, 8(sp)
    	ldw r9, 4(sp)
    	ldw r8, 0(sp)
    	addi sp, sp, 16
   
    	eret
