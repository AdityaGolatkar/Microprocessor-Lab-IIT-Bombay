org 0000h
ljmp main

org 000bh				;interrupt handler vector location for timer 0 interrupt
ljmp interrupt			;ljmp to interrupt

org 100h

interrupt:	
		dec r0				;just decrement the value stored in r0
		cjne r0,#01h,finish
		clr tr0
		mov th0,#07ah
		mov tl0,#0ffh
		setb tr0		
finish:
reti

delayGen:
	mov tmod,#01h	;initialize the timer in mode 1
	setb tr0				;start the timer
	setb et0			;set the interrupt corresponding to timer0
	setb ea				;set the global interrupt enable
	stay: cjne r0,#00h,stay	;this is done to ensure 1fh overflows happen which gives a total of 1 second
	
ret

main:
mov r0,#1fh			;store the r0 the number of times overflows must happen to get a delay of 1 second
lcall delayGen
here: sjmp here

end