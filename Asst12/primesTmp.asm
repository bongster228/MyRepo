; Bong Lee
; CS 218
; Assignment #12
; Threading program, provided template

; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	-1

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

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

; -----
;  Message strings

header		db	"*******************************************", LF
		db	ESC, "[1m", "Primes Program", ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Prime Count", LF, NULL
msgDoneMain	db	"Prime Count: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

primeLimit	dq	10000			; array size
isSequential	db	TRUE			; bool

; -----
;  Globals (used by threads)

iCounter	dq	0
primeCount	dq	0

myLock		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0

; -----
;  Variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Variables for getParams function

LIMITMIN	equ	1000
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./primes <-s|-p> ",
		db	"-l <ocatlNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errSSpec	db	"Error, invalid sequential/parallel specifier."
		db	LF, NULL
errPLSpec	db	"Error, invalid prime limit specifier."
		db	LF, NULL
errPLValue	db	"Error, prime out of range."
		db	LF, NULL

; -----
;  Variables for int2octal function

ddEight		dd	8
tmpNum		dd	0

; -----

section	.bss

tmpString	resb	20


; ***************************************************************

section	.text

; -----
; External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Prime number counting program.

global main
main:
	push	rbp
	mov	rbp, rsp

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, isSequential
	mov	rcx, primeLimit
	call	getParams

	cmp	rax, TRUE
	jne	progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

;  Create new thread(s)
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);
;  if sequntial, start 1 thread
;  if parallel, start 3 threads

	cmp byte[isSequential], FALSE
	je parallel

;	Sequetial(1 Thread)

	mov rdi, pthreadID0
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create


;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);


	mov rdi, qword[pthreadID0]
	mov rsi, NULL
	call pthread_join

	jmp showFinalResults

;	Parallel
	parallel:

	mov qword[iCounter], 0

	;	Create thread 1
	mov rdi, pthreadID0
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

	;	Create thread 2
	mov rdi, pthreadID1
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

	;	Create thread 3
	mov rdi, pthreadID2
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

;	Join threads

	;	Join thread 1
	mov rdi, qword[pthreadID0]
	mov rsi, NULL
	call pthread_join

	;	Join thread 2
	mov rdi, qword[pthreadID1]
	mov rsi, NULL
	call pthread_join

	;	Join thread 3
	mov rdi, qword[pthreadID2]
	mov rsi, NULL
	call pthread_join

; -----
;  Display final count

showFinalResults:
	mov	rdi, msgDoneMain
	call	printString

	mov	rdi, qword [primeCount]
	mov	rsi, tmpString
	call	intToOctal

	mov	rdi, tmpString
	call	printString

	mov	rdi, newLine
	call	printString

; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	mov	rax, SYS_exit			; system call for exit
	mov	rdi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, primeCounter()
;	Detemrine which numbers between 1 and
;	primeLimit (gloabally available) are prime.

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)

global primeCounter
primeCounter:
	push	rbx

	primeCountLp:

	;	Get the number
	;call spinLock

	mov rbx, qword[iCounter]
	add qword[iCounter], 1

	;call spinUnlock

	cmp rbx, qword[primeLimit]
	jge	primeCountDone

	;	Check for prime
	mov rdi, rbx
	call isPrime
	cmp rax, FALSE			;	Don't increment count if not prime
	je primeCountLp

	inc qword[primeCount]

	jmp primeCountLp

	primeCountDone:
	
	pop 	rbx

ret

; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Check if a passed number is prime.
;	note, uses iSqrt() function for integer square root approximation

;  Arguments:
;	number (value)			rdi
;  Returns:
;	TRUE/FALSE

global	isPrime
isPrime:

	push r12

	mov r12, rdi

	;	Number 2 is prime
	cmp r12, 2
	je yesPrime

	mov rsi, 2
	;	Check if divisible by 2
	mov rax, rdi

	mov rdx, 0
	div rsi

	cmp rdx, 0
	je	noPrime

	;	Not divisible by 2
	mov rdi, r12
	call iSqrt			;	rax = k = sqrt(i)

	;	divide k by all odd nums <= k
	mov rdi, rax		;	rdi = k

	mov rsi, 3			;	odd number counter
	chkPrimeLp:
	mov rax, r12

	mov rdx, 0
	div rsi
	
	cmp rdx, 0			;	if divisible, not prime
	je noPrime

	add rsi, 2			;	next odd number
	cmp rsi, rdi		;	keep dividig until oddNum >= k
	jl	chkPrimeLp	

	yesPrime:
	mov rax, TRUE
	jmp exitIsPrime

	noPrime:
	mov rax, FALSE
	jmp exitIsPrime

	exitIsPrime:


	pop r12

ret

; ******************************************************************
;  Function to calculate and return an integer estimate of
;  the square root of a given number.

;  To estimate the square root of a number, use the following
;  algorithm:
;	sqrt_est = number
;	iterate 50 times
;		sqrt_est = ((number/sqrt_est)+sqrt_est)/2

; -----
;  Call:
;	ans = iSqrt(number)

;  Arguments Passed:
;	1) number, value - rdi

;  Returns:
;	square root value (in eax)


