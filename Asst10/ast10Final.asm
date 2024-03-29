;  Assignment #10
;  Support Functions.
;  Provided Template

; -----
;  Function getIterations()
;	Gets, checks, converts, and returns iteration
;	count and rotation speed from the command line.

;  Function drawChaos()
;	Calculates and plots Chaos algorithm

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
EXIT_NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program constants.

IT_MIN		equ	255
IT_MAX		equ	65535
RS_MAX		equ	32768

; -----
;  Local variables for getIterations() function.

errUsage	db	"Usage: chaos -it <octalNumber> -rs <octalNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL
errITsp		db	"Error, iterations specifier incorrect."
		db	LF, NULL
errITvalue	db	"Error, invalid iterations value."
		db	LF, NULL
errITrange	db	"Error, iterations value must be between "
		db	"377 (8) and 177777 (8)."
		db	LF, NULL
errRSsp		db	"Error, rotation speed specifier incorrect."
		db	LF, NULL
errRSvalue	db	"Error, invalid rotation speed value."
		db	LF, NULL
errRSrange	db	"Error, rotation speed value must be between "
		db	"0 (8) and 100000 (8)."
		db	LF, NULL

; -----
;  Local variables for plotChaos() funcction.

red			dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255

pi			dq	3.14159265358979	; constant
oneEighty	dq	180.0
tmp			dq	0.0

dStep		dq	120.0			; t step
scale		dq	500.0			; scale factor

rScale		dq	100.0			; rotation speed scale factor
rStep		dq	0.1			; rotation step value
rSpeed		dq	0.0			; scaled rotation speed

initX		dq	0.0, 0.0, 0.0		; array of x values
initY		dq	0.0, 0.0, 0.0		; array of y values

x		dq	0.0
y		dq	0.0

seed		dq	987123
seed2		dq	0
qThree		dq	3
fTwo		dq	2.0

A_VALUE		equ	9421			; must be prime
B_VALUE		equ	1

tstVal1		dq	0
tstVal2		dq	0
randNum		dd	0
zero		dq	0
sinVal		dq	0

; -----
;  Local variables for readOctalNum()

BUFFSIZE	equ	50
itVal		dd	0
rsVal		dd 	0
char		db	0
rSum		dd	0

; ------------------------------------------------------------

section .bss

inLine		resb	50

section  .text

; -----
; Open GL routines.

extern glutInit, glutInitDisplayMode, glutInitWindowSize
extern glutInitWindowPosition
extern glutCreateWindow, glutMainLoop
extern glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern glutSwapBuffers
extern gluPerspective
extern glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern glClear, glLoadIdentity, glMatrixMode, glViewport
extern glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
extern glutPostRedisplay

; -----
;  c math library funcitons

extern	sin, cos, tan


; ******************************************************************
;  Generic function to display a string to the screen.
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
	push	rbx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; RDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rbx
	ret

; ******************************************************************
;  Function getIterations()
;	Performs error checking, converts ASCII/ternary to integer.
;	Command line format (fixed order):
;	  "-it <ternaryNumber> -rs <ternaryNumber>"

; -----
;  Arguments:
;	1) ARGC, double-word, value
;	2) ARGV, double-word, address
;	3) iterations count, double-word, address
;	4) rotate spped, double-word, address


