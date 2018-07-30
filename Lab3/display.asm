ORG 00H
LJMP MAIN
;---------------------------------------------------------------
ORG 100H
	
display:
	MOV R2,50H;--------------------------------------------Load the value of the number of numbers to be diplayed in R2
	MOV R1,51H;--------------------------------------------Load the starting location of the numbers in R1
	READ:
		MOV A,@R1;-------------------------------------Load the starting number in the accumulator
		INC R1;----------------------------------------Increment R1 to point to the next location
		;----------------------------------------------------Kindly note that A7 goes in P1.4 ,A6 goes in P1.5 and so on.
		RRC A;-----------------------------------------RRC A to get the last bit of A
		MOV P1.4,C;------------------------------------Load the last bit of A in P1.4

		RRC A
		MOV P1.5,C
	
		RRC A
		MOV P1.6,C
	
		RRC A
		MOV P1.7,C
		
		MOV R7,#20;------------------------------------This is used to induce a delay of 1s between two consecutive LED displays.
			BACK2:
				MOV R6,#200
				BACK1:
					MOV R5,#0FFH
					BACK:
						DJNZ R5,BACK
				DJNZ R6,BACK1
			DJNZ R7,BACK2
		DJNZ R2,READ
RET
;---------------------------------------------------------------
MAIN:	
	MOV 50H,#5
	MOV 51H,#60H
	MOV 60H,#24H
	MOV 61H,#25H
	MOV 62H,#26H
	MOV 63H,#2BH
	MOV 64H,#2FH
	ACALL display
	LOOP:SJMP LOOP
;---------------------------------------------------------------
END
