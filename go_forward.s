.equ ADDR_JP1, 0xFF200060   # Address GPIO JP1
.equ ADDR_PUSHB, 0xFF200050 # Address of Push Buttons

.section .exceptions, "ax"
# Prologue
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

HEX0_handler:
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 
    
	movia r10, 0x7F557FF       # set direction for motors to all output 
	stwio r10, 4(r8)
  
	movia r10, 0xFFFFFFFC       # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
	stwio r10, 0(r8)  
    
    addi r11, r0, 30000
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

/*
.global go_forward  
 
go_forward:  
	movia r8, ADDR_JP1
    movia r9, ADDR_PUSHB 
    
	movia r10, x07F557FF       # set direction for motors to all output 
	stwio r10, 4(r8)
  
	movia r10, 0xFFFFFFFC       # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
	stwio r10, 0(r8)    
	ret 
*/
