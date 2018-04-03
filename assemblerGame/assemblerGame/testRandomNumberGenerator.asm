;
; testRandomNumberGenerator.asm
;

;---------------------------------------------------------------------------------------
;-------------------------- STORING X VALUE IN SRAM FOR RANDOM NUMBER GENERATOR --------
;---------------------------------------------------------------------------------------
LDI R19, 0x7
STS 0x300, R19 ; X = 7 | STORING VALUE IN SRAM FOR FURTHER USE


;------------------- GENERATE OUTPUT VALUES AND SHOW THEM -----------------
LDI R21, 8 ; SHOULD GENERATE 8 RANDOM NUMBERS
OUTPUT_LOOP:
	CALL RANDOM_LOOP
	NUMBER_1:
		LDI R25, 0b0000_0001
		DEC R0					; decrements the R0 to see if it is zero
		BRNE NUMBER_1_LOOP		; If R0 is not 0, then jump to number_loop
		RJMP SHOW_NUMBER
			NUMBER_1_LOOP:
				ADD R25,R25		; adding R25 two times
				BREQ NUMBER_1	; If R25 = 0 then it goes back to R25 = 1
				DEC R0			; decrementing R0 until 0
				BRNE NUMBER_1_LOOP ; if R0 is not 0, then Loop on
		SHOW_NUMBER:			; show generated number
			CLR R17
			ADD R17, R25
			OUT DDRA, R17		 ; TURN NUMBER LIGHT ON
			CALL DELAY
			CALL DELAY
			CALL RESET_LIGHTS	; Reset lights for next number
			CALL DELAY
	DEC R21					; decrement R21 
	BRNE OUTPUT_LOOP		; if R21 is not zero, go back and output another number


;----------------------------------------------------------
; ------------------- DELAY -------------------------------
;----------------------------------------------------------
DELAY:
	ldi r18, 255
	loop_1:
	ldi r19, 255
	innerloop_1:
	ldi r20, 25
	mostinnerloop_1:
	dec r20
	brne mostinnerloop_1
	dec r19
	brne innerloop_1
	dec r18
	brne loop_1
	ret


;----------------------------------------------------------
; ------------------- RESET LIGHTS / TURN OFF ALL LIGHTS -----------------------
;----------------------------------------------------------
RESET_LIGHTS:
	LDI R17, 0b0000_0000 ; SAVE REGISTERS VALUES TO TURN ALL LIGHTS OFF
	OUT DDRA, R17		 ; TURN ALL LEDS OFF
	RET



;----------------------------------------------------------
; -------------- RANDOM LOOP FREQUENCY GENERATOR ------------------
;----------------------------------------------------------
; To generate random number Linear Congruential Generator (LCG) algorithm is used
; Formula Xn+1 = (aXn + c) Mod m; 
; where a and c are relativly prime for better randomness
; and X is stored in internal storage so it can be used as a seed for every calculation
RANDOM_LOOP:
	
	LDI R16, 0x1D 	; a = 29 
	LDI R17, 0xB	; c = 11 
	LDI R18, 0x3B	; m = 59 
	LDS R0, 0x300 ; GET VALUE X IN SRAM

	;--------- applying the formula-------

	MUL R0,R16
	ADD R0,R17

	;-------module calculation---------
	L1: 
		SUB	R0, R18
		BRCC L1					; BRANCH IF C IS ZERO

		ADD R0, R18	; ADD BACK TO IT

	STS 0x300, R0 ; UPDAING VALUE X IN SRAM

	;------ DONE CALCULATING X VALUE-----

RET
