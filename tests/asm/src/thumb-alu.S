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

return:
			.word 0x000046F7 @ this is just MOV LR, PC (thumb)

pop_stack:	.word 0xABCDEF99
			.word 0x02829743
			.word 0x38972734
			.word 0x03000058 @ address of return

push_stack: .word 0x48014800


@ just a bunch of SWI #0x03 instructions (0x03 is stop). these should be overwritten
@ when the PUSH tests are run.

overwrite_me_start:
			.word 0xDF03DF03
			.word 0xDF03DF03
			.word 0xDF03DF03
			.word 0xDF03DF03
			.word 0xDF03DF03
			.word 0xDF03DF03
			.word 0xDF03DF03
			.word 0xDF0346F7
overwrite_me_end:	

stmia_data:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

str_testing:
			.word 0x00000000
			.word 0x00000000

@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
			.arm
			LDR   r7, =test_values
			ADD   r3, pc, #1
			BX    r3
	
			.thumb

tests:

@ ADC tests (without carry)

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0100

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1001

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0110

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0xC]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1000

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0110

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1000

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0011

			MOV r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1010

@ ADC tests (with carry)

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0110

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0xC]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0110

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			ADC   r0, r1
			BL    flagcheck @ NZCV = 1010

@ ADD #1 tests (3-bit immediate value)

			LDR   r0, [r7, #0x0]
			ADD   r0, r1, #0x0
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			ADD   r0, r1, #0x1
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			ADD   r0, r1, #0x5
			BL    flagcheck @ NZCV = 0010

			LDR   r0, [r7, #0xC]
			ADD   r0, r1, #0x5
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			ADD   r0, r1, #0x1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			ADD   r0, r1, #0x0
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			ADD   r0, r1, #0x7
			BL    flagcheck @ NZCV = 1010

@ ADD #2 tests (8-bit immediate value)

			LDR   r0, [r7, #0x0]
			ADD   r0,  #0x00
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			ADD   r0,  #0x01
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			ADD   r0, #0xFF
			BL    flagcheck @ NZCV = 0010

			LDR   r0, [r7, #0xC]
			ADD   r0, #0xFF
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			ADD   r0, #0x01
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			ADD   r0, #0x00
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			ADD   r0, #0xAB
			BL    flagcheck @ NZCV = 1010

@ ADD #3 tests (three separate registers)

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 0110

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0xC]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 0110

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			ADD   r2, r0, r1
			BL    flagcheck @ NZCV = 1010

@ ADD #4 tests (high registers)
			
			@ flags should be unaffected

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r8, r1
			BL    flagcheck

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r1, r8
			BL    flagcheck

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r1, r8
			BL    flagcheck

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0xC]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r8, r1
			BL    flagcheck

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r1, r8
			BL    flagcheck

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r8, r1
			BL    flagcheck

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r1, r8
			BL    flagcheck

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			ADD   r8, r1
			BL    flagcheck

@ ADD #5 tests (PC-relative)
			
			@ flags should be unaffected

			ADD   r2, PC, #0x00
			BL    flagcheck

			ADD   r2, PC, #0x04
			BL    flagcheck

			ADD   r2, PC, #0x3F8
			BL    flagcheck

			ADD   r2, PC, #0x3FC
			BL    flagcheck

@ ADD #6 tests (SP-relative)
			
			@ flags should be unaffected

			ADD   r2, SP, #0x00
			BL    flagcheck

			ADD   r2, SP, #0x04
			BL    flagcheck

			ADD   r2, SP, #0x3F8
			BL    flagcheck

			ADD   r2, SP, #0x3FC
			BL    flagcheck

@ ADD #7 tests (Adding to Stack Pointer)
			
			@ flags should be unaffected

			ADD   SP, #0x00
			BL    flagcheck

			ADD   SP, #0x04
			BL    flagcheck

			ADD   SP, #0x1F8
			BL    flagcheck

			ADD   SP, #0x1FC
			BL    flagcheck

@ AND tests (Same register)

			LDR   r0, [r7, #0x0]
			AND   r0, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8]
			AND   r0, r0
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			AND   r0, r0
			BL    flagcheck

@ AND tests (Different registers)

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			AND   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x8]
			AND   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			AND   r0, r1
			BL    flagcheck

@ ASR #1 tests
			
			LDR   r1, [r7, #0x1C]
			ASR   r0, r1, #0b00000
			BL    flagcheck
			
			LDR   r1, [r7, #0xC]
			ASR   r0, r1, #0b00000
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			ASR   r0, r1, #0b00001
			BL    flagcheck
			
			LDR   r1, [r7, #0x18]
			ASR   r0, r1, #0b00010
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			ASR   r0, r1, #0b00101
			BL    flagcheck
			
			LDR   r1, [r7, #0x18]
			ASR   r0, r1, #0b11111
			BL    flagcheck

@ ASR #2 tests (shift == 0)
			
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x24]
			LDR   r1, [r7, #0x0]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x0]
			ASR   r0, r1
			BL    flagcheck

@ ASR #2 tests (shift < 32)
			
			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x4]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x18]
			LDR   r1, [r7, #0x28]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x20]
			ASR   r0, r1
			BL    flagcheck

@ ASR #2 tests (shift >= 32)
			
			LDR   r0, [r7, #0x00]
			LDR   r1, [r7, #0x2C]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x00]
			LDR   r1, [r7, #0x8]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x2C]
			ASR   r0, r1
			BL    flagcheck
			
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			ASR   r0, r1
			BL    flagcheck

@ Conditional Branch tests
	@ these tests will set the CPSR using ADD instructions, and then run some jumps
	@ to make sure the branches work.
			B     beq_start

	error0:
			SWI   #0x3 @ soft reset

	@ BEQ tests
	beq_start:

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BEQ   error0
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BEQ   beq_pass
			B     error0

	beq_pass:	

	@ BNE tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BNE   error0
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BNE   bne_pass
			B     error0
			
	bne_pass:	

	@ BCS tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BCS   error0
	
			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BCS   bcs_pass
			B     error0

	bcs_pass:	

	@ BCC tests
	
			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BCC   error0
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BCC   bcc_pass
			B     error0
			
	bcc_pass:	

	@ BMI tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BMI   error0
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BMI   bmi_pass
			B     error0

	bmi_pass:	

	@ BPL tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BPL   error0
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BPL   bpl_pass
			B     error0
			
	bpl_pass:	

	@ BVS tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BVS   error0
	
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BVS   bvs_pass
			B     error0

	bvs_pass:

	@ BVC tests
	
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BVC   error0
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BVC   bvc_pass
			B     error0
			
	bvc_pass:

	@ BHI tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BHI   error1
	
			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BHI   error1
	
			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BHI   error1
	
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BHI   bhi_pass
			B     error1
	
	bhi_pass:

	@ BLS tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BLS   bls_pass0
			B     error1
	
	bls_pass0:
	
			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BLS   bls_pass1
			B     error1
	
	bls_pass1:
	
			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BLS   bls_pass2
			B     error1
	
	bls_pass2:
	
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BLS   error1

	@ BGE tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BGE   bge_pass0
			B     error1
	
	bge_pass0:
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BGE   error1
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BGE   error1
	
			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADD   r0, r1
			BGE   bge_pass1
			B     error1
	
	bge_pass1:

	@ BLT tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BLT   error1
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BLT   blt_pass0
			B     error1
	
	blt_pass0:
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x8]
			ADD   r0, r1
			BLT   blt_pass1
			B     error1
	
	blt_pass1:
	
			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADD   r0, r1
			BLT   error1

	@ BGT tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BGT   bgt_pass0
			B     error1
	
	bgt_pass0:
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x14]
			ADD   r0, r1
			BGT   error1
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BGT   error1
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BGT   error1
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BGT   error1
	
			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADD   r0, r1
			BGT   bgt_pass1
			B     error1
	
	bgt_pass1:

	@ BLE tests
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BLE   error1
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x14]
			ADD   r0, r1
			BLE   ble_pass0
			B     error1
	
	ble_pass0:
	
			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			ADD   r0, r1
			BLE   ble_pass1
			B     error1
	
	ble_pass1:
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			ADD   r0, r1
			BLE   ble_pass2
			B     error1
	
	ble_pass2:
	
			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			ADD   r0, r1
			BLE   ble_pass3
			B     error1
	
	ble_pass3:
	
			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			ADD   r0, r1
			BLE   error1
			B     bic_start

error1:
			SWI   #0x3 @ soft reset

@ BIC tests
	
bic_start:

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			BIC   r0, r1
			BL    flagcheck
	
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x0]
			BIC   r0, r1
			BL    flagcheck
	
			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			BIC   r0, r1
			BL    flagcheck
	
			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			BIC   r0, r1
			BL    flagcheck

@ CMN tests:

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x10]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 0110

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0xC]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 0110

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x4]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0xC]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x8]
			CMN   r0, r1
			BL    flagcheck @ NZCV = 1010

