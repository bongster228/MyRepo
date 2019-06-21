; Assignment #7
; Example Solution.

;  Sort a list of number using the bubble sort algorithm.
;  Also finds the minimum, median, maximum, and average of the list.

; -----
;  Bubble Sort Algorithm

;	for ( i = (len-1) to 0 )
;	     swapped = false
;	     for ( j = 0 to i ){
;	         if ( lst(j) > lst(j+1) ){
;	             tmp = lst(j)
;	             lst(j) = lst(j+1)
;	             lst(j+1) = tmp
;	             swapped = true
;	         }
;			}
;	     if ( swapped = false ) exit
;	}

; --------------------------------------------------------------
;  Macro, "int2octal", to convert a signed base-10 integer into
;  an ASCII string representing the octal value.  The macro stores
;  the result into an ASCII string (byte-size, right justified,
;  blank filled, NULL terminated).  Each integer is a doubleword value.
;  Assumes valid/correct data.  As such, no error checking is performed.


%macro	int2octal	2
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	mov eax, %1
	; if negative, store the sign
	cmp eax, 0
	jg %%isPos
	mov bl, "-"
	neg eax
	%%isPos:

	; Push Count
	mov rcx, 0
	mov rdi, 8

	%%octLp:
	; Num = Num / 8
	mov rdx, 0
	div edi
	; Push remainder
	push rdx
	inc rcx
	; If Num == 0, exit
	cmp eax, 0
	jne %%octLp

	mov rdx, 0	; Index

	cmp bl, "-"
	jne %%strPos
	mov byte[%2], "-"
	inc rdx
	%%strPos:

	cmp bl, "-"
	je %%octPopLp
	mov byte[%2], "+"
	inc rdx

	%%octPopLp:
	pop rsi
	add rsi, "0"
	mov byte[%2+rdx], sil
	inc rdx

	dec rcx
	cmp rcx, 0
	jne %%octPopLp

	inc r8
	mov byte[%2+rdx], NULL

	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
%endmacro



; --------------------------------------------------------------
;  Simple macro to display a string.
;	Call:	printString  <stringAddress>

;	Arguments:
;		%1 -> <string>, string address

;  Algorithm:
;	Count characters (excluding NULL).
;	Use system service to display string at address <string>

%macro	printString	1
	push	rax			; save altered registers
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	mov	rdx, 0
	mov	rdi, %1
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	mov	rsi, %1			; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro

; ---------------------------------------------

section	.data

; -----
;  Define standard constants

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
NULL		equ	0
ESC		equ	27

; -----
;  Misc. constants

MAX_STR_SIZE	equ	16

; -----
;  String definitions

newLine		db	LF, NULL

hdr		db	LF, "**********************************"
		db	LF, "CS 218 - Assignment #7", LF
		db	LF, "List Statistics:"
		db	LF, LF, NULL

lstMin		db	"List Minimum: ", NULL
lstMed		db	"List Median:  ", NULL
lstMax		db	"List Maximum: ", NULL
lstSum		db	"List Sum:     ", NULL
lstAve		db	"List Average: ", NULL

; -----
;  Provided data.

lst		dd	 1113, -1232,  2146,  1376,  5120
		dd	 2356,  3164,  4565,  3155,  3157
		dd	 6759,  6326,   171,   147, -5628
		dd	 7527,  7569,  1177,  6785,  3514
		dd	-1001,   128,  1133,  1105, -3327
		dd	  101,   115,  1108,  2233, -2115
		dd	 1227,  1226,  5129,   117,   107
		dd	  105,   109,  1730, -1150,  3414
		dd	 1107,  6103,  1245,  6440,  1465
		dd	 2311,   254,  4528,  1913,  6722
		dd	-1149,  2126,  5671,  4647,  4628
		dd	 -327, -2390,  1177,  8275,  5614
		dd	 3121,   415,  -615,   122,  7217
		dd	    1,   410, -1129,  -812,  2134
		dd	-1221, -2234,  6151,   432,   114
		dd	 1629,   114,   522,  2413,   131
		dd	 5639,   126,  1162,   441,   127
		dd	 -877,   199,  5679, -1101,  3414
		dd	-2101,   133,  1133,  2450,  4532
		dd	 8619,   115,  1618,  1113,  -115
		dd	 1219,  3116,  -612,   217,   127
		dd	 6787,  4569,   679, -5675,  4314
		dd	 1104,  6825,  1184,  2143,  1176
		dd	  134, -4626,   100,  4566,  2346
		dd	 1214,  6786,  1617,   183, -3512
		dd	 7881, -8320,  3467,  4559, -1190
		dd	  103,   112,  1146,  2186,   191
		dd	  186,   134,  1125, -5675,  3476
		dd	 2137,  2113, -1647,   114,   115
		dd	-6571, -7624,   128,   113,  3112
		dd	 1724,  6316,  1217,  2183, -4352
		dd	  121,   320,  4540,  5679, -1190
		dd	-9125,   116,  1122,   117,   127
		dd	 5677,   101,  3727, -1125,  3184
		dd	 1897,  6374,  1190,     0,  1224
		dd	  125,   116,  8126,  6784, -2329
		dd	 1104,   124,  1112,   143,   176
		dd	 7534,  2126,  6112,   156,  1103
		dd	 1153,   172, -1146,  2176,   170
		dd	  156,   164,   165,  -155,  5156
		dd	  894,  6325,  1184,   143,   276
		dd	 5634,  7526,  3413,  7686,  7563
		dd	  511, -6383,  1133,  2150,  -825
		dd	 5721,  5615,  4568,  7813,  1231
		dd	  169,   146, -1162,   147,   157
		dd	  167,   169,   177,   175,  2144
		dd	 5527,  1344,  1130,  2172,   224
		dd	 7525,  5616,  5662,  6328,  2342
		dd	  181,   155,  1145,   132,   167
		dd	  185,   150,   149,   182,  1434
		dd	 6581,  3625,  6315,     1,  -617
		dd	 7855,  6737,   129,  4512,  1134
		dd	  177,   164,  1160,  1172,   184
		dd	  175,   166,  6762,   158,  4572
		dd	 6561,  1283,  1133,  1150,   135
		dd	 5631, -8185,   178, -1197,  1185
		dd	 5649,  6366,  1162,  1167,   167
		dd	-1177,   169,  1177,   175,  1169
		dd	 5684,  2179,  1117,  3183,   190
		dd	 1100, -4611,  1123,  3122,  -131

