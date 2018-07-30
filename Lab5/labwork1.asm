org 0000H

ljmp main

;==============================WaitingFor5SecondsBetween2ConsecutiveInputs===============================================
waiting:
	MOV A,#10;---------------------------------Load the D in accumulator
	MOV B,#0AH;--------------------------------Load 10 in B
	MUL AB;------------------------------------AB will the number of time the 50ns loop must be run
	Push 3
	Push 2
	Push 1
	MOV R3,A
	BACK2:;------------------------------------50 ns loop is run 10D times to get correct delay between 2 blinking
		MOV R2,#200
		BACK1:
			MOV R1,#0FFH
			BACK:
				DJNZ R1,BACK
			DJNZ R2,BACK1
	DJNZ R3,BACK2
	Pop 1
	Pop 2
	Pop 3
RET

;=================================ReadTheLowerNibbleFromThePort=============================================

readNibble:
	mov A,P1
	anl A,#0FH
RET

;===============================================================================

packNibbles:
	push 0			;push the register 0
	lcall waiting	;wait for 5 seconds
	lcall readNibble	;call readNibble to read the values from the port
	swap A			;swapping the nibbles of A to get the nibble in the higher 4 bits
	mov R0,A		;store the higher 4 bits in R0 with 00H in the lower 4 bits
	lcall waiting	;again wait for 5 seconds for the user to change the port pins
	lcall readNibble	;call readNibble to read the value from the port
	add A,R0		;add the lower nibble to the prevous upper nibble to get 8 bit number
	mov 4FH,A	;store this 8 bit number at 4FH
	pop 0			;pop the register 0 
RET

;================================================================================

readValues:
	push 2		;push register 2
	push 1		;push register 1
	mov R2,50H	;move the number of values that need to be read in R2
	mov R1,51H	;move the starting location of the destination array in R1
reading:
	lcall packNibbles	;call packNibbles to read 8 bit number from the port
	mov @R1,4FH		;this number is stored in 4FH , copy that to the location pointed by R1
	inc R1					;increment R1 to make it point to the next location
	djnz R2,reading		;decrement R2 to ensure this process takes place K times where K is the number stored in 50H
	pop 1					;pop register 1
	pop 2					;pop register 2
RET
;===================================ShuffleBits==================================
shuffleBits:
	push 4					;push registers into the stack
	push 3
	push 2
	push 1
	push 0
	mov R2,50H			;move the number K in R2 which the number of values that are needed to be accepted
	mov R1,51H			;move the starting location of the input array in R1
	mov R0,52H			;move the starting location of the final output array in R0
	dec R2					;decrement K so that the xoring loop runs R2-1 times as the last XOR happens between the last and the first element
	mov A,@R1			;move the first number in Accumulator
	mov R4,A				;move the first number in R4 this will be used later
	
xoring:	
	mov A,@R1			;move the number pointed by R1 in Accumulator
	mov R3,A				;move this number to R3
	inc R1					;increment R1 so that it points to the next location
	mov A,@R1			;move the number at the next location in the Accumuator
	xrl A,R3				;XOR this number with the previous number 
	mov @R0,A			;store the XORed result at the location pointed by R0
	inc R0					;increment R0 so that it points to next location
	djnz R2,xoring		;decrement R2 and check that the loop runs only R2 - 1 times

	;mov A,@R1
	;xrl A,51H
	;mov @R0,A
	mov A,@R1			;R1 points the last element of the input array....so move that to the accumulator
	xrl A,R4				;XOR this with first element of the array which was stored in R4
	mov @R0,A			;store this in the memory location pointed by R0
	pop 0					;pop all the registers
	pop 1
	pop 2
	pop 3
	pop 4

ret
;======================MAIN=======================================================
ORG 100H

main:

MOV SP,#0CFH;-----------------------Initialize STACK POINTER
MOV 50H,#3;------------------------Set value of K
MOV 51H,#60H;------------------------Array A start location
MOV 4FH,#00H;------------------------Clear location 4FH
LCALL readValues
MOV 50H,#3;------------------------Value of K
MOV 51H,#60H;------------------------Array A start location
MOV 52H,#70H;------------------------Array B start location
LCALL shuffleBits
;MOV 50H,#XX;------------------------Value of K
;MOV 51H,#XX;------------------------Array B start Location
;LCALL displayValues;----------------Display the last four bits of elements on LEDs
here:SJMP here;---------------------WHILE loop(Infinite Loop)
END

; ------------------------------------END MAIN-----------------------------------
