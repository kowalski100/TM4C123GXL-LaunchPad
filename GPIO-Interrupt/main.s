
;	@author:      Ijaz Ahmad
;
;	@warranty:	  void
;
;	@description: Turn ON RED LED on Tivs-C TM4C123GXL Launchpad
;				  upon SW2 press


; clock / bus control registers
RCGC2GPIO_REG               EQU	        0x400FE108
GPIOHBCTL_REG               EQU	        0x400FE06C

;NVIC Registers
NVIC_EN0_REG                EQU         0xE000E100
	
; gpio registers
GPIOFDIR_APB_REG            EQU	        0x40025400
GPIOFDEN_APB_REG            EQU	        0x4002551C
GPIOFDATA_APB_REG           EQU	        0x4002500C
GPIOFLOCK_APB_REG           EQU	        0x40025520
GPIOFCR_APB_REG	            EQU	        0x40025524
GPIOFPUR_APB_REG            EQU	        0x40025510
GPIOFPDR_APB_REG            EQU	        0x40025514
    
GPIOIS_APB_REG              EQU         0x40025404
GPIOIBE_APB_REG             EQU         0x40025408
GPIOIEV_APB_REG             EQU         0x4002540C
GPIOIM_APB_REG              EQU         0x40025410
GPIOICR_APB_REG             EQU         0x4002541C    


; register values
GPIO_UNLOCK_VAL	            EQU	        0x4C4F434B
GPIOF_NVIC_BIT              EQU         0x40000000
DELAY_VALUE	                EQU	        40000

                AREA 	|.text|, CODE, READONLY, ALIGN=2
                THUMB
                ENTRY
                EXPORT Main

Main
				
                BL		__gpio_init
              
                BL		__config_interrupt
              
                B       .


__config_interrupt
                
				; enable edge detection on PF.0
                LDR	    R1,	    =GPIOIS_APB_REG
                LDR	    R0,	    [R1]
                AND	    R0,     R0,     #0x3E  ; clear bit-0
                STR     R0,	    [R1]
                
				; Interrupt generation is controlled by GPIOIEV reg
                LDR	    R1,	    =GPIOIBE_APB_REG
                LDR	    R0,	    [R1]
                AND	    R0,     R0,     #0x3E  ; clear bit-0
                STR     R0,	    [R1]
                
                
				; falling edge (button pressed) generate interrupt
                LDR	    R1,	    =GPIOIEV_APB_REG
                LDR	    R0,	    [R1]
                AND	    R0,     R0,     #0x3E  ; clear bit-0
                STR     R0,	    [R1]

				; enable interrupt for PF.0
                LDR	    R1,	    =GPIOIM_APB_REG
                LDR	    R0,	    [R1]
                ORR	    R0,     R0,     #0x01  ; set bit-0
                STR     R0,	    [R1]

                ; enable GPIO-F interrupt at NVIC side
                ; assuming the core in previllaged mode
                LDR	    R1,	    =NVIC_EN0_REG
                LDR	    R0,	    =GPIOF_NVIC_BIT
                STR     R0,	    [R1]

                BX      LR
                

                
                
__gpio_init
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
				
                ; unlock GPIOAFSEL, GPIOPUR, GPIOPDR, and GPIODEN for PF.0-1
                LDR	    R1,     =GPIOFCR_APB_REG
                LDR	    R0,	    [R1]
                ORR	    R0,     R0,     #0x03
                STR	    R0,	    [R1]
				
                ; set PF.0 as input, PF.1 direction as output
                LDR	    R1,	    =GPIOFDIR_APB_REG
                MOV	    R0,	    #0x02
                STR	    R0,	    [R1]

                ; pull up PF.0
                LDR	    R1,     =GPIOFPUR_APB_REG
                LDR	    R0,	    [R1]
                ORR	    R0,     R0,     #0x01
                STR	    R0,	    [R1]				
			

                ; enable digital functionality for PF.0-1
                LDR	    R1,	    =GPIOFDEN_APB_REG
                MOV	    R0,	    #0x03
                STR	    R0,	    [R1]
                
								
                ; lock GPIOCR Register for write access
                LDR	    R1,	    =GPIOFLOCK_APB_REG
                MOV	    R0,	    #0
                STR	    R0,	    [R1]                

                BX      LR

                ALIGN 
            
            
                AREA    |.text|, CODE, READONLY
    
GPIOF_Handler   PROC
                EXPORT GPIOF_Handler                
                ; assuming we are only expecting PF.0 interrupt from GPIO-F
                ; in case of multiple interrupts on, a check is required 
                ; to see which interrupt event has occured 
               
                ; clear the interrupt
                LDR	    R1,	    =GPIOICR_APB_REG
				LDR	    R0,	    [R1]
				ORR	    R0,     R0,     #0x1 ; set bit-0
				STR	    R0,	    [R1]  

				; read data register value for PF.1
                LDR		R1,		=GPIOFDATA_APB_REG                
				LDR		R0, 	[R1]				
				EOR		R0, 	R0,		#0x2				
				STR		R0, 	[R1]
                              
                BX       LR
                ENDP

                ALIGN
                END
