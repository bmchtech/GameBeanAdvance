.thumb
.text
.global main

main:
	// ADC tests
	MOV R0, #0x00
	MOV R1, #0x7F
	ADC R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x7F
	ADC R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x7F
	ADC R0, R1
	BL flagcheck



	// ADD tests
	MOV R0, #0x00
	MOV R1, #0x7F
	ADD R2, R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x7F
	ADD R2, R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x7F
	ADD R2, R0, R1
	BL flagcheck



	// ADD + 3-bit immediate tests
	MOV R1, #0x00
	ADD R0, R1, #2
	BL flagcheck

	MOV R1, #0x7F
	ADD R0, R1, #2
	BL flagcheck

	MOV R1, #0xFF
	ADD R0, R1, #2
	BL flagcheck



	// ADD + 8-bit immediate tests
	MOV R0, #0x00
	ADD R0, #0xAB
	BL flagcheck

	MOV R0, #0x7F
	ADD R0, #0xAB
	BL flagcheck

	MOV R0, #0xFF
	ADD R0, #0xAB
	BL flagcheck



	// AND tests
	MOV R0, #0x00
	MOV R1, #0x93
	AND R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	AND R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	AND R0, R1
	BL flagcheck



	// ASR 5-bit immediate tests
	MOV R0, #0x00
	MOV R1, #0x93
	ASR R0, R1, #0xA
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	ASR R0, R1, #0xB
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	ASR R0, R1, $0xC
	BL flagcheck



	// ASR tests
	MOV R0, #0x00
	MOV R1, #0x93
	ASR R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	ASR R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	ASR R0, R1
	BL flagcheck



	// BIC tests
	MOV R0, #0x00
	MOV R1, #0x93
	BIC R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	BIC R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	BIC R0, R1
	BL flagcheck



	// CMN tests
	MOV R0, #0x00
	MOV R1, #0x93
	CMN R0, R1
	BL flagcheck

	MOV R0, #0x93
	MOV R1, #0x93
	CMN R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	CMN R0, R1
	BL flagcheck



	// CMN 8-bit immediate tests
	MOV R0, #0x00
	CMP R0, #0x93
	BL flagcheck

	MOV R0, #0x93
	CMP R0, #0x93
	BL flagcheck

	MOV R0, #0xFF
	CMP R0, #0x93
	BL flagcheck



	// CMP tests
	MOV R0, #0x00
	MOV R1, #0x93
	CMP R0, R1
	BL flagcheck

	MOV R0, #0x93
	MOV R1, #0x93
	CMP R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	CMP R0, R1
	BL flagcheck



	// EOR tests
	MOV R0, #0x00
	MOV R1, #0x93
	EOR R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	EOR R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	EOR R0, R1
	BL flagcheck



	// LSL 5-bit immediate tests
	MOV R0, #0x00
	MOV R1, #0x93
	LSL R0, R1, #0xA
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	LSL R0, R1, #0xB
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	LSL R0, R1, $0xC
	BL flagcheck



	// LSL tests
	MOV R0, #0x00
	MOV R1, #0x93
	LSL R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	LSL R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	LSL R0, R1
	BL flagcheck



	// LSR 5-bit immediate tests
	MOV R0, #0x00
	MOV R1, #0x93
	LSR R0, R1, #0xA
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	LSR R0, R1, #0xB
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	LSR R0, R1, $0xC
	BL flagcheck



	// LSR tests
	MOV R0, #0x00
	MOV R1, #0x93
	LSR R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	LSR R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	LSR R0, R1
	BL flagcheck



	// MUL tests
	MOV R0, #0x00
	MOV R1, #0x02
	MUL R0, R1
	BL flagcheck

	MOV R0, #0x7F
	MOV R1, #0x02
	MUL R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x02
	MUL R0, R1
	BL flagcheck



	// MVN tests
	MOV R1, #0x00
	MVN R0, R1
	BL flagcheck

	MOV R1, #0x7F
	MVN R0, R1
	BL flagcheck

	MOV R1, #0xFF
	MVN R0, R1
	BL flagcheck



	// MVN tests
	MOV R1, #0x00
	NEG R0, R1
	BL flagcheck

	MOV R1, #0x7F
	NEG R0, R1
	BL flagcheck

	MOV R1, #0xFF
	NEG R0, R1
	BL flagcheck



	// ORR tests
	MOV R0, #0x00
	MOV R1, #0x93
	ORR R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	ORR R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	ORR R0, R1
	BL flagcheck



	// ROR tests
	MOV R0, #0x00
	MOV R1, #0x93
	ROR R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	ROR R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	ROR R0, R1
	BL flagcheck
	
	
	
	// SBC tests
	MOV R0, #0x00
	MOV R1, #0x7F
	SBC R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x7F
	SBC R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x7F
	SBC R0, R1
	BL flagcheck



	// SUB tests
	MOV R0, #0x00
	MOV R1, #0x7F
	SUB R2, R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x7F
	SUB R2, R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x7F
	SUB R2, R0, R1
	BL flagcheck



	// SUB - 3-bit immediate tests
	MOV R1, #0x00
	SUB R0, R1, #2
	BL flagcheck

	MOV R1, #0x7F
	SUB R0, R1, #2
	BL flagcheck

	MOV R1, #0xFF
	SUB R0, R1, #2
	BL flagcheck



	// SUB - 8-bit immediate tests
	MOV R0, #0x00
	SUB R0, #0xAB
	BL flagcheck

	MOV R0, #0x7F
	SUB R0, #0xAB
	BL flagcheck

	MOV R0, #0xFF
	SUB R0, #0xAB
	BL flagcheck



	// TST tests
	MOV R0, #0x00
	MOV R1, #0x93
	TST R0, R1
	BL flagcheck

	MOV R0, #0xA9
	MOV R1, #0x93
	TST R0, R1
	BL flagcheck

	MOV R0, #0xFF
	MOV R1, #0x93
	TST R0, R1
	BL flagcheck

	B loop

loop:
	B loop





// these are flagchecks. flagchecks will be run after every log by
// calling BL flagcheck_N. this checks the flags of the ALU instructions

 // otherwise known as flagcheck_N
flagcheck:
	BEQ flagcheck_Z
	B flagcheck_Z

flagcheck_Z:
	BCS flagcheck_C
	B flagcheck_C

flagcheck_C:
	BMI flagcheck_V
	B flagcheck_V

flagcheck_V:
	BVS flagcheck_end
	B flagcheck_end

flagcheck_end:
	MOV PC, R14