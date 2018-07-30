; Defining Timer-2 registers
T2CON			DATA	0C8H
T2MOD 		DATA 	0C9H
RCAP2L 		DATA	0CAH
RCAP2H 		DATA	 0CBH
TL2 				DATA	 0CCH
TH2	 			DATA	 0CDH
; Defining interrupt enable (IE) bit
ET2 				BIT		 0ADH
; Defining interrupt priority (IP) bit
PT2				BIT		 0BDH
; Defining P1
T2EX			BIT		 91H
T2				BIT		 90H
; Defining timer control (T2CON) register bits
TF2				BIT		 0CFH
EXF2			BIT		 0CEH
RCLK			BIT		 0CDH
TCLK			BIT		 0CCH
EXEN2			BIT		 0CBH
TR2		 		BIT		 0CAH
C_T2			BIT		 0C9H
CP_RL2 		BIT		 0C8H

;================================================
ORG 0000H
	LJMP MAIN
	
org 0003h
ljmp ext_interrupt

org 000bh
ljmp	timer_interrupt


ORG 002BH
	ljmp ISR
ORG 0100H
;================================================

ISR:
	clr tf2;
	cpl t2;
	mov c,t2;
	mov P3.2, c;
reti

timer_interrupt:				;interrupt for the timer
	inc r0
reti

ext_interrupt:					;interrupt for the external signal
	clr tr0						;all the displaying is done in this block of code........
	;clr ea
	;mov 50h,th0
	;mov 60h,tl0
	;lcall display
	mov a,#0c9h
	acall lcd_command
	acall delay
	
	mov a,r0					;displaying the number of times the counter has overflowed
	mov r2,a
	acall bin2ascii
	mov a,r6
	acall lcd_senddata
	mov a,r7
	acall lcd_senddata
	
	mov a,th0					;displaying the value in TH0
	;mov a,50h	
	clr c
	;add a,th0
	mov r2,a
	acall bin2ascii
	mov a,r6
	acall lcd_senddata
	mov a,r7
	acall lcd_senddata
	
	mov a,tl0					;displaying the value in TL0
	;mov a,60h
	clr c
	;add a,tl0
	mov r2,a
	acall bin2ascii
	mov a,r6
	acall lcd_senddata
	mov a,r7
	acall lcd_senddata
reti
;==========================================================

;Timer-2 initialization
T2_INIT:
MOV T2MOD,#00H
CLR EXF2;
/* Next, disable baud rate generator */
/* Next. ignore events on T2EX */
;Initialize values in TH2, TL2 depending on required frequency
MOV TH2,#0D8H;					/* Init msb_value */
MOV TL2,#0F0H; 					/* Init lsb_value */
;Reload values in RCAP
MOV RCAP2H,#0D8H;	 			/* reload msb_value */
MOV RCAP2L,#0F0H;				/* reload lsb_value */
CLR	C_T2;					/* timer mode */
CLR CP_RL2;				/* reload mode */
SETB ET2;					/* clear timer2 interrupt */
SETB EA;
SETB TR2;
RET

;=============================================================
pulseWidth:
	mov r0,#00h
	mov tmod,#09h		;set the gate bit of the timer 0 and set the timer in mode 1
	setb it0					;set the edge type to falling edge triggered
	setb tr0
	setb et0				;set the interrupt for the timer 0
	setb ex0				;set the external interrupt 0
	setb ea					;enable the global interrupt enable bit
	;stay: cjne,r0,#00h,stay
	mov a,tmod			
	anl a,#08h
	;stayhere: jz stayhere
	waiting: jnb ie0,waiting
ret

delay:	 					;implements delay
	push 0
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
		 
;====================================================================
org 300h
my_string1:
         DB   "PULSE WIDTH", 00H
my_string2:
		 DB   "COUNT IS", 00H

;--------------- MAIN STARTS HERE --------------------
MAIN:
;Port initialization
;clr p3.2;
;==============================================
acall lcd_init
	mov a,#84h		 ;Put cursor on first row,5 column
	acall lcd_command	 ;send command to LCD
	acall delay
	mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	acall lcd_sendstring	   ;call text strings sending routine
	acall delay
	
	mov a,#0C0h		  ;Put cursor on second row,3 column
	acall lcd_command
	acall delay
	mov   dptr,#my_string2
	acall lcd_sendstring
	lcall delay

;===================================================

LCALL T2_INIT

;stay : JNB TF2,stay
;	clr tf2;
;	cpl t2;
;sjmp stay

ljmp pulseWidth

OVER: SJMP OVER
END
