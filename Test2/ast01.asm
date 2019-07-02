
; *****************************************************************
;  Data Declarations
;	Note, all data is declared statically (for now).
          
section	.data

; -----
;  Standard constants.

LF			equ	10
NULL		equ	0
MAXLEN		equ 100


TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

STDIN		equ	0
STDOUT		equ	1
STDERR		equ	2

SYS_read	equ	0	
SYS_write	equ 1
SYS_open	equ 2
SYS_close	equ	3
SYS_fork	equ	57
SYS_exit	equ	60			; call code for terminate
SYS_creat	equ 85
SYS_time	equ	201
; -----

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q


inStr	db	"abCDe123#$fgG", NULL

filenName	db	"Test2", NULL

cvtCnt	dd	0
ltrCnt	dd	0
digitCnt	dd	0
strLen	dd	0


;  Byte (8-bit) variable declarations


section .bss

newStr	resb	100

; *****************************************************************
;  Code Section

section	.text

;	rdi, addr inStr
;	rsi, addr newStr
;	rdx, addr cvtCnt
;	rcx, addr ltrCnt
;	r8,	addr digitCnt
;	r9, addr strLen
global makeLower
makeLower:

		push rbp
		mov rbp, rsp

		push rbx
		push r12			;	index counter
		push r13			;	used to hold temp chr

	;	Initialize all variables
		mov r12, 0
		mov r13, 0


		mov rbx, rsi

		;	Get the character from passed in string
		chrLp:
		mov r13b, byte[rdi+r12]
		add qword[r9], 1			;	strLen count

		cmp r13b, NULL
		je	cvtDone

		;	Check for digit
		cmp r13b, "0"
		jae	isDigit

		jmp notDigit

		isDigit:
		cmp r13b, "9"
		ja	notDigit
		;	If is a digit inc count and add to string
		mov byte[rbx+r12], r13b
		inc r12
		add qword[r8], 1
		jmp chrLp

		notDigit:

		cmp r13b, "A"
		jae	isUpper

		jmp notUpper

		isUpper:
		cmp r13b, "Z"
		ja	notUpper
		;	If upper case, inc cvt count, letter cnt and convert
		add r13b, 32
		mov byte[rbx+r12], r13b
		inc r12
		add qword[rdx], 1
		add qword[rcx], 1
		jmp chrLp

		notUpper:

		cmp r13b, "a"
		jae	isLower

		jmp notLower

		isLower:
		cmp r13b, "z"
		ja	notLower
		;	If lowercase, add to newstr and inc ltrCnt
		mov byte[rbx+r12], r13b
		inc r12
		add qword[rcx], 1
		jmp chrLp

		notLower:

		;	If none of the above, add to str
		mov byte[rbx+r12], r13b
		inc r12
		jmp chrLp

		cvtDone:
		mov byte[rbx+r12], NULL		;	Terminate new string

		pop r13
		pop r12
		pop rbx
		mov rsp, rbp
		pop rbp
ret

global makeUpper
makeUpper:

		push r12
		push r13

		mov r12, 0
		mov r13, 0

	chrLp2:
		mov r13b, byte[rdi+r12]	
		add qword[r9], 1
		cmp r13b, NULL
		je cvtDone2
	
		cmp r13b, "0"
		jae  isDigit2
		jmp notDigit2

	isDigit2:
		cmp r13b, "9"
		ja	notDigit2
		mov byte[rsi+r12], r13b
		inc r12
		add qword[r8], 1
		jmp chrLp2
	
	notDigit2:
		cmp r13b, "A"
		jae	isUpper2
		jmp	notUpper2

	isUpper2:
		cmp r13b, "Z"
		ja	notUpper2
		mov byte[rsi+r12], r13b
		inc r12
		add qword[rcx], 1
		jmp chrLp2

	notUpper2:
		cmp r13b, "a"
		jae isLower2
		jmp notLower2

	isLower2:
		cmp r13b, "z"
		ja notLower2
		sub r13b, 32
		mov byte[rsi+r12], r13b
		inc r12
		add qword[rcx], 1
		add qword[rdx], 1
		jmp chrLp2

	notLower2:
		mov byte[rsi+r12], r13b
		inc r12
		jmp chrLp2

	cvtDone2:
		mov byte[rsi+r12], NULL

		pop r13
		pop r12	
ret

;	rdi,	filenName 	string
;	rsi,	inStr		string
;	rdx,	outStr		address of string
;	rcx,	cvtCnt		addr
;	r8,		ltrCnt		addr
;	r9,		digitCnt	addr
;	7th,	strLen		addr
global writeLowerStr
writeLowerStr:

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi	;	fileName
	mov r13, rsi	;	intStr
	mov r14, rdx	;	outStr
	mov r15, rcx	;	cvtCnt
	mov rbx, r8		;	ltrCnt
	mov r10, r9		;	digitCnt

	mov rdi, r13	;	inStr
	mov rsi, r14	;	newStr
	mov rdx, r15	;	cvtCnt
	mov rcx, rbx	;	ltrCnt
	mov r8, r10		;	digitCnt
	mov r9, qword[rbp+16]	;	strLen
	call makeLower


	;	Return by ref
	mov rsi, r13
	mov rdx, r14
	mov rcx, r15
	mov r8, rbx
	mov r9, r10


	mov rdi, r13
	mov rsi, r14

	call makeLower

	;	Return the values by ref

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp

ret	



global _start
_start:

;
;	mov rdi, inStr
;	mov rsi, newStr
;	mov rdx, cvtCnt
;	mov rcx, ltrCnt
;	mov r8, digitCnt
;	mov r9, strLen
;	call makeUpper
;



mov rdi, filenName
mov rsi, inStr
mov rdx, newStr
mov rcx, cvtCnt
mov r8, ltrCnt
mov r9, digitCnt
push strLen
call writeLowerStr
add rsp, 8







; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call code for exit
	mov	rdi, EXIT_SUCCESS	; exit program with success
	syscall

