;Problem: Quiz 2.a
;Author:Aditya Golatkar
;Roll No:14B030009

ORG 0000H
LJMP MAIN

findMax:
;transfering the input numbers to output locations
	mov 70H,50H
	mov 71H,51H
	mov 72H,52H
	mov 73H,53H
	mov 74H,54H

	;mov r2,#04H	;register r2 determines the number of times the outer loop iterates
	
	;BUBBLE SORTING IS USED HERE
	loop1: 
			mov r0,#70H		;r0 is used to point to the location of the first number
			mov r1,#04H		;register r1 determines the number of times the inner loop iterates
	loop2:
			mov A,@r0		;load the number pointed by r0 in the accumulator
			inc r0				;increment the r0
			clr c
			
			;next 3 lines are for comparing the two numbers
			subb A,@r0		;subtract the number from its next number
			jc loop3				;if the result is negative then first number is lesser than the second number hence go to next iteration
			jz loop3				;if the result is equality then first number is equal to  the second number hence go to next iteration
									;else swap the two numbers
									
			;next remaining lines in loop2 are for swaping the two numbers
			mov A,@r0
			mov r3,A
			
			dec r0
			
			mov A,@r0
			mov r4,A
			
			mov A,r3
			mov @r0,A
			inc r0
			
			mov A, r4
			mov @r0,A

	loop3:
			djnz r1,loop2			;decrement the register r1 and if its value is not zero then go to the next iteration for the inner loop
			;djnz r2,loop1			;decrement the register r2 and if its value is not zero then go to the next iteration for the outer loop
		
		mov 55h,74h
RET

INIT:
;intializing the memory locations with numeric values
	mov 50H,#02H
	mov 51H,#01H
	mov 52H,#0fbH
	mov 53H,#05H
	mov 54H,#04FH

RET

ORG 0100H
MAIN:
	MOV SP,#0C0H	;move stack pointer to indirect RAM location
	ACALL INIT
	ACALL findMax
	repeat: sjmp repeat
END
