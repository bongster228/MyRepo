;Bong Lee
;CS218 1001
;Ast05
; *****************************************************************

section	.data

; -----
;  Define standard constants

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

SYS_exit	equ	60			; call code for terminate

; -------------------------------------------------------------- 
;  Provided Data Set

sides		dw	 10,  14,  13,  37,  54 
		dw	 14,  29,  64,  67,  34 
		dw	 31,  13,  20,  61,  36 
		dw	 14,  53,  44,  19,  42 
		dw	 44,  52,  31,  42,  56 
		dw	 15,  24,  36,  75,  46 
		dw	 27,  41,  53,  62,  10 
		dw	 33,   4,  73,  31,  15 
		dw	  5,  11,  22,  33,  70 
		dw	 15,  23,  15,  63,  26 
		dw	 16,  13,  64,  53,  65 
		dw	 26,  12,  57,  67,  34 
		dw	 24,  33,  10,  61,  15 
		dw	 38,  73,  29,  17,  93 
		dw	 64,  73,  74,  23,  56 
		dw	  9,   8,   4,  10,  15 
		dw	 13,  23,  53,  67,  35 
		dw	 14,  34,  13,  71,  81 
		dw	 17,  14,  17,  25,  53 
		dw	 23,  73,  15,   6,  13

length		dd	100 

caMin		dw	0 
caMid		dw	0 
caMax		dw	0 
caSum		dd	0 
caAve		dw	0 

cvMin		dd	0 
cvMid		dd	0 
cvMax		dd	0 
cvSum		dd	0 
cvAve		dd	0 

; -----
; Additional variables (if any)

cubeSides   dw  6
currArea	dw	0
midIndex	dw	0
currVol		dd	0

; -------------------------------------------------------------- 
;  Uninitialized data 

section	.bss 

cubeAreas	resw	100 
cubeVolumes	resd	100 


section .text
global _start
_start:


;======================================================
; Calculat the areas
mov rax, 0
mov ecx, dword[length]
mov r8, sides
mov r9, 0

; Square the sides and multiply the result
; by number of sides on the cube(6)
; Store the lower part of the dx:ax in the array
calcArea:
mov ax, word[r8]
mul ax
mul word[cubeSides]
mov word[cubeAreas+r9*2], ax

; Increment counter(r9) and move up the index(r8)
add r8, 2
inc r9
cmp r9d, ecx
jb calcArea

;======================================================
; Calculate sum of all area

mov rsi, 0
mov r8, cubeAreas
mov rcx, 0
mov ecx, dword[length]

sumLoop:
mov si, word[r8]
movzx esi, si
add dword[caSum], esi

add r8, 2
loop sumLoop

;======================================================
; Calculate the min and max area

mov r8, cubeAreas
mov di, word[r8]
movzx rdi, di

mov word[caMin], di
mov word[caMax], di
mov rcx, 0
mov ecx, dword[length]

; if(min/max <|> cubeAreas[i]) min/max = cubeAres[i]

minMaxLp:
mov di, word[r8]
cmp word[caMin], di
jbe areaMinDone
mov word[caMin], di
areaMinDone:
cmp word[caMax], di
jae areaMaxDone
mov word[caMax], di
areaMaxDone:
add r8, 2
loop minMaxLp

;======================================================
; Calculate the mid value

; mid index = len / 2
mov rax, 0
mov rdi, 2
mov eax, dword[length]
mov r8w, 2
div r8w
mov word[midIndex], ax
movzx rax, ax

; if length is odd midval = array[midIndex]
cmp dx, 0
je evenLength

mov r10, 0
mov r10w, word[cubeAreas+rax*2]
mov word[caMid], r10w

; else if length is even find the avg of two mid values
evenLength:
mov si, word[midIndex]
movzx rsi, si
mov ax, word[cubeAreas+rsi*2]
dec rsi
add ax, word[cubeAreas+rsi*2]
mov dx, 0
div r8w
mov word[caMid], ax

;======================================================
; Calculate the ave area

mov eax, dword[caSum]
mov edx, 0
div dword[length]
mov word[caAve], ax

;======================================================
; Create an array of volumes

mov rcx, 0				; loop counter
mov ecx, dword[length]
mov rdi, 0
mov r8, 0				; index

cubeVolLp:
; Cube the sides vol = side * side * side
movzx rax, word[sides+r8*2]
mul ax
mul word[sides+r8*2]
mov word[currVol], ax
mov word[currVol+2], dx

mov edi, dword[currVol]
mov dword[cubeVolumes+r8*4], edi

; index++ and loopCounter--
inc r8
dec ecx
cmp ecx, 0
jne cubeVolLp

;======================================================
; Get sum of all volumes

mov r8, 0	; Index
mov rcx, 0
mov ecx, dword[length] ; Loop counter

sumVol:
mov esi, dword[cubeVolumes+r8*4]
add dword[cvSum], esi
inc r8
loop sumVol

;======================================================
; Find the min and max volumes

mov r10, 0		; Index
mov rcx, 0		; Loop counter
mov ecx, dword[length]

mov esi, dword[cubeVolumes]
mov dword[cvMin], esi
mov dword[cvMax], esi

minMaxVol:
mov esi, dword[cubeVolumes+r10*4]
cmp dword[cvMin], esi
jbe volMinDone
mov dword[cvMin], esi
volMinDone:
cmp dword[cvMax], esi
jae volMaxDone
mov dword[cvMax], esi
volMaxDone:

inc r10
loop minMaxVol

;======================================================
; Find the mid value

; midIndex = length / 2
mov rax, 0
mov eax, dword[length]
mov rsi, 0
mov esi, 2
div esi

mov word[midIndex], ax
mov r9, 0
mov r9w, word[midIndex]

mov r8d, dword[cubeVolumes+r9*4]
mov dword[cvMid], r8d
dec r9
mov r8d, dword[cubeVolumes+r9*4]
add dword[cvMid], r8d

mov eax, r8d
mov esi, 2
div esi
mov dword[cvMid], eax

;======================================================
; Find ave volume
mov eax, dword[cvSum]
div dword[length]
mov dword[cvAve], eax

last:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall