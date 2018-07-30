;Problem: Quiz Problem 2.c
;Author:Aditya Golatkar
;Roll No:14B030009

ORG 0000H
LJMP MAIN

compare:


findMax:
;transfering the input numbers to output locations
	mov 70H,50H
	mov 71H,51H
	mov 72H,52H
	mov 73H,53H
	mov 74H,54H

	;mov r2,#01H	;register r2 determines the number of times the outer loop iterates
	
	
	loop1: 
			mov r0,#70H		;r0 is used to point to the location of the first number
			mov r1,#04H		;register r1 determines the number of times the inner loop iterates
	loop2:
			mov A,@r0		;load the number pointed by r0 in the accumulator
			inc r0				;increment the r0
			clr c
			
			mov r2,a			;store the first number in r2 and r5
			mov r5,a
			mov a,@r0
			mov r7,a			;store the second number in r6,r7
			mov r6,a
	
			mov a,r5
			anl a,#80h			;get the msbit of first number
			mov r5,a
			
			mov a,r6
			anl a,#80h			;get the msbit of the second number
			mov r6,a
			
			mov a,r5
			xrl a,r6				;xor the msbits of the first and the second number ,, if the result is 1 then it means one of them is negative and one is positive
			jnz diffsign			;if its not zero jump to different sign
			
			mov a,r2			;since the signs are same larger the 2s complement value larger is the number .... so we follow the steps done below
			
			;next 3 lines are for comparing the two numbers
			subb A,@r0		;subtract the number from its next number
			jc loop3				;if the result is negative then first number is lesser than the second number hence go to next iteration
			jz loop3				;if the result is equality then first number is equal to  the second number hence go to next iteration
									;else swap the two numbers
									
			;next remaining lines in loop2 are for swaping the two numbers
			mov A,@r0		
			mov r3,A			;store the first number in r3
			
			dec r0
			
			mov A,@r0
			mov r4,A			;store the second number in r4
			
			mov A,r3			;swap the two numbers
			mov @r0,A
			inc r0
			
			mov A, r4
			mov @r0,A
			
			sjmp loop3
			
		diffsign:					;the two numbers are of different sign.....so larger
			mov a,r2			;since the 2 nos have different signs larger 2s complement implies smaller number
			clr c
			subb a,r7			
			jnc loop3			;if there is no carry it means larger number is the first number else follow the code below
			
			mov a,@r0		;swap the two numbers
			mov r3,a
			dec r0
			mov a,@r0
			mov r4,a
			mov a,r3
			mov @r0,a
			inc r0
			mov a,r4
			mov @r0,a
			
	loop3:
			djnz r1,loop2			;decrement the register r1 and if its value is not zero then go to the next iteration for the inner loop
			;djnz r2,loop1			;decrement the register r2 and if its value is not zero then go to the next iteration for the outer loop

	mov 55h,74h
RET

INIT:
;intializing the memory locations with numeric values
	mov 50H,#00H
	mov 51H,#12H
	mov 52H,#0f4H
	mov 53H,#0bcH
	mov 54H,#54H

RET

INIT1:
;intializing the memory locations with numeric values
	mov 50H,#15H
	mov 51H,#15H
	mov 52H,#78H
	mov 53H,#84H
	mov 54H,#02H

RET

INIT2:
;intializing the memory locations with numeric values
	mov 50H,#0a1H
	mov 51H,#0ffH
	mov 52H,#92H
	mov 53H,#0c9H
	mov 54H,#0e6H

RET

ORG 0100H
MAIN:
	MOV SP,#0C0H	;move stack pointer to indirect RAM location
	;ACALL INIT
	;ACALL INIT1
	ACALL INIT2
	
	ACALL findMax
	repeat: sjmp repeat
END
