Num			DCD	0x40400000, 0xc0380000
			LDR	R4, =Num
			LDR	R5, [R4, #4]
			LDR	R4, [R4, #0]
			MOV	R0, R4
			MOV	R1, R5
			BL	subtracao
			END
;SUBTRACAO ==================================================
subtracao		STMDB	SP!, { R4-R12, LR }
			CMP	R1, #0
			BEQ	SubtCondEnd
			EOR	R1, R1, #0x80000000
SubtCondEnd	BL	soma
			LDMIA	SP!, { R4-R12, PC }
;SOMA =======================================================
soma			STMDB	SP!, { R4-R12, LR }
			MOV	R4, R0				;R4 = R0
			MOV	R5, R1				;R5 = R1
									;
			CMP	R4, #0				;if(R4 == 0){
				MOVEQ	R0, R5			;	R0 = R5
				BEQ	SomaEnd			;	return R0}
			CMP	R5, #0				;if(R5 == 0){
				MOVEQ	R0, R4			;	R0 = R4
				BEQ	SomaEnd			;	return R0;}
			MOV	R0, R4				;
			BL	mantissa				;
			MOV	R6, R0				;R6 = mantissa(R4)
			MOV	R0, R5				;
			BL	mantissa				;
			MOV	R7, R0				;R7 = mantissa(R5)
			MOV	R0, R4				;
			BL	expoentereal			;
			MOV	R8, R0				;R8 = exp(R4)
			MOV	R0, R5				;
			BL	expoentereal			;
			MOV	R9, R0				;R9 = exp(R5)
									;//Alinhar	mantissas
			CMP	R8, R9				;if(exp(R4) >= exp(R5)){
				BLO	ExpCondElse		;	//se for menor, saltar para else
				SUB	R10, R8, R9		;	R10 = R9-R8
				LSR	R7, R7, R10		;	mantissa(R4) >>= R10
				MOV	R2, R8			;	exp_ret = R9 //R2
				B	ExpCondEnd		;}
			ExpCondElse				;else{
				SUB	R10, R9, R8		;	R10 = R8-R9
				LSR	R6, R6, R10		;	mantissa(R5) >>= R10
				MOV	R2, R9			;	exp_ret = R8 //R2
			ExpCondEnd				;}
									;//R2	= exp_ret, R4,R5 = valores iniciais, R6,R7=mantissas alinhadas
									;//Ocupado:	R2, R4-R7
			MOV	R0, R4				;
			BL	sinal				;
			MOV	R8, R0				;R8 = sinal(R4)
			MOV	R0, R5				;
			BL	sinal				;
			MOV	R9, R0				;R9 = sinal(R5)
			CMP	R8, R9				;if(sinal(R4)==sinal(R5)){
				BNE	SinalCondElse		;	//se diferente, saltar para else
				ADD	R3, R6, R7		;	mantissa_ret = mantissa(R4)+mantissa(R5) //R3
				MOV	R1, R8			;	sinal_ret = sinal(R4) //R1
				B	SinalCondEnd			;}
			SinalCondElse				;else{
				CMP	R6, R7			;	if(mantissa(R4)>=mantissa(R5)){
					BLO	MantCondElse	;		//se falso, saltar para else
					SUB	R3, R6, R7	;		mantissa_ret = mantissa(R4)-mantissa(R5)
					MOV	R1, R8		;		sinal_ret = sinal(R4)
					B	MantCondEnd	;	}
				MantCondElse			;	else{
					SUB	R3, R7, R6	;		mantissa_ret = mantissa(R5)-mantissa(R4)
					MOV	R1, R9		;		sinal_ret = sinal(R5)
				MantCondEnd			;	}
			SinalCondEnd					;}//Agora, esta tudo direito: R[1-3]=(sinal,exp,mantissa)_ret
			MOV	R0, R3				;
			MOV	R3, R2				;
			MOV	R2, R1				;
			MOV	R1, R3				;//Agora, R[0-2] = (mantissa,exp,sinal)_ret
			BL	normaliza				;//Verificar se mantissa_ret esta normalizada
			MOV	R3, R0				;//Agora, R[1-3] = (exp,sinal,mantissa)_ret
			ADD	R1, R1, #127			;//K*
			LSL	R2, R2, #31			;//Mover sinal
			LSL	R1, R1, #23			;//Mover expoente
			BIC	R3, R3, #0x800000 		;//Eliminar parte decimal (1,...)->(,...)
			
			ADD	R0, R2, R1
			ADD	R0, R0, R3
			
SomaEnd		LDMIA	SP!, { R4-R12, PC }



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
