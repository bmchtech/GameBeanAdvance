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


@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
			.arm
			LDR r7, =test_values
			ADD r3, pc, #1
			BX r3
	
			.thumb

tests:

@ ADD tests - without carry

			MOV r1, r1 @ clear carry flag

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

infin:
			B     infin

@ these are flagchecks. flagchecks will be run after every log by
@ calling BL flagcheck_N. this checks the flags of the ALU instructions
@ note that this may not look functional, but keep in mind that the vba-m
@ produces log files that specify which instructions were run in which order.
@ therefore, by setting up a system that would conditionally run some
@ instructions based on the CPSR, we can check the flags of the emulator.

flagcheck: @ otherwise known as flagcheck_N
			BEQ   flagcheck_Z
			B     flagcheck_Z

flagcheck_Z:
			BCS   flagcheck_C
			B     flagcheck_C

flagcheck_C:
			BMI   flagcheck_V
			B     flagcheck_V

flagcheck_V:
			BVS   flagcheck_end
			B     flagcheck_end

flagcheck_end:
			MOV PC, LR
