			.global main

@ ************************* Constants to be Loaded into Registers for Testing *************************
			.data
@ *****************************************************************************************************

test_values:
			.word 0x00000000 @ 00
			.word 0x00000001 @ 04
			.word 0xFFFFFFFF @ 08
			.word 0x80000000 @ 0C
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
test_values_end:

@ the reason we have an addendum here and not in the thumb tests is because we index in arm from both
@ test_values and from test_values_end, which makes it really difficult if not impossible to insert
@ a new word somewhere without ruining some tests that use specific values... so here's an addendum,
@ which should not be indexed backwards

test_values_addendum:
			.word 0x00000005 @ 00
			.word 0x00000010 @ 04
			.word 0xFFFFFFFC @ 08
			.word 0xFFFF7BCD @ 0C
			.word 0xFFFF8BCD @ 10
			.word 0x3FFFFFFF @ 14

end_value:
			.word 0x4EC5F500 @ 00

ldm_tests_start:
			.word 0x00000000
			.word 0x00000001
			.word 0x00000002
			.word 0x00000003
			.word 0x00000004
			.word 0x00000005
			.word 0x00000006
			.word 0x00000007
ldm_tests_end:
			.word 0x00000008

mem_target_addresses:
			.word 0x03000000 @ 00
			.word 0x03000001 @ 04
			.word 0x03000002 @ 08
			.word 0x03000003 @ 0C

@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
            .arm

tests:

