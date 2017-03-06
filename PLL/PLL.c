
/*********************************************************************

			Tiva LaunchPad (TM4C123GH6PM) Bare Matel Programming Demo

                      PLL (Phase Lockup Loop) 
                        
  This Project uses PLL to multiply 16MHz crystal frequency to maximium
         possible frequency supported by LaunchPad i.e. 80MHz
*********************************************************************/

#include <tm4c123gh6pm.h>
#include <stdint.h>

//RCC2
typedef struct {
  __I  uint32_t   reserved:4;
  __IO uint32_t   OSCSRC2:3;
  __I  uint32_t   reserved1:4;
  __IO uint32_t   BYPASS2:1;
  __I  uint32_t   reserved2:1;
  __IO uint32_t   PWRDN2:1;
  __IO uint32_t   USBPWRDN:1;
  __I  uint32_t   reserved3:7;
  __IO uint32_t   SYSDIV2LSB:1;
  __IO uint32_t   SYSDIV2:6;
  __I  uint32_t   reserved4:1;
  __IO uint32_t   DIV400:1;
  __IO uint32_t   USERCC2:1;  
}RCC2_REG;

//we will use only XTL fields of RCC Register
typedef struct {
  __I  uint32_t   reserved:6;
  __IO uint32_t   XTAL:5;
  __I  uint32_t   reserved1:21;
}RCC_REG;

#define RCC_BASE           0x400FE060
#define RCC2_BASE          0x400FE070

#define RCC                ((RCC_REG *)0x400FE060)
#define RCC2               ((RCC2_REG *)0x400FE070)
#define RIS                (*(volatile uint32_t *)0x400FE050)

void initPLL (void);
void toggleLED(void);
void delay (uint32_t);

int main (void) {
  initPLL();    //COMMENT/UNCOMMENT THIS LINE TO SEE THE PLL EFFECT ON LED
  toggleLED();
  return 0;
}

void initPLL (void){
  int i;
  RCC2->USERCC2 =  1;
  RCC2->BYPASS2 =  1;
  for (i = 0; i < 1000; i++);

  RCC2->OSCSRC2 =  0x0;
  RCC->XTAL  = 0x15;
  RCC2->DIV400 = 1;
  RCC2->SYSDIV2LSB = 0;
  RCC2->SYSDIV2  = 0x02;
  while ((RIS & (1UL<<6)) != (1UL<<6));
  RCC2->BYPASS2 = 0;
}

void toggleLED(void) {
  SYSCTL->GPIOHBCTL       &= ~(1UL << 4);   //Use APB bus for GPIOF
  SYSCTL->RCGC2           |= 0x020;         //enable clock to GPIOF
	delay(1);                                 //allow clock to stablize
	GPIOF->LOCK		          = 0x4C4F434B;     //Unlock GPIOCR Register for write access
	GPIOF->CR			          = 0x1F;           //Unlock GPIOAFSEL, GPIOPUR, GPIOPDR, or GPIODEN bits to be written
	GPIOF->DIR 		          = 0x0E;           //PF3-1	Output, PF0,PF4 Input
	GPIOF->AFSEL	          = 0x00;           //Disable alternate function on all PORTF pins
	GPIOF->PCTL 	          = 0x00000000;     //GPIO function on PCTL
	GPIOF->PUR 		          = 0x1F;           //Pullup all Pins
	GPIOF->DEN		          = 0x1F;           //Enable Digital I/O function of all PORTF pins
	GPIOF->AMSEL	          = 0x00;           //Disable analogue functions on PORTF pins
  while (1) {
    GPIOF->DATA = 0x00;
		delay(1000);
		GPIOF->DATA = 0x08;
		delay(1000);
	}
}

void delay (uint32_t count) {
	int i,j;
	for (i = 0;  i < count; i++)
		for (j = 0; j < 1000; j++);
}
