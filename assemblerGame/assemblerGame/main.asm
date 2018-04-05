;
; assemblerGame.asm
;
; Created: 3/15/2018 11:40:41 AM
; Author : Faizan & Tor

;----------------------------------------------------------
;--------------------- CONFIGURATION ----------------------
;----------------------------------------------------------
; stack setup
ldi r16, high(RAMEND)	; 0x21
out sph, r16
ldi r16, low(RAMEND)	; 0xff
out spl, r16

LDI R19, 0x7
STS 0x300, R19		; X = 7 |  STORING X VALUE IN SRAM FOR RANDOM NUMBER GENERATOR
;NOTE: R0 IS USED TO REPRESENT THE VALUE OF X FOR RANDOM NUMBER GENERATOR
ldi r17, 0xff		; 1111_1111 this is used for setting up the output port
out ddra, r17


;----------------------------------------------------------
;----------------------- GAME START -----------------------
;----------------------------------------------------------
;---- from $301, sequence numbers are stored in memory ----

GAME_START:
	CALL WELCOME			; SHOW WELCOME SEQUENCE	

	LDI R23, 0b0000_0001	; R23 IS USED FOR CALCULATING THE CURRENT LEVEL
	LDI R24, 0b1111_1111	; R24 represent the end level - when R27 reaches R24 game ends
	LDI R27, 0				; R27 REPRESENTS THE ACTUAL LEVEL | AT START OF THE GAME IT IS CLEARED

	LDI R21, 1				; R21 REPRESENTS QUANTITY OF OUTPUT VALUES | INCREASES WITH EVERY LEVEL
	LDI R22, 0				; R22 REPRESENTS QUANTITY OF INPUT VALUES | INCREASES WITH EVERY LEVEL
	

	LEVEL_LOOP:
		;------------------- SHOW LEVEL LIGHTS AND WAIT FOR ANY INPUT -------------------
		ADD R27, R23	; INCREASING LEVEL
		ADD R23, R23	; INCREASE THIS FOR CALCULATING NEXT LEVEL 
		LEVEL_LIGHT:
			COM R27				 ; COMPLEMENTING R27 BECAUSE OF stk600
			OUT PORTA, R27		 ; TURN LEVEL LEDS ON
			COM R27				 ; COMPLEMENTING R27 BECAUSE OF stk600
			CALL SHORT_DELAY
			CALL RESET_LIGHTS	 ; RESET LIGHTS
			CALL SHORT_DELAY
			IN R17, PINB		 ; TRY TO RECIEVE INPUT FROM USER
			COM R17				 ; COMPLEMENT R17 TO CHECK IF ANY INPUT WAS GIVEN
			BREQ LEVEL_LIGHT


	;------------------- GENERATE OUTPUT VALUES AND SHOW THEM -----------------
		
	LDI ZL, 0x01		; SET Z POINTER TO ADDRESS $301 IN MEMORY
	LDI ZH, 0x03
	INC R21				; INCREMENT R21
	OUTPUT_LOOP:
		INC R22				; INCREMENT NUMBER OF TIME THE INPUT_LOOP SHOULD RUN
		CALL RANDOM_LOOP	; GENERATE A RANDOM NUMBER FOR GENERATING AN OUTPUT NUMBER | SAVED IN R0 
		OUTPUT_NUMBER:
			LDI R25, 0b0000_0001				; STARTING VALUE OF OUTPUT NUMBER
			DEC R0								; DEC R0 
			BRNE OUTPUT_NUMBER_GENERATOR		; IF NOT 0, THEN BRANCH TO OUTPUT_NUMBER_GENERATOR 
			RJMP SHOW_NUMBER					; ELSE JUMP TO SHOW NUMBER

				OUTPUT_NUMBER_GENERATOR:
					ADD R25,R25						; SUM R25 WITH ITSELF TO SHIFT ITS VALUES TO LEFT
					BREQ OUTPUT_NUMBER				; IF R25 = 0 THEN IT BRANCHES TO OUTPUT_NUMBER AND STARTS OVER WITH R25 = 1
					DEC R0							; DEC R0 UNTIL 0
					BRNE OUTPUT_NUMBER_GENERATOR	; IF NOT 0, THEN LOOP ON

			SHOW_NUMBER: 
				COM R25				 ; COMPLEMENTING R27 BECAUSE OF stk600
				OUT PORTA, R25		 ; TURN ON LED OF GENERATED NUMBER
				COM R25				 ; COMPLEMENTING R27 BECAUSE OF stk600
				CALL DELAY			 ; DELAY
				CALL DELAY
				CALL RESET_LIGHTS	 ; RESET LIGHTS
				CALL DELAY

		ST Z+, R25				; SAVE NUMBER IN MEMORY AND INCREASE THE ADDRESS BY ONE
		DEC R21					; DEC R21 
		BRNE OUTPUT_LOOP		; IF NOT ZERO GO BACK AND OUTPUT ANOTHER NUMBER

