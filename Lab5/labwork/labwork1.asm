ORG 00H
	LJMP main
	
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

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
         
         ret                  ;return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;move the command to LCD port
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
         ret          

lcd_clear:
		 acall delay
		 mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 ret

		 

main:
	mov SP,#0CFH
	mov 50H,#02H
	mov 51H,#60H
	mov 4FH,#00H
	lcall readValues
	
	mov 50H,#02H
	mov 51H,#60H
	mov 52H,#70H
	lcall shuffleBits
	
	lcall lcd_init
	disp:		mov 50H,#02H
		mov 51H,#70H
		lcall displayValues
		SJMP disp
	
	here: SJMP here
	
;==============================================
; 					Binary to Ascii
;==============================================
bin2ascii:
			mov A,R2				
			mov B,#10H				
			div AB
			mov R5,B				
		
			mov B,#0AH					
			div AB							
			JNZ greater1
			mov R3,#30H					
			JMP cont1
			greater1:mov R3,#41H		
			cont1:mov A,B				
			add A,R3		
			
			mov R6,A					
			mov A,R5					
			
			mov B,#0AH					
			div AB							
			JNZ greater
			mov R3,#30H					
			JMP cont
			greater:mov R3,#41H		
			cont:mov A,B				
			add A,R3			
			
			mov R7,A					
        ret

;================================================
;		This function shuffles the bits by performing XOR operation
;================================================
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
	
;================================================
;		This function reads the  values using the packNibble
;================================================
; this sub-routine stores a series of K(stored in location 50H) bytes in K consecutive locations starting from P(value stored in location 51H)
readValues:
	push 1
	push 0
	mov R1,50H
	mov R0,51H
	loop:
		lcall packNibbles
		mov @R0,4FH
		INC R0
		DJNZ R1,loop
	pop 0
	pop 1
	ret

;======================================================
;		This function packs the nibbles 
;======================================================
; this sub-routine takes 2 nibbles as input and stores the corresponding byte in location 4FH
packNibbles:
	push 0
	
	lcall DelayOf5secs		; wait 5s for the first input, i.e. the most significant nibble
	lcall readnibble			; read the most significant nibble
	mov B,#10H			
	MUL AB					; multiply the most significant nibble with 16(10H) to obtain the first 4 bits of the number
	mov R0,A					; store the result in R0
	
	lcall DelayOf5secs		; wait 5s for the second input, i.e. the least significant nibble
	lcall readnibble			; read the least significant nibble
	add A,R0					; add the least significant nibble to the first 4 bits of the number(stored in R0)		
	mov 4FH,A				; store the result in location 4FH
	;mov R2,4FH				; store the value stored at memory location 4FH in R2
	pop 0
ret
		
clear:
	CLR P1.3
	CLR P1.2
	CLR P1.1
	CLR P1.0
ret

; this sub-routine reads a 4 bit nibble from the pins P1.3-P1.0

;========================================================
;		This function reads the nibble from the user
;========================================================
readnibble:	
	setb p1.4
	setb p1.5
	setb p1.6
	setb p1.7
						;wait for 5 sec during which user can give input
	lcall DelayOf5secs
	
						;clear pins P1.4 to P1.7
	clr p1.4
	clr p1.5
	clr p1.6
	clr p1.7

	lcall reading	;read the input on P1.0-P1.3 (nibble)
	
	lcall DelayOf2secs
	
	mov A,r0			
	swap A
	mov p1,A				
						
	lcall DelayOf5secs
						
	clr p1.4
	clr p1.5
	clr p1.6
	clr p1.7	
	ret	
						;read the input from switches
reading:
			setb p1.0		    
			setb p1.1	
			setb p1.2					
			setb p1.3
								; set pins 0-3 for configuring as input pins
			mov a,p1			; read value on pins
			anl a,#0Fh
			;mov r0,a
			ret	
	
;======================================================
;		This function is used to display the values on the LCD
;======================================================
displayValues:

	push 0
	push 1
	push 2
	push 3
	push 6
	push 7
	
	mov R2,50H
	mov R1,51H
	
	lcall DelayOf5secs
	lcall readnibble
	
	mov R3,A
	CLR C
	SUBB A,R2
	
	JNC invalid
	
	mov A,R3
	CLR C
	add A,R1
	mov R1,A
	
	mov A,@R1
	mov R2,A
	
	mov A,#82H
	lcall lcd_command
	lcall delay
	
	lcall bin2ascii
	mov A,R6
	lcall lcd_senddata	;call data sending routine
	
	mov A,R7
	lcall lcd_senddata	;call data sending routine
	lcall DelayOf2secs
	
	invalid:
	lcall lcd_clear
	
	pop 7
	pop 6
	pop 3
	pop 2
	pop 1
	pop 0
	ret
	
;=====================================================
;						Delay
;=====================================================
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret
	 
;=====================================================
;						Delay of 2 seconds
;=====================================================	 
	; this sub-routine generates a delay of 2s
DelayOf2secs:
	mov R3,#28H		;run the code given to generate a delay of 50 ms 40 times
	rback2:								
		mov R4,#200 ;lines 61-66 generates a delay of 50 ms
		rback1: 
			mov R5,#0FFH 
			rback: 
				DJNZ R5,rback
			DJNZ R4,rback1
		DJNZ R3,rback2
ret

;=====================================================
;						Delay of 5 secs
;=====================================================

; this sub-routine generates a delay of 5s
DelayOf5secs:
	mov R3,#64H		;run the code given to generate a delay of 50 ms 20 times
	back2:								
		mov R4,#200 ;lines 61-66 generates a delay of 50 ms
		back1: 
			mov R5,#0FFH 
			back: 
				DJNZ R5,back
			DJNZ R4,back1
		DJNZ R3,back2
ret

END
	
	