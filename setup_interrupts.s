.equ ADDR_PUSHB, 0xFF200050
.equ ADDR_JP1, 0xFF200060   # Address GPIO JP1
.equ IRQ_PUSHBUTTONS, 0x02

.text
.global setup_interrupts

setup_interrupts:
  movia r2,ADDR_PUSHB
  movia r3,0x1	  # Enable interrrupt mask = 0001
  stwio r3,8(r2)  # Enable interrupts on pushbuttons 1,2, and 3
  stwio r3,12(r2) # Clear edge capture register to prevent unexpected interrupt

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
	movia r23, 0x1234
# Check if interrupt was caused by a device
    rdctl et, ipending
    beq et, r0, interrupt_epilogue

# Interrupt was caused by a device, make sure we
# re-execute the interrupted instruction
    subi ea, ea, 4
    
# Check if interrupt was caused by the HEX keypad
    andi r9, et, 0x02 # IRQ 1
    beq r9, r0, interrupt_epilogue

HEX0_handler:
	movia r22, 0x5678
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 
    
	movia r10, 0x7F557FF       # set direction for motors to all output 
	stwio r10, 4(r8)
  
	movia r10, 0xFFFFFFFC       # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
	stwio r10, 0(r8)  
    
    movia r11, 10000 
loop:
	addi r11, r11, -1
	bgt r11, r0, loop
    movia r10, 0xFFFFFFFF
	stwio r10, 0(r8)  
    
    
interrupt_epilogue:
	ldw r11, 12(sp)
    ldw r10, 8(sp)
    ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 16
   
    eret
