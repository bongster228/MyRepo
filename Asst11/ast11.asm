;  CS 218 - Assignment #11

; -----
;  Function - getArguments()
;	Read, parse, and check command line arguments.

;  Function - int2octal()
;	Convert an integer to a octal/ASCII string, NULL terminated.

;  Function - countDigits()
;	Check the leading digit for each number and count 
;	each 0, 1, 2, etc...
;	All file buffering handled within this procedure.

;  Function - showGraph()
;	Create graph as per required format and ouput.


; ****************************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20			; space

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation
EXIT_NOSUCCESS	equ	1			; Unsuccessful operation

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

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q

; -----
;  Variables for getArguments()

usageMsg	db	"Usage: ./benford -i <inputFileName> "
		db	"-o <outputFileName> -d <T/F>", LF, NULL

errMany		db	"Error, too many characters on the "
		db	"command line.", LF, NULL

errFew		db	"Error, too few characters on the "
		db	"command line.", LF, NULL

errDSpec	db	"Error, invalid output display specifier."
		db	LF, NULL

errISpec	db	"Error, invalid input file specifier."
		db	LF, NULL

errOSpec	db	"Error, invalid output file specifier."
		db	LF, NULL

errTF		db	"Error, invalid display option. Must be T or F."
		db	LF, NULL

errOpenIn	db	"Error, can not open input file."
		db	LF, NULL

errOpenOut	db	"Error, can not open output file."
		db	LF, NULL

rdFileDescriptor    dq  0
wrFileDescriptor    dq  0

; -----
;  Variables for countDigits()

BUFFSIZE	equ	500000

SKIP_LINES	equ	5				; skip first 5 lines
SKIP_CHARS	equ	6

nextCharIsFirst	db	TRUE
skipLineCount	dd	0				; count of lines to skip
skipCharCount	dd	0				; count of chars to skip
gotDigit	db	FALSE
fDigit      db  0
chr         db  0


bfMax		dq	BUFFSIZE
curr		dq	BUFFSIZE

wasEOF		db	FALSE

errFileRead	db	"Error reading input file."
		db	"Program terminated."
		db	LF, NULL

; -----
;  Variables for showGraph()

SCALE1		equ	100				; for < 100,000
SCALE2		equ	1000				; for >= 100,000 and < 500,000
SCALE3		equ	2500				; for >= 500,000 and < 1,000,000 
SCALE4		equ	5000				; for >= 1,000,000

scale		dd	SCALE1				; initial scaling factor
totalCnt    dq 0

weight		dd	3

errFileWrite	db	"Error writting output file."
		db	LF, NULL

graphHeader	db	LF, "CS 218 Benfords Law", LF
		db	"Test Results", LF, LF, NULL

graphLine1	db	"Total Data Points: "
tStr1		db	"                     ", LF, LF, NULL

DIGITS_SIZE	equ	15
STARS_SIZE	equ	50

graphLine2	db	"  "				; initial spaces
index2		db	"x"				; overwriten with #
		db	"  "				; spacing
num2		db	"               "		; digit count
		db	"|"				; pipe
stars2		db	"                              "
		db	"                    "
		db	LF, NULL

graphLine3	db	"                     ---------------------------------------------"
		db	LF, LF, NULL

writeDone   db  "Write Done", NULL

; -------------------------------------------------------

section	.bss

buff		resb	BUFFSIZE+1


; ****************************************************************************

section	.text

; ======================================================================
; Read, parse, and check command line paraemetrs.

; -----
;  Assignment #11 requires options for:
;	input file name
;	output file name
;	display results to screen (T/F)

;  For Example:
;	./benford -i <inputFileName> -o <outputFileName> -d <T/F>

; -----
;  Example high-level language call:
;	status = getArguments(ARGC, ARGV, rdFileDesc, wrFileDesc, displayToScreen)

; -----
;  Arguments passed:
;	argc                                        rdi
;	argv                                        rsi
;	address of file descriptor, input file      rdx
;	address of file descriptor, output file     rcx
;	address of boolean for display to screen    r8


