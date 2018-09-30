;	@author:      Ijaz Ahmad
;
;	@warranty:	  void
;
;	@description: Accurate 1000ms delay using Timers
;


; Timer-0 registers
TIMER0CTL_REG               EQU         0x4003000C
TIMER0CFG_REG               EQU         0x40030000
TIMER0AMR_REG               EQU         0x40030004
TIMER0AIL_REG               EQU         0x40030028
TIMER0IMR_REG               EQU         0x40030018
TIMER0ICR_REG               EQU         0x40030024

RCGCTIMER_REG               EQU         0x400FE604


; clock / bus control registers
RCGC2GPIO_REG               EQU	        0x400FE108
GPIOHBCTL_REG               EQU	        0x400FE06C

; gpio registers
GPIOFDIR_APB_REG            EQU         0x40025400
GPIOFDEN_APB_REG            EQU         0x4002551C
GPIOFDATA_APB_REG           EQU         0x40025008
GPIOFLOCK_APB_REG           EQU         0x40025520
GPIOFCR_APB_REG             EQU         0x40025524
GPIOFPUR_APB_REG            EQU         0x40025510
GPIOFPDR_APB_REG            EQU         0x40025514

;NVIC Registers
NVIC_EN0_REG                EQU         0xE000E100

; register values
GPIO_UNLOCK_VAL				EQU			0x4C4F434B
TIMER_DELAY_VAL             EQU         16000000-1


				AREA 	|.text|, CODE, READONLY, ALIGN=2
				THUMB
				ENTRY
				EXPORT Main				
Main
				
				BL		__gpio_config
				
				BL		__timer_init
				
				B		.
                

__timer_init
                
                ;enable clock to Timer-0
                LDR	    R1,	    =RCGCTIMER_REG
                LDR     R0,	    [R1]
                ORR     R0,	    R0,	    #0x1 ; set bit-0
                STR     R0,	    [R1]

				; configure timer-A,B in concatenated mode for Timer-0
                LDR     R1,	    =TIMER0CFG_REG
                MOV     R0,	    #0
                STR     R0,	    [R1]
                                
				
                ; periodic mode -> 1000ms countinuous delay
                LDR     R1,     =TIMER0AMR_REG
                LDR     R0,     [R1]
                BIC     R0,     R0,     #0x3    ; clear the lower two bits
                ORR     R0,     R0,     #0x2    ; set bit-1
				STR     R0,     [R1]

                ; value to count for 1000ms delay @16Mhz clock
                LDR		R1,		=TIMER0AIL_REG
                LDR     R0,     =TIMER_DELAY_VAL
                STR     R0,     [R1]
				
                ; enable Interrupt for Timer-A 
                LDR     R1,     =TIMER0IMR_REG
                LDR     R0,     [R1]
                ORR     R0,     R0,     #0x1 ; set bit-0
                STR     R0,     [R1]
				
                ; 16/32-Bit Timer 0A at NVIC side
                ; assuming the core in previllaged mode
                LDR	    R1,	    =NVIC_EN0_REG
                MOV     R2,     #0x1
                LSLS    R2,     R2,     #19
                STR     R2,	    [R1]                
                
                ; enable  Timer-0 
                LDR     R1,     =TIMER0CTL_REG
                LDR     R0,     [R1]
                ORR     R0,     R0,     #0x1    ; set bit-0    
                STR     R0,     [R1]

                BX		LR
				
                
__gpio_config

                ; use APB bus for GPIOF
                LDR	    R1,	    =GPIOHBCTL_REG
                LDR	    R0,	    [R1]
                AND	    R0,     R0,     #0x1F  ; clear bit-5
                STR	    R0,	    [R1]
				
                ; enable clock to GPIO-F
                LDR     R1,     =RCGC2GPIO_REG
                LDR	    R0,	    [R1] 
                ORR	    R0,     R0,     #0x20
                STR	    R0,	    [R1]
								
                ; unlock GPIOCR Register for write access
                LDR	    R1,	    =GPIOFLOCK_APB_REG
                LDR	    R0,	    =GPIO_UNLOCK_VAL
                STR	    R0,	    [R1]
				
                ; unlock GPIOAFSEL, GPIOPUR, GPIOPDR, and GPIODEN for PF.1
                LDR	    R1,     =GPIOFCR_APB_REG
                LDR	    R0,	    [R1]
                ORR	    R0,     R0,     #0x02
                STR	    R0,	    [R1]
				
                ; set PF.1 direction as output
                LDR	    R1,	    =GPIOFDIR_APB_REG
                MOV	    R0,	    #0x02
                STR	    R0,	    [R1]
			
                ; enable digital functionality for PF.1
                LDR	    R1,	    =GPIOFDEN_APB_REG
                MOV	    R0,	    #0x02
                STR	    R0,	    [R1]
                
								
                ; lock GPIOCR Register for write access
                LDR	    R1,	    =GPIOFLOCK_APB_REG
                MOV	    R0,	    #0
                STR	    R0,	    [R1]

				BX 		LR

				ALIGN
                    
                
                AREA    |.text|, CODE, READONLY
                    
                    
                    
TIMER0A_Handler PROC
                
                EXPORT TIMER0A_Handler

                ; clear the interrupt
                LDR	    R1,	    =TIMER0ICR_REG
				LDR	    R0,	    [R1]
				ORR	    R0,     R0,     #0x1 ; set bit-0
				STR	    R0,	    [R1]  

				; Toggle PF.1
                LDR		R1,		=GPIOFDATA_APB_REG                
				LDR		R0, 	[R1]				
				EOR		R0, 	R0,		#0x2				
				STR		R0, 	[R1]
                
                BX  LR
                ENDP
                
                ALIGN
				END
