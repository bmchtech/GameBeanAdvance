.arm
.text
.global main
main:
	mov r0, #0x4000000  @ the usual set up routine
	mov r1, #0x400   @ 0x403 is BG 2 enable, and mode 3.
	add r1, r1, #3
	strh r1, [r0]   @ the memory I/O value we're setting is actually 16bits, let's not mess 
			@ something else up by writting 32.
	
	mov r0, #0x6000000  @ address of VRAM
	ldr r1, =pic        @ using this form of LDR with a label will put the address of the label into r1.
	mov r2, #0x960     @ the amount of 32 BYTE writes to fill the screen (we'll be using a new instruction)
loop1:
	ldmia r1!, { r3,r4,r5,r6,r7,r8,r9,r10 } @ will start with the address in r1, it will load each listed register
				@ with 32bits from memory, incrementing the address by 4 each time. The final address used +4
				@ will be written back into r1 (because of the !). Note this instruction doesn't use 
				@ brackets around the register used for the address.
	stmia r0!, { r3,r4,r5,r6,r7,r8,r9,r10 } @ will start with the address in r1, it will store each listed register
				@ into memory (32bit write), adding 4 to the address. The final address used +4 will
				@ be written back.
	@ These instructions are a fast(er) way to do block memory copying, they are only useful when you have alot of
	@ registers available (registers 3-10 were used here, but I could have said r2,r4, they don't have to be in order
	@ just don't use the address register in the destination list.

	subs r2, r2, #1  @ subtraction setting the flags
	bne loop1  @ will loop if r2 wasn't zero.

infin:
	b infin  @ infinite loop

.ltorg   @ give the assembler a place to put the immediate value "pool", needed for the ldr REG,= (s).
pic:   @ a label to indicate the address  of the included data.
	.incbin "src/pic.bin"  @ include the binary file
