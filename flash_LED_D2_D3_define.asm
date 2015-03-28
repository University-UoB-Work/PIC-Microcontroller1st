;*********************************************************************************

; File-name:	flash_LED_D2_D3_define.asm
; Author:	Alexander Drabek
; Date:  	26.04.13

; Description:	This Assembler program for PIC16F684 turns ON and OFF LEDs......

;Ways to improve ;Increment memory address!!!! -it is doing it!
;I will define a table with Trisa configuration
;define a table with PORTA configuration
;remember each operation took time -delay for on directly after  setting on this minus i operation for ON

	list     p=16F684		; list directive to define processor
	#include <p16f684.inc>	; processor specific variable definitions
	__CONFIG  _CP_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _CPD_OFF
;****************************** Assignment Statements ****************************
;set up counter for look-up table-stores memory location for 
;seperate varaible for storing 
COUNT1 EQU 20h	; Available GPR at address 20h used for storing COUNT1
COUNT2 EQU 21h	; Available GPR at address 21h used for storing COUNT2
normal EQU 22h	; Available GPR at address 21h used for storing COUNT2
;delay counters
PORTA_Internal EQU 23h
COUNT_LED_NUMBER EQU 24h	; 
COUNT_TRISA_NUMBER EQU 25h	; 

;****************************** Start of Program ******************************
; Initial configuration - Common for all programs for CIS018-1
;errorlevel -302 ; Disable bank switch warning 
	 	org    	0x000		; Processor reset vector
	 	bcf    	STATUS,RP0	; Bank 0 selected
	 	movlw	07h			; Set RA<2:0> to digital and 
	 	movwf  	CMCON0 		; Comparators turned OFF
	 	bsf    	STATUS,RP0	; Bank 1 selected
	 	clrf   	ANSEL 		; Digital I/O selected
	 	movlw	B'00111111'	; Move in W - 0x3F - Set all I/O pins as digital inputs
	 	movwf	TRISA		; Configure I/O ports		
	 	clrf	INTCON		; Disable all interrupts, clear all flags	
	 	bcf    	STATUS,RP0	; Bank 0 selected
	 	clrf	PORTA		; Clear all outputs
;*********************************************************************************
; To preload a counts value and set to 0 addresses for look-up tables ; 
;


;create goto this! and go to start!

     	movlw  	0xF0  	 	; First load a value of say, F0h in the W register
	 	movwf  	COUNT2   	; Now move it to COUNT2 register
     	movlw  	B'00000100'  	 	; First load a value of say, 1 in the W register
	 	movwf  	normal   	; Now move it to COUNT2 register
     	movlw  	B'00000010' ; First load a value of say, 1 in the W register
	 	movwf  	PORTA_Internal  ; Now move it to COUNT2 register
      	movlw  	B'00000000'  	; First load a value of say, 1 in the W register
	 	movwf  	COUNT_LED_NUMBER  	; Now move it to COUNT2 register
     	movlw  	B'00000000'  	 	; First load a value of say, 1 in the W register
	 	movwf  	COUNT_TRISA_NUMBER 	; Now move it to COUNT2 register

;********************************************************************************
;*********************************************************************************
goto start_loop 
        	org    	26h ;OK starting from this address to not overwrite anything!
Lookup_TRISA    
		   	 movlw	low TableTRISA 
		     ADDWF COUNT_TRISA_NUMBER                  ; Jump to entry spec'd by w. PORTA!!
		  	 movwf	PCL
TableTRISA   RETLW B'00001111'                ; 0, 1, 2, 3
             RETLW B'00101011'
             RETLW B'00011011'
             RETLW B'00111001'

	org    	2Dh ;

Lookup_PORTA    
			 movlw	low TablePORTA
		   	 ADDWF COUNT_LED_NUMBER                  ; Jump to entry spec'd by w. PORTA!!
			 movwf	PCL
TablePORTA   RETLW B'00010000'	; Sending HIGH to D0 -OK
             RETLW B'00100000'	; Sending HIGH to D1 -ok
             RETLW B'00010000'	; Sending HIGH to D2 -ok
             RETLW B'00000100'	; Sending HIGH to D3 -ok
			 RETLW B'00100000'	; Sending HIGH to D4 -ok
			 RETLW B'00000100'	; Sending HIGH to D5 -ok
			 RETLW B'00000100'	; Sending HIGH to D6 -ok
			 RETLW B'00000010'	; Sending HIGH to D7 -ok


;********************************************************************************
;*********************************************************************************

start_loop      
   
 			goto ITERNAL_TRISA_LOOP      	   
		;	goto AGAIN

