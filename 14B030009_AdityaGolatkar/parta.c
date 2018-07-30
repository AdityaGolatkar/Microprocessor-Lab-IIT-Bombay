#include "at89c5131.h"
#include "stdio.h"

void Timer_Init();

sbit pin = P3^0;


void timer0_ISR (void) interrupt 1
{
	//Initialize TH0
	//Initialize TL0
	//Increment Overflow 
	//Write averaging of 10 samples code here
	//TL0 = 0x9C;
	//TL0 = 0x0F4;
	//TL0 = 0x0D5;
	//TH0 = 0x0FF;
	pin = ~pin;
}

void main(void)
{
	Timer_Init();
	while(1);
}



void Timer_Init()
{
	// Set Timer0 to work in up counting 16 bit mode. Counts upto 
	// 65536 depending upon the calues of TH0 and TL0
	// The timer counts 65536 processor cycles. A processor cycle is 
	// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
    
	//Initialize TH0
	//Initialize TL0
	//Configure TMOD 
	//Set ET0
	//Set TR0
	TMOD = 0x02;
	//TL0 = 0x9C;
	//TH0 = 0x0FF;
	TH0 = 0x09C;
	TL0 = 0x09C;
	//TH0 = 0x0CE;
	//TL0 = 0x0CE;
	//TH0 = 0x0EC;
	//TL0 = 0x0EC;
	//TL0 = 0x0D5;
	EA = 1;
	ET0 = 1;
	TR0 = 1;
}