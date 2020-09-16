			.global main

@ ************************* Constants to be Loaded into Registers for Testing *************************
			.data
@ *****************************************************************************************************

test_values:
			.word 0x00000000
			.word 0x00000001
			.word 0xFFFFFFFF
			.word 0x80000000
			.word 0x7FFFFFFF
			.word 0x8ABD8297
			.word 0x289BDF39


@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
			.arm
			ADD r3, pc, #1
			BX r3
	
			.thumb
			LDR r7, =test_values


tests:
			MOV r1, r1 @ clear carry flag

			@ ADC tests - without carry

			LDR r0, [r7, #0x0]
			LDR r1, [r7, #0x0]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 0100

			LDR r0, [r7, #0x0]
			LDR r1, [r7, #0x4]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 0000

			LDR r0, [r7, #0x8]
			LDR r1, [r7, #0x4]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 1001

			LDR r0, [r7, #0x8]
			LDR r1, [r7, #0x14]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 0011

			@ ADC tests - with carry

			LDR r0, [r7, #0x8]
			LDR r1, [r7, #0x0]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 0100

			LDR r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR r0, r0, #0x0

			LDR r0, [r7, #0x0]
			LDR r1, [r7, #0x4]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 0000

			LDR r0, [r7, #0x4] @ these two instructions set the carry flag
			ASR r0, r0, #0x0

			LDR r0, [r7, #0x10]
			LDR r1, [r7, #0x0]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 1001

			LDR r0, [r7, #0x4] @ these two instructions set the carry flag
			ASR r0, r0, #0x0

			LDR r0, [r7, #0x10]
			LDR r1, [r7, #0x14]
			ADC r0, r1
			BL  flagcheck @ flag status should be: NZCV = 0011

infin:
			B   infin

@ these are flagchecks. flagchecks will be run after every log by
@ calling BL flagcheck_N. this checks the flags of the ALU instructions

flagcheck: @ otherwise known as flagcheck_N
			BEQ flagcheck_Z
			B   flagcheck_Z

flagcheck_Z:
			BCS flagcheck_C
			B   flagcheck_C

flagcheck_C:
			BMI flagcheck_V
			B   flagcheck_V

flagcheck_V:
			BVS flagcheck_end
			B   flagcheck_end

flagcheck_end:
			MOV PC, LR
