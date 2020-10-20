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

@ LDR tests [Immediate offset]

			LDR   r7, =test_values
			LDR   r2, [r7, #0x0]
			LDR   r2, [r7, #0x4]
			LDR   r2, [r7, #0x8]

			LDR   r8, =test_values_end
			LDR   r2, [r8, #-0x0]
			LDR   r2, [r8, #-0x4]
			LDR   r2, [r8, #-0x8]

@ LDR tests [Register offset]

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x0]
			LDR   r2, [r7, r3]
			LDR   r3, [r7, #0x20]
			LDR   r2, [r7, r3]
			LDR   r3, [r7, #0x34]
			LDR   r2, [r7, r3]
			LDR   r3, [r7, #0x4]
			LDR   r2, [r7, r3]

			LDR   r3, [r7, #0x0]
			LDR   r2, [r8, -r3]
			LDR   r3, [r7, #0x20]
			LDR   r2, [r8, -r3]
			LDR   r3, [r7, #0x34]
			LDR   r2, [r8, -r3]
			LDR   r3, [r9, #0x0]
			LDR   r2, [r8, -r3]

@ LDR tests [Scaled register offset]

            @ (LSL)

			LDR   r7, =test_values
			LDR   r8, =test_values_end

			LDR   r3, [r7, #0x20]
			LDR   r2, [r7, r3, LSL #0x00]
			LDR   r3, [r7, #0x20]
			LDR   r2, [r7, r3, LSL #0x01]
			LDR   r3, [r7, #0x2C]
			LDR   r2, [r7, r3, LSL #0x1F]

			LDR   r3, [r7, #0x20]
			LDR   r2, [r7, -r3, LSL #0x00]
			LDR   r3, [r7, #0x20]
			LDR   r2, [r7, -r3, LSL #0x01]
			LDR   r3, [r7, #0x2C]
			LDR   r2, [r7, -r3, LSL #0x1F]

            @ (LSR)

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, LSR #0x00]

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, LSR #0x01]

			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7, r3, LSR #0x1F]

            @ (ASR)

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, ASR #0x00]

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, ASR #0x01]

			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7, r3, ASR #0x1F]

			LDR   r3, [r9, #0x08]
			LDR   r2, [r8, r3, ASR #0x1F]

            @ (ROR)

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, ROR #0x00]

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, ROR #0x01]

			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7, r3, ROR #0x1D]

			LDR   r3, [r9, #0x1C]
			LDR   r2, [r8, r3, ROR #0x1D]

@ LDR tests [Immediate pre-indexed]

			LDR   r7, =test_values

			LDR   r2, [r7, #0x4]!
			LDR   r2, [r7, #0x8]!
			LDR   r2, [r7, #0x1C]!
			LDR   r2, [r7, #-0x20]!
			LDR   r2, [r7, #0x4]!
			LDR   r2, [r7, #-0x4]!
			LDR   r2, [r7, #0x08]!

@ LDR tests [Register pre-indexed]

			LDR   r7, =test_values

			LDR   r3, [r7, #0x4]
			LDR   r2, [r7, r3]!
			
			LDR   r3, [r7, #0x8]!
			LDR   r2, [r7, r3]!

			LDR   r3, [r7, #0x1C]!
			LDR   r2, [r7, r3]!

			LDR   r3, [r7, #-0x20]!
			LDR   r2, [r7, r3]!

			LDR   r3, [r7, #0x4]!
			LDR   r2, [r7, r3]!

			LDR   r3, [r7, #-0x4]!
			LDR   r2, [r7, r3]!

			LDR   r3, [r7, #0x08]!
			LDR   r2, [r7, r3]!

@ LDR tests [Scaled register pre-indexed]
@ we're assuming if you got here, most of the scaled logic works already,
@ so here's some minimal tests...

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x2C]
			LDR   r2, [r7,  r3, LSL #0x1F]!
			LDR   r7, =test_values
			LDR   r3, [r7, #0x2C]
			LDR   r2, [r7, -r3, LSL #0x1F]!

			LDR   r7, =test_values
			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, LSR #0x01]!
			LDR   r7, =test_values
			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7, r3, LSR #0x1F]!

			LDR   r7, =test_values
			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7, r3, ASR #0x1F]!
			LDR   r7, =test_values
			LDR   r3, [r9, #0x08]
			LDR   r2, [r8, r3, ASR #0x1F]!

			LDR   r7, =test_values
			LDR   r3, [r9, #0x04]
			LDR   r2, [r7, r3, ROR #0x01]!
			LDR   r7, =test_values
			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7, r3, ROR #0x1D]!

@ LDR tests [Immediate post-indexed]

			LDR   r7, =test_values

			LDR   r2, [r7], #0x0
			LDR   r2, [r7], #0x4
			LDR   r2, [r7], #0x8
			LDR   r2, [r7], #0xC
			LDR   r2, [r7], #-0xC
			LDR   r2, [r7], #-0x8
			LDR   r2, [r7], #-0x4

@ LDR tests [Register post-indexed]

			LDR   r7, =test_values

			LDR   r3, [r7, #0x4]
			LDR   r2, [r7], r3
			
			LDR   r3, [r7, #0x8]!
			LDR   r2, [r7], r3

			LDR   r3, [r7, #0x1C]!
			LDR   r2, [r7], r3

			LDR   r3, [r7, #-0x20]!
			LDR   r2, [r7], r3

			LDR   r3, [r7, #0x4]!
			LDR   r2, [r7], r3

			LDR   r3, [r7, #-0x4]!
			LDR   r2, [r7], r3

			LDR   r3, [r7, #0x08]!
			LDR   r2, [r7], r3

@ LDR tests [Scaled register post-indexed]
@ we're assuming if you got here, most of the scaled logic works already,
@ so here's some minimal tests...

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x2C]
			LDR   r2, [r7], r3, LSL #0x1F
			LDR   r3, [r7, #0x2C]
			LDR   r2, [r7], -r3, LSL #0x1F

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7], r3, LSR #0x01
			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7], r3, LSR #0x1F

			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7], r3, ASR #0x1F
			LDR   r3, [r9, #0x08]
			LDR   r2, [r8], r3, ASR #0x1F

			LDR   r3, [r9, #0x04]
			LDR   r2, [r7], r3, ROR #0x01
			LDR   r3, [r7, #0x0C]
			LDR   r2, [r7], r3, ROR #0x1D

@ now we redo all the LDR tests just with LDRB

@ LDRB tests [Immediate offset]

			LDR   r7, =test_values
			LDRB  r2, [r7, #0x0]
			LDRB  r2, [r7, #0x4]
			LDRB  r2, [r7, #0x8]

			LDR   r8, =test_values_end
			LDRB  r2, [r8, #-0x0]
			LDRB  r2, [r8, #-0x4]
			LDRB  r2, [r8, #-0x8]

@ LDRB tests [Register offset]

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x0]
			LDRB  r2, [r7, r3]
			LDR   r3, [r7, #0x20]
			LDRB  r2, [r7, r3]
			LDR   r3, [r7, #0x34]
			LDRB  r2, [r7, r3]
			LDR   r3, [r7, #0x4]
			LDRB  r2, [r7, r3]

			LDR   r3, [r7, #0x0]
			LDRB  r2, [r8, -r3]
			LDR   r3, [r7, #0x20]
			LDRB  r2, [r8, -r3]
			LDR   r3, [r7, #0x34]
			LDRB  r2, [r8, -r3]
			LDR   r3, [r9, #0x0]
			LDRB  r2, [r8, -r3]

@ LDRB tests [Scaled register offset]

            @ (LSL)

			LDR   r7, =test_values
			LDR   r8, =test_values_end

			LDR   r3, [r7, #0x20]
			LDRB  r2, [r7, r3, LSL #0x00]
			LDR   r3, [r7, #0x20]
			LDRB  r2, [r7, r3, LSL #0x01]
			LDR   r3, [r7, #0x2C]
			LDRB  r2, [r7, r3, LSL #0x1F]

			LDR   r3, [r7, #0x20]
			LDRB  r2, [r7, -r3, LSL #0x00]
			LDR   r3, [r7, #0x20]
			LDRB  r2, [r7, -r3, LSL #0x01]
			LDR   r3, [r7, #0x2C]
			LDRB  r2, [r7, -r3, LSL #0x1F]

            @ (LSR)

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, LSR #0x00]

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, LSR #0x01]

			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7, r3, LSR #0x1F]

            @ (ASR)

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, ASR #0x00]

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, ASR #0x01]

			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7, r3, ASR #0x1F]

			LDR   r3, [r9, #0x08]
			LDRB  r2, [r8, r3, ASR #0x1F]

            @ (ROR)

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, ROR #0x00]

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, ROR #0x01]

			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7, r3, ROR #0x1D]

			LDR   r3, [r9, #0x1C]
			LDRB  r2, [r8, r3, ROR #0x1D]

@ LDRB tests [Immediate pre-indexed]

			LDR   r7, =test_values

			LDRB  r2, [r7, #0x4]!
			LDRB  r2, [r7, #0x8]!
			LDRB  r2, [r7, #0x1C]!
			LDRB  r2, [r7, #-0x20]!
			LDRB  r2, [r7, #0x4]!
			LDRB  r2, [r7, #-0x4]!
			LDRB  r2, [r7, #0x08]!

@ LDRB tests [Register pre-indexed]

			LDR   r7, =test_values

			LDR   r3, [r7, #0x4]
			LDRB  r2, [r7, r3]!
			
			LDR   r3, [r7, #0x8]!
			LDRB  r2, [r7, r3]!

			LDR   r3, [r7, #0x1C]!
			LDRB  r2, [r7, r3]!

			LDR   r3, [r7, #-0x20]!
			LDRB  r2, [r7, r3]!

			LDR   r3, [r7, #0x4]!
			LDRB  r2, [r7, r3]!

			LDR   r3, [r7, #-0x4]!
			LDRB  r2, [r7, r3]!

			LDR   r3, [r7, #0x08]!
			LDRB  r2, [r7, r3]!

@ LDRB tests [Scaled register pre-indexed]
@ we're assuming if you got here, most of the scaled logic works already,
@ so here's some minimal tests...

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x2C]
			LDRB  r2, [r7,  r3, LSL #0x1F]!
			LDR   r7, =test_values
			LDR   r3, [r7, #0x2C]
			LDRB  r2, [r7, -r3, LSL #0x1F]!

			LDR   r7, =test_values
			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, LSR #0x01]!
			LDR   r7, =test_values
			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7, r3, LSR #0x1F]!

			LDR   r7, =test_values
			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7, r3, ASR #0x1F]!
			LDR   r7, =test_values
			LDR   r3, [r9, #0x08]
			LDRB  r2, [r8, r3, ASR #0x1F]!

			LDR   r7, =test_values
			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7, r3, ROR #0x01]!
			LDR   r7, =test_values
			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7, r3, ROR #0x1D]!

@ LDRB tests [Immediate post-indexed]

			LDR   r7, =test_values

			LDRB  r2, [r7], #0x0
			LDRB  r2, [r7], #0x4
			LDRB  r2, [r7], #0x8
			LDRB  r2, [r7], #0xC
			LDRB  r2, [r7], #-0xC
			LDRB  r2, [r7], #-0x8
			LDRB  r2, [r7], #-0x4

@ LDRB tests [Register post-indexed]

			LDR   r7, =test_values

			LDR   r3, [r7, #0x4]
			LDRB  r2, [r7], r3
			
			LDR   r3, [r7, #0x8]!
			LDRB  r2, [r7], r3

			LDR   r3, [r7, #0x1C]!
			LDRB  r2, [r7], r3

			LDR   r3, [r7, #-0x20]!
			LDRB  r2, [r7], r3

			LDR   r3, [r7, #0x4]!
			LDRB  r2, [r7], r3

			LDR   r3, [r7, #-0x4]!
			LDRB  r2, [r7], r3

			LDR   r3, [r7, #0x08]!
			LDRB  r2, [r7], r3

@ LDRB tests [Scaled register post-indexed]
@ we're assuming if you got here, most of the scaled logic works already,
@ so here's some minimal tests...

			LDR   r7, =test_values
			LDR   r8, =test_values_end
			LDR   r9, =test_values_addendum

			LDR   r3, [r7, #0x2C]
			LDRB  r2, [r7], r3, LSL #0x1F
			LDR   r3, [r7, #0x2C]
			LDRB  r2, [r7], -r3, LSL #0x1F

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7], r3, LSR #0x01
			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7], r3, LSR #0x1F

			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7], r3, ASR #0x1F
			LDR   r3, [r9, #0x08]
			LDRB  r2, [r8], r3, ASR #0x1F

			LDR   r3, [r9, #0x04]
			LDRB  r2, [r7], r3, ROR #0x01
			LDR   r3, [r7, #0x0C]
			LDRB  r2, [r7], r3, ROR #0x1D

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

@ MRS tests (CPSR)
@ honestly this is more of a test for the CPSR / SPSR than it is for MRS...
@ this test is pretty short, but its real significance is that we can finally check condition codes
@ using MRS! no more BL flagcheck like in thumb-simple.S, just an MRS would do the trick

			MRS   r0, CPSR
			MRS   r1, SPSR

infin:
            B     infin