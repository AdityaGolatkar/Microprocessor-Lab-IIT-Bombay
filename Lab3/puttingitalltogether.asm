ORG 00H
	LJMP MAIN
;--------------------------------------------------------------------------------------------------------------------------
zeroOut:;-------------------------------------------Subroutine for clearing the memory locations
	MOV R2,50H;--------------------------------Load in R2 the number of locations that need to be cleared
	MOV R1,51H;--------------------------------Load the starting location to be cleared in R1
	CLR A
	CLEAR:;----------------------------------------Clear the locations starting from location stored in R1 one by one
		MOV @R1,#00H
		INC R1
		DJNZ R2,CLEAR
RET
;---------------------------------------------------------------------------------------------------------------------------
bin2ascii:
	MOV R2,50H;------------------------------Load the number of numbers in R2
	MOV R0,51H;------------------------------Load the starting location for reading in R1
	MOV R1,52H;------------------------------Load the starting location for storing in R2
	ITERATE:
		MOV A,@R0;--------------------------Load the number in the accumulator
		INC R0
	NIBBLE:	
		SWAP A;-------------------------------Swap the nibbles of A
		;MOV R4,A;---------------------------Stored the swapped number in R4
		MOV R5,A;----------------------------Store the swapped number in R5
		MOV R3,#00H;-----------------------Move 00H in R3
		ANL A,#0F0H;------------------------Store the upper nibble of A in A
		MOV R4,A;----------------------------Move this A to R4
		MOV A,R5;----------------------------Move the intial swapped A back to A
		ANL A,#0FH;-------------------------Get its lower nibble which is actually the upper nibble of the original number
		MOV B,#10;--------------------------Load 10 in B
		DIV AB;--------------------------------Divide A with B
	JZ LESSER;------------------------------If the quotient is zero then it means that the nibble is a number and hence add 48 to get the ascii value
		MOV A,B;-----------------------------If the quotient is not zero then add 65 to the remainder to get ascii value for the alpahbets used to store numbers.
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
;-----------------------------------------------------------------------------------------------------------------------------------------
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


;----------------------------------------------------------------------------------------------------------------------------------------------
DELAY:
			MOV R7,4FH
			BACK2:
				MOV R6,#200
				BACK1:
					MOV R5,#0FFH
					BACK:
						DJNZ R5,BACK
				DJNZ R6,BACK1
			DJNZ R7,BACK2
RET

display:
	MOV R2,50H
	MOV R1,51H
	READ:
		MOV A,@R1
		INC R1
		
		RRC A
		MOV P1.4,C
		RRC A
		MOV P1.5,C
		RRC A
		MOV P1.6,C
		RRC A
		MOV P1.7,C
		LCALL DELAY
		
		DJNZ R2,READ
RET
;--------------------------------------------------------------------------------------------------------------------------------------------
MAIN:
MOV SP,#0CFH;-----------------------Initialize STACK POINTER

MOV 50H,#0AH;------------------------No of memory locations of Array A
MOV 51H,#53H;------------------------Array A start location
LCALL zeroOut;----------------------Clear memory
;
MOV 50H,#0AH;------------------------No of memory locations of Array B
MOV 51H,#63H;------------------------Array B start location
LCALL zeroOut;----------------------Clear memory

MOV 73H,#55H
MOV 74H,#4BH
MOV 75H,#3CH
MOV 76H,#4DH
MOV 77H,#5EH

MOV 50H,#05H;------------------------No of memory locations of source array
MOV 51H,#73H;------------------------Source array start location
MOV 52H,#53H;------------------------Destination array(A) start location
LCALL bin2ascii;--------------------Write at memory location

MOV 50H,#0AH;------------------------No of elements of Array A to be copied in Array B
MOV 51H,#53H;------------------------Array A start location
MOV 52H,#63H;------------------------Array B start location
LCALL memcpy;-----------------------Copy block of memory to other location

MOV 50H,#0AH;------------------------No of memory locations of Array B
MOV 51H,#63H;------------------------Array B start location
MOV 4FH,#0AH;------------------------User defined delay value
LCALL display;----------------------Display the last four bits of elements on LEDs
here:SJMP here;---------------------WHILE loop(Infinite Loop)
END