@ ADC tests [no flag modification] [no carry]

			LDR      r7,  =test_values
			LDR      r0,  [r7, #0x00]

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag
			MRS      r12, CPSR
			
			LDR      r2,  [r7, #0x1C]
            LDR      r4,  [r7, #0x0C]
			ADC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08]
            LDR      r4,  [r7, #0x04]
			ADC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ ADC tests [flag modification] [no carry]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			LDR      r0,  [r7, #0x00]

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = pos
            LDR      r4,  [r9, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x14] @ neg + pos = neg
            LDR      r4,  [r9, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = neg
            LDR      r4,  [r7, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x0C] @ neg + neg = pos
            LDR      r4,  [r7, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = neg
            LDR      r4,  [r7, #0x10]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08] @ neg + pos = pos
            LDR      r4,  [r7, #0x20]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = pos
            LDR      r4,  [r7, #0x24]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x1C] @ neg + neg = neg
            LDR      r4,  [r7, #0x0C]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ ADC tests [no flag modification] [carry]

			LDR      r7,  =test_values
			LDR      r0,  [r7, #0x08]

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag
			MRS      r12, CPSR
			
			LDR      r2,  [r7, #0x1C]
            LDR      r4,  [r7, #0x0C]
			ADC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08]
            LDR      r4,  [r7, #0x04]
			ADC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ ADC tests [flag modification] [carry]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			LDR      r0,  [r7, #0x08]

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = pos
            LDR      r4,  [r9, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x14] @ neg + pos = neg
            LDR      r4,  [r9, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = neg
            LDR      r4,  [r7, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x0C] @ neg + neg = pos
            LDR      r4,  [r7, #0x14]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = neg
            LDR      r4,  [r7, #0x10]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08] @ neg + pos = pos
            LDR      r4,  [r7, #0x20]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = pos
            LDR      r4,  [r7, #0x24]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x1C] @ neg + neg = neg
            LDR      r4,  [r7, #0x0C]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			ADCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ ADD tests [no flag modification]

			LDR      r7,  =test_values

			LDR      r2,  [r7, #0x1C]
            LDR      r4,  [r7, #0x0C]
			ADD      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08]
            LDR      r4,  [r7, #0x04]
			ADD      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ ADD tests [flag modification]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum

			LDR      r2,  [r7, #0x18] @ pos + pos = pos
            LDR      r4,  [r9, #0x14]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x14] @ neg + pos = neg
            LDR      r4,  [r9, #0x14]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + neg = neg
            LDR      r4,  [r7, #0x14]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x0C] @ neg + neg = pos
            LDR      r4,  [r7, #0x14]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + pos = neg
            LDR      r4,  [r7, #0x10]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ neg + pos = pos
            LDR      r4,  [r7, #0x20]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + neg = pos
            LDR      r4,  [r7, #0x24]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x1C] @ neg + neg = neg
            LDR      r4,  [r7, #0x0C]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			ADDS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR
			
@ AND tests [no flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            AND      r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            AND      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            AND      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ AND tests [flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            ANDS     r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            ANDS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            ANDS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR
				
@ BIC tests [no flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            BIC      r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            BIC      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            BIC      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ BIC tests [flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            BICS     r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            BICS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            BICS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ BX  tests [switch to ARM]

			MOV      r2,  pc
			ADD      r2,  #0x4
			BX       r2
			
			B        pass_bx_arm
			SWI      #0x30000 @ abort - you should not run this instruction.

pass_bx_arm:

@ BX  tests [switch to THUMB]

			MOV      r2,  pc
			ADD      r2,  #0x5
			BX       r2
			
			.thumb
			B pass_bx_thumb
			NOP

			.arm
			SWI      #0x30000 @ abort - you should not run this instruction.

pass_bx_thumb:

			.thumb
			NOP
			BX       pc

			.arm

@ CMN tests

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum

			LDR      r2,  [r7, #0x18] @ pos - neg 
            LDR      r4,  [r9, #0x14]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x14] @ neg - neg 
            LDR      r4,  [r9, #0x14]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos - pos 
            LDR      r4,  [r7, #0x14]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x0C] @ neg - pos 
            LDR      r4,  [r7, #0x14]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos - neg 
            LDR      r4,  [r7, #0x10]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ neg - neg 
            LDR      r4,  [r7, #0x20]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos - pos 
            LDR      r4,  [r7, #0x24]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x1C] @ neg - pos 
            LDR      r4,  [r7, #0x0C]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			CMN      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ CMP tests

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum

			LDR      r2,  [r7, #0x18] @ pos + pos 
            LDR      r4,  [r9, #0x14]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x14] @ neg + pos 
            LDR      r4,  [r9, #0x14]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + neg 
            LDR      r4,  [r7, #0x14]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x0C] @ neg + neg 
            LDR      r4,  [r7, #0x14]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + pos 
            LDR      r4,  [r7, #0x10]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ neg + pos 
            LDR      r4,  [r7, #0x20]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + neg 
            LDR      r4,  [r7, #0x24]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x1C] @ neg + neg 
            LDR      r4,  [r7, #0x0C]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			CMP      r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ EOR tests [no flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            EOR      r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            EOR      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            EOR      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ EOR tests [flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            EORS     r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            EORS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            EORS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ LDM tests [LDMIA]

			LDR      r7,  =test_values
			LDMIA    r7,  {r0-r14}

			LDR      r7,  =test_values
			LDMIA    r7,  {r1, r2, r3, r4, r7, r9, r10, r11, r14}

			LDR      r7,  =test_values
			LDMIA    r7!, {r0 ,r1, r3, r4, r8, r9, r10, r11, r14}

			LDR      r7,  =ldm_tests_start
			STR      pc,  [r7, #0x1C]
			LDMIA    r7,  {r1, r3, r4, r7, r9, r10, r11, r15}

@ LDM tests [LDMIB]

			LDR      r7,  =test_values
			LDMIB    r7,  {r0-r14}

			LDR      r7,  =test_values
			LDMIB    r7,  {r1, r2, r3, r4, r7, r9, r10, r11, r14}

			LDR      r7,  =test_values
			LDMIB    r7!, {r0 ,r1, r3, r4, r8, r9, r10, r11, r14}

			LDR      r7,  =ldm_tests_start
			STR      pc,  [r7, #0x20]
			LDMIB    r7,  {r1, r3, r4, r7, r9, r10, r11, r15}

@ LDM tests [LDMDA]

			LDR      r7,  =test_values
			LDMDA    r7,  {r0-r14}

			LDR      r7,  =test_values
			LDMDA    r7,  {r1, r2, r3, r4, r7, r9, r10, r11, r14}

			LDR      r7,  =test_values
			LDMDA    r7!, {r0, r1, r3, r4, r8, r9, r10, r11, r14}

			LDR      r7,  =ldm_tests_end
			STR      pc,  [r7]
			LDMDA    r7,  {r1, r3, r4, r7, r9, r10, r11, r15}

@ LDM tests [LDMDB]

			LDR      r7,  =test_values
			LDMDB    r7,  {r0-r14}

			LDR      r7,  =test_values
			LDMDB    r7,  {r1, r2, r3, r4, r7, r9, r10, r11, r14}

			LDR      r7,  =test_values
			LDMDB    r7!, {r0, r1, r3, r4, r8, r9, r10, r11, r14}

			LDR      r7,  =ldm_tests_end
			STR      pc,  [r7, #-0x04]
			LDMDB    r7,  {r1, r3, r4, r7, r9, r10, r11, r15}

@ TODO: LDM 2 tests must be done in an interrupt.
@ this is because the result is UNPREDICTABLE in
@ SYSTEM mode, which is the default mode for the GBA.
@ the exact same applies for LDM 3

@ LDR tests [non-word aligned]

			LDR      r7,  =test_values
			LDR      r1,  [r7, #0x14]
			LDR      r2,  [r7, #0x15]
			LDR      r2,  [r7, #0x16]
			LDR      r2,  [r7, #0x17]

@ LDRB tests [non-word aligned]

			LDR      r7,  =test_values
			LDRB     r1,  [r7, #0x14]
			LDRB     r2,  [r7, #0x15]
			LDRB     r2,  [r7, #0x16]
			LDRB     r2,  [r7, #0x17]

@ TODO: LDRBT. i'll have to do a lot more research
@ to figure out what parts of the memory map are
@ restricted for USER mode.

@ MLA tests [no flag modification]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			
			LDR      r2,  [r7, #0x00]
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r7, #0x00]
			MLA      r1,  r4, r3, r2
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r2,  [r7, #0x34]
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x10]
			MLA      r1,  r4, r3, r2
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r2,  [r7, #0x14]
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x08]
			MLA      r1,  r4, r3, r2
			MRS      r12, CPSR
			MRS      r13, SPSR

@ MLA tests [flag modification]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			
			LDR      r2,  [r7, #0x00]
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r7, #0x00]
			MLAS     r1,  r4, r3, r2
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r2,  [r7, #0x34]
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x10]
			MLAS     r1,  r4, r3, r2
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r2,  [r7, #0x14]
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x08]
			MLAS     r1,  r4, r3, r2
			MRS      r12, CPSR
			MRS      r13, SPSR
			
@ MOV tests [no flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x00]
			MOV      r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x08]
			MOV      r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

@ MOV tests [flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x00]
			MOVS     r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x08]
			MOVS     r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

@ MUL tests [no flag modification]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r7, #0x00]
			MUL      r1,  r4,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x10]
			MUL      r1,  r4,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x08]
			MUL      r1,  r4,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ MUL tests [flag modification]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r7, #0x00]
			MULS     r1,  r4,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x10]
			MULS     r1,  r4,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR
			
			LDR      r3,  [r7, #0x18]
			LDR      r4,  [r9, #0x08]
			MULS     r1,  r4,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR
			
@ MVN tests [no flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x00]
			MVN      r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x08]
			MVN      r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

@ MVN tests [flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x00]
			MVNS     r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x08]
			MVNS     r3,  r2
			MRS      r12, CPSR
			MRS      r13, SPSR
			
@ ORR tests [no flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            ORR      r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            ORR      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            ORR      r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ ORR tests [flag modification]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            ORRS     r2,  #0xFA
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x10]
            LDR      r3,  [r7, #0x08]
            ORRS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x18]
            ORRS     r2,  r3
			MRS      r12, CPSR
			MRS      r13, SPSR

@ RSB tests [no flag modification]

			LDR      r7,  =test_values

			LDR      r2,  [r7, #0x1C]
            LDR      r4,  [r7, #0x0C]
			RSB      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08]
            LDR      r4,  [r7, #0x04]
			RSB      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ RSB tests [flag modification]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum

			LDR      r2,  [r7, #0x18] @ pos + pos = pos
            LDR      r4,  [r9, #0x14]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x14] @ neg + pos = neg
            LDR      r4,  [r9, #0x14]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + neg = neg
            LDR      r4,  [r7, #0x14]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x0C] @ neg + neg = pos
            LDR      r4,  [r7, #0x14]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + pos = neg
            LDR      r4,  [r7, #0x10]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ neg + pos = pos
            LDR      r4,  [r7, #0x20]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x18] @ pos + neg = pos
            LDR      r4,  [r7, #0x24]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x1C] @ neg + neg = neg
            LDR      r4,  [r7, #0x0C]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			RSBS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ RSC tests [flag modification] [no carry]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			LDR      r0,  [r7, #0x00]

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = pos
            LDR      r4,  [r9, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x14] @ neg + pos = neg
            LDR      r4,  [r9, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = neg
            LDR      r4,  [r7, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x0C] @ neg + neg = pos
            LDR      r4,  [r7, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = neg
            LDR      r4,  [r7, #0x10]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08] @ neg + pos = pos
            LDR      r4,  [r7, #0x20]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = pos
            LDR      r4,  [r7, #0x24]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x1C] @ neg + neg = neg
            LDR      r4,  [r7, #0x0C]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ RSC tests [no flag modification] [carry]

			LDR      r7,  =test_values
			LDR      r0,  [r7, #0x08]

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag
			MRS      r12, CPSR
			
			LDR      r2,  [r7, #0x1C]
            LDR      r4,  [r7, #0x0C]
			RSC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08]
            LDR      r4,  [r7, #0x04]
			RSC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ RSC tests [flag modification] [carry]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			LDR      r0,  [r7, #0x08]

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - neg = pos
            LDR      r4,  [r9, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x14] @ neg - neg = neg
            LDR      r4,  [r9, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - pos = neg
            LDR      r4,  [r7, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x0C] @ neg - pos = pos
            LDR      r4,  [r7, #0x14]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - neg = neg
            LDR      r4,  [r7, #0x10]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08] @ neg - neg = pos
            LDR      r4,  [r7, #0x20]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - pos = pos
            LDR      r4,  [r7, #0x24]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x1C] @ neg - pos = neg
            LDR      r4,  [r7, #0x0C]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			RSCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ SBC tests [flag modification] [no carry]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			LDR      r0,  [r7, #0x00]

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = pos
            LDR      r4,  [r9, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x14] @ neg + pos = neg
            LDR      r4,  [r9, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = neg
            LDR      r4,  [r7, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x0C] @ neg + neg = pos
            LDR      r4,  [r7, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + pos = neg
            LDR      r4,  [r7, #0x10]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08] @ neg + pos = pos
            LDR      r4,  [r7, #0x20]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x18] @ pos + neg = pos
            LDR      r4,  [r7, #0x24]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x1C] @ neg + neg = neg
            LDR      r4,  [r7, #0x0C]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ clear carry flag

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ SBC tests [no flag modification] [carry]

			LDR      r7,  =test_values
			LDR      r0,  [r7, #0x08]

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag
			MRS      r12, CPSR
			
			LDR      r2,  [r7, #0x1C]
            LDR      r4,  [r7, #0x0C]
			SBC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08]
            LDR      r4,  [r7, #0x04]
			SBC      r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ SBC tests [flag modification] [carry]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
			LDR      r0,  [r7, #0x08]

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - neg = pos
            LDR      r4,  [r9, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x14] @ neg - neg = neg
            LDR      r4,  [r9, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - pos = neg
            LDR      r4,  [r7, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x0C] @ neg - pos = pos
            LDR      r4,  [r7, #0x14]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - neg = neg
            LDR      r4,  [r7, #0x10]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08] @ neg - neg = pos
            LDR      r4,  [r7, #0x20]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x18] @ pos - pos = pos
            LDR      r4,  [r7, #0x24]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x1C] @ neg - pos = neg
            LDR      r4,  [r7, #0x0C]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

			EORS     r0,  r0,  r0, LSL #0x01  @ set carry flag

			LDR      r2,  [r7, #0x08] @ zero case
            LDR      r4,  [r7, #0x04]
			SBCS     r3,  r2,  r4
			MRS      r12, CPSR
			MRS      r13, SPSR

@ SMLAL tests

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum

			LDR      r2,  [r7, #0x14]
			LDR      r3,  [r9, #0x10]
			LDR      r4,  [r7, #0x18]
			LDR      r5,  [r9, #0x0C]
			SMLAL    r2, r3, r4, r5

			LDR      r4,  [r7, #0x04]
			LDR      r5,  [r9, #0x0C]
			SMLAL    r2, r3, r4, r5

			LDR      r2,  [r7, #0x00]
			LDR      r3,  [r7, #0x00]
			LDR      r4,  [r7, #0x00]
			LDR      r5,  [r7, #0x00]
			SMLAL    r2, r3, r4, r5

@ SMULL tests

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum

			LDR      r2,  [r7, #0x14]
			LDR      r3,  [r9, #0x10]
			LDR      r4,  [r7, #0x18]
			LDR      r5,  [r9, #0x0C]
			SMULL    r2, r3, r4, r5

			LDR      r4,  [r7, #0x04]
			LDR      r5,  [r9, #0x0C]
			SMULL    r2, r3, r4, r5

			LDR      r2,  [r7, #0x00]
			LDR      r3,  [r7, #0x00]
			LDR      r4,  [r7, #0x00]
			LDR      r5,  [r7, #0x00]
			SMULL    r2, r3, r4, r5

@ STR tests

			LDR      r7,  =mem_target_addresses

			LDR      r2,  [r7, #0x00]
			STR      pc,  [r2]

			LDR      r2,  [r7, #0x04]
			STR      pc,  [r2]

			LDR      r2,  [r7, #0x08]
			STR      pc,  [r2]

			LDR      r2,  [r7, #0x0C]
			STR      pc,  [r2]

@ STRB tests

			LDR      r7,  =mem_target_addresses
			LDR      r8,  =test_values

			LDR      r3,  [r8, #0x14]

			LDR      r2,  [r7, #0x00]
			STRB     r3,  [r2]

			LDR      r2,  [r7, #0x04]
			STRB     r3,  [r2]

			LDR      r2,  [r7, #0x08]
			STRB     r3,  [r2]

			LDR      r2,  [r7, #0x0C]
			STRB     r3,  [r2]

@ make sure we reached the end of the file

			LDR      r7,  =end_value
			LDR      r0,  [r7, #0x00]

infin:
            B     infin