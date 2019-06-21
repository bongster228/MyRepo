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

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
SYS_exit	equ	60			; call code for terminate

; -----
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

	wLst	dw	1, 2, 3, 4, 5, 6, 7, 8, 9, 10
	len		dd	10
	min		dd 	0
	med		dd 	0
	max		dd	0
	sum		dd 	0
	ave		dd 	0

	sqVal	dd	0

section .bss

	dLst	resd	10

; *****************************************************************
;  Code Section

section	.text
global _start
_start:

; ----------
;  Byte variables examples (signed data)

;tstMacro dword[n1], dword[n2w], dword[n3], res1, res2, res3, rem3
	

tstStats dLst, wLst, dword[len], min, med, max, sum, ave

; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call code for exit
	mov	rdi, EXIT_SUCCESS	; exit program with success
	syscall

