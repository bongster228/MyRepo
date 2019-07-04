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

qTwo		dq	2

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


;	YOUR CODE GOES HERE
	cmp byte[isSequential], 1
	jne threeThreads

; pthread_create(&pthreadID0, NULL, &primeCounter, NULL);
	mov rdi, pthreadID0
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

; pthread_join (pthreadID0, NULL);
	mov rdi, qword [pthreadID0]
	mov rsi, NULL
	call pthread_join

	jmp singleThreadDone


;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);


;	YOUR CODE GOES HERE
threeThreads:
	mov rdi, pthreadID0
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

	mov rdi, pthreadID1
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

	mov rdi, pthreadID2
	mov rsi, NULL
	mov rdx, primeCounter
	mov rcx, NULL
	call pthread_create

	mov rdi, qword [pthreadID0]
	mov rsi, NULL
	call pthread_join

	mov rdi, qword [pthreadID1]
	mov rsi, NULL
	call pthread_join

	mov rdi, qword [pthreadID2]
	mov rsi, NULL
	call pthread_join

singleThreadDone:
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


;	YOUR CODE GOES HERE
;  	Display Start message
	mov	rdi, msgThread1
	call	printString
primeCountLP:
;  	Get next number to check, iCounter
	call spinLock
	mov rbx, qword[iCounter]
	inc qword[iCounter]
	call spinUnlock
;  	While(iCounter <= primeLimit)
	cmp rbx, qword[primeLimit]
	jg overPrimeLimit
	
	; check iCounter is prime
	mov rdi, rbx
	call isPrime
;	if (iCounter is prime)
	cmp rax, 1
	jne isPrimeRetFalse
	; inc primeCount
	lock inc qword[primeCount]
isPrimeRetFalse:
	
	jmp primeCountLP	
overPrimeLimit:
	pop rbx
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
;	number (value)
;  Returns:
;	TRUE/FALSE

global	isPrime
isPrime:
	push r12
	push rcx

	mov r12, rdi
;	YOUR CODE GOES HERE
;	if i < 2, not prime
	cmp rdi, 2
	jl notPrime
; 	If i is divisible by 2, then i is not prime
	cmp rdi, 2
	jne greatTwo
	mov rax, 1
	jmp epiloguePrime
greatTwo
	mov rdx, 0
	mov rax, rdi
	div qword[qTwo]
	cmp rdx, 0
	je notPrime
;	If i is not divisible by 2, then:
	;	Calculate k = the approximate square root of i
		mov rdi, r12
		call iSqrt ; iCounter value already in rdi from above
	;	Try to divide i by all odd numbers 3, 5, 7, etc. £ to k
	;	set counters
		mov r12, 0 ; r12 = k (from iSqrt)
		mov r12, rax
		mov rcx, 3 ; rcx = 3
	divideLP:
		cmp rcx, rdi ; rcx is divid counter, rdi is iCounter
		jae foundPrime
		cmp rcx, r12 ; rcx divid counter, r12 sqrt estimate
		jae foundPrime
		mov rdx, 0
		mov rax, rdi
		div rcx
		cmp rdx, 0
		je notPrime
		add rcx, 2
		jmp divideLP
	;	If i is divisible by any of these numbers, then i is not prime

notPrime:
	mov rax, 0
	jmp epiloguePrime
foundPrime:
	mov rax, 1
; epilogue
epiloguePrime:
	pop rcx
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
;	YOUR CODE GOES HERE
	push r12
	push r13
	push rax
	push rcx

;	Set registers
	mov r13, rdi ; num value
	mov r12, rdi ; est value
	mov rcx, 50
;	Sqrt Loop
sqrtLP:
	mov rax, r13
	mov rdx, 0
	div r12
	add rax, r12
	mov rdx, 0
	div qword[qTwo]
	mov r12, rax
	loop sqrtLP
epiogueSqrt:
	inc r12
	mov rax, r12
	pop rcx
	pop rax
	pop r13
	pop r12
	ret


; ******************************************************************
;  Convert integer to ASCII/Octal string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value
;	2) string, address
; -----
;  Returns:
;	ASCII/Octal string (NULL terminated)

