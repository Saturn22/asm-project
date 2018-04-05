;test sequence

; stack setup
ldi r16, high(RAMEND) ; 0x21
out sph, r16
ldi r16, low(RAMEND) ; 0xff
out spl, r16

ldi r17, 0xff ; ; 1111 1111 this is used for setting up output port
out ddra, r17

main: 
	RCALL WELCOME
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
WELCOME:
	PUSH R21
	PUSH R17

	LDI R21, 0x3	; R21 = 3 | TO RUN SEQUENCE 3 TIMES
	WELCOME_LOOP:
		LDI R17, 0b0000_0000 ; 0000_0000 TO TURN ALL LIGHTS ON
		OUT PORTA, R17		 ; TURN ALL LEDS ON
		CALL DELAY
		CALL RESET_LIGHTS	 ; TURN ALL LEDS OFF
		CALL DELAY			 ; TIME DELAY
		DEC R21
		BRNE WELCOME_LOOP

	POP R17
	POP R21
	RET


;----------------------------------------------------------
;---------------------- ROUND WON -------------------------
;----------------------------------------------------------

; ALL LIGHTS SHOULD BLINK IN SEQUENCE FROM LEFT TO RIGHT
ROUND_WON:
	PUSH R16
	PUSH R21
	PUSH R17

	LDI R21, 0x3		; R21 = 3 | TO RUN SEQUENCE 3 TIMES
	ROUND_WON_LIGHTS_LOOP1:
		LDI R16, 8				 ; TO RUN LOOP EIGHT TIMES TURNING ON ONE LED IN EACH LOOP (LEFT TO RIGHT)
		LDI R17, 0b0000_0001	 ; SAVE REGISTER VALUES TO TURN FIRST RIGHT LIGHT ON
		ROUND_WON_LIGHTS_LOOP2:
			COM R17
			OUT PORTA, R17		 ; TURN LIGHT ON
			COM R17
			LSL R17				 ; SHIFT R17 BITMASK TO LEFT
			RCALL SHORT_DELAY	 ; SHORT DELAY
			DEC R16				 ; DECREASE R16 UNTIL 0
			BRNE ROUND_WON_LIGHTS_LOOP2		; IF R16 NOT 0 THEN BRANCH TO TURN NEXT LED ON
		DEC R21							; DECREASE R21 UNTIL 0
		BRNE ROUND_WON_LIGHTS_LOOP1		; IF R16 NOT 0 THEN BRANCH
	CALL RESET_LIGHTS			 ; RESET LIGHTS

	POP R17
	POP R21
	POP R16
	RET


;----------------------------------------------------------
;---------------------- GAME WON --------------------------
;----------------------------------------------------------
; HALF OF LIGHTS SHOULD BLINK IN SEQUENCE FROM FAR LEFT TO RIGHT,
; HALF FROM FAR RIGHT TO LEFT, MEETING TOGETHER IN MIDDLE(LIKE A CLAP)
GAME_WON:
	PUSH R17
	PUSH R21
	
	LDI R21, 0x32			; R21 = 50 | TO RUN SEQUENCE 50 TIMES
	END_GAME_LOOP:
		LDI R17, 0b0111_1110	; SAVE REGISTERS VALUES
		OUT PORTA, R17		 ; TURN ALL LEDS ON
		CALL SHORT_DELAY	 ; SHORT DELAY
		
		LDI R17, 0b0011_1100	; SAVE REGISTERS VALUES
		OUT PORTA, R17		 ; TURN ALL LEDS ON
		CALL SHORT_DELAY	 ; SHORT DELAY

		LDI R17, 0b0001_1000	; SAVE REGISTERS VALUES
		OUT PORTA, R17		 ; TURN ALL LEDS ON
		CALL SHORT_DELAY	 ; SHORT DELAY

		LDI R17, 0b0000_0000	; SAVE REGISTERS VALUES
		OUT PORTA, R17		 ; TURN ALL LEDS ON
		CALL SHORT_DELAY	 ; SHORT DELAY

		CALL RESET_LIGHTS	 ; TURN ALL LEDS OFF
		DEC R21				 ; DESCREASE R21 UNTIL 0
		BRNE END_GAME_LOOP	 ; BRANCH IF NOT 0
	CALL RESET_LIGHTS		 ; RESET LIGHTS
	CALL DELAY				; DELAY
	CALL DELAY				; DELAY

	POP R21
	POP R17

	RET


;----------------------------------------------------------
;---------------------- GAME LOST -------------------------
;----------------------------------------------------------
; ALL LIGHTS SHOULD TURN ON TOGETHER FOR A LONG TIME

GAME_LOST:
	PUSH R17
	PUSH R21

	LDI R17, 0b0000_0000 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS ON
	OUT PORTA, R17		 ; TURN ALL LIGHTS ON

	LDI R21, 0x14		 ; R21 = 20 | TO RUN DELAY SEQUENCE 20 TIMES
	GAME_LOST_DELAY:	 ; DELAY TO KEEP LIGHTS LIT FOR LONG TIME
		CALL DELAY
		DEC R21		
		BRNE GAME_LOST_DELAY

	CALL RESET_LIGHTS	 ; RESET LIGHTS
	CALL DELAY			 ; DELAY
	CALL DELAY

	POP R21
	POP R17
	RET

;----------------------------------------------------------
; ------------------- DELAY -------------------------------
;----------------------------------------------------------
DELAY:
	PUSH R18
	PUSH R19
	PUSH R20

	LDI r18, 255
	LOOP_1:
		LDI r19, 255
		INNERLOOP_1:
			LDI r20, 25
				MOSTINNERLOOP_1:
				DEC r20
				BRNE MOSTINNERLOOP_1
			DEC r19
			BRNE INNERLOOP_1
		DEC r18
		BRNE LOOP_1

	POP R20
	POP R19
	POP R18
	RET

;----------------------------------------------------------
; ------------------- SHORT DELAY -------------------------
;----------------------------------------------------------
SHORT_DELAY:
	PUSH R18
	PUSH R19
	PUSH R20

	LDI R18, 128
	SHORT_LOOP_1:
		LDI R19, 128
		SHORT_INNERLOOP_1:
			LDI R20, 15
				SHORT_MOSTINNERLOOP_1:
				DEC R20
				BRNE SHORT_MOSTINNERLOOP_1
			DEC R19
			BRNE SHORT_INNERLOOP_1
		DEC R18
		BRNE SHORT_LOOP_1

	POP R20
	POP R19
	POP R18
	RET

;----------------------------------------------------------
; --------- RESET LIGHTS / TURN OFF ALL LIGHTS ------------
;----------------------------------------------------------
RESET_LIGHTS:
	PUSH R17
	LDI R17, 0b1111_1111 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS OFF
	OUT PORTA, R17		 ; TURN ALL LEDS OFF
	POP R17
	RET