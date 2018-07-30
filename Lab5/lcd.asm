; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start


	
org 200h
start:
      mov P2,#00h
      mov P1,#00h
	  ;initial delay for lcd power up
;	  acall init_course
	  acall init_name
	;here1:setb p1.0
      	  acall delay
	;clr p1.0
	  acall delay
	;sjmp here1


	  acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
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
	  

here: sjmp here				//stay here 

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
	 
init_name:
		push 0
		mov r0,#80h
		mov @r0,#41h
		inc r0
		mov @r0,#44h
		inc r0
		mov @r0,#49h
		inc r0
		mov @r0,#54h
		inc r0
		mov @r0,#59h
		inc r0
		mov @r0,#41h
		inc r0
		;mov 50h,#41h
		;mov 51h,#44h
		;mov 52h,#49h
		;mov 53h,#54h
		;mov 54h,#59h
		;mov 55h,#41h
		pop 0
		ret

disp_name:
	mov r0,#80h
	mov r1,#6h
	disp_back:
	mov a,@r0
	acall lcd_senddata
	inc r0
	djnz r1,disp_back	
	ret
	
;init_course:
;		mov 56h,#45h
;		mov 57h,#45h
;		mov 58h,#20h
;		mov 59h,#33h
;		mov 60h,#33h
;		mov 61h,#37h
;		mov 62h,#2Dh
;		mov 63h,#4Ch
;		mov 64h,#41h
;		mov 65h,#42h
;		mov 66h,#20h
;		mov 67h,32h
;		ret
;
;disp_course:
;	mov r0,#56h
;	mov r1,#12
;	disp_back1:
;	mov a,@r0
;	acall lcd_senddata
;	inc r0
;	djnz r1,disp_back1	
;	ret

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "EE 337-LAB 2", 00H
my_string2:
		 DB   "ADITYA ", 00H
end

