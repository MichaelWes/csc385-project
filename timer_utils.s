.global initialize_timer
.global initialize_timer1
.global start_timer_once
.global start_timer1_continuous
.global stop_timer0
.global stop_timer1

initialize_timer:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)
	
    movia r16, TIMER0_BASE
    addi r17, r0, %lo(TICKS_PER_T)
    stwio r17, TIMER_PERIODL(r16)

    addi r17, r0, %hi(TICKS_PER_T)
    stwio r17, TIMER_PERIODH(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
	
    ret

initialize_timer1:
    subi sp, sp, 16
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw r19, 12(sp)

    movia r16, TIMER1_BASE
    movia r18, L #L is small, definitely less than 16 bits. 
    ldw r19, 0(r18)
    stwio r19, TIMER_PERIODL(r16)
    
    addi r17, r0, %hi(0)
    stwio r17, TIMER_PERIODH(r16)
    
    ldw r19, 12(sp)
    ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 16
	
    ret

start_timer_once:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, TIMER0_BASE

    movi r17, 0x9					# Stop the timer
    stwio r17, TIMER_CONTROL(r16)
    movi r17, 0x5 					# Start the timer
    stwio r17, TIMER_CONTROL(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
	
    ret

stop_timer0:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)
	
    movia r16, TIMER0_BASE

    movi r17, 0x9					# Stop the timer
    stwio r17, TIMER_CONTROL(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
    
    ret

stop_timer1:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, TIMER1_BASE

    movi r17, 0x9					# Stop the timer
    stwio r17, TIMER_CONTROL(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
    
    ret

start_timer1_continuous:
    subi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)
    
    movia r16, TIMER1_BASE

    movi r17, 0x9					# Stop the timer
    stwio r17, TIMER_CONTROL(r16)
    movi r17, 0x7 					# Start the timer, continuous mode
    stwio r17, TIMER_CONTROL(r16)
    
    ldw r17, 4(sp)
    ldw r16, 0(sp)
    addi sp, sp, 8
	
    ret
