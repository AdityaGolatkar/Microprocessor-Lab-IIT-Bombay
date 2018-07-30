;Quiz 2.b
;Aditya Golatkar
;14B030009


org 0000h
	
ljmp main

check:
mov a,50h		;move the number in a
anl  a,#80h	;get the msbit of the number

jz pos			;if it is zero it is positive hence jump and store 1

mov 56h,#02h	;else store 2

sjmp ending

pos:
	mov 56h,#01h		;store 1 since its positive

ending:
ret

main:

mov 50h,#05h		;store the number
lcall check		;call check
here :sjmp here

end