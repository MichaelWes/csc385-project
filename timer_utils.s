.text

.global initialize_timer
.global initialize_timer1
.global start_timer_once
.global start_timer1_continuous
.global stop_timer0
.global stop_timer1

initialize_timer:
    movia r8, TIMER0_BASE
    addi r9, r0, %lo(TICKS_PER_SEC)
    stwio r9, TIMER_PERIODL(r8)

    addi r9, r0, %hi(TICKS_PER_SEC)
    stwio r9, TIMER_PERIODH(r8)

    ret

initialize_timer1:
    movia r8, TIMER1_BASE
    addi r9, r0, %lo(TICKS_PER_MSEC)
    stwio r9, TIMER_PERIODL(r8)

    addi r9, r0, %hi(TICKS_PER_MSEC)
    stwio r9, TIMER_PERIODH(r8)

    ret

start_timer_once:
    movia r8, TIMER0_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)
    movi r9, 0x5 					# Start the timer
    stwio r9, TIMER_CONTROL(r8)

    ret

stop_timer0:
    movia r8, TIMER0_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)

stop_timer1:
    movia r8, TIMER1_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)

start_timer1_continuous:
    movia r8, TIMER1_BASE

    movi r9, 0x9					# Stop the timer
    stwio r9, TIMER_CONTROL(r8)
    movi r9, 0x7 					# Start the timer, continuous mode
    stwio r9, TIMER_CONTROL(r8)

    ret
