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
.equ TICKS_PER_SEC, 100000000

.text

.global initialize_timer
.global start_timer_once

initialize_timer:
	
	# Save registers?

    movia r8, TIMER0_BASE
    addi r9, r0, %lo(TICKS_PER_SEC)
    stwio r9, TIMER_PERIODL(r8)

    addi r9, r0, %hi(TICKS_PER_SEC)
    stwio r9, TIMER_PERIODH(r8)

    ret

start_timer_once:
	
	# Save registers?
	
    movia r8, TIMER0_BASE
	
	movi r9, 0x9					# Stop the timer
	stwio r9, TIMER_CONTROL(r8)
	movi r9, 0x5 					# Start the timer
    stwio r9, TIMER_CONTROL(r8)

    ret
