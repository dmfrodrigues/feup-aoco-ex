; (C) 2020 Diogo Rodrigues

val             DCD        0xc20a0000
            
entry           LDR R3, =val
                LDR R3, [R3]
                MOV R0, R3
                BL  sinal
                MOV R0, R3
                BL  expoentereal
                MOV R0, R3
                BL  mantissa
                END

;SINAL ======================================================
sinal           LSR R0, R0, #31
                MOV PC, LR
;EXPOENTEREAL ===============================================
expoentereal    LSL R0, R0, #1
                LSR R0, R0, #24
                SUB R0, R0, #127
                MOV PC, LR
;MANTISSA ===================================================
mantissa        LSL R0, R0, #9
                LSR R0, R0, #9
                ADD R0, R0, #0x800000
                MOV PC, LR
