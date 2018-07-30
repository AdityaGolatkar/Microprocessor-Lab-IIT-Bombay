ORG 00H
	LJMP main
	
ORG 100H
main:
	MOV 50H,#03H
	MOV 51H,#60H
	LCALL readValues
	here : SJMP here

; this sub-routine stores a series of K(stored in location 50H) bytes in K consecutive locations starting from P(value stored in location 51H)
readValues:
	MOV R2,50H
	MOV R1,51H
	loop:
		LCALL packNibbles
		MOV @R1,4FH
		INC R1
		DJNZ R2,loop
	RET

; this sub-routine takes 2 nibbles as input and stores the corresponding byte in location 4FH
packNibbles:
	;LCALL clear
	LCALL delay5		; wait 5s for the first input, i.e. the most significant nibble
	LCALL readnibble	; read the most significant nibble
	MOV B,#10H			
	MUL AB				; multiply the most significant nibble with 16(10H) to obtain the first 4 bits of the number
	MOV R0,A			; store the result in R0
	;LCALL clear
	LCALL delay5		; wait 5s for the second input, i.e. the least significant nibble
	LCALL readnibble	; read the least significant nibble
	ADD A,R0			; add the least significant nibble to the first 4 bits of the number(stored in R0)		
	MOV 4FH,A			; store the result in location 4FH
	;MOV R2,4FH			; store the value stored at memory location 4FH in R2
RET
		
clear:
	CLR P1.3
	CLR P1.2
	CLR P1.1
	CLR P1.0
RET

; this sub-routine reads a 4 bit nibble from the pins P1.3-P1.0
readnibble:
	CLR A
	MOV C,P1.3			;read value on pins
	RLC A
	MOV C,P1.2
	RLC A
	MOV C,P1.1
	RLC A
	MOV C,P1.0
	RLC A
RET
	
; this sub-routine generates a delay of 5s
delay5:
	MOV R3,#64H		;run the code given to generate a delay of 50 ms 20 times
	back2:								
		MOV R4,#200 ;lines 61-66 generates a delay of 50 ms
		back1: 
			MOV R5,#0FFH 
			back: 
				DJNZ R5,back
			DJNZ R4,back1
		DJNZ R3,back2
RET
	
END