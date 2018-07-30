org 0000h
ljmp main

org 100h

;when the timer runs 46079 it gives a delay of 1/20 of a second....so we need to run this 20 times
;so 65535-46079 = 19456 which in hex is 4c00h
delayGen:
	mov tmod,#01h
	mov th0,#00h
	mov tl0,#00h
	setb tr0
overflow:	
	jnb tf0,$
	clr tf0
	djnz r0,overflow
	clr tf0
	clr tr0
	mov th0,#07ah
	mov tl0,#0ffh
	setb tr0
	jnb tf0,$
	ret
	

main:
mov r0,#1eh
lcall delayGen		;calling function here
here:sjmp here
end