;	Bong Lee
;	CS218 1001
;	Ast06

;  CS 218, Assignment #6
;  Provided Main

;  Write a simple assembly language program to convert integers
;  to ASCII charatcers and output the ASCII strings to the screen
;  (using the provided routine).

; --------------------------------------------------------------
;  STEP #3
;  Macro, "octal2int", to convert a signed octal/ASCII string
;  into an integer.  The macro reads the octal/ASCII string (byte-size,
;  signed, NULL terminated) and converts to a doubleword sized integer.
;  Assumes valid/correct data.  As such, no error checking is performed.

;  Example:  given the ASCII string: "+123", NULL
;  (+ sign, "1", followed by "2",  followed by "3", and NULL)
;  would be converted to integer 83.

;  Note, the string address is passed in %1 (first argument), which
;  must not be altered until the address is used.

;  Note, should preserve any registers that the macro alters
;  by pushing and, when done, poping.  The registers pushed/poped
;  below may need to be updated based on the actual code.

; -----
;  Arguments
;	%1 -> string address (reg)
;	%2 -> integer number (reg)


%macro	octal2int	2
	push	rax
	push	rcx
	push	rsi
	push	rdi
	push	r8
	push	r9
	push	r10

	mov rcx, %1		; index
	mov rsi, 0		; store char
	mov sil, byte[rcx]
	; Store the sign
	mov dil, sil

	inc rcx
	mov sil, byte[rcx]
	mov r9, 0		; Store running sum

	%%macroCutLp:
	cmp sil, 0
	je %%macroExitCutLp

	mov sil, byte[rcx]
	sub sil, "0"

	mov rax, 0
	mov eax, r9d
	mov r10d, 8
	mul r10d

	add eax, esi
	mov r9d, eax

	inc rcx
	mov sil, byte[rcx]
	jmp %%macroCutLp

	%%macroExitCutLp:
	mov r10, 0
	mov r10d, r9d
	cmp dil, "+"
	je %%macroAnsPos
	neg r10d
	%%macroAnsPos:
	mov dword[%2], r10d

	pop r10
	pop r9
	pop r8
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rax
%endmacro


; --------------------------------------------------------------
;  STEP #4
;  Macro, "int2octal", to convert a signed base-10 integer into
;  an octal/ASCII string representing the octal value.  The macro stores
;  the result into an ASCII string (byte-size, right justified,
;  blank filled, NULL terminated).  Each integer is a doubleword value.
;  Assumes valid/correct data.  As such, no error checking is performed.

;  Example:  Since, 11 (base 10) is 13 (base 8), then the integer 8
;  would be converted to ASCII resulting in: "      +13", NULL
;  (6 spaces, + sign, and "1" followed by "3", and NULL).

;  To access the value, copy into a register.  For example:
;	mov	eax, %1

;  Note, should preserve any registers that the macro alters
;  by pushing and, when done, poping.  The registers pushed/poped
;  below may need to be updated based on the actual code.

; -----
;  Arguments
;	%1 -> integer number
;	%2 -> string address


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


; --------------------------------------------------------------
;  Simple to skip forward to next string in an array of NULL
;  terminated strings.

;	Call:	nextString  <string>
;	Arguments:
;		%1 -> string address (reg)
;  Note, changes passed register

%macro	nextString	1

%%skpForward:
	cmp	byte [%1], NULL
	je	%%nextStringDone
	inc	%1
	jmp	%%skpForward

%%nextStringDone:
	inc	%1

%endmacro


; --------------------------------------------------------------

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

MAX_STR_SIZE	equ	10
NUMS_PER_LINE	equ	5

newLine		db	LF, NULL

; -----
;  Header string definitions.

hdr1		db	LF, "**********************************"
		db	LF, "CS 218 - Assignment #6", LF
		db	LF, LF, NULL
hdr2		db	LF, LF, "----------------------"
		db	LF, "List Stats"
		db	LF, NULL

firstNum	db	"First Number: ", NULL
firstNumPlus	db	"First Number (*2): ", NULL

lstSum		db	LF, "List Sum:"
		db	LF, NULL
lstAve		db	LF, "List Average:"
		db	LF, NULL

