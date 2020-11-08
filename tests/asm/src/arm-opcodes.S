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
			.word 0xE1A0F00E @ return instruction
			.word 0x00000001
			.word 0x00000002
			.word 0x00000003
			.word 0x00000004
			.word 0x00000005
			.word 0x00000006
			.word 0x00000007
ldm_tests_end:
			.word 0xE1A0F00E @ return instruction

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

			@ LDR      r7,  =test_values
			@ LDMIA    r7,  {r0-r14}

			@ LDR      r7,  =test_values
			@ LDMIA    r7,  {r1, r3, r4, r7, r9, r10, r11, r13, r14}

			@ LDR      r7,  =test_values
			@ LDMIA    r7!, {r1, r3, r4, r8, r9, r10, r11, r13, r14}

			@ LDR      r7,  =ldm_tests_start
			@ ADD      r7,  #0x4
			@ MOV      lr,  pc   @ save the PC so i can return later when we branch
			@ LDMIA    r7,  {r1, r3, r4, r7, r9, r10, r11, r15}

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

@ STR tests

			LDR      r7,  =test_values
			
@ make sure we reached the end of the file

			LDR      r7, =end_value
			LDR      r0, [r7, #0x00]

infin:
            B     infin