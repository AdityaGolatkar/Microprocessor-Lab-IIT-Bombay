org 00H

ljmp main


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
READ_NIBBLE:	
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
			mov p1,#0Fh
			mov a,p1			; read value on pins
			anl a,#0Fh
			mov r0,a
			ret	
;----------------------------------------------------------------------
packNibble:
	using 0
	push ar0
	push ar1
	lcall READ_NIBBLE
	;mov r0,#04h
	mov 01h,00h			; transfer from r0 to r1
	lcall READ_NIBBLE
	;mov r0,#01h
	mov A,r1
	swap A
	ADD A,r0
	mov 4fh,A
	pop ar1
	pop ar0
	ret

;================================================================================

readValues:
	push 2		;push register 2
	push 1		;push register 1
	mov R2,50H	;move the number of values that need to be read in R2
	mov R1,51H	;move the starting location of the destination array in R1
reading:
	lcall packNibble	;call packNibbles to read 8 bit number from the port
	mov @R1,4FH		;this number is stored in 4FH , copy that to the location pointed by R1
	inc R1					;increment R1 to make it point to the next location
	djnz R2,reading		;decrement R2 to ensure this process takes place K times where K is the number stored in 50H
	pop 1					;pop register 1
	pop 2					;pop register 2
RET

;================================================================================

main:
	mov 50H,#3
	mov 51H,#61H
	lcall readValues
stop: 	sjmp stop

end
