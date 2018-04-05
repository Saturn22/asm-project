;
; outpuTest.asm
;
; Author : Faizan & Tor

; configuration of port
ldi r17, 0xff ; ; 1111 1111 this is used for setting up the port and to turn all lights on and off
out ddra, r17

START:
	I1:		
		IN r17, pinb		; Gets input from button.
		OUT porta, r17		; Shows input on the led.
		COM r17				; complementing r17 because of stk600
		BREQ I1				; Check if a button has been pressed. If not it keeps looping 
	RJMP START			; start over again - loop forever -
