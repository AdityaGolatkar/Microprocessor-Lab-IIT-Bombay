LED EQU P1.7

ORG 00H
LJMP MAIN

;--------------------------------------------------
DELAY:
	MOV A,4FH;---------------------------------Load the D in accumulator
	MOV B,#0AH;--------------------------------Load 10 in B
	MUL AB;------------------------------------AB will the number of time the 50ns loop must be run
	MOV R3,A
	BACK2:;------------------------------------50 ns loop is run 10D times to get correct delay between 2 blinking
		MOV R2,#200
		BACK1:
			MOV R1,#0FFH
			BACK:
				DJNZ R1,BACK
			DJNZ R2,BACK1
	DJNZ R3,BACK2
RET
;------------------------------------------------
MAIN:
		MOV 4FH,#08H
		SETB LED;------------------------Set the LED bit to 1
		LCALL DELAY
		CLR LED;-------------------------Set the LED bit to 0
		LCALL DELAY
		SJMP MAIN
;------------------------------------------------
END
