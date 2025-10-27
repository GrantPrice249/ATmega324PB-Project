.def counter = r16

ldi counter, 0x00        ; Counter register
ldi r17, 0x00        ; Previous button state
ldi r18, 0x03        ; Mask for PA0 and PA1

; set PORTA as input
ldi r20, 0x00
out DDRA, r20        ; set PA0 and PA1 as input
ldi r20, 0x03
out PORTA, r20

counter_loop:
    in r19, PINA         ; read current button state
    and r19, r18         ; mask to PA0 and PA1

    ; Check for button press and release
    cp r19, r17          ; compare current and previous state
    breq no_change       ; if same, reset loop

    ; Button 1 (PA0) pressed
    sbrs r19, 0          ; skip if bit 0 is set
    inc counter              ; increment counter

    ; Button 2 (PA1) pressed
    sbrs r19, 1          ; skip if bit 1 is set
    dec counter              ; decrement counter

    ; Update previous state
    mov r17, r19
	rjmp counter_loop       ; repeat loop

no_change:
    rjmp counter_loop       ; repeat loop

;plays 1kHz for .499s
play_alarm:
	ldi temp, 250 ; 500ms / 2 = (250 cycles)
tone_loop:
	sbi PORTB, BUZZER ; Buzzer pin set high
	rcall delay_500us
	cbi PORTB, BUZZER; Buzzer pin set low
	rcall delay_500us
	dec temp
	brne tone_loop
	ret

;100.6 ms delay
delay_100ms:
	ldi temp,100
delay_100ms_loop:
	rcall delay_1ms
	dec temp
	brne delay_100ms_loop
	ret

;1ms delay
delay_1ms:
	ldi delayCnt, 332
delay_1ms_loop:
	dec delayCnt
	brne delay_1ms_loop
	ret

;500us delay
delay_500us:
	ldi delayCnt, 125
delay_500us_loop:
	dec delayCnt
	brne delay_500us_loop
	ret
