;
; assemblerGame.asm
;
; Created: 3/15/2018 11:40:41 AM
; Author : Faizan & Tor

LDI R19, 0x7
STS 0x300, R19 ; UPDAING VALUE X IN SRAM


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

;----------------------------------------------------------
;----------------------- GAME INIT ------------------------
;----------------------------------------------------------
;------ from 301 sequence numbers are stored in memory-----

CLR R23
CLR R27
LDI R21, 1
CLR R10
ADD R10, R21
LDI R22, 0
LDI R27, 0
LDI R23, 0b0000_0001	; R23 represent the start Level and will increment every time a person wins one level
LDI R24, 0b1000_0000	; R24 represent the end level - when R23 reaches R24 game ends

LEVEL_LOOP:
;------------------- SHOW LEVEL LIGHTS -------------------
	ADD R27, R23
	LEVEL_LIGHT:		
		OUT DDRA, R27		 ; TURN LEVEL LEDS ON
		RCALL DELAY
		RCALL RESET_LIGHTS
		RCALL DELAY
		IN R17, PINB
		COM R17
		BREQ LEVEL_LIGHT


;------------------- GENERATE OUTPUT VALUES AND SHOW THEM -----------------
	INC R10
	LDI ZL, 0x01			; POINT Z to address $301 in memory
	LDI ZH, 0x03
	OUTPUT_LOOP:
		INC R22				; Number of times the INPUT_LOOP should run
		RCALL RANDOM_LOOP
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
				RCALL DELAY
				RCALL DELAY
				RCALL RESET_LIGHTS
				RCALL DELAY
		ST Z+, R25				; save number in memory and increment the address by 1
		DEC R10					; decrement R21 
		BRNE OUTPUT_LOOP		; if R20 is not zero, go back and output another number

		LDI R17, 0x0
		OUT DDRA, R17
		RCALL DELAY

;----------------------- RECEIVE INPUT FROM USER -----------------

	LDI ZL, 0x01		; reseting the Z pointer to $301
	LDI ZH, 0x03
	INPUT_LOOP:		
		INC R10
		LD R17, Z+				; Gets value from stack.
		OUT DDRA, R17			; SHOW HINT
		RCALL DELAY

		I1:		
			IN r16, pinb		; Gets input from button.
			OUT porta, r16		; Shows input on the led.
			COM R16				
			BREQ I1				; Check if a button has been pressed. If not it keeps looping 
			
		; Checks if input is correct
		CP R16, R17				; compares R16 with R17
		BRNE GAME_LOST			; If equals goes to check. 

		; If input is correct	 
		RCALL DELAY			
		DEC R22					; If input was correct it decreases R22 by 1.
		BRNE  INPUT_LOOP		; If R22 = 0 the round was won.
		RCALL ROUND_WON	

	ADD R23, R23				; Incease level by one. 
	CP R23, R24			
	BREQ GAME_WON				; If level equals final level game is won.
	RCALL LEVEL_LOOP			; Else it goes to next level.



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

RJMP Welcome				 ; START GAME AGAIN


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
RJMP GAME_START				; START GAME AGAIN

<<<<<<< HEAD
;----------------------------------------------------------
; ------------------- DELAY -------------------------------
;----------------------------------------------------------
; DELAY CALCUCATOIN
; Clock frequency = 125 kHz = 0,125 MHz
; 1 Machine cycle = 8 ns
; DELAY = ((74 * 1018 * 1018)  + 12 + 4 + 1) * 8ns
;		= (76687976 + 17) * 8ns
;	    = 613503944 ns = 0.613 seconds.
DELAY:										; INSTRUCTION CYCLES
	PUSH R18								; 2
	PUSH R19								; 2	
	PUSH R20								; 2

	LDI r18, 255							; 1
	LOOP_1:
		LDI r19, 255						; 1
		INNERLOOP_1:
			LDI r20, 25						; 1
				MOSTINNERLOOP_1:
				DEC r20						; 1
				BRNE MOSTINNERLOOP_1		; 2/1
			DEC r19							; 1
			BRNE INNERLOOP_1				; 2/1
		DEC r18								; 1
		BRNE LOOP_1							; 2/1

	POP R20									; 2
	POP R19									; 2
	POP R18									; 2
	RET										; 4

;----------------------------------------------------------
; ------------------- SHORT DELAY -------------------------
;----------------------------------------------------------
; DELAY CALCUCATOIN
; Clock frequency = 125 kHz = 0,125 MHz
; 1 Machine cycle = 8 ns
; DELAY = ((44 * 384 * 384)	+ 12 + 4 + 1) * 8 ns
;	    = (6488064 + 17) * 8
;       = 51904648 ns = 0,0519 seconds.
SHORT_DELAY:									; INSTRUCTION CYCLES
	PUSH R18									; 2		
	PUSH R19									; 2	
	PUSH R20									; 2

	LDI R18, 128								; 1
	SHORT_LOOP_1:
		LDI R19, 128							; 1
		SHORT_INNERLOOP_1:
			LDI R20, 15							; 1
				SHORT_MOSTINNERLOOP_1:
				DEC R20							; 1
				BRNE SHORT_MOSTINNERLOOP_1		; 2/1
			DEC R19								; 1
			BRNE SHORT_INNERLOOP_1				; 2/1
		DEC R18									; 1
		BRNE SHORT_LOOP_1						; 2/1

	POP R20										; 2
	POP R19										; 2
	POP R18										; 2	
	RET											; 4

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
>>>>>>> parent of 38ca08e... Merge branch 'master' of https://github.com/spaceCampBoy/asm-project

;----------------------------------------------------------
; --------- RESET LIGHTS / TURN OFF ALL LIGHTS ------------
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
	LDI R16, 0x1D
	LDI R17, 0xB
	LDI R18, 0x3B
	LDI R19, 0x7

	LDS R0, 0x300 ; GET VALUE X IN SRAM
	ADD R1, R16	; a = 29 
	ADD R2, R17	; c = 11 
	ADD R3, R18	; m = 59 

;--------- applying the formula-------
MUL R0,R1
ADD R0,R2

;-------module calculation---------
L1: 
	SUB	R0, R3
	BRCC L1		; BRANCH IF C IS ZERO

	ADD R0, R3	; ADD BACK TO IT

STS 0x300, R0 ; UPDAING VALUE X IN SRAM

<<<<<<< HEAD
	POP R18
	POP R17
	POP R16
	RET
=======
;------ DONE CALCULATING X VALUE-----
RET
>>>>>>> parent of 38ca08e... Merge branch 'master' of https://github.com/spaceCampBoy/asm-project
