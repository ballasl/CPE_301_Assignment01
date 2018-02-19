;
; CPE_301_Assignment01.asm
;
; Created: 2/8/2018 11:00:25 AM
; Author : Monty Sourjah Spring 2018
;
.INCLUDE "M328pDEF.INC"  ; Atmel Xplained mini 328p

   .cseg      ;Indicates that the next segment refers to program memory
	.org 0    ;burn into ROM starting at 0

	; Iteration Counter
	.def ITCOUNTERH=r20
	.def ITCOUNTERL=r21
	.def DIVCOUNTERH = r22
	.def DIVCOUNTERL = r23
	.def UNDIVCOUNTERH = r24
	.def UNDIVCOUNTERL = r25
	

	.equ LASTITERATION=299	; Max value of the decreasing counter - from 0 to 299 (300 iterations)

	rjmp start

DATATABLE:	
.db 0x03 ,0x12 ,0x5d ,0xd4 ,0x27 ,0xc6 ,0xe1 ,0x68 ,0x0b ,0x3a ,0x25 ,0xbc ,0xaf ,0x6e ,0x29 , \
0xd0 ,0x13 ,0x62 ,0xed ,0xa4 ,0x37 ,0x16 ,0x71 ,0x38 ,0x1b ,0x8a ,0xb5 ,0x8c ,0xbf ,0xbe , \
0xb9 ,0xa0 ,0x23 ,0xb2 ,0x7d ,0x74 ,0x47 ,0x66 ,0x01 ,0x08 ,0x2b ,0xda ,0x45 ,0x5c ,0xcf , \
0x0e ,0x49 ,0x70 ,0x33 ,0x02 ,0x0d ,0x44 ,0x57 ,0xb6 ,0x91 ,0xd8 ,0x3b ,0x2a ,0xd5 ,0x2c , \
0xdf ,0x5e ,0xd9 ,0x40 ,0x43 ,0x52 ,0x9d ,0x14 ,0x67 ,0x06 ,0x21 ,0xa8 ,0x4b ,0x7a ,0x65 , \
0xfc ,0xef ,0xae ,0x69 ,0x10 ,0x53 ,0xa2 ,0x2d ,0xe4 ,0x77 ,0x56 ,0xb1 ,0x78 ,0x5b ,0xca , \
0xf5 ,0xcc ,0xff ,0xfe ,0xf9 ,0xe0 ,0x63 ,0xf2 ,0xbd ,0xb4 ,0x87 ,0xa6 ,0x41 ,0x48 ,0x6b , \
0x1a ,0x85 ,0x9c ,0x0f ,0x4e ,0x89 ,0xb0 ,0x73 ,0x42 ,0x4d ,0x84 ,0x97 ,0xf6 ,0xd1 ,0x18 , \
0x7b ,0x6a ,0x15 ,0x6c ,0x1f ,0x9e ,0x19 ,0x80 ,0x83 ,0x92 ,0xdd ,0x54 ,0xa7 ,0x46 ,0x61 , \
0xe8 ,0x8b ,0xba ,0xa5 ,0x3c ,0x2f ,0xee ,0xa9 ,0x50 ,0x93 ,0xe2 ,0x6d ,0x24 ,0xb7 ,0x96 , \
0xf1 ,0xb8 ,0x9b ,0x0a ,0x35 ,0x0c ,0x3f ,0x3e ,0x39 ,0x20 ,0xa3 ,0x32 ,0xfd ,0xf4 ,0xc7 , \
0xe6 ,0x81 ,0x88 ,0xab ,0x5a ,0xc5 ,0xdc ,0x4f ,0x8e ,0xc9 ,0xf0 ,0xb3 ,0x82 ,0x8d ,0xc4 , \
0xd7 ,0x36 ,0x11 ,0x58 ,0xbb ,0xaa ,0x55 ,0xac ,0x5f ,0xde ,0x59 ,0xc0 ,0xc3 ,0xd2 ,0x1d , \
0x94 ,0xe7 ,0x86 ,0xa1 ,0x28 ,0xcb ,0xfa ,0xe5 ,0x7c ,0x6f ,0x2e ,0xe9 ,0x90 ,0xd3 ,0x22 , \
0xad ,0x64 ,0xf7 ,0xd6 ,0x31 ,0xf8 ,0xdb ,0x4a ,0x75 ,0x4c ,0x7f ,0x7e ,0x79 ,0x60 ,0xe3 , \
0x72 ,0x3d ,0x34 ,0x07 ,0x26 ,0xc1 ,0xc8 ,0xeb ,0x9a ,0x05 ,0x1c ,0x8f ,0xce ,0x09 ,0x30 , \
0xf3 ,0xc2 ,0xcd ,0x04 ,0x17 ,0x76 ,0x51 ,0x98 ,0xfb ,0xea ,0x95 ,0xec ,0x9f ,0x1e ,0x99 , \
0x00 ,0x3f ,0x70 ,0x33 ,0x7f ,0x60 ,0x07 ,0x76 ,0xab ,0x69 ,0xfb ,0x45 ,0xe8 ,0x1d ,0xda , \
0xae ,0xa5 ,0xf0 ,0x13 ,0x67 ,0x7e ,0xa1 ,0xf5 ,0xcc ,0x00 ,0x3f ,0x70 ,0x33 ,0x7f ,0x60 , \
0x07 ,0x76 ,0xab ,0x69 ,0xfb ,0x45 ,0xe8 ,0x1d ,0xda ,0xae ,0xa5 ,0xf0 ,0x13 ,0x67 ,0x7e 



