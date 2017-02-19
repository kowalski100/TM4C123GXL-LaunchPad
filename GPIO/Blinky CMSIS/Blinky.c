
/*********************************************************************

			Tiva LaunchPad (TM4C123GH6PM) Bare Matel Programming Demo

                        BLINKY LED (GREEN)
                        
  This Project uses CMSIS-CORE Library to Program GPIO on Launch Pad
          Green LED blinks continuously on Tiva Launchpad
*********************************************************************/


#include <tm4c123gh6pm.h>
#include <stdint.h>


/*
	Function Prototypes
*/
void init_GPIOF(void);
void delay (uint32_t count);


int main (void) {
  
  init_GPIOF();
	while (1) {
    GPIOF->DATA = 0x00;
		delay(1024);
		GPIOF->DATA = 0x08;
		delay(1024);
	}
}

void init_GPIOF(void) {
  
	SYSCTL->GPIOHBCTL       &= ~(1UL << 4);		//Use APB bus for GPIOF
  SYSCTL->RCGC2           |= 0x020;					//enable clock to GPIOF
	delay(1);															    //allow clock to stablize
	GPIOF->LOCK		          = 0x4C4F434B;     //Unlock GPIOCR Register for write access
	GPIOF->CR			          = 0x1F;					  //Unlock GPIOAFSEL, GPIOPUR, GPIOPDR, or GPIODEN bits to be written
	GPIOF->DIR 		          = 0x0E;					  //PF3-1	Output, PF0,PF4 Input
	GPIOF->AFSEL	          = 0x00;					  //Disable alternate function on all PORTF pins
	GPIOF->PCTL 	          = 0x00000000;		  //GPIO function on PCTL
	GPIOF->PUR 		          = 0x1F;					  //Pullup all Pins
	GPIOF->DEN		          = 0x1F;					  //Enable Digital I/O function of all PORTF pins
	GPIOF->AMSEL	          = 0x00;					  //Disable analogue functions on PORTF pins
}

void delay (uint32_t count) {
	int i,j;
	for (i = 0;  i < count; i++)
		for (j = 0; j < 1000; j++);
}
