/*
 * first_task.asm
 *
 *  Created: 06.10.2023 0:18:25
 *   Author: helge
 * Задание: 
 * При инициализации контроллера вводиться 5 чисел в РОН. 
 * Программа должна найти (любым способом) наименьшее число, после чего обнулить его. 
 * Программа выполняется до тех пор, пока все 5 чисел не будут равны 0, после чего выполняется заново инициализация.
 */ 


.include "m16def.inc" ; Используем ATMega16
.equ R16_ADDR = 0x10
.equ R17_ADDR = 0x11
.equ R18_ADDR = 0x12
.equ R19_ADDR = 0x13
.equ R20_ADDR = 0x14
.equ BITS = 0b11111
.def ARG_REG = R22
.def ZERO = R24
.def arg = R21
.def ZERO_BITS = R27
.def COUNT_OF_ZEROS = R28
; MACRO ===================================================

.MACRO CHANGE_ARG
	lds arg, @0
	ldi ARG_REG, @0
.ENDM

; RAM =====================================================

.DSEG 


; FLASH ===================================================

.CSEG ; Кодовый сегмент

; Инициализируем стек

ldi R16, Low(RAMEND)
out SPL, R16

ldi R16, High(RAMEND)
out SPH, R16

 ; Инициализация пяти чисел 
Start: 
	 ldi R16, 250
	 ldi R17, 77
	 ldi R18, 153
	 ldi R19, 122
	 ldi R20, 177
	 clr ZERO  
	 ldi ZERO_BITS, 31
	 call MIN_FUNCTION
	 rjmp Start

MIN_FUNCTION:
	clr COUNT_OF_ZEROS ; во время цикла считаем количество нулей, когда все регистры с нулем, то выходим из функции
	call CHOOSE_REG
	cp R16, ZERO
	breq R16_Z_INC
	cp arg, R16
	brcs R17_M
	CHANGE_ARG R16_ADDR
	rjmp R17_M
R16_Z_INC: 
	inc COUNT_OF_ZEROS
	subi ZERO_BITS, 16

R17_M: 
	cp R17, ZERO
	breq R17_Z_INC 
	cp arg, R17
	brcs R18_M
	CHANGE_ARG R17_ADDR
	rjmp R18_M
R17_Z_INC: 
	inc COUNT_OF_ZEROS
	subi ZERO_BITS, 8
R18_M:
	cp R18, ZERO
	breq R18_Z_INC 
	cp arg, R18
	brcs R19_M
	CHANGE_ARG R18_ADDR
	rjmp R19_M
R18_Z_INC: 
	inc COUNT_OF_ZEROS
	subi ZERO_BITS, 4
R19_M:
	cp R19, ZERO
	breq R19_Z_INC 
	cp arg, R19
	brcs R20_M
	CHANGE_ARG R19_ADDR
	rjmp R20_M
R19_Z_INC: 
	inc COUNT_OF_ZEROS
	subi ZERO_BITS, 2
R20_M:
	cp R20, ZERO
	breq R20_Z_INC
	cp arg, R20
	brcs CHECK
	CHANGE_ARG R20_ADDR
	rjmp CHECK
R20_Z_INC: 
	inc COUNT_OF_ZEROS
	subi ZERO_BITS, 1
CHECK: 
	call CLR_REG
	cpi COUNT_OF_ZEROS, 5
	brcs MIN_FUNCTION
	ret

CHOOSE_REG: ; выбираем не нулевой регистр, с которым мы будем сравнивать остальные 
	mov R26, ZERO_BITS
	andi R26, BITS
	cpi R26, 16 
	brcs M1
	CHANGE_ARG R16_ADDR
	rjmp END
M1:
	cpi R26, 8
	brcs M2
	CHANGE_ARG R17_ADDR
	rjmp END
M2: 
	cpi R26, 4
	brcs M3
	CHANGE_ARG R18_ADDR
	rjmp END
M3:
	cpi R26, 2
	brcs M4
	CHANGE_ARG R19_ADDR
	rjmp END
M4: CHANGE_ARG R20_ADDR
END: ret 

CLR_REG:
	subi ARG_REG, 0xF
	cpi ARG_REG, 1 
	breq CLR_R16
	cpi ARG_REG, 2
	breq CLR_R17
	cpi ARG_REG, 3
	breq CLR_R18 
	cpi ARG_REG, 4
	breq CLR_R19
	cpi ARG_REG, 5
	breq CLR_R20
CLR_R16: clr R16
CLR_R17: clr R17
CLR_R18: clr R18
CLR_R19: clr R19
CLR_R20: clr R20
	ret 