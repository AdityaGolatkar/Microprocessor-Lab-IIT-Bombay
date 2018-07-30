#include "at89c5131.h"
#include "stdio.h"

void serial_interrupt();
void ISR_Serial(void) interrupt 4											//ISR routine for the serial interrupt	
{
		serial_interrupt();
}

void serial_interrupt()
{
			P0_0 = ~ P0_0;
			ACC = 0x0ab;
			ACC = ACC + 0;
			TB8 = PSW^0;
			SBUF = 0x0ab;
			TI = 0;
}

void init_serial()
{
	
	TMOD = 0x20;
	TH1 = -52;
	EA = 1;
	ES = 1;
	ET1 = 0;
	SCON = 0x0c0;
	TR1 = 1;
	
}

	void main(void)
{
			
	    //P3_1 =  0;
			ACC = 0x0ab;
			ACC = ACC + 0;
			TB8 = PSW^0;
			init_serial();
	    SBUF = 0x0ab;
			while(1);
}




	
