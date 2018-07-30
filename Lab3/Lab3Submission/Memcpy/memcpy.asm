ORG 00H
LJMP MAIN
;-------------------------------------------
memcpy:
	MOV R2,50H
	MOV R0,51H
	MOV R1,52H
	CLR A
	MOV A,R0;----------------------------------------------------A stores the memory location of the original array
	MOV B,R1;----------------------------------------------------B stores the memory location of the final array in which the original array needs to be copied
	DIV AB;---------------------------------------------------------Divide them 
	JZ COND1;-----------------------------------------------------If you get 0 as the quotient then it means R1 is to the right of R0
	JNZ FORWARDFILLING;---------------------------------Else R1 is to the left of R0 and we need to start filling from front
	COND1:
				MOV A,R0;----------------------------------------Mov R0 in A
				ADD A,R2;
				DEC A;----------------------------------------------Add R2 -1 to A to get the ending location of the orignal array
				DIV AB;----------------------------------------------If this new value of A is greater than B then we need to fill backwards or else forward filling
				JNZ BACKFILLING;------------------------------Do backward filling
				LCALL FORWARDFILLING;------------------Do forward filling
	BACKFILLING:;------------------------------------------------Copy the orignal in the final array from the end to the start position
				MOV A,R0
				ADD A,R2
				MOV R0,A;-------------------------------------------Increment R0 to the ending of the original array
				DEC R0
				MOV A,R1
				ADD A,R2
				MOV R1,A;-------------------------------------------Increment R1 to the ending of the final array
				DEC R1
				LCALL BACKWARDFILL
RET

				BACKWARDFILL:;--------------------------------Backward Filling
										MOV A,@R0
										MOV @R1,A
										DEC R1
										DEC R0
										DJNZ R2,BACKWARDFILL
				RET
									
				FORWARDFILLING:;-----------------------------Forward Filling
										MOV A,@R0
										MOV @R1,A
										INC R1
										INC R0
										DJNZ R2,FORWARDFILLING
					RET


;--------------------------------------------------
MAIN:
	MOV 50H,#0AH;----------------------------------------Alloting the corresponding memory locations with values for testing.
	MOV 51H,#60H
	MOV 52H,#55H
	MOV 60H,#01H
	MOV 61H,#02H
	MOV 62H,#03H
	MOV 63H,#04H
	MOV 64H,#05H
	MOV 65H,#06H
	MOV 66H,#07H
	MOV 67H,#08H
	MOV 68H,#09H
	MOV 69H,#0AH
	ACALL memcpy
	LOOP:SJMP LOOP
;-------------------------------------------------
END