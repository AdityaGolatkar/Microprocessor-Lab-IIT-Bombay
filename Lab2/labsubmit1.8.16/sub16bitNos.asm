;Problem: Subtraction of two 16 bit numbers
;Author:Aditya Golatkar
;Roll No:14B030009

ORG 0000H
LJMP MAIN

SUB_16BIT:
	
	MOV A,R1					;load the LSB of the first number in the accumulator
	CLR C							
	SUBB A,R3					;subtract the LSB of the second number from the LSB of the first number
	MOV 64H,A					;store this as the third byte in the memory
	
	MOV A,R0					;same comments as above but this time it is for MSB and borrow will matter
	SUBB A,R2
	MOV 63H,A
	
	MOV A,#00H					;ensures the first byte is stored computed correctly and stored in the memory
	ADDC A,#00H
	MOV 62H,A
RET
		
INIT:
	;Used to initialize the 
	MOV 60H,#0FEH				;MSB of the first number
	MOV 61H,#0BEH 				;LSB of the first number
	MOV 70H,#0FFH				;MSB of the second number
	MOV 71H,#0FFH				;LSB of the second number
	
	;Transfering the MSB and LSB values in the Registers
	MOV R0,60H
	MOV R1,61H
	MOV R2,70H
	MOV R3,71H
RET

ORG 0100H
MAIN:
	MOV SP,#0C0H	;move stack pointer to indirect RAM location
	ACALL INIT
	ACALL SUB_16BIT
	repeat: sjmp repeat
END
