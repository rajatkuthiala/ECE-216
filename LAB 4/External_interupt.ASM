;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F84A. This file contains the basic code               *
;   building blocks to build upon.                                    *
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F84A.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list      p=16F84A            ; list directive to define processor
	#include <p16F84A.inc>        ; processor specific variable definitions

	__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.




;***** VARIABLE DEFINITIONS
w_temp        EQU     0x0C        ; variable used for context saving
status_temp   EQU     0x0D        ; variable used for context saving

CBLOCK 0x0E
	delay_count
	delay_countTwo
	Scale
ENDC






;**********************************************************************
		ORG     0x000             ; processor reset vector
  		goto    Main              ; go to beginning of program


		ORG     0x004             ; interrupt vector location
		movwf   w_temp            ; save off current W register contents
		movf	STATUS,w          ; move status register into W register
		movwf	status_temp       ; save off contents of STATUS register

	
		btfsc INTCON, INTF
			call TimerInterrupt



		movf    status_temp,w     ; retrieve copy of STATUS register
		movwf	STATUS            ; restore pre-isr STATUS register contents
		swapf   w_temp,f
		swapf   w_temp,w          ; restore pre-isr W register contents
		retfie                    ; return from interrupt

Main
bsf STATUS, RP0
movlw 0x00;
movwf TRISA;
bcf STATUS, RP0
movlw 0x00;
movwf PORTA;
movlw b'00000001';
bsf STATUS, RP0
movwf TRISB;
movlw 0x00;
bcf STATUS, RP0
movwf PORTB;


clrwdt ;
bsf STATUS, RP0
movlw b'01001000'
movwf OPTION_REG
bcf STATUS, RP0
movlw b'10010000'
movwf INTCON

movlw 0x01
call EERead
movwf PORTA

loop
nop
goto loop
		



   TimerInterrupt
		call ToggleLight
		bcf INTCON , INTF
	return

		ToggleLight
			movlw b'00010'
			xorwf PORTA, 1
			movfw PORTA
			movwf EEDATA
			movlw 0x01
			call EEWrite
		return


EERead
BCF STATUS, RP0  
movwf EEADR
bsf STATUS, RP0
bsf EECON1, RD
bcf STATUS, RP0
movf EEDATA, w
return

EEWrite
;bsf EECON1, WREN
movwf EEADR
bsf STATUS, RP0
movlw 0x55
movwf EECON2
movlw 0xAA
movwf EECON2
bsf EECON1, WR
bcf STATUS, RP0
return

END
