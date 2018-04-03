;test sequence

main: 
		RCALL GAME_START
		RCALL DELAY

		RCALL ROUND_WON
		RCALL DELAY

		RCALL GAME_WON
		RCALL DELAY

		RCALL GAME_LOST
		RCALL DELAY

		rjmp main

;----------------------------------------------------------
;----------------------- GAME START -----------------------
;----------------------------------------------------------
;BEFORE GAME START ALL LED LIGHTS SHOULD BLINK THREE TIMES
GAME_START:
	LDI R21, 0x3
WELCOME:
	LDI R17, 0b1111_1111 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS ON
	OUT DDRA, R17		 ; TURN ALL LEDS ON
	RCALL DELAY
	RCALL RESET_LIGHTS
	RCALL DELAY			 ; TIME DELAY
	DEC R21
	BRNE WELCOME
	RET


;----------------------------------------------------------
;---------------------- ROUND WON -------------------------
;----------------------------------------------------------
; ALL LIGHTS SHOULD BLINK IN SEQUENCE FROM LEFT TO RIGHT
ROUND_WON:
	LDI R16, 0x00
	OUT PORTA, R16
	LDI R16, 0x3
	ROUND_WON_LIGHTS_LOOP1:
		LDI R21, 8				 ; TO RUN LOOP EIGHT TIMES
		LDI R17, 0b0000_0001	 ; SAVE REGISTER VALUES TO TURN FIRST RIGHT LIGHT ON
		ROUND_WON_LIGHTS_LOOP2:
			OUT DDRA, R17		 ; TURN LIGHT ON
			ADD R17, R17		 ; PREPARE REGISTER VALUES TO TURN NEXT LIGHT ON
			RCALL SHORT_DELAY	 ; SMALL DELAY
			DEC R21
			BRNE ROUND_WON_LIGHTS_LOOP2
		DEC R16
		BRNE ROUND_WON_LIGHTS_LOOP1
	RCALL RESET_LIGHTS			 ; RESET LIGHTS
	LDI R17, 0xff
	OUT DDRA, R17
	RET


;----------------------------------------------------------
;---------------------- GAME WON --------------------------
;----------------------------------------------------------
; ALL LIGHTS SHOULD BLINK TOGETHER FOR A LONG TIME
GAME_WON:
	LDI R16, 0x00
	OUT PORTA, R16
	LDI R21, 0x30
	END_GAME_LOOP:
		LDI R17, 0b1111_1111 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS ON
		OUT DDRA, R17		 ; TURN ALL LEDS ON
		RCALL SHORT_DELAY
		RCALL RESET_LIGHTS
		RCALL SHORT_DELAY	 ; SHORT TIME DELAY
		DEC R21
		BRNE END_GAME_LOOP
	RCALL RESET_LIGHTS		 ; RESET LIGHTS
	RCALL DELAY
	RCALL DELAY
	LDI R17, 0xff
	OUT DDRA, R17
	RET


;----------------------------------------------------------
;---------------------- GAME LOST -------------------------
;----------------------------------------------------------
; ALL LIGHTS SHOULD TURN ON TOGETHER FOR A LONG TIME

GAME_LOST:
	LDI R16, 0x00
	OUT PORTA, R16
	LDI R17, 0b1111_1111 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS ON
	OUT DDRA, R17		 ; TURN ALL LIGHTS ON
	LDI R16, 0x11
	GAME_LOST_DELAY:	 ; DELAY TO KEEP LIGHTS LIT FOR LONG TIME
		RCALL DELAY
		DEC R16
		BRNE GAME_LOST_DELAY
	RCALL RESET_LIGHTS	 ; RESET LIGHTS
	RCALL DELAY
	RCALL DELAY
	LDI R17, 0xff
	OUT DDRA, R17

RCALL DELAY
RET

;----------------------------------------------------------
;-------------------- DELAY -------------------------------
;----------------------------------------------------------
; DELAY CALCUCATOIN
; Clock frequency 10 MHz
; DELAY = 4.876.875 + 260.100 + 3825 + 4 + 1 * 1000 ns 
;		= 5.140.805 * 1000 ns = 5.072.719.000 
;	    = 


DELAY:								;INSTRUCTION CYCLES
	LDI r18, 255					; 1
loop_1:							
	LDI r19, 255					; 1
innerloop_1:
	LDI r20, 25						; 1
mostinnerloop_1:
	DEC r20							; 1
	BRNE mostinnerloop_1			; 2/1
	DEC r19							; 1
	BRNE innerloop_1				; 2/1
	DEC r18							; 1
	BRNE loop_1						; 2/1
	RET								; 4

;----------------------------------------------------------
; ------------------- SHORT DELAY -------------------------
;----------------------------------------------------------
; DELAY CALCUCATOIN
; Clock frequency 10 MHz
; DELAY = 737.280 + 65.536 + 640 + 4 + 1 * 1000 ns
;	    = 803.461 * 1000 ns 
;       =


SHORT_DELAY:						; INSTRUCTION CYCLES
	LDI R18, 128					; 1
SHORT_loop_1:
	LDI R19, 128					; 1
SHORT_innerloop_1:
	LDI R20, 15						; 1
SHORT_mostinnerloop_1:
	DEC R20							; 1
	BRNE SHORT_mostinnerloop_1		; 2/1
	DEC R19							; 1
	BRNE SHORT_innerloop_1			; 1
	DEC R18							; 1
	BRNE SHORT_loop_1				; 2/1
	RET								; 4

;----------------------------------------------------------
; --------- RESET LIGHTS / TURN OFF ALL LIGHTS ------------
;----------------------------------------------------------
RESET_LIGHTS:
	LDI R17, 0b0000_0000 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS OFF
	OUT DDRA, R17		 ; TURN ALL LEDS OFF
	RET