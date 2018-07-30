ORG 0000H
LJMP MAIN
ORG 100H
MAIN:
	NOP 
	MOV A, 50H    ;load the first number from 50H in the accumulator
	ADD A, 60H    ;add the second number with the first number
	MOV 70H,A     ;store the sum to 70H
END
