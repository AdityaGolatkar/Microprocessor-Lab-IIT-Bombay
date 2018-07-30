;Problem: Addition of two 16 bit numbers
;Author:Aditya Golatkar
;Roll No:14B030009

ORG 0000H
LJMP MAIN


ADDER_16BIT:
	
	MOV A,R1				;load the LSB of the first number in the accumulator
	ADD A,R3					;add the LSB of the second number to the first number
	MOV 64H,A				;store the LSB of the sum in memory
	
	MOV A,R2				;same comments as the one for LSB with extra carry into consideration
	ADDC A,R0
	
	MOV A,#00H				;load the accumulator with 00
	ADDC A,#00H			;add the carry to the accumulator 
	MOV 62H,A				;store the third byte of the sum in the memory
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
	ACALL ADDER_16BIT
	repeat: sjmp repeat
END
