/********************************************************************

			Tiva LaunchPad (TM4C123GH6PM) Bare Matel Programming Demo

												BLINKY LED (RED)
********************************************************************/


#include <tm4c123gh6pm.h>
#include <stdint.h>

#define GPIO_PORTF_DATA_REG						*(volatile uint32_t *)0x400253FC		
#define GPIO_PORTF_DIR_REG						*(volatile uint32_t *)0x40025400		
#define GPIO_PORTF_AFSEL_REG					*(volatile uint32_t *)0x40025420		
#define GPIO_PORTF_PUR_REG						*(volatile uint32_t *)0x40025510		
#define GPIO_PORTF_DEN_REG						*(volatile uint32_t *)0x4002551C		
#define GPIO_PORTF_LOCK_REG						*(volatile uint32_t *)0x40025520		
#define GPIO_PORTF_CR_REG							*(volatile uint32_t *)0x40025524		
#define GPIO_PORTF_AMSEL_REG					*(volatile uint32_t *)0x40025528		
#define GPIO_PORTF_PCTL_REG						*(volatile uint32_t *)0x4002552C
	
/*
BUS CONTROL REGISTER
		0:	USE APB BUS
		1:	USE AHB BUS
Bits:
		Bit-0 (R/W):	PORTA
		Bit-1 (R/W):	PORTB
		Bit-2 (R/W):	PORTC
		Bit-3 (R/W):	PORTD
		Bit-4 (R/W):	PORTE
		Bit-5 (R/W):	PORTF
*/
#define GPIO_HBCTL_REG								*(volatile uint32_t *)0x400FE06C

/*
BUS CLOCK CONTROL REGISTER
		0:	DISABLE CLOCK TO PORT
		1:	ENABLE CLOCK TO PORT
Bits:
		Bit-0 (R/W):	PORTA
		Bit-1 (R/W):	PORTB
		Bit-2 (R/W):	PORTC
		Bit-3 (R/W):	PORTD
		Bit-4 (R/W):	PORTE
		Bit-5 (R/W):	PORTF
*/
#define GPIO_RCGC_REG									*(volatile uint32_t *)0x400FE608

/*
	Function Prototypes
*/
void init_GPIOF(void);
void delay (uint32_t count);

int main (void) {
	
	init_GPIOF();
	while (1) {
		GPIO_PORTF_DATA_REG = 0x00;
		delay(5000);
		GPIO_PORTF_DATA_REG = 0x02;
		delay(5000);
	}
	
}

void init_GPIOF(void) {
	GPIO_HBCTL_REG &= ~(1UL << 4);				//Use APB bus for GPIOF
	GPIO_RCGC_REG |= 0x020;								//enable clock to GPIOF
	delay(1);															//allow clock to stablize
	GPIO_PORTF_LOCK_REG		= 0x4C4F434B;		//Unlock GPIOCR Register for write access
	GPIO_PORTF_CR_REG			= 0x1F;					//Unlock GPIOAFSEL, GPIOPUR, GPIOPDR, or GPIODEN bits to be written
	GPIO_PORTF_DIR_REG 		= 0x0E;					//PF3-1	Output, PF0,PF4 Input
	GPIO_PORTF_AFSEL_REG	= 0x00;					//Disable alternate function on all PORTF pins
	GPIO_PORTF_PCTL_REG 	= 0x00000000;		//GPIO function on PCTL
	GPIO_PORTF_PUR_REG 		= 0x1F;					//Pullup all Pins
	GPIO_PORTF_DEN_REG		= 0x1F;					//Enable Digital I/O function of all PORTF pins
	GPIO_PORTF_AMSEL_REG	= 0x00;					//Disable analogue functions on PORTF pins
}

void delay (uint32_t count) {
	int i,j;
	for (i = 0;  i < count; i++)
		for (j = 0; j < 500; j++);
}
