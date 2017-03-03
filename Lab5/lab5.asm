;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC12F675. This file contains the basic code               *
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
;    Files Required: P12F675.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************

	list      p=12f675           ; list directive to define processor
	#include <p12f675.inc>        ; processor specific variable definitions

	errorlevel  -302              ; suppress message 302 from list file

	__CONFIG   _CP_OFF & _CPD_OFF & _BODEN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT 

; '__CONFIG' directive is used to embed configuration word within .asm file.
; The lables following the directive are located in the respective .inc file.
; See data sheet for additional information on configuration word settings.




;***** VARIABLE DEFINITIONS
w_temp        EQU     0x20        ; variable used for context saving 
status_temp   EQU     0x21        ; variable used for context saving
CBLOCK	0x40
ADData
delay_count2
delay_count
endc





;**********************************************************************
		ORG     0x000             ; processor reset vector
		goto    main              ; go to beginning of program
	

		ORG     0x004             ; interrupt vector location
		movwf   w_temp            ; save off current W register contents
		movf	STATUS,w          ; move status register into W register
		movwf	status_temp       ; save off contents of STATUS register


; isr code can go here or be located as a call subroutine elsewhere



		movf    status_temp,w     ; retrieve copy of STATUS register
		movwf	STATUS            ; restore pre-isr STATUS register contents
		swapf   w_temp,f
		swapf   w_temp,w          ; restore pre-isr W register contents
		retfie                    ; return from interrupt


; these first 4 instructions are not required if the internal oscillator is not used
main
		call    0x3FF             ; retrieve factory calibration value
		bsf     STATUS,RP0        ; set file register bank to 1 
		movwf   OSCCAL            ; update register with factory cal value 
		bcf     STATUS,RP0        ; set file register bank to 0


; remaining code goes here
		bcf STATUS, RP0
		movlw b'00000111'
		movwf CMCON 
		movlw b'10001101'
		movwf ADCON0
		bsf STATUS, RP0	
		movlw b'00011000'
		movwf ANSEL
		movlw b'010000'
		movwf TRISIO 
		bcf STATUS, RP0
		




Main_Loop
	bsf GPIO, 0x05	;turn the LED on
	call Delay		;delay
	bcf GPIO, 0x05	;turn LED off
	call Delay		;delay
	call Get_AD_Sample;
goto Main_Loop
	
Delay
	movf ADData, W

	movwf delay_count2	;init outer loop index
	Delay_loop_big
		movlw 0xFF
		movwf delay_count	;init inner loop index
	Delay_loop
		nop
		decfsz delay_count
			goto Delay_loop
		decfsz delay_count2
			goto Delay_loop_big
return

Get_AD_Sample
	bsf ADCON0,1
	Wait_for_finish
	btfss PIR1,6
	goto Wait_for_finish
	bsf STATUS,RP0
	movf ADRESL, W
	movwf ADData
	bcf STATUS, RP0
return

END