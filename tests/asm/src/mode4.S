@ https://patater.com/gbaguy/gba/ch4.htm

.arm
.text
.global main
main:
	mov r0, #0x4000000  @ the usual set up routine
	mov r1, #0x400   @ 0x403 is BG 2 enable, and mode 3.
	add r1, r1, #4
	strh r1, [r0]   @ the memory I/O value we're setting is actually 16bits, let's not mess 
			@ something else up by writting 32.
	
	mov r0, #0x6000000  @ address of VRAM
    mov r5, #0x5000000   @ address of palette
	ldr r1, =pic        @ using this form of LDR with a label will put the address of the label into r1.
	mov r2, #0x200     @ the amount of 32 BYTE writes to fill the screen (we'll be using a new instruction)

loop1:
    ldrb r6, [r1], #1
    strb r6, [r5], #1  @ will store the 16bit value in r1 into address in r0, then 
				@ add 2 to r0. (16bit values are 2 bytes long).
	subs r2, r2, #1   @ subtract 1 from r2 (r2 = r2 - 1). the S after SUB means to set the 
			  @ flags in CPSR based on the result.
	bne loop1         @ If the status doesn't reflect the result of an instruction being zero, jump to loop1.

	mov r2, #0x12c00     @ the amount of 32 BYTE writes to fill the screen (we'll be using a new instruction)

loop2:
    ldrb r6, [r1], #1
    strb r6, [r0], #1  @ will store the 16bit value in r1 into address in r0, then 
				@ add 2 to r0. (16bit values are 2 bytes long).
	subs r2, r2, #1   @ subtract 1 from r2 (r2 = r2 - 1). the S after SUB means to set the 
			  @ flags in CPSR based on the result.
	bne loop2         @ If the status doesn't reflect the result of an instruction being zero, jump to loop1.

infin:
	b infin  @ infinite loop

.ltorg   @ give the assembler a place to put the immediate value "pool", needed for the ldr REG,= (s).
pic:   @ a label to indicate the address  of the included data.
	.incbin "src/zuyd.bin"  @ include the binary file