global	iSqrt
iSqrt:

	mov rcx, 50		;	iterate counter
	mov rax, 0		;	number
	mov rsi, 2

	mov r9, 0		;	store prev sqrt_est
	mov r8,	rdi		;	sqrt_est = number
	sqrtLp:
	mov rax, rdi

	mov rdx, 0
	div r8			;	number / sqrt_est

	add rax, r8		;	+ sqrt_est
	
	mov rdx, 0
	div rsi
	mov rdx, 0

	mov r8, rax		;	r8 = sqrt_est

	cmp r8, r9		;	if curr and pre estimates are same, done
	je sqrtDone

	mov r9, rax

	dec rcx
	cmp rcx, 0
	jne sqrtLp

	sqrtDone:

	inc rax			;	increase by 1 to force round up

ret

; ******************************************************************
;  Convert integer to ASCII/Octal string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value			rdi
;	2) string, address			rsi
; -----
;  Returns:
;	ASCII/Octal string (NULL terminated)

global	intToOctal
intToOctal:

	push r12

	mov rax, rdi
	mov r8, 8
	mov r12, 0		;	push counter

	toOctLp:
	mov rdx, 0
	div r8

	push rdx
	inc r12

	cmp rax, 0
	je toOctLpDone

	jmp toOctLp

	toOctLpDone:

	;	Pop the digits into string
	mov r8, 0		; stringcd  index counter
	popOctLp:

	pop rax
	dec r12
	add rax, "0"

	mov byte[rsi+r8], al
	inc r8

	cmp r12, 0
	je popOctLpDone
	jmp popOctLp

	popOctLpDone:

	mov byte[rsi+r8], NULL

	pop r12

ret

; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
; Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************
;  Function getParams()
;	Get, check, convert, verify range, and return the
;	thread count and prime limit.

;  Example HLL call:
;	stat = getParams(argc, argv, &isSequntial, &primeLimit)

;  This routine performs all error checking, conversion of ASCII/Vegismal
;  to integer, verifies legal range of each value.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	<-s|-p> -l <vegismalNumber>

; -----
;  Arguments:
;	1) ARGC, value						rdi
;	2) ARGV, address					rsi
;	3) sequential(bool), address		rdx
;	4) prime limit (dword), address		rcx

global getParams
getParams:

	push r12
	push r13

	mov r13, rcx

	cmp rdi, 1
	je showUsage

	;	Check for 3 Argument counts
	cmp rdi, 4
	jne	invldArgCount

	;	Check argv[1]
	mov r12, qword[rsi+8]
	cmp byte[r12], "-"
	jne invldArgOne

	inc r12

	cmp byte[r12], "s"
	jne notSequential
	mov qword[rdx], TRUE
	jmp notParallel
	notSequential:


	cmp byte[r12], "p"
	jne	invldArgOne
	mov qword[rdx], FALSE
	notParallel:

	inc r12

	cmp byte[r12], NULL
	jne	invldArgOne

	;	Check argv[2]
	mov r12, qword[rsi+16]

	cmp byte[r12], "-"
	jne invldArgTwo

	inc r12

	cmp byte[r12], "l"
	jne invldArgTwo

	inc r12
	cmp byte[r12], NULL
	jne invldArgTwo

	;	Check argv[3], find prime range
	mov rdi, qword[rsi+24]
	call octal2int

	mov r8, LIMITMIN
	cmp rsi, r8
	jb	invldLimit

	mov r8, LIMITMAX
	cmp rsi, r8
	ja	invldLimit

	mov qword[r13], rsi
	mov rax, TRUE
	jmp exitGetArgument

	invldArgCount:
	mov rdi, errOptions
	call printString
	mov rax, FALSE
	jmp exitGetArgument

	invldArgOne:
	mov rdi, errSSpec
	call printString
	mov rax, FALSE
	jmp exitGetArgument

	invldArgTwo:
	mov rdi, errPLSpec
	call printString
	mov rax, FALSE
	jmp exitGetArgument

	showUsage:
	mov rdi, errUsage
	call printString
	mov rax, FALSE
	jmp exitGetArgument

	invldLimit:
	mov rdi, errPLValue
	call printString
	mov rax, FALSE
	jmp exitGetArgument

	exitGetArgument:

	pop r13
	pop r12

ret

; ******************************************************************
;  Function: Check and convert ASCII/octal to integer
;	return false 

;  Example HLL Call:
;	stat = octal2int(vStr, &num);

	;	rdi		vStr
	;	rsi		num addr

global	octal2int
octal2int:

	mov rdx, 0		;	hold digit
	mov rcx, 0		;	index counter
	mov rax,	0	;	running sum
	mov r8,	8

	toIntLp:
	mov dl, byte[rdi+rcx]	;	Get the digit char

	sub dl, "0"
	add rax, rdx

	mov dl, byte[rdi+rcx+1]
	cmp dl, NULL
	je exitIntCvt

	mul r8
	mov rdx, 0		;	reset rdx
	inc rcx
	jmp toIntLp

	exitIntCvt:

	mov rsi, rax		;	return num by ref
	mov rax, TRUE		;	retun TRUE by value

ret

; ******************************************************************

