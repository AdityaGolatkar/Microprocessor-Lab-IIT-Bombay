ORG 0000H
LJMP MAIN

SUM:
	MOV 50H,#05H
	MOV R1,50H        ;load the number in R1
	MOV R0,#51H       ;store the address in R0
	MOV R2,#01H       ;store the address 01H in R2
	CLR A               

	LOOP:	ADD A,R2   ;add 1 to the current value of the accumulator
			MOV @R0,A  ;store this value in the corresponding locations
			INC R0     ;increment the address by 1
			INC R2     ;increment R2 to get the next sum of N nos
			DJNZ R1,LOOP  ;decrement to check the that you dont exceed N
	RET
	
ORG 100H
MAIN:
	ACALL SUM 
	repeat: sjmp repeat
END