@ CMP #1 tests (8-bit immediate value)

			LDR   r0, [r7, #0x0]
			CMP   r0,  #0x00
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			CMP   r0,  #0x01
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			CMP   r0, #0xFF
			BL    flagcheck @ NZCV = 0010

			LDR   r0, [r7, #0xC]
			CMP   r0, #0xFF
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			CMP   r0, #0x01
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			CMP   r0, #0x00
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			CMP   r0, #0xAB
			BL    flagcheck @ NZCV = 1010

@ CMP #2 tests (low register with low register)

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x4]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 0010

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x8]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x0]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x14]
			CMP   r0,  r1
			BL    flagcheck @ NZCV = 1010

@ CMP #3 tests (at least one high register)

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			MOV   r8, r1 @ can't load directly into high register, so i use this method instead
			CMP   r0,  r8
			BL    flagcheck @ NZCV = 0100

			LDR   r0, [r7, #0x10]
			LDR   r1, [r7, #0x4]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			CMP   r8,  r1
			BL    flagcheck @ NZCV = 1001

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x8]
			MOV   r8, r1 @ can't load directly into high register, so i use this method instead
			CMP   r0,  r8
			BL    flagcheck @ NZCV = 0010

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x8]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			CMP   r8,  r1
			BL    flagcheck @ NZCV = 0011

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x4]
			MOV   r8, r1 @ can't load directly into high register, so i use this method instead
			CMP   r0,  r8
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x0]
			MOV   r8, r0 @ can't load directly into high register, so i use this method instead
			CMP   r8,  r1
			BL    flagcheck @ NZCV = 1000

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x14]
			MOV   r8, r1 @ can't load directly into high register, so i use this method instead
			CMP   r0,  r8
			BL    flagcheck @ NZCV = 1010

