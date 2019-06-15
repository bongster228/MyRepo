; Bong Lee
; CS218 1001
; Ast04

section	.data

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

SYS_exit	equ	60			; call code for terminate

; -----

lst		dd	 1246,  1116,  1542,  1240,  1677
		dd	 1635,  2426,  1820,  1246, -2333
		dd	 2317, -1115,  2726,  2140,  2565
		dd	 2871,  1614,  2418,  2513,  1422
		dd	-2119,  1215, -1525, -1712,  1441
		dd	-3622,  -731, -1729,  1615,  1724
		dd	 1217, -1224,  1580,  1147,  2324
		dd	 1425,  1816,  1262, -2718,  2192
  		dd	-1432,  1235,  2764, -1615,  1310
		dd	 1765,  1954,  -967,  1515,  3556
		dd	 1342,  7321,  1556,  2727,  1227
		dd	-1927,  1382,  1465,  3955,  1435
		dd	-1225, -2419, -2534, -1345,  2467
		dd	 1315,  1961,  1335,  2856,  2553
  		dd	-1032,  1835,  1464,  1915, -1810
		dd	 1465,  1554, -1267,  1615,  1656
		dd	 2192, -1825,  1925,  2312,  1725
		dd	-2517,  1498, -1677,  1475,  2034
		dd	 1223,  1883, -1173,  1350,  1415
		dd	  335,  1125,  1118,  1713,  3025
len		dd	100

lstMin		dd	0
lstMid		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

posCnt		dd	0
posSum		dd	0
posAve		dd	0

threeCnt	dd	0
threeSum	dd	0
threeAve	dd	0
three		dd	3


section .text
global _start
_start:

; Find the total sum

; Store the address of the array
	mov r10, lst

; Set up register to be used to hold values
; from the array
	mov rdx, 0

; Set up counter and initialize totalSum variable
	mov dword[lstSum], 0
	mov rsi, 0
	mov esi, dword[len]

; Use loop to sum up elements
sumLoop:
	mov edx, dword[r10]
	add dword[lstSum], edx
	add r10, 4
	dec esi
	
	cmp esi, 0
	jne sumLoop


; Find min value

; Store the address of the lst array
	mov rdi, lst

; Store current element
	mov rsi, 0

; Store the counter
	mov r8, 0
	mov r8d, dword[len]

; Put the first element in the min variable
	mov esi, dword[rdi]
	mov dword[lstMin], esi

; Use loop to find the min element
minLoop:
	mov esi, dword[rdi]
	cmp dword[lstMin], esi
	jle minDone
	mov dword[lstMin], esi
minDone:
	add rdi, 4
	dec r8d
	cmp r8d, 0
	jne minLoop


; Find the max value

; Store the base address of the array
	mov r8, lst

; Store the size of the array
	mov rdi, 0
	mov edi, dword[len]

; Register to store the current value from the array
; Store the first element in the array in the lstMax variable
	mov rsi, 0
	mov esi, dword[r8]
	mov dword[lstMax], esi

; Loop through the array to find the max value
maxLoop:
	mov esi, dword[r8]
	cmp dword[lstMax], esi
	jge maxDone
	mov dword[lstMax], esi
maxDone:
	add r8, 4
	dec edi
	cmp edi, 0
	jne maxLoop

; Find the mid value(unsorted)

	mov r8, 196
	mov r9, 200
	mov r10, 0
	mov r10d, dword[lst+r8]
	add dword[lstMid], r10d
	mov r10d, dword[lst+r9]
	add dword[lstMid], r10d
	
	mov rax, 0
	mov r10d, 2
	mov eax, dword[lstMid]
	cdq
	idiv r10d
	mov dword[lstMid], eax
	
; Find the average
	mov edi, dword[len]
	mov eax, dword[lstSum]
	cdq
	idiv edi
	mov dword[lstAve], eax

; Find the sum, count, and avg of positive elements
	
; Find the positive sum and count
	mov r8, lst ; Store the address of the array
	mov rsi, 0 ; Used to store current element
	mov rcx, 0
	mov ecx, dword[len] ; Store the length of the array

posSumLp:
	mov esi, dword[r8]
	cmp esi, 0
	jl notPositive
	add dword[posSum], esi
	inc dword[posCnt]
notPositive:
	add r8, 4
	dec ecx
	cmp ecx, 0
	jne posSumLp

; Calculate positive avg

	mov eax, dword[posSum]
	cdq
	idiv dword[posCnt]
	mov dword[posAve], eax

; Calculate threeCnt, sum, and avg

	mov r8, lst
	mov rsi, 0
	mov rax, 0
	mov rdi, 0
	mov edi, dword[len]

threeLp:
	mov esi, dword[r8]
	mov eax, esi
	cdq
	idiv dword[three]
	cmp edx, 0
	jne notThree
	add dword[threeSum], esi
	inc dword[threeCnt]
notThree:
	add r8, 4
	dec edi
	cmp edi, 0
	jne threeLp

; Calculate threeAve
	mov eax, dword[threeSum]
	cdq
	idiv dword[threeCnt]
	mov dword[threeAve], eax

last:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall