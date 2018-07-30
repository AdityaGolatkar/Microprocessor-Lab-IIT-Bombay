org 00h
	ljmp main
;-----------------------------------------------------------------------------------------------------------------------------------
waiting:
	MOV A,4FH;---------------------------------Load the D in accumulator
	MOV B,#0AH;--------------------------------Load 10 in B
	MUL AB;------------------------------------AB will the number of time the 50ns loop must be run
	Push 3
	Push 2
	Push 1
	MOV R3,A
	BACK2:;------------------------------------50 ns loop is run 10D times to get correct delay between 2 blinking
		MOV R2,#200
		BACK1:
			MOV R1,#0FFH
			BACK:
				DJNZ R1,BACK
			DJNZ R2,BACK1
	DJNZ R3,BACK2
	Pop 1
	Pop 2
	Pop 3
RET
;--------------------------------------------------------------------------------------------------------------------------
readNibble:
	mov A,P1
	anl A,#0FH
	mov R4,A
RET
;------------------------------------------------------------------------------------------------------------------------	

org 100h
main:
	sjmp loop

display_old:
	mov A,R4
	mov A,P1			;load P1 in A
	anl A,#0FH		;get the last four bits of P1 i.e. the nibble
	mov B,A;			;store the last four bits in B
	mov A,4EH		;load the nibble stored in 4EH in A
	swap A				;swap the nibbles in A
	add A,B			;Add A to B to show that both the nibbles are the same i.e. the higher nibble of P1 is set to the lower nibble
	mov P1,A			;Load A in P1
	mov 4FH,#0AH	;Load 10 at 4FH location to wait for 5 seconds
	lcall waiting		;calling the waiting function
	
	lcall readNibble
	
	clr C					;clear the carry bit
	subb A,#0FH		;subtract 0FH from A to check if A equals to 0FH

	JZ display_old	;if A equals to 0FH then go to display_old or else go to value_changed
	JNZ value_changed

loop:
	mov A,P1 			;load P1 in A
	anl A,#0FH		;get the last four bits of P1 in A
	add A,#0F0H		;add #10H, to set the upper nibble to #FH
	mov P1,A			;move this to P1
	mov 4FH,#0AH	;move 10 to 4FH so that waiting gives a delay of 5 seconds			
	lcall waiting		;wait for 5 sec during which user can give input 
	
	;During this period the user can change the values of the last four bits of of P1
	
	mov A,P1 			;load P1 in A
	anl A,#0FH		;clearing the upper nibble of P1
	mov P1,A			;moving it back to P1
	mov 4FH,#02H	;move 2 to 4FH so that waiting gives a delay of 1 second			
	lcall waiting		;wait for one sec

	lcall readNibble 	;read the input on P1.0-P1.3 (nibble)

value_changed:
	mov A,R4
	anl A,#0FH		;show the read value on pins P1.4-P1.7
	mov B,A			;store the last four bits of P1 in B
	mov 4EH,A		;store the last four bits of P1 in 4EH
	swap A				;swap the nibbles of A so that the upper nibble now has the read value and lower nibble is 0H
	add A,B			;add A and B so that the upper and lower nibble are the same i.e the the lower nibble is displayed on the upper nibble
	mov P1,A			;move A to P1
	mov 4FH,#0AH	;wait for 5 sec 
	lcall waiting
	
	mov A,P1			;clear leds
	anl A,#0FH		;make the upper nibble of P1 0H
	mov P1,A			;load A back to P1
	mov 4FH,#02H	;waiting for 1 second
	lcall waiting

	lcall readNibble
	
	clr C
	subb A,#0FH		;subtract 0FH to check if A equals 0FH
	JNZ value_changed
	JZ display_old
										
stop:
	sjmp stop
	
end
