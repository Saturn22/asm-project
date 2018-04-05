;
; testRandomNumberGenerator.asm
;

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


;------------------- GENERATE OUTPUT VALUES AND SAVE THEM -----------------
LDI ZL, 0x01		; SET Z POINTER TO ADDRESS $301 IN MEMORY
LDI ZH, 0x03
LDI R21, 2 ; SHOULD GENERATE 2 RANDOM NUMBERS | CHANGE THIS TO GENERATE MORE NUMBERS
OUTPUT_LOOP:
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
				CALL RESET_LIGHTS	 ; RESET LIGHTS

		ST Z+, R25				; SAVE NUMBER IN MEMORY AND INCREASE THE ADDRESS BY ONE
		DEC R21					; DEC R21 
		BRNE OUTPUT_LOOP		; IF NOT ZERO GO BACK AND OUTPUT ANOTHER NUMBER




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
