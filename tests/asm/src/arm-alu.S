			.global main

@ ************************* Constants to be Loaded into Registers for Testing *************************
			.data
@ *****************************************************************************************************

test_values:
			.word 0x00000000 @ 0
			.word 0x00000001 @ 4
			.word 0xFFFFFFFF @ 8
			.word 0x80000000 @ C
			.word 0x7FFFFFFF @ 10
			.word 0x8ABD8297 @ 14
			.word 0x289BDF39 @ 18
			.word 0xEFFFFFFF @ 1C
			.word 0x00000004 @ 20
			.word 0xFFFFFF00 @ 24
			.word 0xFFFFFF04 @ 28
			.word 0xFFFFFF20 @ 2C
			.word 0x00000008 @ 30
			.word 0x0000000C @ 34


@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
            .arm
			LDR   r7, =test_values
			LDR   r2, [r7, #0x4]!
			LDR   r2, [r7, #0x8]!
			LDR   r2, [r7, #0x1C]!
			LDR   r2, [r7, #-0x20]!

			LDR   r2, [r7], #0x8

infin:
            B     infin