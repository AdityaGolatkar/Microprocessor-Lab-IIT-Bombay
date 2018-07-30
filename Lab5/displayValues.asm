org 00h
; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ljmp main 

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 lcall delay
         clr   LCD_en
	     lcall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 lcall delay
         clr   LCD_en
         
		 lcall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 lcall delay
         clr   LCD_en
         
		 lcall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 lcall delay
         clr   LCD_en

		 lcall delay
         
         ret                  ;Return from routine
;--------------------------lcd clear--------------
lcd_clear:
	 lcall delay
	 mov   LCD_data,#01H  ;Clear LCD
	 clr   LCD_rs         ;Selected command register
	 clr   LCD_rw         ;We are writing in instruction register
	 setb  LCD_en         ;Enable H->L
	 lcall delay
	 clr   LCD_en
	 lcall delay
	ret

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 lcall delay
         clr   LCD_en
		 lcall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 lcall delay
         clr   LCD_en
         lcall delay
		 lcall delay
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
;-------------------------------------custom delay-------------------------------------
waiting:
	USING 0		;ASSEMBLER DIRECTIVE TO INDICATE REGISTER BANK0
        PUSH PSW
        PUSH AR0	; STORE R1 (BANK O) ON THE STACK
        PUSH AR1
		PUSH AR2
		PUSH AR3
		;
		mov B,#50					; stored processed val in r1
        mul AB
		mov r1,A
		back1:
		mov R2,#100
		back2:
		mov r3,#200
		back3:
		djnz r3,back3
		djnz r2,back2
		djnz r1,back1
		
		POP AR3
        POP AR2 	; POP MUST BE IN REVERSE ORDER OF PUSH
        POP AR1
		POP AR0
        POP PSW
        RET
;-----------------------------------------read nibble------------------------------
readingNibbles:	
	setb p1.4			; Set pins P1.7-P1.4 (indication that routine is ready to accept input)
	setb p1.5
	setb p1.6
	setb p1.7
						;wait for 5 sec during which user can give input
	mov A,#5h
	lcall waiting
	
						;clear pins P1.4 to P1.7
	clr p1.4
	clr p1.5
	clr p1.6
	clr p1.7

	lcall readnibble	;read the input on P1.0-P1.3 (nibble)
	
	mov A,#1            ; variable for 1sec delay					
	lcall waiting			; wait for one sec
	
	mov A,r0			;show the read value on pins P1.4-P1.7
	swap A
	mov p1,A				
						
	mov A,#5			;wait for 5 sec
	lcall waiting	
						;clear leds 
	clr p1.4
	clr p1.5
	clr p1.6
	clr p1.7	
	ret	
						;read the input from switches
readnibble:
			setb p1.0		    
			setb p1.1	
			setb p1.2					
			setb p1.3
								; set pins 0-3 for configuring as input pins
			mov a,p1			; read value on pins
			anl a,#0Fh
			mov r0,a
			ret	
;----------------------------------------------------------------------
packNibble:
	using 0
	push ar0
	push ar1
	lcall readingNibbles
	;mov r0,#04h
	mov 01h,00h			; transfer from r0 to r1
	lcall readingNibbles
	;mov r0,#01h
	mov A,r1
	swap A
	ADD A,r0
	mov 4fh,A
	pop ar1
	pop ar0
	ret
;-----------------------------------------------------------------------------
reading:
	using 0
	push ar0
	push ar1
	mov r0,50h
	mov r1,51h
	back_read:
	lcall packNibble
	mov @r1,4fh
	inc r1
	djnz r0,back_read
	pop ar1
	pop ar0
	ret
;-------------------------------------------------------------------------------	
displayingValues:
	using 0
	push ar1
	  ;;----------------
	mov r2,50h
	read_loop:
		mov r1,51h			; pointer to array
		lcall readingNibbles
		; now r0 will have the value of input
		mov a,#0
		;dec r2
		clr c
		subb a,r2
		jnc	invalid_input
		;LCD ----valid input
		mov a,r0
		clr c
		addc a,r1
		mov r1,a
		mov a,@r1
		lcall bin2ascii
		mov a,52h
	    lcall lcd_senddata	   ;call data sending routine
	    lcall delay
		mov a,#2
		lcall waiting
		ljmp read_loop
	invalid_input:
		lcall lcd_clear
	pop ar1
	ret
;--------------------------------------------------------------------------------------------------------------------------------------------	
	bin2ascii:
	push 0
	push 1
	push 2
	push 3
	push 4
	push 5
	mov A,#1
	MOV R2,#1;------------------------------Load the number of numbers in R2
	MOV R0,A;------------------------------Load the starting location for reading in R1
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
		MOV 52h,A
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
		pop 5
		pop 4
		pop 3
		pop 2
		pop 1
		pop 0
RET
;;;;-----------------------------------------
;---------------------------------- MAIN ---------------------------------

;--------------------
main:
	mov 50h,#01h
	mov 51h,#60h
	start:
      mov P2,#00h
      mov P1,#00h
      	  lcall delay
		lcall delay
	  lcall lcd_init      ;initialise LCD
	  lcall delay
	  lcall delay
	  lcall delay
	  mov a,#82h		 ;Put cursor on first row,5 column
	  lcall lcd_command	 ;send command to LCD
	  lcall delay
	  
	;-------------------------  
	Lcall reading
	lCALL delay
	mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	  lcall lcd_sendstring	   ;call text strings sending routine
	  lcall delay
	  lcall delay
	  lcall lcd_clear
	LCALL displayingValues
	stop:sjmp stop
;---------------------------------------
org 500h
my_string1:
         DB   "displaying", 00H	
END	