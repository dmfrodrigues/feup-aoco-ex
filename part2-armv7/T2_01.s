; (C) 2020 Diogo Rodrigues

seqA		DCD		3,-5,21,2,-10,50,9
tseqA	DCD		7
		
		LDR		R0, =tseqA
		LDR		R0, [R0]
		LDR		R1, =seqA
ciclo	CMP		R0, #0
		BEQ		fim
		LDR		R2, [R1]
		LSL		R2, R2, #1
		STR		R2, [R1]
		ADD		R1, R1, #4
		SUB		R0, R0, #1
		B		ciclo
fim		END
