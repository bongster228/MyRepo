; Bong Lee
; CS218 1001
; Ast04

%macro tstStats 8
	;mov r8, %2
	;mov r9, %1
	;mov rsi, 0
	;mov rcx, 0
	;mov ecx, %3
	;mov rax, 0
	;mov rbx, 0
	;%%sqLoop:
	;mov ax, word[r8+rsi*2]
	;mul ax
	;mov word[sqVal], ax
	;mov word[sqVal+2], dx
	;mov ebx, dword[sqVal]
	;mov dword[r9+rsi*4], ebx
	;inc rsi
	;loop %%sqLoop

	mov r8, %2
	mov r9, %1
	mov rcx, 0
	mov ecx, %3
	mov rsi, 0
	mov rax, 0

	%%sqLoop
	mov ax, word[r8+rsi*2]
	mul ax
	mov word[sqVal], ax
	mov word[sqVal+2], dx
	mov ebx, dword[sqVal]
	mov dword[r9+rsi*4], ebx
	inc rsi
	loop %%sqLoop

	; Find min & max
	mov esi, dword[r9]
	mov %4, esi

	mov ecx, %3
	mov esi, dword[r9+rcx*4-4]
	mov %6, esi

	;Find mid
;	mov rdx, 0
	mov rax, 0
	mov eax, %3
	mov esi, 2
	cdq
	div esi
	cmp edx, 0
	je %%isEven
	mov esi, dword[r9+rax*4]
	mov %5, esi

	%%isEven:
	mov rsi, rax
	mov rax, 0
	mov eax, dword[r9+rsi*4]
	dec rsi
	add eax, dword[r9+rsi*4]
	mov esi, 2
	cdq
	div esi
	mov %5, eax

	mov r8, %1
	mov rsi, 0
	mov rcx, 0
	mov ecx, %3
	%%sumLp:
	mov rsi, 0
	add esi, dword[r8]
	add r8, 4
	loop %%sumLp
	mov %7, rsi
	
%endmacro

section	.data

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

SYS_exit	equ	60			; call code for terminate

; -----

wLst		dw	 1246,  1116,  1542,  1240,  1677
		dw	 1635,  2426,  1820,  1246,  2333
		dw	 2317,  1115,  2726,  2140,  2565
		dw	 2871,  1614,  2418,  2513,  1422
		dw	 2119,  1215,  1525,  1712,  1441
		dw	 3622,   731,  1729,  1615,  1724
		dw	 1217,  1224,  1580,  1147,  2324
		dw	 1425,  1816,  1262,  2718,  2192
  		dw	 1432,  1235,  2764,  1615,  1310
		dw	 1765,  1954,   967,  1515,  3556
		dw	 1342,  7321,  1556,  2727,  1227
		dw	 1927,  1382,  1465,  3955,  1435
		dw	 1225,  2419,  2534,  1345,  2467
		dw	 1315,  1961,  1335,  2856,  2553
  		dw	 1032,  1835,  1464,  1915,  1810
		dw	 1465,  1554,  1267,  1615,  1656
		dw	 2192,  1825,  1925,  2312,  1725
		dw	 2517,  1498,  1677,  1475,  2034
		dw	 1223,  1883,  1173,  1350,  1415
		dw	  335,  1125,  1118,  1713,  3025
len		dd	100

min		dd	0
med		dd	0
max		dd	0
sum		dq	0
ave		dd	0
sqVal	dd	0
midIndex	dd	0

posCnt		dd	0
posSum		dd	0
posAve		dd	0

threeCnt	dd	0
threeSum	dd	0
threeAve	dd	0
three		dd	3

section .bss

dLst	resd	100


section .text
global _start
_start:

; Find the total sum

tstStats dLst, wLst, dword[len], dword[min], dword[med], dword[max], qword[sum], dword[ave]



; Store the address of the array



last:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall