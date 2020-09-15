			.global main

// ************************* Constants to be Loaded into Registers for Testing *************************
			.data
// *****************************************************************************************************

test_values:
			.word 0x00000000
			.word 0x00000001
			.word 0xFFFFFFFF
			.word 0x80000000
			.word 0x7FFFFFFF
			.word 0x8ABD8297
			.word 0x289BDF39


// ******************************************** Test Cases *********************************************
			.text
// *****************************************************************************************************

main:
			.arm
			ADD r3, pc, #1
			BX r3
	
			.thumb
			LDR r7, =test_values


tests:
			// ADC tests
			LDR r0, [r7, #0x0]
			LDR r1, [r7, #0x0]
			MOV r1, r1 // clear carry flag
			ADC r0, r1
			BL  flagcheck

infin:
			B   infin





// these are flagchecks. flagchecks will be run after every log by
// calling BL flagcheck_N. this checks the flags of the ALU instructions

// otherwise known as flagcheck_N
flagcheck:
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
