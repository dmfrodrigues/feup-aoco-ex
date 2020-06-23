; (C) 2020 Diogo Rodrigues

Num			DCD	0x40400000, 0xc0380000
			LDR	R4, =Num
			LDR	R5, [R4, #4]
			LDR	R4, [R4, #0]
			MOV	R0, R4
			MOV	R1, R5
			BL	multiplica
			END

;MULTIPLICA =================================================
multiplica	STMDB	SP!, { R4-R12, LR }
			CMP	R4, #0			;if(R4==0)
				MOVEQ	R0, #0	;jump to Arg0True
				BEQ	MulEnd
			CMP	R5, #0			;if(R5==0)
				MOVEQ	R0, #0	;	jump to Arg0True
				BEQ		MulEnd	;if both false, jump to after this thing
			MOV	R0, R4			;
			BL	sinal			;
			MOV	R6, R0			;
			MOV	R0, R5			;
			BL	sinal			;
			EOR	R6, R6, R0		;//Agora, R4,R5=R0,R1, e R6=sinal_ret
								;
			MOV	R0, R4			;
			BL	expoentereal		;
			MOV	R7, R0			;
			MOV	R0, R5			;
			BL	expoentereal		;
			ADD	R7, R7, R0		;//Agora, R4,R5=R0,R1, e R[6,7]=(sinal,exp)_ret
								;
			MOV	R0, R5			;
			BL	mantissa			;
			MOV	R1, R0			;
			MOV	R0, R4			;
			BL	mantissa			;//Agora, R0,R1=mantissa(R4,R5), R4,R5=R0,R1, e R[6,7]=(sinal,exp)_ret
			BL	peasantmul		;//Agora, R0=mantissa_ret, R[6,7]=(sinal,exp)_ret
			MOV	R1, R7			;//Agora, R[0,1]=(mantissa,exp)_ret, R6=sinal_ret
			BL	normaliza			;//(mantissa,exp)_ret foram normalizados
								;//Agora, R[0,1]=(mantissa,exp)_ret, R6=sinal_ret
			MOV	R2, R0			;//Agora, R[1,2]=(exp,mantissa)_ret, R6=sinal_ret
			EOR	R2, R2, #0x800000
			
			LSL	R0, R6, #31
			ADD	R1, R1, #127
			LSL	R1, R1, #23
			ADD	R0, R0, R1
			ADD	R0, R0, R2
			
MulEnd		LDMIA	SP!, { R4-R12, PC }
;PEASANTMUL =================================================
peasantmul	LSR	R2, R0, #8
			LSR	R3, R1, #8
			MOV	R0, #0
PeasLoop		CMP	R2, #0
				BEQ	PeasLoopEnd
				TST	R2, #0b1		
					ADDNE	R0, R0, R3
				LSR	R2, R2, #1
				LSL	R3, R3, #1
				B	PeasLoop
PeasLoopEnd
			LSR	R0, R0, #7
			MOV	PC, LR
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
