@ from: https://patater.com/gbaguy/gba/ch2.htm

.arm
.text
.global main

main:
	mov r0, #0x4000000
	mov r1, #0x400
	add r1, r1, #3
	str r1, [r0]

	mov r0, #0x6000000
	mov r1, #0xFF
	mov r2, #0x9600
loop1:
	strh r1, [r0], #2
	subs r2, r2, #1
	bne loop1

infin:
	b infin