start:

	; *** STORAGE STAGE ***

	; Initialize Iteration Counter with 299
	ldi ITCOUNTERL, (LASTITERATION & 0xFF)
	ldi ITCOUNTERH, ((LASTITERATION >> 8) & 0xFF)

	; X will point to the STARTADDS
	ldi XH, high(STARTADDS)
	ldi XL, low(STARTADDS)

    ; The Lookup table is stored in ROM, where bytes are stored as words.
	; We need to multiply by 2
	ldi ZH, high(2*DATATABLE)
	ldi ZL, low(2*DATATABLE)

	; Fill STARTADDS from our Lookup Table
    FillLoop:
	;Load Program memory(lpm).Read the table, then increment Z
	lpm r16, Z+
	;Register indirect addressing mode(Auto-increment)
	;copy R16 to memory location X.Store R16 in RAM and inc X
	st X+, r16
	;subtract immediate
	subi ITCOUNTERL, 1
	; SuBtract with Carry immediate
	sbci ITCOUNTERH, 0
	;Branch if Carry Cleared
	brcc FillLoop


	; *** PARSING STAGE ***

	; Now, we will separate the numbers into divisible by 5 and 
	; not divisible by 5

	; Initialize again the Iteration Counter with 299
	ldi ITCOUNTERL, (LASTITERATION & 0xFF)
	ldi ITCOUNTERH, ((LASTITERATION >> 8) & 0xFF)
	; X will point to the start of STARTADDS
	ldi XH, high(STARTADDS)
	ldi XL, low(STARTADDS)
	; Y will point to the start of DIVBY5
	ldi YH, high(DIVBY5)
	ldi YL, low(DIVBY5)
	; Z will point to the start of NOTDIVBY5
	ldi ZH, high(NOTDIVBY5)
	ldi ZL, low(NOTDIVBY5)
	; Initilize counters of multiples and not multiples of 5
	clr DIVCOUNTERH
	clr DIVCOUNTERL
	clr UNDIVCOUNTERH
	clr UNDIVCOUNTERL
	clr r19
	ldi r18,1

DivideLoop:
	ld r16, X+
	mov r17, r16	; Save it for later
	; We will check divisibility using successive subtrations of
	; 5 from r16 until the carry flag is set