global	intToOctal
intToOctal:
push rax  
push rcx  
    mov rax, rdi

	cmp dword[tmpNum],0
	jne notZero
	mov byte[rsi], '0'
	jmp intToOctalDone

notZero:
	; counter = 0
	mov rcx, 0
nextDiv:
	; num = num/8
	mov rdx, 0
	div dword[ddEight]
	; push remainder (rdx)
	push rdx
	; inc counter
	inc rcx
	; if (num != 0) goto nextDiv
	cmp eax, 0
	jne nextDiv
back2String:
	; pop
	pop rax
	; add '0'
	add rax, '0'
	; insert into string
	mov byte[rsi], al
	; loop back2String
	inc rsi
	loop back2String
	; insert NULL
	; mov byte[rsi], NULL

intToOctalDone:
pop rcx
pop rax
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
;	1) ARGC, value (rdi)
;	2) ARGV, address (rsi)
;	3) sequential(bool), address (rdx)
;	4) prime limit (dword), address (rcx)

global getParams
getParams:
;	YOUR CODE GOES HERE
;  prologue
;  preserve registers/save some values
	mov r10, rcx
;  get/check number of arguments (must be 3)
	cmp rdi, 1
	jne notOne
	; display usage message
	mov rdi, errUsage
	call printString
	jmp argExit
notOne:
	cmp rdi, 4
	je argcCorrect
	mov rdi, errOptions
	call printString
	jmp argExit
argcCorrect:
;  get/check serialVparallel arg
	mov r8, qword[rsi+8]
	cmp byte[r8], '-'
	jne firstArgInvalid
	inc r8
	cmp byte[r8], 's'
	je getFirstArg
	cmp byte[r8], 'p'
	je getFirstArg
	jmp firstArgInvalid
getFirstArg:
	mov byte[rdx], TRUE
	cmp byte[r8], 's'
	je gotFirstArg
	mov byte[rdx], FALSE
gotFirstArg:
;  check -l
	mov r8, qword[rsi+16]
	cmp byte[r8], '-'
	jne secondArgInvalid
	inc r8
	cmp byte[r8], 'l'
	jne secondArgInvalid
;  get/check prime limit arg
	mov r8, qword[rsi+24]
	mov rdi, r8
	mov rsi, tmpNum
	call octal2int

	; converted value in rax
	mov r8, LIMITMIN
	cmp rax, r8
	jl primeRangeError
	mov r8, LIMITMAX 
	cmp rax, r8
	jg primeRangeError

goodExit:
	mov eax, dword[tmpNum]
	mov dword[r10], eax
	mov rax, 0
	mov al, TRUE
	ret

;  error and exit
argExit:
	mov rax, 0
	mov al, FALSE
	ret

firstArgInvalid:
	mov rdi, errSSpec
	call printString
	jmp argExit
secondArgInvalid:
	mov rdi, errPLSpec
	call printString
	jmp argExit
primeRangeError:
	mov rdi, errPLValue
	call printString
	jmp argExit

; ******************************************************************
;  Function: Check and convert ASCII/octal to integer
;	return false 

;  Example HLL Call:
;	stat = octal2int(vStr, &num);
;                    rdi    rsi 
global	octal2int
octal2int:
;	YOUR CODE GOES HERE

	mov rax, 0
cutString:
	mov r8, 0
	; get char
	mov r8b, byte[rdi]
	; if char == NULL, exit loop
	cmp r8b, NULL
	je cutDone
	; int = char - '0'
	sub r8b, '0'
	; check range
	cmp r8b, 0
	jl octalError
	cmp r8b, 7
	jg octalError
	; rsum = rsum * 8
	mul dword[ddEight]
	; rsum = rsum + int
	add eax, r8d
	; inc rdi
	inc rdi
	; go to cutString loop
	jmp cutString

cutDone:
	mov rsi, rax
	mov rax, 1
	ret

octalError:
	mov rdi, errPLValue
	call printString
	mov rax, SYS_exit
	syscall
; ******************************************************************