global getIterations
getIterations:

	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r14, rdx		;	save 3rd arg
	mov r15, rcx		;	save 4th arg

	cmp rdi, 1
	je oneArgc

	cmp rdi, 5
	jne	invalidArgc

	mov rbx, rsi

	;	Check argv[1]	"-it"
	mov r13, qword[rbx+8]		;	r13 = argv[1]
	cmp dword[r13], 0x0074692d	;	check argv[1] == "-it", NULL in hex
	jne errItInput

	;	Check argv[2]	-it value min: 225, max: 65535
	mov rdi, itVal			;	1st arg to store the converted int
	mov rsi, qword[rbx+16]	;	2nd arg of the string oct number
	call readOctalNum
	
	;	If input -it value was invalid or out of range, display error
	cmp rax, TRUE
	jne	invalidIt

	cmp dword[itVal], IT_MIN
	jb	invalidItRange

	cmp dword[itVal], IT_MAX
	ja	invalidItRange

	;	Check argv[3] for "-rs"
	mov r13, qword[rbx+24]		;	r13 = argv[3]
	cmp dword[r13], 0x0073722d	;	"sr-"
	jne	errRsInput

	;	Check argv[4] for validity and rotation speed RS_MAX = 32768
	mov rdi, rsVal
	mov rsi, qword[rbx+32]
	call readOctalNum

	cmp rax, TRUE
	jne	invalidRsVal

	cmp dword[rsVal], RS_MAX
	ja	invalidRsRange


	;	All inputs are good, return true
	;	and return values by reference
	mov rax, TRUE
	
	mov ebx, dword[itVal]
	mov qword[r14], rbx

	mov ebx, dword[rsVal]
	mov qword[r15], rbx

	;	Update rSpeed from the user input
	;cvtsi2sd xmm0, rbx
	;movsd qword[rSpeed], xmm0
	
	jmp endIteration

oneArgc:
	mov rdi, errUsage
	call printString
	mov rax, FALSE
	jmp endIteration

invalidArgc:
	mov rdi, errBadCL
	call printString
	mov rax, FALSE
	jmp endIteration

errItInput:
	mov rdi, errITsp
	call printString
	mov rax, FALSE
	jmp endIteration

invalidIt:
	mov rdi, errITvalue
	call printString
	mov rax, FALSE
	jmp endIteration

invalidItRange:
	mov rdi, errITrange
	call printString
	mov rax, FALSE
	jmp endIteration

errRsInput:
	mov rdi, errRSsp
	call printString
	mov rax, FALSE
	jmp endIteration

invalidRsVal:
	mov rdi, errRSvalue
	call printString
	mov rax, FALSE
	jmp endIteration

invalidRsRange:
	mov rdi, errRSrange
	call printString
	mov rax, FALSE
	jmp endIteration

endIteration:

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	ret



; ******************************************************************
;  Function to draw chaos algorithm.

;  Chaos point calculation algorithm:
;	seed = 7 * 100th of seconds (from current time)
;	for  i := 1 to iterations do
;		s = rand(seed)
;		n = s mod 3
;		x = x + ( (init_x(n) - x) / 2 )
;		y = y + ( (init_y(n) - y) / 2 )
;		color = n
;		plot (x, y, color)
;		seed = s
;	end_for

; -----
;  Global variables (from main) accessed.

common	drawColor	1:4			; draw color
common	degree		1:4			; initial degrees
common	iterations	1:4			; iteration count
common	rotateSpeed	1:4			; rotation speed

; -----

global drawChaos
drawChaos:

; -----
;  Save registers...

	;push rbx
	push r12	

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);

	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

; -----
;  Set rotation speed step value.
;	rStep = rotationSpeed / scale

	cvtsi2sd xmm5, dword[rotateSpeed]
	divsd xmm5, qword[rScale]
	movsd qword[rStep], xmm5

; -----
;  Plot initial points.

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Calculate and plot initial points.

	;	initX = sin ( ( rSpeed + ( i * dStep ) ) pi / 180 ) * scale
	;	initY = cos ( ( rSpeed + ( i * dStep ) ) pi / 180 ) * scale

