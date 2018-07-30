#include "at89c5131.h"
#include "stdio.h"

void ISR_Serial(void) interrupt 4 {
//ISR for serial interrupt
	TI = 0;
	ACC = 'A';
	ACC = ACC + 0;
	TB8 = PSW^0;
	SBUF = 'A';
}

void init_serial() {
//Initialize serial communication and interrupts 
	TMOD = 0x20;
	TH1 = -52;
	EA = 1;
	ES = 1;
	ET1 = 0;
	SCON = 0x0C0;
	TR1 = 1;
	//REN = 1;
}

void main() {
	ACC = 'A';
	ACC = ACC + 0;
	TB8 = PSW^0;
	init_serial();
	SBUF = 'A';
	while(1);
}
