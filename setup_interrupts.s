.equ ADDR_PUSHB, 0xFF200050
.equ ADDR_JP1, 0xFF200060   # Address GPIO JP1
.equ IRQ_PUSHBUTTONS, 0x02

.text
.global setup_interrupts

setup_interrupts:
/* Turn everything off*/
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 
    
	movia r10, 0x7F557FF       # set direction for motors to all output 
	stwio r10, 4(r8)
  
	movia r10, 0xFFFFFFFF       # turn off all motors.
	stwio r10, 0(r8)
/*     */

  movia r2,ADDR_PUSHB
  movia r3,0x3	  # Enable interrrupt mask = 0011
  stwio r3,8(r2)  # Enable interrupts on pushbuttons 1,2, and 3
  stwio r10,12(r2) # Clear edge capture register (write all 1's) to prevent unexpected interrupt

  movia r2,IRQ_PUSHBUTTONS
  wrctl ctl3,r2   # Enable bit 1 - Pushbuttons use IRQ 1

  movia r2,1
  wrctl ctl0,r2   # Enable global Interrupts on Processor 
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
    andi r9, et, 0x02 # IRQ 1
    beq r9, r0, interrupt_epilogue

# If we get here, a HEX keypad button was pushed for sure.
# Determine which HEX keypad button was pushed, and branch to its handler.
    movia r9, ADDR_PUSHB 
    ldwio r10, 12(r9)           # load edge capture register
    addi r11, r0, 1

    # bit 0 set -> HEX0
    beq r10, r11, HEX0_handler
    slli r11, r11, 1
    beq r10, r11, HEX1_handler

HEX0_handler:
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 
    
	movia r10, 0x7F557FF       # set direction for motors to all output 
	stwio r10, 4(r8)
  
	movia r10, 0xFFFFFFFC       # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
	stwio r10, 0(r8)
    jmpi interrupt_epilogue  

HEX1_handler:
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 
    
	movia r10, 0x7F557FF       # set direction for motors to all output 
	stwio r10, 4(r8)
  
	movia r10, 0xFFFFFFFF       # turn off all motors.
	stwio r10, 0(r8)
    jmpi interrupt_epilogue  

    
interrupt_epilogue:
    
    movia et, ADDR_PUSHB
    movia r11, 0xFFFFFFFF
    stwio r11, 12(et)            # clear HEX edge capture registers by write.

    ldw r11, 12(sp)
    ldw r10, 8(sp)
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 16
   
    eret