ITERNAL_TRISA_LOOP
			 bsf  STATUS,RP0		  ;Bank 1
             clrf TRISA
 			 CALL Lookup_TRISA          ; Call the table. -it should obtain the address for next memory cell with trisa config
             movwf TRISA				;Move config to TRISA
			;set the normal to 4,decrease ,omit next operation if 0 go to AGAIN
			 
			 decfsz normal,1 ; it should have value of 4 XD if 0 omit XD        No sure --it will omit las one (option 4)
			 goto INTERNAL_LOOP_2DIODS ; 
			 goto AGAIN ; 

INTERNAL_LOOP_2DIODS	;develop the delay ! +TRISA CHANGE
		   	 bcf	STATUS, RP0	; 
	       	 call	DELAY
             CALL Lookup_PORTA  ; Call the table. -it should obtain the address for next memory cell with PORTA config
             movwf	PORTA ;light this diod!
		     call	DELAY; for a half second
             INCFSZ COUNT_LED_NUMBER,1 ;increase LED NUmber!			
		     clrf	PORTA		;  Clear PORTA 
             decfsz PORTA_Internal,1 ; it should have value of 2/1 XD
             goto INTERNAL_LOOP_2DIODS ; only 1 repeat!
			 INCFSZ COUNT_TRISA_NUMBER,1
			 movlw  B'00000001'  	 	; First load a value of say, 1 in the W register
	 	   	 movwf  PORTA_Internal 	; Now move it to COUNT2 register
	      	 goto  start_loop

AGAIN
;reset all value and go to start

     	movlw  	0xF0  	 	; First load a value of say, F0h in the W register
	 	movwf  	COUNT2   	; Now move it to COUNT2 register
     	movlw  	B'00000100'  	 	; First load a value of say, 1 in the W register
	 	movwf  	normal   	; Now move it to COUNT2 register
     	movlw  	B'00000010' ; First load a value of say, 1 in the W register
	 	movwf  	PORTA_Internal  ; Now move it to COUNT2 register
      	movlw  	B'00000000'  	; First load a value of say, 1 in the W register
	 	movwf  	COUNT_LED_NUMBER  	; Now move it to COUNT2 register
     	movlw  	B'00000000'  	 	; First load a value of say, 1 in the W register
	 	movwf  	COUNT_TRISA_NUMBER 	; Now move it to COUNT2 register
		goto start_loop 


;*********************************************************************************
; Call the DELAY subroutine to generate a delay for ON period
		call	DELAY
;*********************************************************************************
; Sending data through PORTA to switch OFF LED D3
	 	clrf	PORTA		; Clear PORTA 
;*********************************************************************************
; Call the DELAY subroutine to generate a delay for OFF period
		call	DELAY
;*********************************************************************************
;	goto   start_loop	; loop again - Loop forever - blink continuously
;*********************************************************************************
; DELAY Subroutine
;*********************************************************************************
; Generate a delay period
DELAY
LOOP1   decfsz   COUNT1,1  	; Decrement COUNT1 and skip next instruction if zero
     	goto     LOOP1     	; else loop back to LOOP1
	 	decfsz   COUNT2,1  	; Decrement COUNT2 and skip next instruction if zero
     	goto     LOOP1      ; else loop back to LOOP1
;****Both counters are zero at this point ******
		movlw	 0xF0	   	; Reload the second counter for the next iteration
		movwf	 COUNT2
		return
;*********************************************************************************
	 	end
;*********************************************************************************








;BLINK_NEXT_WITH_DELAY

				; Initialising Port A
				; Setting the data direction register for LED D2 PORTA (TRISA)
;					 	bsf		STATUS,RP0		; Bank 1 selected
;					 	movlw	TRISA_D2_D3		; Configure LEDs D2 and D3 in TRISA 
;					 	movwf	TRISA
				;*********************************************************************************
				; Sending data through PORTA to switch ON LED D2
;					 	bcf		STATUS, RP0	; Bank 0 selected
;				     	movlw	LED_D2_ON	; Write '1' for D2 into Working Register
;				 	 	movwf	PORTA		; Send '1' through PORTA to light up LED D2
				;*********************************************************************************
				; Call the DELAY subroutine to generate a delay for ON period
;						call	DELAY
				;*********************************************************************************
				; Sending data through PORTA to switch OFF LED D2
;					 	clrf	PORTA		; Clear PORTA 
				;*********************************************************************************
				; Call the DELAY subroutine to generate a delay for OFF period
;						call	DELAY

;blinks D2 on and off delay period included! template for normal way ,
;you need to copy each time lots of code for each of the diode XD

 ;      				 return