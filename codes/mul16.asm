MOV R1,MSB1
MOV R2,MSB2
MOV R3,LSB1
MOV R4,LSB2

MOV A,R3
MOV B,R4
MUL AB
MOV 20H,A
MOV 21H,B

MOV A,R3
MOV B R2
MUL AB
MOV 22H,B
ADDC A,21H
MOV 21H,A

MOV A,R1
MOV B,R4
MUL AB
ADDC A,21H
MOV 21H,A
MOV A,B
ADDC A,22H
MOV 22H,A

MOV A,R1
MOV B,R2
MUL AB
ADDC A,22H
MO 22H,A
MOV A,B
ADDC A,#00H
MOV 23H,A
