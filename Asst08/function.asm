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


;	YOUR CODE GOES HERE


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


;	YOUR CODE GOES HERE


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


;	YOUR CODE GOES HERE


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


;	YOUR CODE GOES HERE


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


;	YOUR CODE GOES HERE


	ret

; ***************************************************************************

