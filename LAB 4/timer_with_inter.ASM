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

	__CONFIG   _CP_OFF & _WDT_ON & _PWRTE_ON & _HS_OSC

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

	
		btfsc INTCON, T0IF
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
movlw 0x00;
movwf PORTA;
bcf STATUS, RP0

clrwdt ;
bsf STATUS, RP0
movlw 0x87
movwf OPTION_REG
bcf STATUS, RP0
movlw 0xA0
movwf INTCON

loop
nop
goto loop
		



   TimerInterrupt
		incf Scale
		movlw d'100'
		subwf Scale , W
		btfsc STATUS , Z
		call ToggleLight
		bcf INTCON , T0IF
	return

		ToggleLight
			movlw b'00010'
			xorwf PORTA, f
			clrf Scale
		return
END
