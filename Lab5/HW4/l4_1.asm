ORG 00H
	LJMP main
;======================================
;				MAIN
;======================================
ORG 100H
main:
	mov  SP,#0CFH
	mov  50H,#03H
	mov  51H,#60H
	mov  4FH,#00H
	lcall readValues
	
	mov  50H,#03H
	mov  51H,#60H
	mov  52H,#70H
	lcall shuffleBits
	
	lcall lcd_init
	disp: 
		mov  50H,#03H
		mov  51H,#70H
		lcall displayValues
		SJMP disp
	
	here: SJMP here
	
;========================================
;				SHUFFLE BITS
;========================================
	
shuffleBits:
	mov  R0,51H
	mov  R1,52H
	mov  R2,50H
	DEC R2
	xor_loop:
		mov  A,@R0
		mov  R3,A
		INC R0
		mov  A,@R0
		XRL A,R3
		mov  @R1,A
		INC R1
		DJNZ R2,xor_loop
	mov  A,@R0
	mov  R2,A
	mov  R0,51H
	mov  A,@R0
	XRL A,R2
	mov  @R1,A
	ret
	
;===================================================
;					READING
;===================================================
; this sub-routine stores a series of K(stored in location 50H) bytes in K consecutive locations starting from P(value stored in location 51H)
readValues:
	mov  R2,50H
	mov  R1,51H
	loop:
		lcall packNibbles
		mov  @R1,4FH
		INC R1
		DJNZ R2,loop
	ret

;====================================================
;					PACKNIBBLE
;====================================================
; this sub-routine takes 2 nibbles as input and stores the corresponding byte in location 4FH
packNibbles:
	;lcall clear
	setb P1.7
	setb P1.6
	setb P1.5
	setb P1.4
	lcall delay5		; wait 5s for the first input, i.e. the most significant nibble
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	lcall readnibble	; read the most significant nibble
	mov  B,#10H			
	MUL AB				; multiply the most significant nibble with 16(10H) to obtain the first 4 bits of the number
	mov  R0,A			; store the result in R0
	mov  P1,A
	
	lcall delay5
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	;lcall clear
	lcall delay5
	setb P1.7
	setb P1.6
	setb P1.5
	setb P1.4
	lcall delay5		; wait 5s for the second input, i.e. the least significant nibble
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	lcall readnibble	; read the least significant nibble
	swap a
	mov  p1,a
	swap a
	lcall delay5
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	
	ADD A,R0			; add the least significant nibble to the first 4 bits of the number(stored in R0)		
	mov  4FH,A			; store the result in location 4FH
	;mov  R2,4FH			; store the value stored at memory location 4FH in R2
ret
		
clear:
	CLR P1.3
	CLR P1.2
	CLR P1.1
	CLR P1.0
ret

;====================================================
;						READNIBBLE
;====================================================
; this sub-routine reads a 4 bit nibble from the pins P1.3-P1.0
readnibble:
	
	setb P1.3
	setb P1.2
	setb P1.1
	setb P1.0
	
	CLR A
	mov  C,P1.3			;read value on pins
	RLC A
	mov  C,P1.2
	RLC A
	mov  C,P1.1
	RLC A
	mov  C,P1.0
	RLC A
ret
	
;=====================================================
;							DISPLAY VALUES
;=====================================================
displayValues:
	mov  R2,50H
	mov  R1,51H
	lcall delay5
	setb P1.7
	clr P1.6
	setb P1.5
	clr P1.4
	lcall delay5		; wait 5s for the first input, i.e. the most significant nibble
	clr P1.7
	setb P1.6
	clr P1.5
	setb P1.4
	lcall delay5
	clr P1.7
	clr P1.6
	clr P1.5
	clr P1.4
	lcall readnibble
	mov  R3,A
	CLR C
	SUBB A,R2
	JNC invalid
	mov  A,R3
	CLR C
	ADD A,R1
	mov  R1,A
	mov  A,@R1
	mov  R2,A
	; display on LCD
	mov  A,#82H
	lcall lcd_command
	lcall delay
	lcall bin2ascii
	mov  A,R6
	lcall lcd_senddata	;call data sending routine
	mov  A,R7
	lcall lcd_senddata	;call data sending routine
	lcall delay2
	invalid:
	lcall lcd_clear
	ret
	
; this sub-routine generates a delay of 5s
delay5:
	mov  R3,#64H		;run the code given to generate a delay of 50 ms 20 times
	back2:								
		mov  R4,#200 ;lines 61-66 generates a delay of 50 ms
		back1: 
			mov  R5,#0FFH 
			back: 
				DJNZ R5,back
			DJNZ R4,back1
		DJNZ R3,back2
ret

; this sub-routine generates a delay of 2s
delay2:
	mov  R3,#28H		;run the code given to generate a delay of 50 ms 40 times
	aback2:								
		mov  R4,#200 ;lines 61-66 generates a delay of 50 ms
		aback1: 
			mov  R5,#0FFH 
			aback: 
				DJNZ R5,aback
			DJNZ R4,aback1
		DJNZ R3,aback2
ret
	
; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

lcd_clear:
		 acall delay
		 mov    LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 ret


;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov    LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov    LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov    LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov    LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov    LCD_data,A     ;mov e the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov    LCD_data,A     ;mov e the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;return from busy routine

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
         mov  r0,#1
loop2:	 mov  r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret
	 
 
getAscii:
		mov  B,#0AH						
		DIV AB						
		JNZ morethan9				
		mov  R3,#30H					
		JMP cont
		morethan9:mov  R3,#41H		
		cont:mov  A,B				
		ADD A,R3					
		ret
	

bin2ascii:
			mov  A,R2				
			mov  B,#10H			
			DIV AB					
			mov  R5,B				
			ACALL getAscii		
			mov  R6,A				
			mov  A,R5				
			ACALL getAscii			
			mov  R7,A				
			ret
		
END
	
	