#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_WriteString(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);
void init_serial();																							//Initialize the serial port
int check_switch();
void transmit_data();

sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag

int index_send = 0;
int index_rec = 0;
int printpos = 0x80;
char *data_sen = "WHY DO WE FALL  ";
void serial ();
void ISR_Serial(void) interrupt 4											//ISR routine for the serial interrupt	
{
		serial();
}

void serial()
{
	/*if(TI == 1)
		{
			TI = 0;
			if(index_send<=15)
			{
				ACC = data_sen[index_send];
				ACC = ACC + 0;
				TB8 = PSW^0;
				SBUF = data_sen[index_send];
				index_send ++;
			}
		}
	*/
			if(RI == 1)
			{
					char data_rec = SBUF;
				/*	if(printpos==0x90)
					{	
						printpos = 0x80;
					}
				*/
					LCD_CmdWrite(printpos);
					printpos++;
					//LCD_WriteString(data_rec,1);
				  LCD_DataWrite(data_rec);
					RI = 0;
			}
}
void init_serial()
{
	TMOD = 0x20;
	TH1 = -52;
	SCON = 0x0c0;
	ES = 1;
	ET1 = 0;
	EA = 1;
	//TI = 0;
	//RI = 0;
	//REN = 1;
	TR1 = 1;
}

int check_switch()
{
	bit a = P1_0;
	delay_ms(500);
	if(a!=P1_0)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

void transmit_data()
{
	int ctr;
	char *data_temp = data_sen;
	for(ctr = 0; ctr < 16; ctr++){
		ACC = *data_temp;
		data_temp++;
		ACC = ACC + 0;
		TB8 = PSW^0;
		SBUF = ACC;
		while(1){
			if(TI == 1){
				TI = 0;
				break;
			}
		}
	}
	LCD_CmdWrite(0x0C0);
	LCD_WriteString(data_sen,16);
}

void main(void)
{
			/*P3_0 = 1;
			P3_1 = 0;
			P2 = 0x00;											// Make Port 2 output 
  		*/
			LCD_Init();
			init_serial();
			REN = 1;
		
			while(1)
			{
				if(check_switch())
				{
					transmit_data();
					
				}
			}
}

//================================================LCD FUNCITONS================================================

/**
 * FUNCTION_PURPOSE:LCD Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Init()
{
  sdelay(100);
  LCD_CmdWrite(0x38);   	// LCD 2lines, 5*7 matrix
  LCD_CmdWrite(0x0E);			// Display ON cursor ON  Blinking off
  LCD_CmdWrite(0x01);			// Clear the LCD
  LCD_CmdWrite(0x80);			// Cursor to First line First Position
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: cmd- command to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_CmdWrite(char cmd)
{
	LCD_Ready();
	LCD_data=cmd;     			// Send the command to LCD
	LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
  LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
  LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: dat- data to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_DataWrite( char dat)
{
	LCD_Ready();
  LCD_data=dat;	   				// Send the data to LCD
  LCD_rs=1;	   						// Select the Data Register by pulling LCD_rs HIGH
  LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
  LCD_en=1;	   						// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}
/**
 * FUNCTION_PURPOSE: Write a string on the LCD Screen
 * FUNCTION_INPUTS: 1. str - pointer to the string to be written, 
										2. length - length of the array
 * FUNCTION_OUTPUTS: none
 */
void LCD_WriteString( char * str, unsigned char length)
{
    while(length>0)
    {
        LCD_DataWrite(*str);
        str++;
        length--;
    }
}

/**
 * FUNCTION_PURPOSE: To check if the LCD is ready to communicate
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Ready()
{
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{
		LCD_en = 0;
		LCD_en = 1;
	}
	LCD_en = 0;
}

/**
 * FUNCTION_PURPOSE: A delay of 15us for a 24 MHz crystal
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

/**
 * FUNCTION_PURPOSE: A delay of around 1000us for a 24MHz crystel
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}
	
