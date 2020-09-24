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
			ADD   r3, pc, #1
			BX    r3
	
			.thumb

tests:

@ ADC tests - without carry

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

@ ADC tests - with carry

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

			LDMIA r7!, {r0, r2, r5, r6}
			LDMIA r7!, {r0, r2, r5, r6, r7}
			LDR   r7, =test_values

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
			MOV   r1, r2
			BL    flagcheck

			LDR   r3, [r7, #0x08]
			MOV   r3, r0
			BL    flagcheck

			LDR   r5, [r7, #0x14]
			MOV   r5, r7
			BL    flagcheck

@ MOV #3 tests (at least one high register)

			LDR   r1, [r7, #0x00]
			MOV   r1, r8
			BL    flagcheck

			LDR   r3, [r7, #0x08]
			MOV   r3, r9
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