global getArguments
getArguments:

    push rbx
    push r12
    push r13
    push r14

    mov r12, rsi        ;   argv[]
    mov r13, rdx        ;   addr of file descriptor, input file
    mov r14, rcx        ;   addr of file descriptor, output file

    ;   Display usage directions
    cmp rdi, 1
    je  usage

    ;   Too many arguments
    cmp rdi, 7
    jg  many

    ;   Too few arguments
    cmp rdi, 7
    jl  few

    ;   Check for argv[1] for "-i"
    mov rbx, qword[r12+8]
    cmp word[rbx], 0x692d 
    jne invalidInputSpecifier

    ;   Check for argv[2] if input file could be opened
    mov rax, SYS_open
    mov rdi, qword[r12+16]      ;   file name string, NULL terminated
    mov rsi, O_RDONLY           ;   read only
    syscall

    cmp rax, 0                  ;   Check if opened succesfully
    jl  errorOnInputFile

    mov qword[r13], rax         ;   If opened, save descriptor
    mov qword[rdFileDescriptor], rax

    ;   Check for argv[3] for "-o"
    mov rbx, qword[r12+24]
    cmp word[rbx], 0x6f2d
    jne invalidOutputSpecifier

    ;   Check for argv[4] if output file could be opened
    mov rax, SYS_creat          ;   Create file
    mov rdi, qword[r12+32]
    mov rsi, S_IRUSR | S_IWUSR
    syscall

    cmp rax, 0
    jl errorOnOutputFile

    mov qword[r14], rax         ;   Save the file descriptor

    mov rax, SYS_open           ;   Check if file can be opened
    mov rdi, qword[r12+32]      ;   argv[4]
    mov rsi, O_RDONLY
    syscall

    cmp rax, 0
    jl  errorOnOutputFile

    ;   Check for argv[5]
    mov rbx, qword[r12+40]
    cmp word[rbx], 0x642d
    jne invalidDisplaySpecifier

    ;   Check for argv[6]
    mov rbx, qword[r12+48]

    ;   Check if argv[6] is T
    cmp byte[rbx], 0x54
    je displayTrue
    ;   Check if argv[6] is F
    cmp byte[rbx], 0x46
    je displayFalse
    
    
    ;   Error if its neither
    jmp invalidDisplayOption


    usage:  
    mov rdi, usageMsg
    call printString
    mov rax, FALSE
    jmp argsDone

    many:
    mov rdi, errMany
    call printString
    mov rax, FALSE
    jmp argsDone

    few:
    mov rdi, errFew
    call printString
    mov rax, FALSE
    jmp argsDone

    invalidInputSpecifier:
    mov rdi, errISpec
    call printString
    mov rax, FALSE
    jmp argsDone

    errorOnInputFile:
    mov rdi, errOpenIn
    call printString
    mov rax, FALSE
    jmp argsDone

    invalidOutputSpecifier:
    mov rdi, errOSpec
    call printString
    mov rax, FALSE
    jmp argsDone

    errorOnOutputFile:
    mov rdi, errOpenOut
    call printString
    mov rax, FALSE
    jmp argsDone

    invalidDisplaySpecifier:
    mov rdi, errDSpec
    call printString
    mov rax, FALSE
    jmp argsDone

    displayTrue:
    mov qword[r8], TRUE
    mov rax, TRUE
    mov rbx, qword[rdFileDescriptor]
    mov qword[r13], rbx
    jmp argsDone

    displayFalse:
    mov qword[r8], FALSE
    mov rax, TRUE
    jmp argsDone

    invalidDisplayOption:
    mov rdi, errTF
    call printString
    mov rax, FALSE
    jmp argsDone

    argsDone:

    pop r14
    pop r13
    pop r12
    pop rbx
ret

;


; ======================================================================
;  Simple function to convert an integer to a NULL terminated
;	octal string.
;	NOTE, may change arguments as desired.

; -----
;  HLL Call
;	bool = int2octal(int, &str);

; -----
;  Arguments passed:
;	1) integer value            rdi
;	2) string, address          rsi


; -----
;  Returns
;	1) string (via passed address)
;	2) bool, TRUE if valid conversion, FALSE for error


;   int2octal(int, &str)

global int2octal
int2octal:

    push r12
    push r13

    mov r12, 8
    mov rcx, 0              ;   push counter
    mov r13, rsi            ;   string addr

    ;   Convert and push the values
    mov rax, rdi

    convertLp:
    mov rdx, 0
    div r12

    push rdx
    inc rcx

    ;   Convert done when the number is 0
    cmp rax, 0
    je cvtPushDone
    
    jmp convertLp
    
    cvtPushDone:

    ;   Pop and convert the values into octal strings
    mov rdx, 0
    popLp:

    pop r12
    dec rcx
    add r12, "0"
    mov byte[r13+rdx], r12b       ;   str[rbx]

    inc rdx

    cmp rcx, 0
    je convertDone
    jmp popLp

    convertDone:

    mov byte[r13+rdx], NULL
    mov rax, TRUE

    pop r13
    pop r12

ret
;




; ======================================================================
; Count leading digits....
;	Check the leading digit for each number and count 
;	each 0, 1, 2, etc...
;	The counts (0-9) are stored in an array.

; -----
;  High level language call:
;	countDigits (rdFileDesc, digitCounts)

; -----
;  Arguments passed:
;	value for input file descriptor             rdi
;	address for digits array                    rsi