; -----
;  Misc. data definitions (if any).

weight		dd	8
sign		db	0
rSum		db	0
octal1		dd	0

check		dd	507


; -----
;  Assignment #6 Provided Data:

oNum1		db	"+12345", NULL
iNum1		dd	0


oLst1		db	   "+17", NULL,   "-347", NULL,  "+6747", NULL, "-12375", NULL
len1		dd	4
sum1		dd	0
ave1		dd	0

oLst2		db	   "+32", NULL, "-16740", NULL, "+10300", NULL, "-25000", NULL
		db	"+11000", NULL, "-14321", NULL, "+22432", NULL, "-11010", NULL
		db	"-11201", NULL,   "+312", NULL,     "-7", NULL ,   "-16", NULL
		db	  "-731", NULL,  "-5173", NULL, "-10345", NULL, "-15557", NULL
		db	 "+2360", NULL, "-13230", NULL, "+21234", NULL, "+11111", NULL
		db	 "+1725", NULL,  "-6312", NULL,   "+420", NULL,  "-5532", NULL
len2		dd	24
sum2		dd	0
ave2		dd	0

oLst3		db	"+12627", NULL, "-11622", NULL, "+15110", NULL, "+10667", NULL
		db	"+26516", NULL,  "-5112", NULL,   "+152", NULL, "+21344", NULL
		db	  "+134", NULL,  "+7206", NULL, "+24112", NULL,  "+1231", NULL
		db	 "+7765", NULL, "-17312", NULL,   "+312", NULL,   "+704", NULL
		db	"-12344", NULL,	"+27111", NULL,     "+7", NULL,     "-6", NULL
		db	"-11512", NULL,  "+7552", NULL, "+11344", NULL, "+10134", NULL
		db	 "-7164", NULL,   "+471", NULL,  "-2344", NULL,   "-214", NULL
		db	"-11212", NULL, "+11115", NULL,	 "-1265", NULL, "-22130", NULL
		db	   "+75", NULL, "+23311", NULL
len3		dd	34
sum3		dd	0
ave3		dd	0

oLst4		db	 "+7164", NULL,  "+1067", NULL, "+11721", NULL, "+21000", NULL
		db	 "-2174", NULL,  "-2127", NULL, "-23212", NULL,   "+117", NULL
		db	"-20163", NULL, "+12112", NULL, "+11345", NULL, "+11064", NULL
		db	"+11721", NULL, "+26000", NULL, "-23575", NULL, "+13725", NULL
		db	 "+3110", NULL,   "-120", NULL, "+13332", NULL, "+10022", NULL
		db	 "-7560", NULL, "+12313", NULL, "+11760", NULL,  "+4312", NULL
		db	"+17465", NULL, "+23241", NULL, "-27431", NULL,   "-730", NULL
		db	 "+4313", NULL, "+30233", NULL, "+13657", NULL, "-31113", NULL
		db	 "+1661", NULL, "+11312", NULL, "+17555", NULL, "-12241", NULL
		db	"+13231", NULL,  "+3270", NULL,  "-7653", NULL, "+15127", NULL
len4		dd	40
sum4		dd	0
ave4		dd	0

; --------------------------------------------------------------

section	.bss

num1String	resb	MAX_STR_SIZE
tempString	resb	MAX_STR_SIZE
tempNum		resd	1


; --------------------------------------------------------------

section	.text
global	_start
_start:

