;  CS 218 - Assignment 8
;  Functions Template.

; --------------------------------------------------------------------
;  Write assembly language procedures/functions.

;  * Void function, bubbleSort(), sorts the numbers into descending
;    order (large to small).  Uses the bubble sort algorithm from
;    assignment #7 (modified to sort in descending order).

;  * Void function, cubeAreas(), to calculate the area of each cube
;    in a series of cube sides.

;  * Void function, cubeStats(), that given an array of integer
;    cube areas, finds the minimum, maximum, sum, integer average,
;    sum of numbers evenly divisible by 3.

;  * Integer function, iMedian(), to compute and return the integer
;    median for a list of numbers. Note, for an odd number of items,
;    the median value is defined as the middle value.  For an even
;    number of values, it is the integer average of the two middle
;    values. A 32-bit integer function returns the result in eax.

;  * Integer function, eStatistic(), to compute the m-statistic for
;    a list of numbers.

;  Note, all data is signed!

; ********************************************************************************

section	.data

; -----
;  Define standard constants.

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
;  Variables for bubbleSort() void function (if any)

; -----
;  Variables for cubeAreas() void function (if any)


; -----
;  Variables for cubeStats() void function (if any)


; -----
;  Variables for integer iMedian() function (if any)


; -----
;  Variables for integer eStatistic() function (if any)


; **************************************************************************

section	.text

; **************************************************************************
;  Function to calculate cube areas
;	cubeAreas[i] = 6 ∗ sides[i]^2

; -----
;  Call:
;	cubeAreas(cSides, len, cAreas);

;  Arguments Passed:
;	1) cube sides array, addr
;	2) length, value
;	3) cube areas array, addr

;  Returns:
;	cAreas[] via reference

global cubeAreas
cubeAreas:

	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	push r8
	push r9

	mov ecx, esi
	mov r8, rdx		;	Save the address of cube areas array
	mov rax, 0

cubeAreaLp:
	mov eax, dword[rdi]
	mul eax
	mov ebx, 6
	mul ebx
	mov dword[r8], eax

	add r8, 4
	add rdi, 4
	loop cubeAreaLp

	pop r9
	pop r8
	pop rcx
	pop rbx
	
	pop rbp
	ret

; **************************************************************************
;  Function to implement bubble sort to sort an integer array.
;	Note, sorts in desending order

; -----
;  HLL Call:
;	bubbleSort(list, len);

;  Arguments Passed:
;	1) list, addr
;	2) length, value

;  Returns:
;	sorted list (list passed by reference)

global	bubbleSort
bubbleSort:

	push rbp
	mov rbp, rsp
	sub rsp, 1
	push rbx
	push r8
	push r9

	dec esi		; i = len - 1
outerForLp:
	;	swapped = false
	mov byte[rbp-1], FALSE
	;	for (j = 0 to i)
	mov ebx, 0
inForLp:
	;	if( lst[j] < lst[j+1])
	mov r8d, dword[rdi+rbx*4]		;	lst[j]
	mov r9d, dword[rdi+rbx*4+4]	;	lst[j+1]
	cmp r8d, r9d
	jge ifDone				;	if	lst[j] >= lst[j+1] then jump

	mov dword[rdi+rbx*4], r9d
	mov dword[rdi+rbx*4+4], r8d
	mov byte[rbp-1], TRUE

ifDone:
	inc ebx			; j++
	cmp ebx, esi
	jne inForLp

	cmp byte[rbp-1], FALSE
	je sortDone

	;	--i
	dec esi
	cmp esi, 0
	jne outerForLp

	;	exit
sortDone:
	
	pop r9
	pop r8
	pop rbx
	mov rsp, rbp
	pop rbp

	ret

; **************************************************************************
;  Function to find some statistical information of an integer array:
;	minimum, median, maximum, sum, average, sum of numbers
;	evenly diviside by 3
;  Note, you may assume the list is already sorted.

; -----
;  HLL Call:
;	cubeStats(list, len, min, max, sum, ave, threeSum);

;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) minimum, addr
;	4) maximum, addr
;	5) sum, addr
;	6) average, addr
;	7) threeSum, addr

;  Returns:
;	minimum, maximum, sum, average, amd
;	three sum via pass-by-reference

global cubeStats
cubeStats:

	push rbp
	mov rbp, rsp
	push r12
	push r13

	;	Min
	mov eax, dword[rdi+rsi*4-4]
	mov dword[rdx], eax

	;	Max
	mov eax, dword[rdi]
	mov dword[rcx], eax

	;	Sum and Avg
	mov rax, 0
	mov r12d, esi
	mov r13, rdi
sumLp:
	add eax, dword[r13]
	add r13, 4
	dec r12d
	cmp r12d, 0
	jne sumLp

	mov dword[r8], eax
	cdq
	idiv esi
	mov dword[r9], eax

	;	ThreeSum
	mov rax, 0	
	mov r12, 0
	mov r13, 0	;	running sum

threeSumLp:
	mov eax, dword[rdi]
	cdq
	mov r12d, 3
	idiv r12d
	cmp edx, 0
	jne notThree
	add r13d, eax

notThree:
	add rdi, 4
	dec esi
	cmp esi, 0
	jne threeSumLp

	;	Copy the address from the stack
	;	then put the value in
	mov r12, qword[rbp+16]
	mov dword[r12], r13d

	pop r12
	pop r13
	pop rbp

	ret

; **************************************************************************
;  Function to calculate the integer median of an integer array.
;	Note, for an odd number of items, the median value is defined as
;	the middle value.  For an even number of values, it is the integer
;	average of the two middle values.

; -----
;  HLL Call:
;	med = iMedian(list, len);

;  Arguments Passed:
;	1) list, addr - 8
;	2) length, value - 12

;  Returns:
;	integer median - value (in eax)

global iMedian
iMedian:

	push rbp
	mov rbp, rsp
	
	mov rcx, 0

	;	Check if length is even or odd
	mov eax, esi
	cdq
	mov ecx, 2
	idiv ecx
	mov ecx, eax	;	Move index to ecx
	cmp edx, 0
	je isEven

	mov eax, dword[rdi+rcx*4]
	jmp medDone

isEven:

	mov eax, dword[rdi+rcx*4]
	dec rcx
	add eax, dword[rdi+rcx*4]
	mov ecx, 2
	cdq
	idiv ecx
	
medDone:
	pop rbp
	ret

; **************************************************************************
;  Function to calculate the integer e-statictic of an integer array.
;	Formula for eStat is:
;		eStat = sum [ (list[i] - median)^2 ]
;	Must use iMedian() function to find median.
;  Note, due to the data sizes, the summation must be performed as a quad-word.

; -----
;  HLL Call:
;	var = eStatistic(list, len);

;  Arguments Passed:a
;	1) list, addr
;	2) length, value

;  Returns:
;	eStat - value (in rax)

global eStatistic
eStatistic:

	push rbp
	mov rbp, rsp
	sub rsp, 8
	push r11
	
	mov rax, 0
	call iMedian	;	returns the median into eax
	
	mov rcx, rax	;	store median in rcx
	mov r11, 0		;	running sum

eStatsSumLp:
	mov eax, dword[rdi]
	sub eax, ecx

	imul eax		; (area - med)^2

	;	Combine the result
	mov dword[rbp-8], eax
	mov dword[rbp-4], edx

	;	Add to running sum
	add r11, qword[rbp-8]

	add rdi, 4
	dec esi
	cmp esi, 0
	jne eStatsSumLp

	mov rax, r11


	pop r11
	mov rsp, rbp
	pop rbp

	ret

; ***************************************************************************

