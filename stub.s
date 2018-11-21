.text
.global _start

_start:
    movia sp, 0x80000000
    call setup_interrupts

loop:
    beq r0, r0, loop
