; (C) 2020 Diogo Rodrigues

;SINAL ======================================================
sinal		LSR	R0,	R0, #31
			MOV	PC,	LR
;EXPOENTEREAL ===============================================
expoentereal	LSL	R0,	R0,	#1
			LSR	R0,	R0,	#24
			SUB	R0,	R0,	#127
			MOV	PC,	LR
;MANTISSA ===================================================
mantissa		LSL	R0,	R0,	#9
			LSR	R0,	R0,	#9
			ADD	R0,	R0,	#0x800000
			MOV	PC,	LR
;NORMALIZA(mantissa,exp) ====================================
normaliza
norm_loop1	CMP	R0, #0x1000000
			BLO	norm_end1
			LSR	R0, R0, #1
			ADD	R1, R1, #1
			B	norm_loop1
norm_end1
norm_loop2	CMP	R0, #0x800000
			BHS	norm_end2
			LSL	R0, R0, #1
			SUB	R1, R1, #1
			B	norm_loop2
norm_end2
			MOV	PC, LR
