#include<at89c5131.h>

void timer2_init();
void external_init();
void pwm_setup (int duty_cycle);
void serial_init(int baud_rate);//use 8 b i t UART
void delay (int k);
void serial_send (char dat) ;
void serial_send_string(char *str) ;
int measure_rpm ( ) ;
void int_to_string(int val,char *arr);

// Defining Timer-2 registers
sfr T2CON = 0C8H;
sfr T2MOD = 0C9H;
sfr RCAP2H = 0CBH;
sfr TL2 = 0CCH;
sfr TH2 = 0CDH;
//Defining interrupt enable (IE) bit
sbit ET2 = 0ADH;
//Defining interrupt priority (IP) bit
sbit PT2	= 0BDH;
//Defining P1
sbit T2EX = 91H;
sbit T2	= 90H;
// Defining timer control (T2CON) register bits
sbit TF2 = 0CFH;
sbit EXF2 = 0CEH;
sbit RCLK = 0CDH;
sbit TCLK = 0CCH;
sbit EXEN2 = 0CBH;
sbit TR2 = 0CAH;
sbit C_T2 = 0C9H;
sbit CP_RL2 = 0C8H;

int pwm_width=50; // 0 t o 100
int on=0,off = 0,ct=0,t2ct=0;
sbit pin = P1^4;

void external_ISR(void) interrupt 0
{
	ct++;
}

void timer0(void) interrupt 1
{
	if(pin)
	{
		pin = 0;
		TH0 = off>>256;
		TL0 = off%256;
	}
	else
	{
		pin = 1;
		TH0 = on>>256;
		TL0 = on%256;	
	}
}

void serial_read(void) interrupt 4
{
	ES =0;
	if(RI)
	{
		RI =0;
		pwm_width = SBUF;
		pwm_setup(pwn_width);
	}
	ES=1;
}

void timer2_ISR (void) interrupt 5
{
	TF2 = 0;
	t2ct++;
}

void main ()
{
	pin = 0;
	int rpm=0;
	pwm_setup(pwm_width) ; // d e f a u l t 50% d u t y c y c l e
	serial_init(9600); // b a u d r a t e =9600 d e f a u l t
	while (1)
	{
	rpm = measure_rpm() ;
	
	//motor ’ s RPM i s more than 255 , So we need t o send 16 b i t s
	
	serial_send_string(”INPUT : ”);
	serial_send(pwm_width) ;
	serial_send_string(” ,RPM: ”);
	serial_send(rpm/8) ; // send Higher 8 b i t s o f rpm
	// t o Terminal /UART
	serial_send(rpm%256) ; // send Lower 8 b i t s o f rpm
	// t o Terminal /UART
	}
}

int measure_rpm()
{
	external_init();
	timer2_init();
	while(1)
	{
		if(t2ct==33)
		{
			TR2 = 0;
			t2ct = 0;
			ET2 = 0;
			EX0 = 0;

			return (ct/30);
		}
	}
}


void serial_send_string(char*str)
{
	while(*str!='\0')
	{
		SBUF = *str;
		str++;
		while(1)
		{
			if(TI == 1){
				TI = 0;
				break;
			}
		}
		
	}
}

void serial_send(char dat)
{
	SBUF = dat;
	while(1)
	{
		if(TI == 1)
		{
			TI = 0;
			break;
		}
	}
}


void delay(int k)						//delay in ms
{
	int d=0;
	while(k>0)
	{
		for(d=0;d<382;d++);
		k--;
	}
}

void pwn_setup(int duty_cycle)
{
	on = 65536-(0.6*duty_cycle*1000);
	off = 65536-(0.6*(100-duty_cycle)*1000);
	TMOD = 0x01;
	TH0 = on>>8;
	TL0 = on%256;
	ET0 = 1;
	EA = 1;
	TR0 = 1;
}

void timer2_init()
{
	EA = 1;
	T2MOD = 0x00;
	EXF2 = 0;
	RCLK = 0;
	TCLK = 0;
	EXEN2 = 0;
	TH2 =0x15;
	TL2 = 0x0A0;
	RCAP2H = 0x15;
	RCAP2L = 0x0A0;
	C_T2 = 0;
	CP_RL2 = 0;
	ET2 = 1;
	TR2 = 1;
}

void external_init()
{
	EA = 1;
	IT0 = 1;
	EX0 = 1;
}


void serial_init(int baud_rate)
{
	TMOD |= 0x20;
	TMOD &= 0x2F;
	TH1 = 256-(24000000/(384*baud_rate));
	EA = 1;
	ES = 1;
	ET1 = 0;
	SCON = 0x50;
	TR1 = 1;
}

void int_to_string(int val,char *arr)
{
	int pos = 3;
	int rem;
	while(pos>=0)
	{	
		rem = val%10;
		arr[pos] = rem + 48;
		val = val/10;
		pos--;
	}
}


