;  Must include:
;	Bong Lee
;   Asst 02
;   Section 1001

; -----
; Write a simple assembly language program to compute the following formulas:
;	bAns1  =  bVar1 + bvar2
;	bAns2  =  bVar1 - bvar2
;	wAns1  =  wVar1 + wvar2
;	wAns2  =  wVar1 - wvar2
;	dAns1  =  dVar1 + dVar2
;	dAns2  =  dVar1 - dVar2

; *****************************************************************
          
section	.data

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

SYS_exit	equ	60			; call code for terminate

; -----
;  Assignment specific variables.

bVar1		db	38
bVar2		db	16
bAns1		db	0
bAns2		db	0
wVar1		dw	3716
wVar2		dw	1867
wAns1		dw	0
wAns2		dw	0
dVar1		dd	168318283
dVar2		dd	135678291
dVar3		dd	-47156
dAns1		dd	0
dAns2		dd	0
flt1		dd	-14.125
flt2		dd	-13.25
fourPi		dd	12.56636
qVar1		dq	134278427262
myClass		db	"CS 218", NULL
edName		db	"Ed Jorgensen", NULL
myName		db	"Bong Lee", NULL


; *****************************************************************

section	.text
global _start
_start:

; -----
;  bAns1  =  bVar1 + bVar2
;  bAns2  =  bVar1 - bVar2

;	YOUR CODE GOES HERE

;   bAns1 = bVar1 + bVar2
    mov al, byte [bVar1]
    add al, byte [bVar2]
    mov byte [bAns1], al

;   bAns2 = bVar1 - bVar2
    mov al, byte [bVar1]
    sub al, byte [bVar2]
    mov byte [bAns2], al

; -----
;  wAns1  =  wVar1 + wVar2
;  wAns2  =  wVar1 - wVar2

;	YOUR CODE GOES HERE

;   wAns1 = wVar1 + wVar2
    mov ax, word [wVar1]
    add ax, word [wVar2]
    mov word [wAns1], ax

;   wAns2 = wVar1 - wVar2
    mov ax, word [wVar1]
    sub ax, word [wVar2]
    mov word [wAns2], ax


; -----
;  dAns1  =  dVar1 + dVar2
;  dAns2  =  dVar1 - dVar2

;	YOUR CODE GOES HERE

;   dAns1 = dVar1 + dVar2
    mov eax, dword [dVar1]
    add eax, dword [dVar2]
    mov dword[dAns1], eax

;   dAns2 = dVar1 - dVar2
    mov eax, dword[dVar1]
    sub eax, dword[dVar2]
    mov dword[dAns2], eax


; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS
	syscall

