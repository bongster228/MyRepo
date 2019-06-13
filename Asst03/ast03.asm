; *****************************************************************
;  Must include:
;	name
;	assignmnet #
;	section #

; -----
;  Write a simple assembly language program to compute the
;  the provided formulas.

;  Focus on learning basic arithmetic operations
;  (add, subtract, multiply, and divide).
;  Ensure understanding of sign and unsigned operations.

; *****************************************************************
;  Data Declarations (provided).

section	.data

; -----
;  Define constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

SYS_exit	equ	60			; call code for terminate

; -----
;  Assignment #3 data declarations

; byte data
bNum1		db	33
bNum2		db	19
bNum3		db	16
bNum4		db	13
bNum5		db	-46
bNum6		db	-69
bAns1		db	0
bAns2		db	0
bAns3		db	0
bAns4		db	0
bAns5		db	0
bAns6		db	0
bAns7		db	0
bAns8		db	0
bAns9		db	0
bAns10		db	0
wAns11		dw	0
wAns12		dw	0
wAns13		dw	0
wAns14		dw	0
wAns15		dw	0
bAns16		db	0
bAns17		db	0
bAns18		db	0
bRem18		db	0
bAns19		db	0
bAns20		db	0
bAns21		db	0
bRem21		db	0

; word data
wNum1		dw	356
wNum2		dw	1953
wNum3		dw	5817
wNum4		dw	2314
wNum5		dw	-753
wNum6		dw	-276
wAns1		dw	0
wAns2		dw	0
wAns3		dw	0
wAns4		dw	0
wAns5		dw	0
wAns6		dw	0
wAns7		dw	0
wAns8		dw	0
wAns9		dw	0
wAns10		dw	0
dAns11		dd	0
dAns12		dd	0
dAns13		dd	0
dAns14		dd	0
dAns15		dd	0
wAns16		dw	0
wAns17		dw	0
wAns18		dw	0
wRem18		dw	0
wAns19		dw	0
wAns20		dw	0
wAns21		dw	0
wRem21		dw	0

; double-word data
dNum1		dd	14365870
dNum2		dd	32451
dNum3		dd	938671
dNum4		dd	58473
dNum5		dd	-7982
dNum6		dd	-5358
dAns1		dd	0
dAns2		dd	0
dAns3		dd	0
dAns4		dd	0
dAns5		dd	0
dAns6		dd	0
dAns7		dd	0
dAns8		dd	0
dAns9		dd	0
dAns10		dd	0
qAns11		dq	0
qAns12		dq	0
qAns13		dq	0
qAns14		dq	0
qAns15		dq	0
dAns16		dd	0
dAns17		dd	0
dAns18		dd	0
dRem18		dd	0
dAns19		dd	0
dAns20		dd	0
dAns21		dd	0
dRem21		dd	0

; quadword data
qNum1		dq	204623
qNum2		dq	32543819
qNum3		dq	2415331
qNum4		dq	341087
qNum5		dq	-921028
qNum6		dq	-281647
qAns1		dq	0
qAns2		dq	0
qAns3		dq	0
qAns4		dq	0
qAns5		dq	0
qAns6		dq	0
qAns7		dq	0
qAns8		dq	0
qAns9		dq	0
qAns10		dq	0
dqAns11		ddq	0
dqAns12		ddq	0
dqAns13		ddq	0
dqAns14		ddq	0
dqAns15		ddq	0
qAns16		dq	0
qAns17		dq	0
qAns18		dq	0
qRem18		dq	0
qAns19		dq	0
qAns20		dq	0
qAns21		dq	0
qRem21		dq	0

; *****************************************************************

section	.text
global _start
_start:

; ----------------------------------------------
;  BYTE Operations

; -----
;  unsigned byte additions
;	bans1 = bnum1 + bnum2

    mov al, byte [bNum1]
    add al, byte [bNum2]
    mov byte [bAns1], al

;	bans2 = bnum3 + bnum4

    mov al, byte [bNum3]
    add al, byte [bNum4]
    mov byte [bAns2], al

;	bans3 = bnum3 + bnum1

    mov al, byte[bNum3]
    add al, byte[bNum1]
    mov byte[bAns3], al

; -----
;  signed byte additions
;	bans4 = bnum6 + bnum3

    mov al, byte [bNum6]
    add al, byte [bNum3]
    mov byte [bAns4], al

;	bans5 = bnum6 + bnum5

    mov al, byte[bNum6]
    add al, byte[bNum5]
    mov byte[bAns5], al

; -----
;  unsigned byte subtractions
;	bans6 = bnum1 - bnum3

    mov al, byte [bNum1]
    sub al, byte [bNum3]
    mov byte [bAns6], al