; ******************************
;  Main program
;	display headers
;	calls the macro on various data items
;	display results to screen (via provided macro's)

;  Note, since the print macros do NOT perform an error checking,
;  	if the conversion macros do not work correctly,
;	the print string will not work!

;  Debugging Tip:
;	Since macro's can be difficult to debug, can write the code
;	and place it in the main (below) where each macro call is.
;	After the code is debugged and working, can copy it into
;	the macro (making the appropriate adjustments for the labels
;	and arguments).

; ******************************
;  Prints some cute headers...

	printString	hdr1
	printString	firstNum
	printString	oNum1
	printString	newLine

; -----
;  STEP #1
;  Convert ASCII octal NULL terminated string at 'oNum1' (esi)
;	into an integer which is placed into 'iNum1'

	;Store the sign
	mov r8, oNum1		; Index
	mov r9, 0			; Used to store char
	mov r9b, byte[r8]
	mov byte[sign], r9b

	inc r8
	mov r9b, byte[r8]
	mov dword[rSum], 0
	; Cut and convert
	cutLp:
	;if(char == NULL) exit
	cmp r9b, 0
	je exitCutLp

	; int = char - "0"
	mov r9b, byte[r8]
	sub r9b, "0"
	; rSum = rSum * 8
	mov eax, dword[rSum]
	mov ebx, 8
	mul ebx
	; rSum = rSum + int
	add eax, r9d
	mov dword[rSum], eax
	; r8++
	inc r8
	mov r9b, byte[r8]
	jmp cutLp

	exitCutLp:
	mov r10d, dword[rSum]
	; if(sign == "-") rSum = rSum * -1
	cmp byte[sign], "+"
	je ansPos
	neg r10d
	ansPos:
	mov dword[iNum1], r10d

; -----
;  Perform simple *2 operation

	mov	eax, dword [iNum1]
	mov	ebx, 2
	imul	ebx

; -----
;  STEP #2
;  Convert the double-word integer (in eax) into a string which
;	will be stored into the 'num1String'

	mov rdx, 0
	; If int is negative, store the sign
	cmp eax, 0
	jg isPos
	mov byte[sign], "-"
	neg eax
	isPos:

	; Push count
	mov rcx, 0
	mov rsi, 8

	octLp:
	; iNum = iNum / 8
	mov rdx, 0
	div esi
	; Push the remainder
	push rdx
	inc rcx
	; If (iNum == 0) exit
	cmp eax, 0
	jne octLp

	mov r8, 0		; Index
	
	; If the value was negavie, add the "-"
	; at the front of the string
	cmp byte[sign], "-"
	jne strPos
	mov byte[num1String], "-"
	inc r8
	strPos:

	cmp byte[sign], "-"
	je octPopLp
	mov byte[num1String], "+"
	inc r8

	octPopLp:
	pop r9
	add r9, "0"
	mov byte[num1String+r8], r9b
	inc r8

	; if(pushCount == 0) exit
	dec rcx
	cmp rcx, 0
	jne octPopLp

	inc r8
	mov byte[num1String+r8], NULL
	
; -----
;  Display a simple header and then the ASCII/octal string.

	printString	firstNumPlus
	printString	num1String


; ******************************
;  Next, repeatedly call the macro on each value in an array.

; -----
;  Data Set #1

	printString	hdr2

	mov	ecx, dword [len1]		; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, oLst1			; address of string

cvtLoop1:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum1], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop1

	int2octal	dword [sum1], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine


	mov	eax, [sum1]
	cdq
	idiv	dword [len1]
	mov	dword [ave1], eax
	int2octal	dword [ave1], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

; -----
;  Data Set #2

	printString	hdr2

	mov	ecx, [len2]			; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, oLst2			; address of string

cvtLoop2:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum2], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop2

	int2octal	dword [sum2], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum2]
	cdq
	idiv	dword [len2]
	mov	dword [ave2], eax
	int2octal	dword [ave2], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

; -----
;  Data Set #3

	printString	hdr2

	mov	ecx, [len3]			; length
	mov	esi, 0				; starting index of integer list
	mov	edi, oLst3			; address of string

cvtLoop3:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum3], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop3

	int2octal	dword [sum3], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum3]
	cdq
	idiv	dword [len3]
	mov	dword [ave3], eax
	int2octal	dword [ave3], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

; -----
;  Data Set #4

	printString	hdr2

	mov	ecx, [len4]			; length
	mov	esi, 0				; starting index of integer list
	mov	edi, oLst4			; address of string

cvtLoop4:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum4], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop4

	int2octal	dword [sum4], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum4]
	cdq
	idiv	dword [len4]
	mov	dword [ave4], eax
	int2octal	dword [ave4], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

	printString	newLine
	printString	newLine

; ******************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit			; call code for exit (sys_exit)
	mov	rdi, EXIT_SUCCESS
	syscall