; -----
;  set and plot x[0], y[0]

	;	x[0]
	movsd xmm0, qword[rSpeed]

	;	pi / 180
	movsd xmm3, qword[pi]
	divsd xmm3, qword[oneEighty]

	;	rSpeed * (pi/180)
	mulsd xmm0, xmm3

	call sin
	movsd xmm5, xmm0
	mulsd xmm0, qword[scale]
	movsd qword[initX], xmm0

	;	y[0]
	movsd xmm0, qword[rSpeed]
	movsd xmm3, qword[pi]
	divsd xmm3, qword[oneEighty]
	mulsd xmm0, xmm3

	call cos

	mulsd xmm0, qword[scale]
	movsd qword[initY], xmm0

	;	Plot
	movsd xmm0, qword[initX]
	movsd xmm1, qword[initY]
	call glVertex2d 


; -----
;  set and plot x[1], y[1]

	;	x[1]
	movsd xmm0, qword[dStep]
	addsd xmm0, qword[rSpeed]

	movsd xmm3, qword[pi]
	divsd xmm3, qword[oneEighty]

	mulsd xmm0, xmm3

	call sin
	movsd qword[sinVal], xmm0
	mulsd xmm0, qword[scale]

	movsd qword[initX+8], xmm0

	;	y[1]
	movsd xmm0, qword[dStep]
	addsd xmm0, qword[rSpeed]

	movsd xmm3, qword[pi]
	divsd xmm3, qword[oneEighty]

	mulsd xmm0, xmm3


	call tan
	
	movsd xmm5, qword[sinVal]
	divsd xmm5, xmm0


	mulsd xmm5, qword[scale]

	movsd qword[tstVal1], xmm5

	movsd qword[initY+8], xmm5

	;	Plot
	movsd xmm0, qword[initX+8]
	movsd xmm1, qword[initY+8]
	call glVertex2d

; -----
;  set and plot x[2], y[2]

	;	x[2]

	;	rSpeed + ( i * dStep )
	movsd xmm0, qword[dStep]
	mulsd xmm0, qword[fTwo]
	addsd xmm0, qword[rSpeed]

	movsd xmm3, qword[pi]
	divsd xmm3, qword[oneEighty]

	mulsd xmm0, xmm3
	call sin
	movsd qword[sinVal], xmm0

	mulsd xmm0, qword[scale]
	movsd qword[initX+16], xmm0

	;	y[2]
	movsd xmm0, qword[dStep]
	mulsd xmm0, qword[fTwo]
	addsd xmm0, qword[rSpeed]


	movsd xmm3, qword[pi]
	divsd xmm3, qword[oneEighty]


	mulsd xmm0, xmm3
	call tan

	;	xmm5 = cos = tan / sin
	movsd xmm5, qword[sinVal]
	divsd xmm5, xmm0

	mulsd xmm5, qword[scale]
	movsd qword[initY+16], xmm5

	;	Plot
	movsd xmm0, qword[initX+16]
	movsd xmm1, qword[initY+16]
	call glVertex2d

; -----
;  Main plot loop.

	mov eax, dword[seed]		;	eax = seed = 987123
	mov dword[seed2], eax
	mov r12d, 1					; Iteration count


mainPlotLoop:

; -----
;  Generate pseudo random number, via linear congruential generator 
;	s = R(n+1) = (A × seed + B) mod 2^16
;	n = s mod 3
;  Note, A and B are constants.

	mov eax, dword[seed2]
	mov esi, A_VALUE
	mul esi
	add eax, B_VALUE
	mov ecx, 0
	mov cx, ax
	mov dword[seed2], ecx
	mov eax, ecx
	mov edx, 0
	div dword[qThree]		; edx = n = 0, 1, 2
	mov dword[randNum], edx

; -----
;  Generate next (x,y) point.
;	x = x + ( (initX[n] - x) / 2 )
;	y = y + ( (initY[n] - y) / 2 )

	;	x = x + ( (initX[n] - x) / 2 )
	;	xmm0 = initX[n]
	movsd xmm0, qword[initX+rdx*8]

	;	xmm0 = initX[n] - x
	subsd xmm0, qword[x]

	;	xmm0 = (initX[n] - x) / 2
	divsd xmm0, qword[fTwo]

	;	xmm0 = x + ( (initX[n] - x) / 2)
	addsd xmm0, qword[x]

	;	x = xmm0
	movsd qword[x], xmm0

	;	y = y + ( (initY[n] - y) / 2 )
	movsd xmm0, qword[initY+rdx*8]
	subsd xmm0, qword[y]
	divsd xmm0, qword[fTwo]
	addsd xmm0, qword[y]
	movsd qword[y], xmm0

