
;	@author:	Ijaz Ahmad
;	
;	@warranty:	void
;
;	@description: Blinkys onboard RED led on Tivs-C TM4C123GXL Launchpad


; clock / bus control registers
RCGC2GPIO_REG				EQU			0x400FE108
GPIOHBCTL_REG				EQU			0x400FE06C

	
; gpio registers
GPIOFDIR_APB_REG			EQU			0x40025400
GPIOFDEN_APB_REG			EQU			0x4002551C
GPIOFDATA_APB_REG			EQU			0x40025008
GPIOFLOCK_APB_REG			EQU			0x40025520
GPIOFCR_APB_REG				EQU			0x40025524
GPIOPURF_APB_REG			EQU			0x40025510

; register values
GPIO_UNLOCK_VAL		        EQU			0x4C4F434B
DELAY_VALUE			        EQU			500000

				AREA 	|.text|, CODE, READONLY, ALIGN=2
				THUMB
				ENTRY
				EXPORT Main				
Main
				
				BL		__gpio_init
				
				LDR		R1,		=GPIOFDATA_APB_REG

loop            LDR		R2,		=DELAY_VALUE

delay			SUB		R2, 	R2, 	#0x1
				CMP		R2,		#0
				BNE		delay

				LDR		R0, [R1]
				EOR		R0, 	R0, 	#0x02
				STR		R0, [R1]
				
				B		loop



__gpio_init	

				; use AHB bus for GPIOF
				LDR		R1,		=GPIOHBCTL_REG
				LDR		R0,		[R1]
				AND		R0, 	R0, 	#0x1F  ; clear bit-5
				STR		R0,		[R1]
				
				; enable clock to GPIO-F
				LDR 	R1, 	=RCGC2GPIO_REG
				LDR		R0,		[R1] 
				ORR		R0, 	R0, 	#0x20
				STR		R0,		[R1]
				
				
				; unlock GPIOCR Register for write access
				LDR		R1,		=GPIOFLOCK_APB_REG
				LDR		R0,		=GPIO_UNLOCK_VAL
				STR		R0,		[R1]
				
				; unlock GPIOAFSEL, GPIOPUR, GPIOPDR, and GPIODEN for PF.1
				LDR		R1, 	=GPIOFCR_APB_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x02
				STR		R0,		[R1]
				
				; set PF.1 direction as output
				LDR		R1,		=GPIOFDIR_APB_REG
				MOV		R0,		#0x02
				STR		R0,		[R1]

				; pull up PF.1
				LDR		R1, 	=GPIOPURF_APB_REG
				LDR		R0,		[R1]
				ORR		R0, 	R0, 	#0x02
				STR		R0,		[R1]				

				; enable digital functionality for PF.1
				LDR		R1,		=GPIOFDEN_APB_REG
				MOV		R0,		#0x02
				STR		R0,		[R1]
				
				BX 		LR
					
				ALIGN 
				END
