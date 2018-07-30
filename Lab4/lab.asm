org 00h
ljmp main

main:

here:
	lcall funct
	sjmp here


funct:
	setb p1.7
	setb p1.6
	setb p1.5
	setb p1.4

	lcall delay5

	clr p1.7
	clr p1.6
	clr p1.5
	clr p1.4

	setb p1.3
	setb p1.2
	setb p1.1
	setb p1.0
	mov a,p1
	anl a,#0fh
	mov r2,a
	
	mov b,#0ah
	div ab
	jnz allup
	
	mov a,r2
	add a,#03h
	swap a
	mov p1,a
	lcall delay5
	lcall delay5
	ret	

	allup:
		mov p1,#0f0h
		lcall delay5
		lcall delay5
	ret

delay5:
	MOV R3,#64H		;run the code given to generate a delay of 50 ms 20 times
	back2:								
		MOV R4,#200 ;lines 61-66 generates a delay of 50 ms
		back1: 
			MOV R5,#0FFH 
			back: 
				DJNZ R5,back
			DJNZ R4,back1
		DJNZ R3,back2
RET
end