len		dd	300

min		dd	0
med		dd	0
max		dd	0
sum		dd	0
avg		dd	0


; -----
;  Misc. data definitions (if any).

swapped		db	TRUE

weight		dd	3
dtwo		dd	2
midIndex	dw	0

; -----

section	.bss
tempString	resb	MAX_STR_SIZE


; ---------------------------------------------

section	.text
global	_start
_start:


;	YOUR CODE GOES HERE...

;  Bubble Sort Algorithm

;	for ( i = (len-1) to 0 )

;   i = len - 1
mov r8d, dword[len]
dec r8d
outerForLp:
;	     swapped = false
mov byte[swapped], FALSE
;	     for ( j = 0 to i )
mov r9d, 0
inForLp:
;	         if ( lst(j) > lst(j+1) )
mov esi, dword[lst+r9d*4]   ; lst[j]
mov edi, dword[lst+r9d*4+4] ;lst[j+1]
cmp esi, edi
jle ifDone
;	             lst(j) = lst(j+1)
mov dword[lst+r9d*4], edi
;	             lst(j+1) = tmp
mov dword[lst+r9d*4+4], esi
;	             swapped = true
mov byte[swapped], TRUE
ifDone:

;   j++
inc r9d
cmp r9d, r8d
jne inForLp

;	     if ( swapped = false ) exit
cmp byte[swapped], FALSE
je sortDone

;   i--
dec r8d
cmp r8d, 0
jne outerForLp

;	Exit
sortDone:

;-----
;	Find the Min Med and Max

;Find Min
mov ebx, dword[lst]
mov dword[min], ebx

;Find Max
mov r9, 0
mov r9d, dword[len]
dec r9d
mov ebx, dword[lst+r9*4]
mov dword[max], ebx

;Find Mid
;	midIndex = len / 2
mov rax, 0
mov eax, dword[len]
mov r8d, 2
div r8w
mov word[midIndex], ax

cmp dx, 0
je evenLen

; for odd lengths
mov esi, dword[lst+rax*4]
mov dword[med], esi

; Med value for even lengths
evenLen:
mov esi, dword[lst+rax*4]
dec rax
add esi, dword[lst+rax*4]
mov eax, esi
div r8d
mov dword[med], eax

;-----
;	Find sum and avg

;	Sum Loop
;	for(i = (len - 1) to 0 )
mov edi, dword[len]
mov r8, 0			; Index
sumLp:
mov ecx, dword[lst+r8*4]
add dword[sum], ecx

inc r8
dec edi
cmp edi, 0
jne sumLp

;	Get Avg
mov eax, dword[sum]
div dword[len]
mov dword[avg], eax

; -----
;  Output results to console.
;	Convert each result into a string
;	Display header and then ASCII/octal string

	printString	hdr

	printString	lstMin
	int2octal	dword [min], tempString
	printString	tempString
	printString	newLine

	printString	lstMed
	int2octal	dword [med], tempString
	printString	tempString
	printString	newLine

	printString	lstMax
	int2octal	dword [max], tempString
	printString	tempString
	printString	newLine

	printString	lstSum
	int2octal	dword [sum], tempString
	printString	tempString
	printString	newLine

	printString	lstAve
	int2octal	dword [avg], tempString
	printString	tempString
	printString	newLine

	printString	newLine

; -----
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall

