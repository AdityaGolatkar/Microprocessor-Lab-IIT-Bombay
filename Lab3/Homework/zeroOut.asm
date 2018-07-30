ORG 00H
LJMP MAIN
;-----------------------------------
zeroOut:
	MOV R2,50H;-----------------Load in R2 the number of locations that need to be cleared
	MOV R1,51H;-----------------Load in R1 the starting location of the location to be cleared
	CLEAR:;---------------------Run the clearing loop R2 times to clear locations
		MOV @R1,#00H;-------Clearing is done by initializing the value at location stored by R1 to 00H
		INC R1
		DJNZ R2,CLEAR

RET
;----------------------------------
MAIN:
	;MOV 50H,#5
	;MOV 51H,#60H
	;MOV 60H,#10H
	;MOV 61H,#10H
	;MOV 62H,#10H
	;MOV 63H,#10H
	;MOV 64H,#20H
	;MOV 65H,#30H
	ACALL zeroOut
	LOOP: SJMP LOOP
;---------------------------------
END