;----------------------- RECEIVE INPUT FROM USER -----------------

	LDI ZL, 0x01		; RESET THE Z POINTER TO ADDRESS $301 IN MEMORY
	LDI ZH, 0x03

	INPUT_LOOP:		
		INC R21				; INCREMENT NUMBER OF TIME THE OUTPUT_LOOP SHOULD RUN
		LD R17, Z+			; LOAD VALUE FROM MEMORY AND INCREMENT THE ADDRESS BY ONE.

		I1:		
			IN r16, pinb		; Gets input from button.
			OUT porta, r16		; Shows input on the led.
			COM R16				
			BREQ I1				; Check if a button has been pressed. If not it keeps looping 
			
		;--------------- Check if input is correct --------------
		CP R16, R17				; COMPARE INPUT VALUE WITH SAVED OUTPUT VALUE | R16 WITH R17
		BREQ INPUT_CORRECT
		RJMP GAME_LOST			; BRANCH TO GAME_LOST IF NOT EQUAL

		;-------------- If input is correct	----------------
		INPUT_CORRECT:
			CALL DELAY			
			DEC R22					; IF INPUT WAS CORRECT DEC R22 by 1.
			BRNE  INPUT_LOOP		; If R22 = 0 the round was won.
			CALL ROUND_WON	
	;------------- CHECK IF FINAL LEVEL ------------
	CP R27, R24					; CHECK IF IT WAS THE FINAL LEVEL
	BREQ GAME_WON				; IF LEVEL EQUALS FINAL LEVEL THE GAME IS WON
	RCALL LEVEL_LOOP			; ELSE GO TO NEXT LEVEL



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

RJMP GAME_START				 ; START GAME AGAIN

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

RJMP GAME_START				; START GAME AGAIN

<<<<<<< HEAD
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
=======
	;----------------------------------------------------------
	; ------------------- DELAY -------------------------------
	;----------------------------------------------------------
	; DELAY CALCUCATOIN
	; Clock frequency 10 MHz
	; DELAY = 4.876.875 + 260.100 + 3825 + 4 + 1 * 1000 ns 
	;		= 5.140.805 * 1000 ns = 5.072.719.000 
	;	    = 

	DELAY:
		LDI r18, 255
		LOOP_!:
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
		RET

	;----------------------------------------------------------
	; ------------------- SHORT DELAY -------------------------
	;----------------------------------------------------------
	; DELAY CALCUCATOIN
	; Clock frequency 10 MHz
	; DELAY = 737.280 + 65.536 + 640 + 4 + 1 * 1000 ns
	;	    = 803.461 * 1000 ns 
	;       =

	SHORT_DELAY:
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
		RET
>>>>>>> 12c8cd566983e2bb75ced5df39ea7f71b9f4770a


;----------------------------------------------------------
; --------- RESET LIGHTS / TURN OFF ALL LIGHTS ------------
;----------------------------------------------------------
RESET_LIGHTS:
	PUSH R17

	LDI R17, 0b1111_1111 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS OFF
	OUT PORTA, R17		 ; TURN ALL LEDS OFF

	POP R17
	RET


;----------------------------------------------------------
; -------------- RANDOM LOOP FREQUENCY GENERATOR ------------------
;----------------------------------------------------------
; To generate random number Linear Congruential Generator (LCG) algorithm is used
; Formula Xn+1 = (aXn + c) Mod m; 
; where a and c are relativly prime for better randomness
; and X is stored in internal storage so it can be used as a seed for every calculation
RANDOM_LOOP:
	PUSH R16
	PUSH R17
	PUSH R18

	LDI R16, 0x1D		; a = 29 
	LDI R17, 0xB		; c = 11 
	LDI R18, 0x3B		; m = 59 
	LDS R0, 0x300		; GET VALUE X IN SRAM

	;--------- applying the formula-------
	MUL R0,R16
	ADD R0,R17

	;-------module calculation---------
	L1: 
		SUB	R0, R18
		BRCC L1		; BRANCH IF C IS ZERO

		ADD R0, R18	; ADD BACK TO IT

	STS 0x300, R0 ; UPDAING VALUE X IN SRAM

	;------ DONE CALCULATING X(R0) VALUE-----

	POP R18
	POP R17
	POP R16

	RET
