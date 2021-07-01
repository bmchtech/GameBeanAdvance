@ from: https://patater.com/gbaguy/gba/ch2.htm

.arm
.text
.global main

main:
	b test
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

test:
	ldr r0, [pc, #-0x4]

infin:
	b infin