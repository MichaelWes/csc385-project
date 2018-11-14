initialize_timer:
    movia r8, TIMER0_BASE
    addi r9, r0, %lo(TICKS_PER_SEC)
    stwio r9, TIMER0_PERIODL(r8)

    addi r9, r0, %hi(TICKS_PER_SEC)
    stwio r9, TIMER0_PERIODH(r8)

    ret

start_timer_once:
    movia r8, TIMER0_BASE

    movi r9, 0x4

    stwio r9, TIMER0_CONTROL(r8)

    ret