DivideLoopAgain:
    ;Subtract Immediate
	subi r16, 5
	brcc DivideLoopAgain   ;Branch if Carry Clear
	subi r16, -5	; This the same as adding 5
	cpi r16,0       ;Compare with immediate
	breq RemainingIsZero ;Branch if equal
		st Z+, r17      ;Register indirect addressing mode(Auto-increment)
	                    ;copy R17 to memory location Z.Store R16 in RAM and inc Z
		add UNDIVCOUNTERL, r18
		adc UNDIVCOUNTERH, r19
		rjmp DivideCheckEnd
RemainingIsZero:
		st Y+, r17      ;Register indirect addressing mode(Auto-increment)
	                    ;copy R17 to memory location Y.Store R17 in RAM and inc Y
		add DIVCOUNTERL, r18
		adc DIVCOUNTERH, r19

	; Now, we will check if the 300 iterations limit was reached.
DivideCheckEnd:
	subi ITCOUNTERL, 1  ;Subtract Immediate
	sbci ITCOUNTERH, 0
	;Branch if Carry Clear
	brcc DivideLoop 

	;Task 3
	; **** ADDITIONS STAGE ***

	; Initialize
	; X will point to the start of DIVBY5
	ldi XH, high(DIVBY5)
	ldi XL, low(DIVBY5)
	; Y will point to the start of NOTDIVBY5
	ldi YH, high(NOTDIVBY5)
	ldi YL, low(NOTDIVBY5)

	; Zero our sum registers r16:r17 and r18_r19
	clr r16		
	clr r17
	clr r18
	clr r19
	clr r0		; This register will be used as a dummy 0 to perform addition with carry
	ldi r20, 3	; This register works as a flag to control the flow

	; Our sums loop will start here
SumLoop:
    ;Compare r20 with 1 
	cpi r20, 1		; Have with done only additions of multiples of 5 in the last iteration?
	breq SumDivBy5
	cpi r20, 3		; Also all kinds of additions in the last iteration?
	brne SumNotDiv	; Skip if we are done with the multiples of 5
SumDivBy5:
	clc
	subi DIVCOUNTERL,1  ;Subtract Immediate
	sbci DIVCOUNTERH, 0   ;Subtract Immediate with Carry
	;Logical AND with Immediate
	andi r20, 0xfe	; Clear up our flag - assume we are not adding multiples of 5
	brcs SumNotDiv   ;Branch if Carry Set
	    ;Logical OR with Immediate
		ori r20,1	; We are indeed adding multiples of 5
		ld r1, X+	; Load from memory to a temp register and increment memory pointer
		add r17, r1
		adc r16, r0  ;Add with Carry

SumNotDiv:
	; Have with done additions of non-multiples of 5 in the last iteration but not addition of multiples of 5 in this itertation?
	cpi r20, 2
	breq SumNotDivBy5
	; Have with done additions of non-multiples of 5 in the last iteration and addition of multiples of 5 in this itertation?
	cpi r20, 3  ;Compare r20 with 3
	brne SumCheckEnd  ;Branch if Not Equal
SumNotDivBy5:
	clc
	subi UNDIVCOUNTERL,1  ;Subtract Immediate
	sbci UNDIVCOUNTERH, 0  ;Subtract Immediate with Carry
	;Logical AND with Immediate
	andi r20, 0xfd	; Clear up our flag for no-multiples of 5.
	brcs SumCheckEnd
		ori r20, 2   ;Logical OR with Immediate
		ld r1, Y+	; Load from memory to a temp register and increment memory pointer
		add r19, r1
		adc r18, r0  ;;Add with Carry

SumCheckEnd:
;Compare r20 with 0
	cpi r20, 0	; If no operation has been done in this iteration we are done.
	brne SumLoop  ;Branch if Not Equal

; Expected result	
; Sum multiles of 5 = 0x1ed7
; Sum not multiples of 5 = 0x7663

stop:
	rjmp stop
	
	

	.dseg
	.org 0x222
	STARTADDS: .byte 300
	.org 0x400
	DIVBY5: .byte 300
	.org 0x600
	NOTDIVBY5: .byte 300

	