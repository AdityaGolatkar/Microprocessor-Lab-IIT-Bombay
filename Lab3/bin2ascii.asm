ORG 00H
LJMP MAIN
;-------------------------------------------------
bin2ascii:
	MOV R2,50H;------------------------------Load the number of numbers in R2
	MOV R0,51H;------------------------------Load the starting location for reading in R1
	MOV R1,52H;------------------------------Load the starting location for storing in R2
	ITERATE:
		MOV A,@R0;-----------------------Load the number in the accumulator
		INC R0
	NIBBLE:	
		SWAP A;--------------------------Swap the nibbles of A
		;MOV R4,A;------------------------Stored the swapped number in R4
		MOV R5,A;------------------------Store the swapped number in R5
		MOV R3,#00H;---------------------Move 00H in R3
		ANL A,#0F0H;---------------------Store the upper nibble of A in A
		MOV R4,A;------------------------Move this A to R4
		MOV A,R5;------------------------Move the intial swapped A back to A
		ANL A,#0FH;----------------------Get its lower nibble which is actually the upper nibble of the original number
		MOV B,#10;-----------------------Load 10 in B
		DIV AB;--------------------------Divide A with B
	JZ LESSER;-------------------------------If the quotient is zero then it means that the nibble is a number and hence add 48 to get the ascii value
		MOV A,B;-------------------------If the quotient is not zero then add 65 to the remainder to get ascii value for the alpahbets used to store numbers.
		ADD A,#41H
		MOV @R1,A
		INC R1
		MOV A,R4
	JZ NEXT
	JNZ NIBBLE	

	LESSER:;--------------------------------Add 48 to convert the nibble to ascii
		MOV A,B
		ADD A,#30H
		MOV @R1,A
		INC R1
		MOV A,R4
	JZ NEXT
	JNZ NIBBLE
		
	NEXT:
		DJNZ R2,ITERATE
RET
;-------------------------------------------------
MAIN:
	MOV 50H,#05H
	MOV 51H,#60H
	MOV 52H,#70H
	MOV 60H,#9EH
	MOV 61H,#0B2H
	MOV 62H,#21H
	MOV 63H,#0A7H
	MOV 64H,#0FBH
	ACALL bin2ascii
	LOOPING : SJMP LOOPING
;-------------------------------------------------
END