@ EOR tests (Same register)

			LDR   r0, [r7, #0x0]
			EOR   r0, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8]
			EOR   r0, r0
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			EOR   r0, r0
			BL    flagcheck

@ EOR tests (Different registers)

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			EOR   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x8]
			EOR   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			EOR   r0, r1
			BL    flagcheck

@ LDMIA tests

			MOV   r8, r7
			LDMIA r7!, {r0, r2, r5, r6}
			LDMIA r7!, {r0, r2, r5, r6, r7}
			MOV   r7, r8

@ Note: LDR #1 is minimally tested, because it is required for the tests to even 
@ run in the first place.
@ LDR #1 tests (immediate offset)

			LDR r2, [r7, #0x0]
			LDR r2, [r7, #0x4]
			LDR r2, [r7, #0x8]
			LDR r2, [r7, #0xC]

@ LDR #2 tests (register offset)

			LDR   r0, [r7, #0x0]
			LDR   r2, [r7, r0]

			LDR   r0, [r7, #0x20]
			LDR   r2, [r7, r0]
			
			LDR   r0, [r7, #0x30]
			LDR   r2, [r7, r0]

			LDR   r0, [r7, #0x34]
			LDR   r2, [r7, r0]

@ LDR #3 tests (PC offset)

			LDR   r2, [PC, #0x0]
			LDR   r2, [PC, #0x4]
			LDR   r2, [PC, #0x8]
			LDR   r2, [PC, #0xC]

@ LDR #4 tests (SP offset)

			LDR   r2, [SP, #0x0]
			LDR   r2, [SP, #0x4]
			LDR   r2, [SP, #0x8]
			LDR   r2, [SP, #0xC]

@ LDRB #1 tests (immediate offset)

			LDRB  r2, [r7, #0x14]
			LDRB  r2, [r7, #0x15]
			LDRB  r2, [r7, #0x16]
			LDRB  r2, [r7, #0x17]

@ LDRB #2 tests (register offset)

			LDR   r0, [r7, #0x0]
			LDRB  r2, [r7, r0]

			LDR   r0, [r7, #0x20]
			LDRB  r2, [r7, r0]
			
			LDR   r0, [r7, #0x30]
			LDRB  r2, [r7, r0]

			LDR   r0, [r7, #0x34]
			LDRB  r2, [r7, r0]

@ LDRH #1 tests (immediate offset)

			LDRH  r2, [r7, #0x14]
			LDRH  r2, [r7, #0x16]
			LDRH  r2, [r7, #0x18]
			LDRH  r2, [r7, #0x1A]

@ LDRH #2 tests (register offset)

			LDR   r0, [r7, #0x0]
			LDRH  r2, [r7, r0]

			LDR   r0, [r7, #0x20]
			LDRH  r2, [r7, r0]
			
			LDR   r0, [r7, #0x30]
			LDRH  r2, [r7, r0]

			LDR   r0, [r7, #0x34]
			LDRH  r2, [r7, r0]

@ LDRSB tests

			LDR   r0, [r7, #0x0]
			LDRSB r2, [r7, r0]

			LDR   r0, [r7, #0x20]
			LDRSB r2, [r7, r0]
			
			LDR   r0, [r7, #0x30]
			LDRSB r2, [r7, r0]

			LDR   r0, [r7, #0x34]
			LDRSB r2, [r7, r0]

@ LDRSH tests

			LDR   r0, [r7, #0x0]
			LDRSH r2, [r7, r0]

			LDR   r0, [r7, #0x20]
			LDRSH r2, [r7, r0]
			
			LDR   r0, [r7, #0x30]
			LDRSH r2, [r7, r0]

			LDR   r0, [r7, #0x34]
			LDRSH r2, [r7, r0]

@ LSL #1 tests (immediate value)

			LDR   r1, [r7, #0x1C]
			LSL   r0, r1, #0b00000
			BL    flagcheck
			
			LDR   r1, [r7, #0xC]
			LSL   r0, r1, #0b00000
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSL   r0, r1, #0b00001
			BL    flagcheck
			
			LDR   r1, [r7, #0x18]
			LSL   r0, r1, #0b00010
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSL   r0, r1, #0b00101
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSL   r0, r1, #0b01001
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSL   r0, r1, #0b01010
			BL    flagcheck
			
			LDR   r1, [r7, #0x18]
			LSL   r0, r1, #0b11111
			BL    flagcheck

@ LSL #2 tests (register shift)

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x0]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x24]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x4]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x4]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x30]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x30]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x2C]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x2C]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x08]
			LSL   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x08]
			LSL   r1, r2
			BL    flagcheck

@ LSR #1 tests (immediate value)

			LDR   r1, [r7, #0x1C]
			LSR   r0, r1, #0b00000
			BL    flagcheck
			
			LDR   r1, [r7, #0xC]
			LSR   r0, r1, #0b00000
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSR   r0, r1, #0b00001
			BL    flagcheck
			
			LDR   r1, [r7, #0x18]
			LSR   r0, r1, #0b00010
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSR   r0, r1, #0b00101
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSR   r0, r1, #0b01001
			BL    flagcheck
			
			LDR   r1, [r7, #0x14]
			LSR   r0, r1, #0b01010
			BL    flagcheck
			
			LDR   r1, [r7, #0x18]
			LSR   r0, r1, #0b11111
			BL    flagcheck

@ LSR #2 tests (register shift)

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x0]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x24]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x4]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x4]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x30]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x30]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x2C]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x2C]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r2, [r7, #0x08]
			LSR   r1, r2
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r2, [r7, #0x08]
			LSR   r1, r2
			BL    flagcheck

@ MOV #1 tests (8-bit immediate value)

			MOV   r2, #0x00
			BL    flagcheck

			MOV   r3, #0x20
			BL    flagcheck

			MOV   r4, #0xA5
			BL    flagcheck

@ MOV #2 tests (low register to low register move)

			LDR   r1, [r7, #0x00]
			MOV   r2, r1
			BL    flagcheck

			LDR   r3, [r7, #0x08]
			MOV   r0, r3
			BL    flagcheck

			LDR   r6, [r7, #0x14]
			MOV   r5, r6
			BL    flagcheck

@ MOV #3 tests (at least one high register)

			LDR   r1, [r7, #0x00]
			MOV   r8, r1
			BL    flagcheck

			LDR   r3, [r7, #0x08]
			MOV   r9, r3
			BL    flagcheck

			LDR   r3, [r7, #0x14]
			MOV   r14, r3
			BL    flagcheck

			@ a bunch of checks on the program counter to make sure MOV #3 accurately takes pipelining into account
			MOV   r0,  r15  @ get the program counter
			MOV   r0,  r15  @ get the program counter
			MOV   r0,  r15  @ get the program counter
			MOV   r0,  r15  @ get the program counter

			@ and now for a *really* fancy test
			MOV   r0,  r15  @ get the program counter
			ADD   r0,  #0x5 @ skip ahead two instructions, set thumb mode
			MOV   r15, r0   @ set the program counter, which should skip the next instruction
			B     error2    @ should be skipped
			B     mul_start @ should be run
			B     error2    @ should be skipped

error2:
			SWI   #0x3

@ MUL tests
mul_start:

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			MUL   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x8]
			MUL   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			MUL   r0, r1
			BL    flagcheck

@ MVN tests

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			MVN   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x8]
			MVN   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			MVN   r0, r1
			BL    flagcheck

@ NEG tests

            LDR   r0, [r7, #0x0]
            NEG   r1, r0
            BL    flagcheck

            LDR   r1, [r7, #0x8]
            NEG   r1, r0
            BL    flagcheck

            LDR   r0, [r7, #0x14]
            NEG   r1, r0
            BL    flagcheck

            LDR   r1, [r7, #0x18]
            NEG   r1, r0
            BL    flagcheck

            LDR   r1, [r7, #0x20]
            NEG   r1, r0
            BL    flagcheck	

@ ORR tests (Same register)

			LDR   r0, [r7, #0x0]
			ORR   r0, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8]
			ORR   r0, r0
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			ORR   r0, r0
			BL    flagcheck

@ ORR tests (Different registers)

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x8]
			ORR   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x8]
			ORR   r0, r1
			BL    flagcheck

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			ORR   r0, r1
			BL    flagcheck

@ POP tests (PC not included)
			POP {r0, r3, r6}
			POP {r0, r1, r2, r3, r4, r5, r6, r7}
			
@ POP tests (PC included)

			LDR   r0, =pop_stack    @ load the fake stack into r0
			MOV   SP, r0            @ move it to the stack pointer
			MOV   LR, PC            @ save the PC into LR
			POP   {r2, r5, r6, PC}  @ pop, which branches us to 0x03000058 (which contains a MOV PC, LR instruction)
			                        @ after all is said and done, we should be back here, ready for PUSH tests

@ PUSH tests

			@ we're going to load instructions in hex form into the registers,
			@ and then PUSH them to ram, and let the cpu execute them.
			@ this verifies that the registers were pushed in the right order.

			LDR   r7, =overwrite_me_end
			MOV   SP, r7
			LDR   r7, =push_stack

			@ i would use LDMIA, but i want to make sure tests can be run while relying on 
			@ as few other instructions as possible. LDR is a simple instruction, so it gets 
			@ a pass. plus, im just loading the same thing into every register, sooo....

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			LDR   r2, [r7, #0x0]
			LDR   r3, [r7, #0x0]
			LDR   r4, [r7, #0x0]
			LDR   r5, [r7, #0x0]
			LDR   r6, [r7, #0x0]

			LDR   r7, =return
			LDR   r7, [r7, #0x0]
			
			PUSH  {r0, r1, r2, r3, r4, r5, r6, r7}
			
			LDR   r0, =overwrite_me_start
			MOV   LR, PC
			MOV   PC, r0

@ ROR tests (Rs[7:0] == 0)
			LDR   r7, =test_values

			LDR   r1, [r7, #0x14]
			LDR   r0, [r7, #0x0]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r0, [r7, #0x0]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r0, [r7, #0x24]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r0, [r7, #0x24]
			ROR   r1, r0
			BL    flagcheck

@ ROR tests (Rs[4:0] == 0)

			LDR   r1, [r7, #0x14]
			LDR   r0, [r7, #0x0]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r0, [r7, #0x0]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r0, [r7, #0x2C]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r0, [r7, #0x2C]
			ROR   r1, r0
			BL    flagcheck

@ ROR tests (Rs[4:0] > 0)

			LDR   r1, [r7, #0x14]
			LDR   r0, [r7, #0x30]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r0, [r7, #0x4]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x14]
			LDR   r0, [r7, #0x34]
			ROR   r1, r0
			BL    flagcheck

			LDR   r1, [r7, #0x18]
			LDR   r0, [r7, #0x20]
			ROR   r1, r0
			BL    flagcheck

@ SBC tests (without carry)

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x30]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x10]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x24]
			LDR   r1, [r7, #0x28]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x1C]
			LDR   r1, [r7, #0x0]
			SBC   r1, r0
			BL    flagcheck

			MOV   r1, r1 @ clear carry flag

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x10]
			SBC   r1, r0
			BL    flagcheck

@ SBC tests (with carry)

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x0]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x4]
			LDR   r1, [r7, #0x30]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0xC]
			LDR   r1, [r7, #0x10]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x14]
			LDR   r1, [r7, #0x18]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x24]
			LDR   r1, [r7, #0x28]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x1C]
			LDR   r1, [r7, #0x0]
			SBC   r1, r0
			BL    flagcheck

			LDR   r0, [r7, #0x8] @ these two instructions set the carry flag
			ASR   r0, r0, #0x0

			LDR   r0, [r7, #0x8]
			LDR   r1, [r7, #0x10]
			SBC   r1, r0
			BL    flagcheck

@ STMIA tests

			@ after the showoff that was PUSH tests, i've decided i don't want to do that
			@ ever again and i'm just going to use ldr to test the STMIA's functionality...

			LDR   r0, [r7, #0x0]
			LDR   r1, [r7, #0x4]
			LDR   r2, [r7, #0x8]
			LDR   r3, [r7, #0xC]
			LDR   r4, [r7, #0x10]
			LDR   r5, [r7, #0x14]
			LDR   r6, [r7, #0x18]

			LDR   r7, =stmia_data
			STMIA r7!, {r0, r2, r3, r5, r6}
			LDR   r7, =stmia_data
			LDR   r6, [r7, #0x0]
			LDR   r6, [r7, #0x4]
			LDR   r6, [r7, #0x8]
			LDR   r6, [r7, #0xC]
			LDR   r6, [r7, #0x10]
			LDR   r6, [r7, #0x14]
			LDR   r6, [r7, #0x18]
			LDR   r6, [r7, #0x1C]

			MOV   r8, r7
			LDR   r6, [r7, #0x18]

			LDR   r7, =stmia_data
			STMIA r7!, {r0, r2, r3, r4, r5, r6, r7}
			LDR   r7, =stmia_data
			LDR   r6, [r7, #0x0]
			LDR   r6, [r7, #0x4]
			LDR   r6, [r7, #0x8]
			LDR   r6, [r7, #0xC]
			LDR   r6, [r7, #0x10]
			LDR   r6, [r7, #0x14]
			LDR   r6, [r7, #0x18]
			LDR   r6, [r7, #0x1C]

			MOV   r8, r7
			LDR   r6, [r7, #0x18]
			ADD   r7, #0x3

			LDR   r7, =stmia_data
			STMIA r7!, {r0, r2, r3, r5, r6}
			LDR   r7, =stmia_data
			LDR   r6, [r7, #0x0]
			LDR   r6, [r7, #0x4]
			LDR   r6, [r7, #0x8]
			LDR   r6, [r7, #0xC]
			LDR   r6, [r7, #0x10]
			LDR   r6, [r7, #0x14]
			LDR   r6, [r7, #0x18]
			LDR   r6, [r7, #0x1C]

			MOV   r8, r7
			LDR   r6, [r7, #0x18]
			ADD   r7, #0x3
			
			LDR   r7, =stmia_data
			STMIA r7!, {r0, r2, r3, r4, r5, r6, r7}
			LDR   r7, =stmia_data
			LDR   r6, [r7, #0x0]
			LDR   r6, [r7, #0x4]
			LDR   r6, [r7, #0x8]
			LDR   r6, [r7, #0xC]
			LDR   r6, [r7, #0x10]
			LDR   r6, [r7, #0x14]
			LDR   r6, [r7, #0x18]
			LDR   r6, [r7, #0x1C]

@ STR #1 tests (5-bit immediate offset)

			@ kinda feel guilty testing STR instructions using LDR... but it's whatever
			@ besides if the emulator got to this point it probably has a working LDR

			LDR   r7, =test_values
			LDR   r6, =str_testing

			LDR   r3, [r7, #0x14]
			STR   r3, [r6, #0x00] 
			LDR   r3, [r7, #0x18]
			STR   r3, [r6, #0x04] 

			LDR   r3, [r6, #0x00]
			LDR   r3, [r6, #0x04]

@ STR #2 tests (register offset)

			LDR   r7, =test_values
			LDR   r6, =str_testing

			LDR   r2, [r7, #0x00]
			LDR   r3, [r7, #0x18]
			STR   r3, [r6, r2] 
			LDR   r2, [r7, #0x20]
			LDR   r3, [r7, #0x14]
			STR   r3, [r6, r2] 

			LDR   r3, [r6, #0x00]
			LDR   r3, [r6, #0x04]

@ STR #3 tests (stack pointer offset)

			LDR   r7, =test_values
			LDR   r6, =str_testing

			LDR   r3, [r7, #0x18]
			STR   r3, [SP, #0x00]
			LDR   r3, [r7, #0x14]
			STR   r3, [SP, #0x04]

			LDR   r3, [SP, #0x00]
			LDR   r3, [SP, #0x04]

@ STRB #1 tests (5-bit immediate offset)

			LDR   r7, =test_values
			LDR   r6, =str_testing

			LDR   r3, [r7, #0x08]
			STRB  r3, [r6, #0x00] 
			LDR   r3, [r7, #0x2C]
			STRB  r3, [r6, #0x04] 

			LDR   r3, [r6, #0x00]
			LDR   r3, [r6, #0x04]

infin:
			B     infin

@ these are flagchecks. flagchecks will be run after every log by
@ calling BL flagcheck. this checks the flags of the ALU instructions
@ note that this may not look functional, but keep in mind that the vba-m
@ produces log files that specify which instructions were run in which order.
@ therefore, by setting up a system that would conditionally run some
@ instructions based on the CPSR, we can check the flags of the emulator.

flagcheck: @ otherwise known as flagcheck_N
			BMI   flagcheck_Z
			B     flagcheck_Z

flagcheck_Z:
			BEQ   flagcheck_C
			B     flagcheck_C

flagcheck_C:
			BCS   flagcheck_V
			B     flagcheck_V

flagcheck_V:
			BVS   flagcheck_end
			B     flagcheck_end

flagcheck_end:
			MOV PC, LR
