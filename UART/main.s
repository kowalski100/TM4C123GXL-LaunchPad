
;	@author:      Ijaz Ahmad
;
;	@warranty:	  void
;
;	@description: Simple Transmission/Reception over UART0
;				  data is pingged back


; uart registers
UART0DR_REG					EQU			0x4000C000
UART0FR_REG					EQU			0x4000C018
UART0CTL_REG				EQU			0x4000C030
UART0IBRD_REG				EQU			0x4000C024
UART0FBRD_REG				EQU			0x4000C028	
UART0LCRH_REG				EQU			0x4000C02C
UART0CC_REG					EQU			0x4000CFC8	
RCGC1_REG					EQU			0x400FE104


; clock / bus control registers
RCGC2_REG					EQU			0x400FE108
GPIOHBCTL_REG				EQU			0x400FE06C


; gpio registers
GPIOAFSEL_APB_REG			EQU			0x40004420
GPIOAPCTL_APB_REG			EQU			0x4000452C	
GPIOACR_APB_REG				EQU			0x40004524
GPIOADEN_APB_REG			EQU			0x4000451C
GPIOALOCK_APB_REG			EQU			0x40004520
GPIOAPDR_APB_REG			EQU			0x40004514


; register values
GPIO_UNLOCK_VAL				EQU			0x4C4F434B


				AREA 	|.text|, CODE, READONLY, ALIGN=2
				THUMB
				ENTRY
				EXPORT Main				
Main
				
				BL		__gpio_config
				
				BL		__uart_init
				
				LDR		R1,		=UART0FR_REG
				LDR		R2,		=UART0DR_REG

loop
				; read UART0 flags for any received data
				LDR		R0, 	[R1]				
				AND		R0, 	R0,		#0x40				
				CMP 	R0, 	#0x40			
				BNE		loop   			; loop back if no data is received

				; transmit data
				LDR		R0,		[R2]				
				AND 	R0,		R0,		#0xFF
				STR		R0, 	[R2]

				; wait until TX completes
tx_busy			LDR		R0, 	[R1]				
				AND		R0, 	R0,		#0x80
				CMP 	R0, 	#0x80				
				BNE		tx_busy   		; loop back if no data is received
				
				B		loop


__uart_init
				; enable clock to UART0
				LDR		R1,		=RCGC1_REG
				LDR		R0,		[R1]
				ORR		R0,		R0,		#0x1
				STR		R0,		[R1]
				
				NOP
				NOP
				NOP

				; baudrate integer part @ 16Mhz, BR: 9600
				LDR		R1,		=UART0IBRD_REG
				MOV		R0,		#104
				STR		R0,		[R1]
				
				; baudrate floating part @ 16Mhz, BR: 9600
				LDR		R1,		=UART0FBRD_REG
				MOV		R0,		#11
				STR		R0,		[R1]	

				; Frame format 1-start/stop bit, 8-bit data, no parity
				LDR		R1,		=UART0LCRH_REG
				MOV		R0,		#0x60
				STR		R0,		[R1]
				
				; enable both transmission and reception on UART0
				LDR		R1,		=UART0CTL_REG
				LDR		R0,		[R1]
				ORR		R0,		R0,		#0x300
				STR		R0,		[R1]
				
				; UART0 clocked from system clock
				LDR		R1,		=UART0CC_REG
				MOV		R0,		#0x5
				STR		R0,		[R1]
				
				; enable both transmission and reception on UART0
				LDR		R1,		=UART0CTL_REG
				LDR		R0,		[R1]
				ORR		R0,		R0,		#0x1
				STR		R0,		[R1]

				BX		LR
				
				

__gpio_config

				; use APB bus for GPIOA
				LDR		R1,		=GPIOHBCTL_REG
				LDR		R0,		[R1]
				AND		R0, 	R0, 	#0x7E  ; clear bit-0
				STR		R0,		[R1]

				; enable clock to GPIO-A
				LDR 	R1, 	=RCGC2_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x01
				STR		R0,		[R1]
				
				; unlock GPIOCR Register for write access
				LDR		R1,		=GPIOALOCK_APB_REG
				LDR		R0,		=GPIO_UNLOCK_VAL
				STR		R0,		[R1]
				
				; unlock GPIODEN for PA.0-1
				LDR		R1, 	=GPIOACR_APB_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x03
				STR		R0,		[R1]
				
				; pull down PA.0-1
				LDR		R1, 	=GPIOAPDR_APB_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x03
				STR		R0,		[R1]				
			

				; enable digital functionality for PA.0-1
				LDR		R1,		=GPIOADEN_APB_REG
				MOV		R0,		#0x03
				STR		R0,		[R1]
				
				
				; set alternate function for PA.0-1
				LDR		R1,		=GPIOAFSEL_APB_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x03
				STR		R0,		[R1]
				
				
				; alternate function as UART0
				LDR		R1,		=GPIOAPCTL_APB_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x11
				STR		R0,		[R1]  


				BX 		LR
					
				ALIGN 
				END
