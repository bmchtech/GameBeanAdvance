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
			.word 0x00000020 @ 14

@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
            .arm

tests:

@ EOR tests [Immediate offset]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            EOR      r2,  #0xFA

@ EOR tests [Register offset]

			LDR      r7,  =test_values

            LDR      r2,  [r7, #0x18]
            LDR      r3,  [r7, #0x14]
            EOR      r2,  r3

@ EOR tests [LSL by Immediate]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
            LDR      r3,  [r7, #0x14]

            LDR      r2,  [r7, #0x18]
            EOR      r2,  r3, LSL #0x0

            LDR      r2,  [r7, #0x18]
            EOR      r2,  r3, LSL #0x2

@ EOR tests [LSL by Register]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
            LDR      r3,  [r7, #0x14]

            LDR      r2,  [r7, #0x18]
            LDR      r4,  [r7, #0x00]
            EOR      r2,  r3, LSL r4

            LDR      r2,  [r7, #0x18]
            LDR      r4,  [r9, #0x00]
            EOR      r2,  r3, LSL r4

            LDR      r2,  [r7, #0x18]
            LDR      r4,  [r9, #0x14]
            EOR      r2,  r3, LSL r4

            LDR      r2,  [r7, #0x18]
            LDR      r4,  [r7, #0x14]
            EOR      r2,  r3, LSL r4

@ EOR tests [LSR by Immediate]

			LDR      r7,  =test_values
			LDR      r9,  =test_values_addendum
            LDR      r3,  [r7, #0x14]

            LDR      r2,  [r7, #0x18]
            EOR      r2,  r3, LSR #0x0

            LDR      r2,  [r7, #0x18]
            EOR      r2,  r3, LSR #0x2

infin:
            B     infin