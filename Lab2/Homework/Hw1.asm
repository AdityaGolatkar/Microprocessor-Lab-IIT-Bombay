ORG 0000H
LJMP MAIN

ADD8BIT:
	NOP 
	mov 50H,#0FFH
	mov 60H,#0FFH
	MOV A, 50H    ;load the first number from 50H in the accumulator
	ADD A, 60H    ;add the second number with the first number
	MOV 70H,A     ;store the sum to 70H
	RET

ORG 100H
MAIN:
	ACALL ADD8BIT
	repeat: sjmp repeat
END
