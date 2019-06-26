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

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255

pi		dq	3.14159265358979	; constant
oneEighty	dq	180.0
tmp		dq	0.0

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
qThree		dq	3
fTwo		dq	2.0

A_VALUE		equ	9421			; must be prime
B_VALUE		equ	1


; -----
;  Local variables for readOctalNum()

BUFFSIZE	equ	50
intCvt		dd	0


; ------------------------------------------------------------

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

extern	cos, sin


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
	push	rsi
	push	rdi
	push	rdx

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
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	ret

; ******************************************************************
;  Function getIterations()
;	Performs error checking, converts ASCII/ternary to integer.
;	Command line format (fixed order):
;	  "-it <ternaryNumber> -rs <ternaryNumber>"

; -----
;  Arguments:
;	1) ARGC, double-word, value                 rdi 
;	2) ARGV, double-word, address               rsi
;	3) iterations count, double-word, address   rdx
;	4) rotate spped, double-word, address       rcx


	;	Check ARGC
	;	if argc == 1, display usage and exit. Return false

global getIterations
getIterations:

	push r12
	push r13

	mov rcx, rsi		;	rcx = argv[]

	cmp rdi, 1
	je oneArgc

	;cmp rdi, 5
	;jne	invalidArgc

	;	Check argv[1]	"-it"
	mov r13, qword[rcx+8]		;	r13 = argv[1]
	cmp dword[r13], 0x0074692d	;	check argv[1] == "-it", NULL in hex
	jne errItInput

	;	Check argv[2]	-it value min: 225, max: 65535
	mov rdi, intCvt			;	1st arg to store the converted int
	mov rsi, qword[rcx+16]	;	2nd arg of the string oct number
	call readOctalNum
	
	;	If input -it value was invalid or out of range, display error
	cmp rax, TRUE
	jne	invalidIt

	cmp dword[intCvt], IT_MIN
	jb	invalidItRange

	cmp dword[intCvt], IT_MAX
	ja	invalidItRange

	;	Check argv[3] for "-rs"
	mov r13, qword[rcx+24]		;	r13 = argv[3]	
	cmp dword[r13], 0x73722d	;	"sr-"
	jne	errRsInput


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

endIteration:

	pop r13
	pop r12
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


; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);

	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

; -----
;  Set rotation speed step value.
;	rStep = rotationSpeed / scale




; -----
;  Plot initial points.

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Calculate and plot initial points.



; -----
;  set and plot x[0], y[0]



; -----
;  set and plot x[1], y[1]



; -----
;  set and plot x[2], y[2]



; -----
;  Main plot loop.

mainPlotLoop:

; -----
;  Generate pseudo random number, via linear congruential generator 
;	s = R(n+1) = (A × seed + B) mod 2^16
;	n = s mod 3
;  Note, A and B are constants.



; -----
;  Generate next (x,y) point.
;	x = x + ( (initX[n] - x) / 2 )
;	y = y + ( (initY[n] - y) / 2 )



; -----
;  Set draw color



; -----

	call	glEnd
	call	glFlush

; -----
;  Update rotation speed.
;  Then tell OpenGL to re-draw with new rSpeed value.

	call	glutPostRedisplay

	pop	r12
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

	push rbp
	mov rbp, rsp
	sub rsp, 55		;	Allocate local stack memory
	push rbx
	push r12
	push r13
	push r14


	mov rbx, rdi			;	save the 1st argument
	mov r10, rsi			;	save the 2nd argument

	lea r12, byte[rbp-50]	;	char array
	mov r13, 0				;	count
	mov dword[rbp-55], 0	;	running sum variable
	mov byte[rbp-51], 0

readLp:

	mov al, byte[r10]	;	get the input

	inc r10

	;	Only skip spaces if they are in the front
	;	when the input count is zero
	cmp r13, 0
	jne	dontSkipSpc

	;	Skip space in front
	cmp al, 0x20
	je readLp

dontSkipSpc:

	;	Null marks the end of the string
	cmp al, NULL
	je inputDone

	inc r13					;	inc counter
	cmp r13, BUFFSIZE		;	check for buffer overflow
	jge	readLp

	mov byte[r12], al
	inc r12					;	move index of lineArray

	jmp readLp

inputDone:

	cmp r13, BUFFSIZE
	jge	overflow

	mov byte[r12], NULL		;	terminate the string

	lea r12, byte[rbp-50]	;	Address of the string
	mov dword[rbp-55], 0	;	initialize running sum

;-----
	;	Convert to int
	mov rax, 0
	mov r14, 8
	mov cl, byte[r12]

convert:
	cmp cl, NULL
	je convertDone

	;	Check the validity of the character
	cmp cl, 0x30
	jb	invalidInput
	cmp cl, 0x37
	ja	invalidInput

	sub cl, "0"
	movzx ecx, cl

	;	Mult by 8 and add to running sum
	mov eax, dword[rbp-55]
	mul r14d
	add eax, ecx
	mov dword[rbp-55], eax

	inc r12
	mov cl, byte[r12]
	jmp convert

convertDone:

	mov r14d, dword[rbp-55]
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
	mov rsp, rbp
	pop rbp
	ret


; **************************************************************************