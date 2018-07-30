/**
 SPI HOMEWORK2 , LABWORK2 (SAME PROGRAM)
 */

/* @section  I N C L U D E S */
#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);
void int_to_string(int val,char *arr);

sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit ONULL = P1^0;
sbit p = P1^1;
bit transmit_completed= 0;					// To check if spi data transmit is complete
bit offset_null = 0;								// Check if offset nulling is enabled

char * msg = "if you are good ";
sbit switchPin = P1^3;
int prevSwitchVal = 0, currSwitchVal = 0;
int cmdPos = 0x080;

void ISR_Serial(void) interrupt 4 {
//ISR for serial interrupt
	if(RI == 1){
		char tmp = SBUF;
		RI = 0;
		LCD_CmdWrite(cmdPos);
		cmdPos++;
		LCD_DataWrite(tmp);
	}
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

int check_switch() {
//function to check switches after every 500ms
	if(switchPin == 1){
		currSwitchVal = 1;
	}
	else{
		currSwitchVal = 0;
	}
	if(currSwitchVal != prevSwitchVal){
		prevSwitchVal = currSwitchVal;
		return 1;
	}
	else{
		prevSwitchVal = currSwitchVal;
		return 0;
	}
}

void transmit_data(char * str) {
//function to transmit data over TxD pin.
	int i;
	for(i = 0; i < 16; i++){
		ACC = *str;
		ACC = ACC + 0;
		TB8 = PSW^0;
		SBUF = *str;
		str++;
		while(1){
			if(TI == 1){
				TI = 0;
				break;
			}
		}
	}
}

void main() { 
	LCD_Init();
	init_serial();
	REN = 1;
	while(1) {
		//check switch value
		//if unequal 
		// transmit data
		if(check_switch() == 1){
			transmit_data(msg);
			LCD_CmdWrite(0x0C0);
			LCD_StringWrite(msg,16);
		}
		delay_ms(500);
	}
}

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
void LCD_StringWrite( char * str, unsigned char length)
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

/** Function to obtain string form representation of an integer value
 */
void int_to_string(int val,char *arr)
{
	int index = 3;
	while(index>=0)
	{	
		int r = val%10;
		arr[index--] = r + 48;
		val = val/10;
	}
}