; -----
;  Set draw color (based on n)
;	0 => read
;	1 => blue
;	2 => green

	cmp dword[randNum], 0
	je drawRed

	cmp dword[randNum], 1
	je drawBlue

	cmp dword[randNum], 2
	je drawGreen

drawRed:
	mov rdi, 255
	mov rsi, 0
	mov rdx, 0
	call glColor3ub

	mov rdi, GL_POINTS
	call glBegin

	jmp drawDone

drawBlue:
	mov rdi, 0
	mov rsi, 255
	mov rdx, 0
	call glColor3ub

	mov rdi, GL_POINTS
	call glBegin

	jmp drawDone

drawGreen:
	mov rdi, 0
	mov rsi, 0
	mov rdx, 255
	call glColor3ub

	mov rdi, GL_POINTS
	call glBegin

	jmp drawDone

drawDone:

	;	Plot x and y
	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d


	inc r12d
	cmp r12d, dword[iterations]
	jne mainPlotLoop

; -----

	call	glEnd
	call	glFlush

; -----
;  Update rotation speed.
;  Then tell OpenGL to re-draw with new rSpeed value.

	movsd xmm0, qword[rSpeed]
	addsd xmm0, qword[rStep]
	movsd qword[rSpeed], xmm0


	call	glutPostRedisplay

	pop	r12
	;pop rbx
	ret

; ******************************************************************

; -----------------------------------------------------------------------
;  Read an octal/ASCII number from the user

; -----
;  Call:
;	status = readOctalNum(&numberRead);

;  Arguments Passed:
;	1) numberRead, addr - rdi
;	2) addr of string represnting octal num, rsi

;  Returns:
;	number read (via reference)
;	status code (as above)



global readOctalNum
readOctalNum:


	push rbx
	push r12
	push r13
	push r14


	mov rbx, rdi			;	save the 1st argument
	mov r10, rsi			;	save the 2nd argument

	mov r12, inLine			;	char array addr
	mov r13, 0				;	Counter

readLp:

	mov al, byte[r10]		;	get the letter
	inc r10					;	move index

	cmp al, NULL			;	Check end of string
	je inputDone

	inc r13					;	Check for overflow
	cmp r13, BUFFSIZE
	jge readLp

	mov byte[r12], al		;	Place the letter in the char arry
	inc r12

	jmp readLp


inputDone:

	cmp r13, BUFFSIZE
	jge overflow

	mov byte[r12], NULL		;	Terminate the string

	mov r12, inLine			;	Move index to the front of the string
	mov dword[rSum], 0		;	Running sum

;--------
;	Convert to int
	mov rax, 0
	mov r14, 8
	mov cl, byte[r12]

convert:
	cmp cl, NULL
	je convertDone

	;	Check validity of character
	cmp cl, 0x30
	jb	invalidInput
	cmp cl,	0x37
	ja invalidInput

	sub cl, "0"
	movzx ecx, cl

	;	Mult by 8 and add to running sum
	mov eax, dword[rSum]
	mul r14d
	add eax, ecx
	mov dword[rSum], eax

	inc r12
	mov cl, byte[r12]
	jmp convert

convertDone:

	mov r14d, dword[rSum]
	mov qword[rbx], r14

	mov rax, TRUE
	jmp end


invalidInput:
	mov rax, FALSE
	jmp end


overflow:
	mov rax, FALSE
	jmp end


end:

	pop r14
	pop r13
	pop r12
	pop rbx
	ret


; **************************************************************************