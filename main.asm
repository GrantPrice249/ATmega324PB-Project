.def counter = r16
.def temp = r25

; Stack Pointer initialization
.ORG 0
LDI counter, HIGH(RAMEND)
OUT SPH, counter
LDI counter, LOW(RAMEND)
OUT SPL, counter

ldi counter, 0x00        ; Counter register
ldi r17, 0x00        ; Previous button state
ldi r18, 0x03        ; Mask for PA0 and PA1

; set PORTA as input
ldi r20, 0x00
out DDRA, r20
ldi r20, 0x07
out PORTA, r20

; LED Setup
LDI R21, 0b00001111
OUT DDRD, R21
SBI DDRE, 5
SBI DDRE, 4

main:
	; Increment/Decrement Buttons
	rcall counter_loop

	; Auto-Decrement Button
	SBIS PINA, 2
		RCALL AUTO_DECREMENT

	rjmp main

counter_loop:
    in r19, PINA         ; read current button state
    and r19, r18         ; mask to PA0 and PA1

    ; Check for button press and release
    cp r19, r17          ; compare current and previous state
    breq no_change       ; if same, reset loop

    ; Button 1 (PA0) pressed
    sbrs r19, 0          ; skip if bit 0 is set
    rcall TwentyFivetoZero ; checks for overflow and increments counter if not exists

    ; Button 2 (PA1) pressed
    sbrs r19, 1          ; skip if bit 1 is set
    rcall ZeroToTwentyFive   ; checks for overflow and decrements counter if not exists

    ; Update previous state
    mov r17, r19

	; Update LEDs
	rcall LED_ON

	; Delay so flickering switch doesn't cause multiple increments/decrements
	rcall delay_100ms
	RET

no_change:
    RET; Return to main loop

; LED Function
LED_ON:
	SBI PORTD, 0
	SBRC counter, 0
	CBI PORTD, 0
	SBI PORTD, 1
	SBRC counter, 1
	CBI PORTD, 1
	SBI PORTD, 2
	SBRC counter, 2
	CBI PORTD, 2
	SBI PORTD, 3
	SBRC counter, 3
	CBI PORTD, 3
	SBI PORTE, 5
	SBRC counter, 4
	CBI PORTE, 5
	RET

AUTO_DECREMENT:
	; Wait for button to be released
	NOT_RELEASED:
		SBIS PINA, 2
			RJMP NOT_RELEASED

	; Decrement counter every 100ms. When counter == 0, go to alarm
	DEC_LOOP:
		tst counter
		BREQ ALARM
		DEC counter
		RCALL LED_ON
		RCALL delay_100ms ; Fixed :)
		RJMP DEC_LOOP

	ALARM:
		RCALL play_alarm
		RET

;plays 1kHz for .499s
play_alarm:
	ldi temp, 100 
	tone_loop:
		sbi PORTE, 4 ; Buzzer pin set high
		rcall delay_500us
		cbi PORTE, 4; Buzzer pin set low
		rcall delay_500us
		dec temp
		brne tone_loop
	ldi counter, 0
	ret

;100 ms delay
delay_100ms: ldi temp, 35
loop11: rcall delay_1ms
	dec temp
	brne loop11
	ret

;1ms delay
delay_1ms: ldi r22, 100
loop_1: ldi r23, 160
loop_2: dec r23
	brne loop_2
	dec r22
	brne loop_1
	ret

;500us delay
delay_500us:
    ldi r27, 250         ; outer loop count
loop___1:				; we ran out of registers :(
	nop					; I needed 26 nops for the math to be right 
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	
	nop
	nop
	nop
	nop
	nop
	nop
	dec r27
	brne loop___1
	ret
 
delay1:	ldi r30, 200 ;1kHz delay
Loop1:	ldi r31, 13
		nop
Loop2:	dec r31
		brne Loop2
		dec r30
		brne Loop1
		ret

delay15:ldi r30, 200 ;1.5kHz delay
Loop15:	ldi r31, 12
		nop
Loop25:	dec r31
		brne Loop25
		dec r30
		brne Loop15
		ret

TwentyFivetoZero: ; Plays a sound if the counter increments past 25 and resets it to zero
		ldi r28, 25
		cp r28, counter
		breq IsTwentyFive
		inc counter
		ret
	IsTwentyFive:	
		ldi temp, 100
		TwentyFiveLoop: 
			sbi PORTE, 4 ; Buzzer pin set high
			rcall delay15
			cbi PORTE, 4; Buzzer pin set low
			rcall delay15
			dec temp
			brne TwentyFiveLoop
		ldi counter, 0
		ret

ZeroToTwentyFive: ; Plays a sound if the counter decrements below 0 and resets it to 25
		ldi r28, 0
		cp r28, counter
		breq IsZero
		dec counter
		ret
	IsZero:	
		ldi temp, 100
		ZeroLoop: 
			sbi PORTE, 4 ; Buzzer pin set high
			rcall delay1
			cbi PORTE, 4; Buzzer pin set low
			rcall delay1
			dec temp
			brne ZeroLoop
		ldi counter, 25
		ret

