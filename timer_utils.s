.text

.global initialize_timer
.global initialize_timer1
.global start_timer_once
.global start_timer1_continuous
.global stop_timer0
.global stop_timer1

initialize_timer:
	subi sp, sp, 8
	stw r8, 0(sp)
	stw r9, 4(sp)
	
    movia r8, TIMER0_BASE
    addi r9, r0, %lo(TICKS_PER_DSEC)
    stwio r9, TIMER_PERIODL(r8)

    addi r9, r0, %hi(TICKS_PER_DSEC)
    stwio r9, TIMER_PERIODH(r8)

	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 8
	
    ret

initialize_timer1:
	subi sp, sp, 16
	stw r8, 0(sp)
	stw r9, 4(sp)
	stw r10, 8(sp)
	stw r11, 12(sp)

    movia r8, TIMER1_BASE
    movia r10, L #L is small, definitely less than 16 bits. 
    ldw r11, 0(r10)

    stwio r11, TIMER_PERIODL(r8)
    
    addi r9, r0, %hi(0)
    stwio r9, TIMER_PERIODH(r8)

	ldw r11, 12(sp)
	ldw r10, 8(sp)
	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 16
	
    ret

start_timer_once:
	subi sp, sp, 8
	stw r8, 0(sp)
	stw r9, 4(sp)

    movia r8, TIMER0_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)
    movi r9, 0x5 					# Start the timer
    stwio r9, TIMER_CONTROL(r8)

	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 8
	
    ret

stop_timer0:
	subi sp, sp, 8
	stw r8, 0(sp)
	stw r9, 4(sp)
	
    movia r8, TIMER0_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)
	
	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 8
	
	ret

stop_timer1:
	subi sp, sp, 8
	stw r8, 0(sp)
	stw r9, 4(sp)

    movia r8, TIMER1_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)
	
	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 8
	ret

start_timer1_continuous:
	subi sp, sp, 8
	stw r8, 0(sp)
	stw r9, 4(sp)
    movia r8, TIMER1_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)
    movi r9, 0x7 					# Start the timer, continuous mode
    stwio r9, TIMER_CONTROL(r8)

	ldw r9, 4(sp)
	ldw r8, 0(sp)
	addi sp, sp, 8
	
    ret
