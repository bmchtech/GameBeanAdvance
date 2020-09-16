.global flagcheck

@ these are flagchecks. flagchecks will be run after every log by
@ calling BL flagcheck_N. this checks the flags of the ALU instructions

flagcheck: @ otherwise known as flagcheck_N
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
