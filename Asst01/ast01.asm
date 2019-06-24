;	Macro Test File

%macro tstStats 7

	push rax
	push rbx
	push rcx
	push rdx
	push rsi


	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

%endmacro

%macro tstStats 8

	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	mov rsi, %1
	mov rdi, %2
	mov ecx, %3

	%%sqLoop:
	mov ax, word[rdi]
	mul ax
	mov word[sqVal], ax
	mov word[sqVal+2], dx
	mov ebx, dword[sqVal]
	mov dword[rsi], ebx
	add rdi, 2
	add rsi ,4
	loop %%sqLoop

	;Min and max
	mov eax, dword[%1]
	mov dword[%4], eax
	mov ecx, %3
	mov eax, dword[%1+ecx*4-4]
	mov dword[%6], eax

	;Find med
	mov eax, %3
	mov ebx, 2
	mov edx, 0
	div ebx
	cmp edx, 0
	je %%isEven
	mov ebx, dword[%1+eax*4]
	mov dword[%5], ebx

	%%isEven:
	mov ebx, eax
	mov eax, dword[%1+ebx*4]
	dec ebx
	add eax, dword[%1+ebx*4]
	mov ebx, 2
	mov edx, 0
	div ebx
	mov dword[%5], eax

	mov rsi, %1
	mov ecx, %3
	mov rax, 0
	%%sumLp:
	add eax, dword[rsi]
	add rsi, 4
	loop %%sumLp
	mov dword[%7], eax
	mov ecx, %3
	mov edx, 0
	div ecx
	mov dword[%8], eax

	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

%endmacro



; *****************************************************************
;  Data Declarations
;	Note, all data is declared statically (for now).
          
section	.data

; -----
;  Standard constants.

LF			equ	10
NULL		equ	0


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


message1	db	"Hello World", LF, NULL
message2	db	"Enter Answer: ", NULL
newLine		db	LF, NULL

inChar		db	0
STRLEN		equ	50
pmpt		db	"Enter Text: ", NULL


;  Byte (8-bit) variable declarations


	;	tstMacro Macro variables

	n1	dd	0
	n2w	dw	0
	n3	dd	0

	res1	dd	0
	res2	dd	0
	res3	dd	0
	rem3	dd	0

	;	tstStats Macro variables

	list	db	6,4,3,-1,2,-3,5,7

	wLst	dw	1, 2, 3, 4, 5, 6, 7, 8, 9, 10
	arr		dd	1,2,3,4,5,6,7,8,10
	len		dd	10
	min		dd 	0
	med1	dd 	0
	med2	dd	0
	max		dd	0
	sum		dd 	0
	ave		dd 	0

	sqVal	dd	0

section .bss

	dLst	resd	10
	chr		resb	1
	inLine	resb	STRLEN+2

; *****************************************************************
;  Code Section

section	.text

global _stats1
stats1:
	push r12

	mov r12, 0	;counter index
	mov rax, 0	;	running sum
sumLoop:
	add eax, dword[rdi+r12*4]
	inc r12
	cmp r12, rsi
	jl sumLoop

	mov dword[rdx], eax	;	return sum

	cdq
	idiv esi
	mov dword[rcx], eax	;	return ave

	pop r12
	ret

global _stats2
; stats2(arr, len, min, med1, med2, max, sum, ave)
stats2:
	push rbp
	mov rbp, rsp
	push r12

;	Get min and max
	mov eax, dword[rdi]
	mov dword[rdx], eax

	mov r12, rsi
	dec r12
	mov eax, dword[rdi+r12*4]
	mov dword[r9], eax

;	Get medians
	mov rax, rsi
	mov rdx, 0
	mov r12, 2
	div r12
	
	cmp rdx, 0
	je	evenLength

	mov r12d, dword[rdi+rax*4]
	mov dword[rcx], r12d
	mov dword[r8], r12d
	jmp medDone

evenLength:
	mov r12d, dword[rdi+rax*4]
	mov dword[r8], r12d
	dec rax
	mov r12d, dword[rdi+rax*4]
	mov dword[rcx], r12d
medDone:

;	Find Sum
	mov r12, 0
	mov rax, 0

sumLoop2:
	add eax, dword[rdi+r12*4]
	inc r12
	cmp r12, rsi
	jl	sumLoop2

	mov r12, qword[rbp+16]	;	Get the sum addr
	mov dword[r12], eax

;	Calc Ave
	cdq
	idiv rsi
	mov r12, qword[rbp+24]
	mov dword[r12], eax

	pop r12
	pop rbp
	ret

;-----------
;Function to print out string

;1) address, string
;	Returns nothing

global printString
printString:

	push rbx

	mov rbx, rdi
	mov rdx, 0

strCountLoop:
	cmp byte[rbx], NULL
	je	strCountDone
	inc rdx
	inc rbx
	jmp strCountLoop
strCountDone:

	cmp rdx, 0
	je prtDone

	;------
	;	Call OS to output string
	mov rax, SYS_write
	mov rsi, rdi
	mov rdi, STDOUT
	syscall

	;------
	;	String printed, return to calling routine
	prtDone:
	pop rbx
	ret

global _start
_start:



	;--------------------------------

	mov rbx, list
	mov rsi ,2
	mov rax, 4
	mov rcx, 2
	cmp al, byte[list+2]
	jne qLp
	mov byte[list+4], 6
qLp:
	add al, byte[list+rsi]
	add rsi, 2
	loop qLp
	imul byte[rbx+4]
	inc ax
	idiv byte[rbx+2]
	mov bx, word[list]

	;--------------------------------

	; Pass arguments in reverse order

	push ave	;	8th arguemnt
	push sum	;	7th arguemnt
	mov r9, max	;	6th argument
	mov r8, med2;	5th argument
	mov rcx, med1;	4th argument
	mov rdx, min	; 3rd argument
	mov esi, dword[len]	;	2nd arguemnt
	mov rdi, arr	;	1st argument

	call stats2
	add rsp, 16		; clear passed arguments, ave and sum, from the stack



	mov rdi, message1
	call printString

	mov rdi, message2
	call printString

	mov rdi, newLine
	call printString


	
	;----
	;Display Prompt
	mov rdi, pmpt
	call printString

	;-----
	;Read characters from the user one at a time

	mov rbx, inLine
	mov r12, 0				; character count

readCharacters:
	mov rax, SYS_read
	mov rdi, STDIN
	lea rsi, byte[chr]		; address of chr
	mov rdx, 1				; count of how many to read
	syscall

	mov al, byte[chr]		;	get character just read
	cmp al, LF				;	if linefeed, input done
	je	readDone

	inc r12					; count++
	cmp r12, STRLEN			; if #of chars >= STRLEN, stop
	jae	readCharacters		

	mov byte[rbx], al		; inLine[i] = chr
	inc rbx

	jmp readCharacters
readDone:
	mov byte[rbx], NULL

	mov rdi, inLine
	call printString

	mov rdi, newLine
	call printString


; ----------
;  Byte variables examples (signed data)

;tstMacro dword[n1], dword[n2w], dword[n3], res1, res2, res3, rem3
	

;tstStats dLst, wLst, dword[len], min, med, max, sum, ave

; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call code for exit
	mov	rdi, EXIT_SUCCESS	; exit program with success
	syscall

