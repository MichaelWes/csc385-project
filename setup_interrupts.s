.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ IRQ_PUSHBUTTONS, 0x02

.global setup_interrupts

setup_interrupts:
  movia r2,ADDR_PUSHBUTTONS
  movia r3,0x1	  # Enable interrrupt mask = 0001
  stwio r3,8(r2)  # Enable interrupts on pushbuttons 1,2, and 3
  stwio r3,12(r2) # Clear edge capture register to prevent unexpected interrupt

  movia r2,IRQ_PUSHBUTTONS
  wrctl ctl3,r2   # Enable bit 1 - Pushbuttons use IRQ 1

  movia r2,1
  wrctl ctl0,r2   # Enable global Interrupts on Processor 
  ret 