;	bans7 = bnum2 - bnum1

    mov al, byte[bNum2]
    sub al, byte[bNum1]
    mov byte[bAns7], al

;	bans8 = bnum4 - bnum3

    mov al, byte[bNum4]
    sub al, byte[bNum3]
    mov byte[bAns8], al

; -----
;  signed byte subtraction
;	bans9 = bnum6 - bnum4

    mov al, byte[bNum6]
    sub al, byte[bNum4]
    mov byte[bAns9], al

;	bans10 = bnum6 - bnum5

    mov al, byte[bNum6]
    sub al, byte[bNum5]
    mov byte[bAns10], al


; -----
;  unsigned byte multiplication
;	wans11 = bnum2 * bnum4

    mov al, byte[bNum2]
    mul byte[bNum4]
    mov word[wAns11], ax

;	wans12 = bnum1 * bnum4

    mov al, byte[bNum1]
    mul byte[bNum4]
    mov word[wAns12], ax

;	wans13 = bnum3 * bnum2

    mov al, byte[bNum3]
    mul byte[bNum2]
    mov word[wAns13], ax

; -----
;  signed byte multiplication
;	wans14 = bnum3 * bnum5

    mov al, byte[bNum3]
    imul byte[bNum5]
    mov word[wAns14], ax

;	wans15 = bnum5 * bnum6

    mov al, byte[bNum5]
    imul byte[bNum6]
    mov word[wAns15], ax

; -----
;  unsigned byte division
;	bans16 = bnum2 / bnum4 

    mov al, byte[bNum2]
    mov ah, 0
    div byte[bNum4]
    mov byte[bAns16], ah

;	bans17 = bnum1 / bnum3 

    mov al, byte[bNum1]
    mov ah, 0
    div byte[bNum3]
    mov byte[bAns17], al

;	bans18 = wnum2 / bnum3 

    mov ax, word[wNum2]
    div byte[bNum3]
    mov byte[bAns18], al

;	brem18 = modulus (wnum2 / bnum3) 

    mov ax, word[wNum2]
    div byte[bNum3]
    mov byte[bRem18], ah

; -----
;  signed byte division
;	bans19 = bnum6 / bnum3

    mov al, byte[bNum6]
    cbw
    idiv byte[bNum3]
    mov byte[bAns19], al

;	bans20 = bnum6 / bnum5

    mov al, byte[bNum6]
    cbw
    idiv byte[bNum5]
    mov byte[bAns20], al

;	bans21 = wmum4 / bnum1

    mov ax, word[wNum4]
    idiv byte[bNum1]
    mov byte[bAns21], al

;	brem21 = modulus (wnum4 / bnum1)

    mov ax, word[wNum4]
    idiv byte[bNum1]
    mov byte[bRem21], ah



; *****************************************
;  WORD Operations

; -----
;  unsigned word additions
;	wans1 = wnum1 + wnum4
;	wans2 = wnum2 + wnum3
;	wans3 = wnum2 + wnum4



; -----
;  signed word additions
;	wans4 = wnum5 + wnum6
;	wans5 = wnum6 + wnum4



; -----
;  unsigned word subtractions
;	wans6 = wnum3 - wnum2
;	wans7 = wnum4 - wnum2
;	wans8 = wnum2 - wnum4



; -----
;  signed word subtraction
;	wans9 = wnum6 - wnum4
;	wans10 = wnum5 - wnum6



; -----
;  unsigned word multiplication
;	dans11 = wnum3 * wnum2

    mov ax, word[wNum3]
    mul word[wNum2]
    mov word[dAns11], ax
    mov word[dAns11+2], dx

;	dans12 = wnum2 * wnum4

    mov ax, word[wNum2]
    mul word[wNum4]
    mov word[dAns12], ax
    mov word[dAns12+2], dx

;	dans13 = wnum1 * wnum3



; -----
;  signed word multiplication
;	dans14 = wnum6 * wnum5

    mov ax, word[wNum6]
    imul word[wNum5]
    mov word[dAns14], ax
    mov word[dAns14+2], dx

;	dans15 = wnum4 * wnum5

    mov ax, word[wNum4]
    imul word[wNum5]
    mov word[dAns15], ax
    mov word[dAns15+2], dx

; -----
;  unsigned word division
;	wans16 = wnum2 / wnum1

    mov ax, word[wNum2]
    mov dx, 0
    div word[wNum1]
    mov word[wAns16], ax

;	wans17 = wnum4 / wnum2
;	wans18 = dnum2 / wnum3 
;	wrem18 = modulus (dnum2 / wnum3) 



; -----
;  signed word division
;	wans19 = wnum5 / wnum6

    mov ax, word[wNum5]
    cwd
    idiv word[wNum6]
    mov word[wAns19], ax