global countDigits
countDigits:

    push r12
    push r13

    mov r12, rdi
    mov r13, rsi

    mainLp:

    mov rdi, qword[curr]
    mov rsi, qword[bfMax]
    ;   if(curr >= bfMax)
    cmp rdi, rsi
    jl endMainLp
    ;       if(wasEof) jmp to exit
    cmp byte[wasEOF], TRUE
    je exitCount

    ;   if(error) display mesg, exit
    ;   Read file, check read error
    mov rax, SYS_read
    mov rdi, r12                     ;   File descriptor
    mov rsi, buff                   ;   Place data here
    mov rdx, BUFFSIZE
    syscall

    ;   if(actual == 0) jmp exit
    ;   rax < 0 means error
    cmp rax, 0
    jl  errOnRead

    ;   rax = 0 means no characters read.
    cmp eax, 0
    je exitCount

    ;   if(actual < requested)
    cmp eax, BUFFSIZE
    jl  reachedEndOfFile

    jmp notEndOfFile

    reachedEndOfFile:
    ;       wasEof = true
    ;       bfMax = actual
    mov byte[wasEOF], TRUE
    mov dword[bfMax], eax

    notEndOfFile:

    ;    // end if()
    ;   curr = 0
    mov qword[curr], 0

    ; // end if()
    endMainLp:
    
    ;   Get chr from buffer
    ;   ch = buffer[curr]
    mov rsi, qword[curr]
    mov dl, byte[buff+rsi]
    mov byte[chr], dl


    ;   Skip 5 lines
    ;   if(lineCnt < LINEMAX)
    cmp dword[skipLineCount], SKIP_LINES
    jge  skipLineDone
    ;       if(ch == LF) lineCnt++
        cmp byte[chr], LF
        jne noLineCnt
        inc dword[skipLineCount]
        noLineCnt:

    ;       curr++
    inc qword[curr]
    ;   go to mainLp
    jmp mainLp
    ;   // end if()
    skipLineDone:

    ;   Skip 7 characters
    ;   if(chrCnt < CHRMAX)
    cmp dword[skipCharCount], SKIP_CHARS
    jg  skipCharDone

    ;       chrCnt++
    
    inc dword[skipCharCount]
    ;       curr++
    
    inc qword[curr]
    ;       jmp manLp
    
    jmp mainLp
    ;   // end if()
    skipCharDone:

    ;   Skip the white space in the front
    cmp byte[chr], 0x20
    jne skipSpace

    ;   inc curr and go to main loop
    inc qword[curr]
    jmp mainLp

    skipSpace:

    ;   if(gotDigit = False)
    cmp byte[gotDigit], TRUE
    je notFirstDigit
    
    ;   convert firstdigit to int
    mov rax, 0
    mov al, byte[chr]
    sub al, "0"
    mov byte[fDigit], al

    ;   Increase the count of the digit
    add dword[r13+rax*4], 1

    inc qword[curr]
    inc qword[totalCnt]

    ;   gotDigit = true
    mov byte[gotDigit], TRUE 
    jmp mainLp

    notFirstDigit:

    ;   if (chr == LF)
    cmp byte[chr], LF
    jne notNewLine
    ;   set skipCharCount = 0
    mov dword[skipCharCount], 0

    ;   gotDigit = False
    mov byte[gotDigit], FALSE

    inc qword[curr]
    jmp mainLp

    notNewLine:

    ;   Ignore all other digits
    inc qword[curr]
    jmp mainLp

    errOnRead:

    mov rdi, errFileRead
    call printString
    jmp exitCount    

    exitCount:

    mov rdi, qword[totalCnt]
    mov rsi, num2
    call int2octal

    pop r13
    pop r12


ret


; ======================================================================
;  Create graph as per required format.
;	write graph to file
;	if requested, also show graph to output screen

;  High-level language call:
;	showGraph (wrFileDesc, digitCounts, displayToScreen)

; -----
;  Arguments passed:
;	file descriptor, output file - value        rdi
;	address for digits array - address          rsi
;	display to screen option, T or F - value    rdx



global showGraph
showGraph:


    push r12
    push r13
    push r14

    mov r12, rdi            ;   file descriptor
    mov r13, rsi            ;   addr of digits array
    mov r14, rdx            ;   display to screen option

    mov rdi, r12
    mov rsi, graphHeader
    call writeString



    pop r14
    pop r13
    pop r12
ret


; ======================================================================
;  Generic function to write a string to an already opened file.
;  Similar to printString(), but must handle possible file write error.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters to file

;  Arguments:
;	file descriptor, value              rdi
;	address, string                     rsi
;  Returns:
;	nothing


;   writeString()

global writeString
writeString:

    push r12
    push r13
    push r14

    mov r12, rdi        ;   file descriptor
    mov r13, rsi        ;   addr of string

    ;   Count the characters in the string
    mov r14, 0          ;   char counter
       

    countChar:
    ;   rsi is addr of the passsed in string
    cmp byte[rsi], NULL
    je  charCountDone
    inc r14
    inc rsi
    jmp countChar
    charCountDone:


    mov rax, SYS_write
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    syscall

    cmp rax, 0
    jl  errorOnWrite

    jmp endWrite

    errorOnWrite:

    mov rdi, errFileWrite
    call printString
    jmp endWrite

    endWrite:

    pop r14
    pop r13
    pop r12
ret
;



; ======================================================================
;  Generic function to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.

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
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************

