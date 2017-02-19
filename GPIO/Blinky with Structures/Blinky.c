
/*********************************************************************

			Tiva LaunchPad (TM4C123GH6PM) Bare Matel Programming Demo

                        BLINKY LED (BLUE)
                        
  This Project DEFINES a Structure and map it PORTF APB Base Address
          BLUE LED blinks continuously on Tiva Launchpad
*********************************************************************/


#include <tm4c123gh6pm.h>
#include <stdint.h>

typedef struct {                                                       
  __I uint32_t  RESERVED[255];
  __IO uint32_t  GPIO_DATA_REG;                              /*!< GPIO Data                                                             */
  __IO uint32_t  GPIO_DIR_REG;                               /*!< GPIO Direction                                                        */
  
  /*
    SKIPPED MEMORY MAPPED REGISTERS
  */
  __I uint32_t  SKIPPED_REG[7];                              

  __IO uint32_t  GPIO_AFSEL_REG;                             /*!< GPIO Alternate Function Select                                        */

  /*
    SKIPPED MEMORY MAPPED REGISTERS
  */
  __I uint32_t  RESERVED1[55];
  __I uint32_t  SKIPPED_REG1[4];                              

  __IO uint32_t  GPIO_PUR_REG;                               /*!< GPIO Pull-Up Select                                                   */

  /*
    SKIPPED MEMORY MAPPED REGISTERS
  */  
  __I uint32_t  SKIPPED_REG2[2];                               

  __IO uint32_t  GPIO_DEN_REG;                               /*!< GPIO Digital Enable                                                   */
  __IO uint32_t  GPIO_LOCK_REG;                              /*!< GPIO Lock                                                             */
  __IO uint32_t  GPIO_CR_REG;                                /*!< GPIO Commit                                                           */
  __IO uint32_t  GPIO_AMSEL_REG;                             /*!< GPIO Analog Mode Select                                               */
  __IO uint32_t  GPIO_PCTL_REG;                              /*!< GPIO Port Control                                                     */

  /*
    SKIPPED MEMORY MAPPED REGISTERS
  */
  __I uint32_t  SKIPPED_REG3[2];                              

} GPIO_REG_MAP;


#define GPIOF_BASE                      0x40025000UL
#define GPIOF_APB                   ((GPIO_REG_MAP *) GPIOF_BASE)
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
		GPIOF_APB->GPIO_DATA_REG = 0x00;
		delay(1000);
		GPIOF_APB->GPIO_DATA_REG = 0x04;
		delay(1000);
	}

}


void init_GPIOF(void) {
	GPIO_HBCTL_REG &= ~(1UL << 4);				            //Use APB bus for GPIOF
	GPIO_RCGC_REG |= 0x020;								            //enable clock to GPIOF
	delay(1);															            //allow clock to stablize
	GPIOF_APB->GPIO_LOCK_REG	 = 0x4C4F434B;		//Unlock GPIOCR Register for write access
	GPIOF_APB->GPIO_CR_REG		 = 0x1F;					//Unlock GPIOAFSEL, GPIOPUR, GPIOPDR, or GPIODEN bits to be written
	GPIOF_APB->GPIO_DIR_REG      = 0x0E;					//PF3-1	Output, PF0,PF4 Input
	GPIOF_APB->GPIO_AFSEL_REG    = 0x00;					  //Disable alternate function on all PORTF pins
	GPIOF_APB->GPIO_PCTL_REG 	 = 0x00000000;		  //GPIO function on PCTL
	GPIOF_APB->GPIO_PUR_REG 	 = 0x1F;					//Pullup all Pins
	GPIOF_APB->GPIO_DEN_REG		 = 0x1F;					  //Enable Digital I/O function of all PORTF pins
	GPIOF_APB->GPIO_AMSEL_REG	 = 0x00;					  //Disable analogue functions on PORTF pins
}

void delay (uint32_t count) {
	int i,j;
	for (i = 0;  i < count; i++)
		for (j = 0; j < 1000; j++);
}
