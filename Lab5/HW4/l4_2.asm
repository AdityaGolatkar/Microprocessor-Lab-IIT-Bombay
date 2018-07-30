ORG 00H
	LJMP main
	
ORG 100H
main:
	MOV R0,#50H
	MOV A,#60H
	MOV R1,#10H
	;initialization function
	init_loop:
		MOV @R0,A
		INC R0
		INC A
		DJNZ R1,init_loop
		
	LCALL lcd_init
	LCALL display16RAMLocs
	;SJMP disp
	
	;here: SJMP here
	
display16RAMLocs:
	;start:
	LCALL delay5
	setb P1.7
	setb P1.6
	setb P1.5
	setb P1.4
	LCALL delay5		; wait 5s for the first input, i.e. the most significant nibble
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	LCALL readnibble
	swap a
	mov p1,a
	swap a
	lcall delay5
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	
	MOV R1,A
	LCALL delay5
	setb P1.7
	setb P1.6
	setb P1.5
	setb P1.4
	LCALL delay5		; wait 5s for the first input, i.e. the most significant nibble
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	LCALL readnibble
	swap a
	mov p1,a
	swap a
	lcall delay5
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	
	CLR C
	SUBB A,R1
	JNZ display16RAMLocs
	MOV B,#10H
	MOV A,R1
	MUL AB
	MOV R4,#04H
	MOV R0,#82H
	;LCALL lcd_init
	dispLoop1:
		;MOV R1,A
		LCALL displayValues
		INC A
		INC R0
		INC R0
		INC R0
		DJNZ R4,dispLoop1
		
	MOV R4,#04H
	MOV R0,#0C2H	
	dispLoop2:
		LCALL displayValues
		INC A
		INC R0
		INC R0
		INC R0
		DJNZ R4,dispLoop2
		
	LCALL delay5
	;LCALL lcd_clear
	MOV R4,#04H
	MOV R0,#82H
	;LCALL lcd_init
	dispLoop3:
		LCALL displayValues
		INC A
		INC R0
		INC R0
		INC R0
		DJNZ R4,dispLoop3
		
	MOV R4,#04H
	MOV R0,#0C2H	
	dispLoop4:
		LCALL displayValues
		INC A
		INC R0
		INC R0
		INC R0
		DJNZ R4,dispLoop4
	LCALL delay5
	LJMP display16RAMLocs
	;RET
		
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
	setb P1.3
	setb P1.2
	setb P1.1
	setb P1.0
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
	
displayValues:
	MOV R1,A
	;MOV R3,#82H
	MOV A,@R1
	MOV R2,A
	; display on LCD
	MOV A,R0
	LCALL lcd_command
	LCALL delay
	LCALL bin2ascii
	MOV A,R6
	LCALL lcd_senddata	;call data sending routine
	MOV A,R7
	LCALL lcd_senddata	;call data sending routine
	;LCALL delay2
	MOV A,R1
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

; this sub-routine generates a delay of 2s
delay2:
	MOV R3,#28H		;run the code given to generate a delay of 50 ms 40 times
	aback2:								
		MOV R4,#200 ;lines 61-66 generates a delay of 50 ms
		aback1: 
			MOV R5,#0FFH 
			aback: 
				DJNZ R5,aback
			DJNZ R4,aback1
		DJNZ R3,aback2
RET
	
; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

lcd_clear:
		 acall delay
		 mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 ret


;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret
	 
 ; this sub-routine stores the ASCII value of a hex digit(0 to F) stored in the accumulator, in the accumulator itself
getAscii:
		MOV B,#0AH					; store 10 in B	
		DIV AB						; divide A by B to check if the value stored in A is greater than 9 or not
		JNZ moreThan9				; if the quotient(stored in A) is not zero, then the value stored originally in A is greater than 9
		MOV R3,#30H					; store 30H in R3(ASCII value of characters from 0-9 is 30-39)
		JMP cont
		moreThan9:MOV R3,#41H		; store 41H in R3(ASCII value of charcters from A-F is 41-46)
		cont:MOV A,B				; copy the remainder stored in B to A
		ADD A,R3					; add the remainder to the value stored in R3, to obtain the ASCII value of the hex digit originally stored in the accumulator
		RET
	
; this sub-routine stores the ASCII values of the numbers stored in memory locations P1 to P1+N-1 in P2 to P2+2*N-1 with the higher nibble stored in the first byte and the lower nibble stored in the second byte	
bin2ascii:
			MOV A,R2				; copy the value pointed to by R0 in the accumulator
			MOV B,#10H				; store 10H(16 in decimal) in B
			DIV AB					; divide A by B to store the higher nibble in A and the lower nibble in B
			MOV R5,B				; store the lower nibble in R4
			ACALL getAscii			; obtain the ASCII value of the higher nibble in A
			MOV R6,A				; store the ASCII value of the higher nibble in the memory location pointed to by R1
			MOV A,R5				; copy the lower nibble in the accumulator
			ACALL getAscii			; obtain the ASCII value of the lower nibble in A
			MOV R7,A				; store the ASCII value of the lower nibble in the memory location pointed to by R1
        RET
		
END
	
	
