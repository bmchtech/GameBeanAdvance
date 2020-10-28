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

@ ******************************************** Test Cases *********************************************
			.text
@ *****************************************************************************************************

main:
            .arm

tests:

@ LDRH tests [immediate offset]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRH  r2, [r9, #0x0C]
			LDRH  r2, [r9, #0x10]

@ LDRH tests [register offset]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x34]
			LDRH  r2, [r9, r3]
			LDR   r3, [r9, #0x04]
			LDRH  r2, [r9, r3]

@ LDRH tests [immediate pre-indexed]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRH  r2, [r9, #+0x10]!
			LDRH  r2, [r9, #-0x04]!

@ LDRH tests [register pre-indexed]

			LDR   r7, =test_values

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRH  r2, [r9, r3]!

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRH  r2, [r9, r3]!

@ LDRH tests [immediate post-indexed]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRH  r2, [r9], #+0x10
			LDRH  r2, [r9], #-0x04
			LDRH  r2, [r9], #-0x00

@ LDRH tests [register post-indexed]

			LDR   r7, =test_values

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRH  r2, [r9], r3

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x0C]
			LDRH  r2, [r9], r3

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x00]
			LDRH  r2, [r9], r3

@ LDRSB tests [immediate offset]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRSB r2, [r9, #0x0C]
			LDRSB r2, [r9, #0x10]

@ LDRSB tests [register offset]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x34]
			LDRSB r2, [r9, r3]
			LDR   r3, [r9, #0x04]
			LDRSB r2, [r9, r3]

@ LDRSB tests [immediate pre-indexed]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRSB r2, [r9, #+0x10]!
			LDRSB r2, [r9, #-0x04]!

@ LDRSB tests [register pre-indexed]

			LDR   r7, =test_values

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRSB r2, [r9, r3]!

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRSB r2, [r9, r3]!

@ LDRSB tests [immediate post-indexed]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRSB r2, [r9], #+0x10
			LDRSB r2, [r9], #-0x04
			LDRSB r2, [r9], #-0x00

@ LDRSB tests [register post-indexed]

			LDR   r7, =test_values

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRSB r2, [r9], r3

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x0C]
			LDRSB r2, [r9], r3

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x00]
			LDRSB r2, [r9], r3

@ LDRSH tests [immediate offset]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRSH r2, [r9, #0x0C]
			LDRSH r2, [r9, #0x10]

@ LDRSH tests [register offset]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x34]
			LDRSH r2, [r9, r3]
			LDR   r3, [r9, #0x04]
			LDRSH r2, [r9, r3]

@ LDRSH tests [immediate pre-indexed]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRSH r2, [r9, #+0x10]!
			LDRSH r2, [r9, #-0x04]!

@ LDRSH tests [register pre-indexed]

			LDR   r7, =test_values

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRSH r2, [r9, r3]!

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRSH r2, [r9, r3]!

@ LDRSH tests [immediate post-indexed]

			LDR   r7, =test_values
			LDR   r9, =test_values_addendum

			LDRSH r2, [r9], #+0x10
			LDRSH r2, [r9], #-0x04
			LDRSH r2, [r9], #-0x00

@ LDRSH tests [register post-indexed]

			LDR   r7, =test_values

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x04]
			LDRSH r2, [r9], r3

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x0C]
			LDRSH r2, [r9], r3

			LDR   r9, =test_values_addendum
			LDR   r3, [r9, #0x00]
			LDRSH r2, [r9], r3

@ Addressing Mode 2 PC tests

			LDR   r9, =test_values_addendum
			LDR   r2, [PC, #-0x8]
			LDR   r3, [r9, #+0x8]
			LDR   r3, [PC, r3]

infin:
            B     infin