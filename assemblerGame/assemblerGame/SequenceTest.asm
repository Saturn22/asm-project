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
;---------------------- GAME WELCOME ----------------------
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
; ------------------- DELAY -------------------------------
;----------------------------------------------------------
DELAY:
	LDI r18, 255
	loop_1:
	LDI r19, 255
	innerloop_1:
	LDI r20, 25
	mostinnerloop_1:
	DEC r20
	BRNE mostinnerloop_1
	DEC r19
	BRNE innerloop_1
	DEC r18
	BRNE loop_1
	RET

;----------------------------------------------------------
; ------------------- SHORT DELAY -------------------------
;----------------------------------------------------------
SHORT_DELAY:
	LDI R18, 128
	SHORT_loop_1:
	LDI R19, 128
	SHORT_innerloop_1:
	LDI R20, 15
	SHORT_mostinnerloop_1:
	DEC R20
	BRNE SHORT_mostinnerloop_1
	DEC R19
	BRNE SHORT_innerloop_1
	DEC R18
	BRNE SHORT_loop_1
	RET

;----------------------------------------------------------
; --------- RESET LIGHTS / TURN OFF ALL LIGHTS ------------
;----------------------------------------------------------
RESET_LIGHTS:
	LDI R17, 0b0000_0000 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS OFF
	OUT DDRA, R17		 ; TURN ALL LEDS OFF
	RET