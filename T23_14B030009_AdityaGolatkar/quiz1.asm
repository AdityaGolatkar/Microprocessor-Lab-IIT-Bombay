;Aditya Golatkar
;14B030009
;Quiz prob 1

org 0000h
ljmp main

signedmult:
mov r0,70h	;store the first number in r0
mov r1,71h	;store the second number in r1

mov a,r0		;storing the last 7 bits of first number in r0
anl a,#01111111b	
mov r0,a

mov a,r1		;storing the last 7 bits of second number in r1
anl a,#01111111b
mov r1,a

mov a,r0		;multiply the two numbers 
mov b,r1
mul ab
mov 72h,a		;store the lsb in 72h

mov a,70h		;get the ms bit of the first number
anl a,#10000000b
mov r0,a

mov a,71h		;get the ms bit of the second number
anl a,#10000000b
mov r1,a

mov a,r0	
xrl a,r1			;xor the msbits of the two numbers 
clr c
add a,b			;add the xored result to the msb of multiplication
mov 73h,a		;store the result in 73h

main:
mov 70h,#0b6h	;giving first number here
mov 71h,#91h	;giving second number here
lcall signedmult
here :sjmp here
end