;	wans20 = wnum4 / wnum2
;	wans21 = dnum2 / wnum3 
;	wrem21 = modulus (dnum2 / wnum3)



; *****************************************
;  DOUBLEWORD Operations

; -----
;  unsigned double word additions
;	dans1 = dnum1 + dnum3
;	dans2 = dnum3 + dnum2
;	dans3 = dnum4 + dnum1



; -----
;  signed double word additions
;	dans4 = dnum5 + dnum4 
;	dans5 = dnum6 + dnum2



; -----
;  unsigned double word subtractions
;	dans6 = dnum3 - dnum2

    mov eax, dword[dNum3]
    sub eax, dword[dNum2]
    mov dword[dAns6], eax

;	dans7 = dnum1 - dnum4
;	dans8 = dnum4 - dnum3



; -----
;  signed double word subtraction
;	dans9 = dnum2 - dnum6 
;	dans10 = dnum5 – dnum2 



; -----
;  unsigned double word multiplication
;	qans11 = dnum3 * dnum4

    mov eax, dword[dNum3]
    mul dword[dNum4]
    mov dword[qAns11], eax
    mov dword[qAns11+4], edx

;	qans12 = dnum1 * dnum3

    mov eax, dword[dNum1]
    mul dword[dNum3]
    mov dword[qAns12], eax
    mov dword[qAns12+4], edx

;	qans13 = dnum2 * dnum3



; -----
;  signed double word multiplication
;	qans14 = dnum2 * dnum5

    mov eax, dword[dNum2]
    imul dword[dNum5]
    mov dword[qAns14], eax
    mov dword[qAns14+4], edx

;	qans15 = dnum5 * dnum6



; -----
;  unsigned double word division
;	dans16 = dnum4 / dnum2

    mov eax, dword[dNum4]
    mov edx, 0
    div dword[dNum2]
    mov dword[dAns16], eax

;	dans17 = dnum1 / dnum2
;	dans18 = qAns13 / dnum1
;	drem18 = modulus (qAns13 / dnum1)



; -----
;  signed double word division
;	dans19 = dnum2 / dnum6

    mov eax, dword[dNum2]
    cdq
    idiv dword[dNum6]
    mov dword[dAns19], eax

;	dans20 = dnum5 / dnum6
;	dans21 = qans12 / dnum2
;	drem21 = modulus (qans12 / dnum2)



; *****************************************
;  QUADWORD Operations

; -----
;  unsigned quadword additions
;	qAns1  = qNum1 + qNum3

    mov rax, qword[qNum1]
    add rax, qword[qNum3]
    mov qword[qAns1], rax

;	qAns2  = qNum2 + qNum4
;	qAns3  = qNum3 + qNum2



; -----
;  signed quadword additions
;	qAns4  = qNum2 + qNum5

    mov rax, qword[qNum2]
    add rax, qword[qNum5]
    mov qword[qAns4], rax

;	qAns5  = qNum6 + qNum5



; -----
;  unsigned quadword subtractions
;	qAns6  = qNum1 - qNum3
;	qAns7  = qNum2 - qNum4
;	qAns8  = qNum4 - qNum3



; -----
;  signed quadword subtraction
;	qAns9  = qNum2 - qNum5
;	qAns10 = qNum5 - qNum2



; -----
;  unsigned quadword multiplication
;	dqAns11  = qNum4 * qNum2

    mov rax, qword[qNum4]
    mul qword[qNum2]
    mov qword[dqAns11], rax
    mov qword[dqAns11+8], rdx

;	dqAns12  = qNum2 * qNum3
;	dqAns13  = qNum3 * qNum1



; -----
;  signed quadword multiplication
;	dqAns14  = qNum2 * qNum5

    mov rax, qword[qNum2]
    imul qword[qNum5]
    mov qword[dqAns14], rax
    mov qword[dqAns14+8], rdx

;	dqAns15  = qNum6 * qNum1



; -----
;  unsigned quadword division
;	qAns16 = qNum2 / qNum3

    mov rax, qword[qNum2]
    mov rdx, 0
    div qword[qNum3]
    mov qword[qAns16], rax

;	qAns17 = qNum3 / qNum4

    mov rax, qword[qNum3]
    mov rdx, 0
    div qword[qNum4]
    mov qword[qAns17], rax

;	qAns18 = dqAns13 / qNum2
;	qRem18 = dqAns13 % qNum2



; -----
;  signed quadword division
;	qAns19 = qNum5 / qNum6

    mov rax, qword[qNum5]
    cqo
    idiv qword[qNum6]
    mov qword[qAns19], rax

;	qAns20 = qNum3 / qNum6
;	qAns21 = dqAns12 / qNum5
;	qRem21 = dqAns12 % qNum5



; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call code for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS
	syscall

