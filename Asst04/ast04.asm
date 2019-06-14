section	.data

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

SYS_exit	equ	60			; call code for terminate

; -----

lst		dd	 1246,  1116,  1542,  1240,  1677
		dd	 1635,  2426,  1820,  1246, -2333
		dd	 2317, -1115,  2726,  2140,  2565
		dd	 2871,  1614,  2418,  2513,  1422
		dd	-2119,  1215, -1525, -1712,  1441
		dd	-3622,  -731, -1729,  1615,  1724
		dd	 1217, -1224,  1580,  1147,  2324
		dd	 1425,  1816,  1262, -2718,  2192
  		dd	-1432,  1235,  2764, -1615,  1310
		dd	 1765,  1954,  -967,  1515,  3556
		dd	 1342,  7321,  1556,  2727,  1227
		dd	-1927,  1382,  1465,  3955,  1435
		dd	-1225, -2419, -2534, -1345,  2467
		dd	 1315,  1961,  1335,  2856,  2553
  		dd	-1032,  1835,  1464,  1915, -1810
		dd	 1465,  1554, -1267,  1615,  1656
		dd	 2192, -1825,  1925,  2312,  1725
		dd	-2517,  1498, -1677,  1475,  2034
		dd	 1223,  1883, -1173,  1350,  1415
		dd	  335,  1125,  1118,  1713,  3025
len		dd	100

lstMin		dd	0
lstMid		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

posCnt		dd	0
posSum		dd	0
posAve		dd	0

threeCnt	dd	0
threeSum	dd	0
threeAve	dd	0


section .text
global _start
_start:

; Find the total Sum
mov dword[lstSum], 0 ; Initialize the variable used to store the sum
mov r8, lst ; Has the starting point of the array
mov rcx, 0
mov ecx, dword[len] ; Store the length of the array
mov rsi, 0 ; Used to store value that will be added to the total sum

lp:
mov esi, dword[r8] ; Store the current value from the array
add dword[lstSum], esi ; Add the current value to the total sum

add r8, 4 ; Move the index by 4 bytes(double word)
dec ecx ; Decrement the count
cmp ecx, 0 ; Compare value at ecx with zero
jne lp ; If the value at ecx is not zero, jump to lp

; Find the min value
mov r8, 0
mov r8, lst ; Used as index to iterate throug the array
mov dword[lstMin], 0
mov rcx, 0
mov ecx, dword[len] ; Used to decrement down for the iteration
mov rsi, 0 ; Used to temporarily store the values from the array
mov esi, dword[r8] ; Put the first value in the array into the esi register

add r8, 4 ; Add 4 bytes to move the index

lp2:
mov esi, dword[r8] ; Put the value inside esi register
cmp dword[lstMin], esi
jl minDone
mov dword[lstMin], esi
minDone:
add r8, 4
dec ecx
cmp ecx, 0
jne lp2

last:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall