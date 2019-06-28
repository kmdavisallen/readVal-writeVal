TITLE Low level I/O procedures    

; Author: Kevin Allen
; Program 6A
; Due 03/18/2018
; Description: Takes 10 user entered numebrs, validates them, then displays their sum and average

INCLUDE Irvine32.inc

displayString	MACRO outputStr
	push	edx
	mov		edx, outputStr
	call	WriteString
	pop		edx
ENDM

getString	MACRO input, size
	push	edx
	push	ecx
	mov		edx, input
	mov		ecx, size
	call	ReadString
	pop		ecx
	pop		edx
ENDM

.data
intro_1		BYTE	"--Program Intro--",0
intro_2		BYTE	"**EC DESCRIPTION: This program implements the readVal and writeVal procedures recursively",0
intro_3		BYTE	"Welcome to Program 6A: designing low level I/O procedures", 0
intro_4		BYTE	"Written by Kevin Allen",0
instruct_1	BYTE	"Please enter 10 unsigned integers that are small enough to fit in 32 bits",0
instruct_2	BYTE	"I will calculate and display their sum and average",0
prompt_1	BYTE	"Please enter an unsigned integer: ",0
error		BYTE	"You did not enter a valid integer or an integer that was too large",0
contents	BYTE	"You entered the following numbers : ",0
space		BYTE	" ",0
total		BYTE	"The sum of the integers is : ",0
average		BYTE	"The avarage of the array is : ",0

userArray	DWORD	10 DUP(?)
arraySize	DWORD	10
tempArray	BYTE	31 DUP(?)
tempNum		DWORD	0
sum			DWORD	0


.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Displays introduction
;Recieves: address of intro 1, 2, 3 and 4
;Returns: none
;Preconditions: none
; Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
introduction PROC
	push	ebp
	mov		ebp, esp
	displayString [ebp+8]
	call	CrLf
	displayString [ebp + 12]
	call	CrLf
	displayString [ebp +16]
	call	CrLf
	displayString [ebp + 20]
	call	Crlf
	pop		ebp
	ret 16
introduction ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Displays instructions
;Recieves: address of instruct 1 and instruct 2
;Returns: none
;Preconditions: none
; Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instruction PROC
	push	ebp
	mov		ebp, esp
	displayString [ebp+8]
	call	CrLf
	displayString [ebp + 12]
	call	CrLf
	pop		ebp
	ret 8
instruction ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Fills an array with a user entered nubers
;Recieves: Address of array, temp array, temp number, and strings 
;Returns: Array is populated with user numbers
;Preconditions: none
;Registers changed:none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fillArray PROC
	pushad	
	mov		ebp, esp
	mov		edi, [ebp + 56]		;userArray
	mov		ecx, 10
	mov		ebx, [ebp +36]		;tempNum
	mov		eax, 225	
	mov		[ebx], eax			;dummy value to check against in readVal
	
L_fill:					
		
	push	[ebp + 52]		;error
	push	[ebp + 48]		;prompt message
	push	[ebp + 44]		;legnth of temp array
	push	[ebp + 40]		;tempArray		
	push	[ebp + 36]		;temp number
	call	readVal
	mov		eax, [ebx]
	cmp		eax, 'E'
	je		badNumber
	cld
	stosd
	jmp		next
badNumber:
	inc	ecx
next:
	mov		eax, 225
	mov		[ebx], eax
	loop	L_fill
	popad
	ret 24
fillArray ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Converts string to numeric
;Recieves: Address of string and address of temp variable
;Returns: numeric value in temp variable
;Preconditions: temp variable initialized to 225
;Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readVal PROC
	pushad	
	
	mov		ebp, esp
	mov		edx, [ebp + 44]			;length of temparray
	mov		esi, [ebp + 40]			;tempArray
	mov		ecx, [ebp + 36]			;tempNum
	mov		ebx, 0					;store intermediate values in ebx
	mov		eax, [ecx]				;check to see if number has started conversion
	cmp		eax, 225
	jne		parseNum
	clc
	displayString [ebp + 48]
	getString [ebp + 40], [ebp + 44]
	mov		eax, 0
	mov		[ecx], eax
	
parseNum:
	
	cld
	lodsb					;load a byte to process
	cmp		al, 0			;if 0, at end of string
	je		done
	cmp		al, 48			;lower limit of digits
	jb		invalid
	cmp		al, 57			; upper limit of digits
	ja		invalid
	sub		al, 48			;subtract 48 to get numberic value
	mov		bl, al			;temp storage	
	mov		eax, [ecx]		;current value of temp number
	mov		edx, 10			
	mul		edx				;multiply by ten to get decimal place
	
	add		eax, ebx		;add current number to temp number
	jc		invalid			;check carry flag for edge cases
	cmp		edx,0			;check for overflow into edx
	jg		invalid			;check if number is too large to fit in 32 bits
	mov		[ecx], eax		;mov temp number back to memory
	mov		eax ,0			;empty register to recieve next number

	push	[ebp + 52]
	push	[ebp + 48]
	push	edx
	push	esi
	push	ecx
	call	readVal
	jmp		done
invalid:
	mov		eax,0
	displayString [ebp + 52]	;display error message
	call	CrLf
	mov		eax, 'E'			;return character to test against when exiting procedure
	mov		[ecx], eax
	
done:
	popad	
	ret		20
readVal ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Converts numeric to string
;Recieves: Address of string and address of variable
;Returns: none
;Preconditions: valid numeric string
;Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writeVal PROC
	pushad	
	mov		ebp, esp
	mov		eax, 0
	mov		edi, [ebp + 36]		;address of temp array to hold converted numbers
	mov		eax, [ebp +40]		;load a number, 

	mov		edx, 0				;clear register to hold  byte value
	mov		ebx, 10				
	div		ebx					;divide number by ten to break number into individual digits
	add		dl, 48				;add 48 to get ascII character
	mov		ecx, eax			;store remaining number in temp register
	mov		eax, edx				;move the character to be loaded from al
	mov		[edi], eax
	mov		eax, ecx			;restore remaining number in eax
	cmp		eax, 0				;when eax is empty number is finished converting
	je		done
	push	eax
	push	[ebp +36]
	call	writeVal
	
done:
	mov		[edi], edx		;move most recent value into address of edi
	displayString edi
	popad	
	ret		8
writeVal ENDP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Sums the contents of an array and displays
;Recieves: Address of array and address of variable to store the sum
;		address of strings to be displayed
;Returns: numeric value in a variable
;Preconditions: none
;Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sumArray PROC
	pushad
	mov		ebp, esp
	displayString [ebp + 44]
	mov		esi, [ebp + 36]
	mov		ebx, [ebp + 40]
	mov		ecx, 10
	mov		eax, 0
	sumLoop:
	lodsd
	add		[ebx], eax
	loop	sumLoop
	push	[ebx]
	push	[ebp + 48]
	call	writeVal
	call	CrLf
	popad
	ret		16
sumArray ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Averages the contents of an array
;Recieves: Address of array and address of variable to store the sum
;Returns: none
;Preconditions: none
;Registers changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
averageArray PROC
	pushad
	mov		ebp, esp
	displayString [ebp + 44]
	mov		edi, [ebp + 48]		;tempArray for writeVal
	mov		eax, [ebp + 40]		;total of array
	mov		ebx, [ebp + 36]		;number of elements
	mov		edx,0				;empty edx for division
	div		ebx
	push	eax
	push	edi
	call	writeVal
	call	CrLf
	popad
	ret		16
averageArray ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Description: Displays the contents of the userArray
;Recieves: Address of array, temp array and address of string to display
;Returns: none
;Preconditions: User numbers has been validated to be within range
;Registers changed:none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayArray PROC
	pushad	
	mov		ebp, esp
	mov		esi, [ebp + 40]
	mov		ecx, 10
nextNum:					
	lodsd	
	push	eax
	push	[ebp + 36]
	call	writeVal
	displayString [ebp + 48]
	loop	nextNum
	call	CrLf
	popad
	ret 16
displayArray ENDP


main PROC
;display introduction
	push	OFFSET intro_4
	push	OFFSET intro_3
	push	OFFSET intro_2
	push	OFFSET intro_1
	call	introduction
	call	CrLf

;display instructions
	push	OFFSET instruct_2
	push	OFFSET instruct_1
	call	instruction
	call	CrLf

;loop to fill array
	push	OFFSET userArray
	push	OFFSET error
	push	OFFSET prompt_1
	push	OFFSET (LENGTHOF tempArray)-1
	push	OFFSET tempArray
	push	OFFSET tempNum
	call	fillArray

;loop to display contents	
	push	OFFSET space
	push	OFFSET contents
	push	OFFSET userArray
	push	OFFSET tempArray
	call	displayArray


;calculate and display the sum
	push	OFFSET tempArray
	push	OFFSET total
	push	OFFSET sum
	push	OFFSET userArray
	call	sumArray

;calculate and display the average
	push	OFFSET tempArray
	push	OFFSET average	
	push	sum
	push	LENGTHOF userArray
	call	averageArray

	exit
main ENDP

END main





; Calculate sum
	mov		eax, userNumA
	mov		ebx, userNumB
	add		eax, ebx
	mov		sum, eax
; Calculate difference
	mov		eax, userNumA
	mov		ebx, userNumB
	sub		eax, ebx
	mov		difference, eax
; Calculate product
	mov		eax, userNumA
	mov		ebx, userNumB
	mul		ebx
	mov		product, eax
; Calculate quotient
	mov		eax, userNumA
	mov		ebx, userNumB
	idiv	ebx
	mov		quotient, eax
	mov		remainder, edx
; Report sum results
	mov		eax, userNumA
	call	WriteDec
	mov		edx, OFFSET result_1
	call	WriteString
	mov		eax, userNumB
	call	WriteDec
	mov		edx, OFFSET result_6
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf
; Report difference results
	mov		eax, userNumA
	call	WriteDec
	mov		edx, OFFSET result_2
	call	WriteString
	mov		eax, userNumB
	call	WriteDec
	mov		edx, OFFSET result_6
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf
; Report product results
	mov		eax, userNumA
	call	WriteDec
	mov		edx, OFFSET result_3
	call	WriteString
	mov		eax, userNumB
	call	WriteDec
	mov		edx, OFFSET result_6
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf
; Report quotient and remainder results
	mov		eax, userNumA
	call	WriteDec
	mov		edx, OFFSET result_4
	call	WriteString
	mov		eax, userNumB
	call	WriteDec
	mov		edx, OFFSET result_6
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET result_5
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf
; say goodbye
	mov		edx, OFFSET goodBye
	call	WriteString
	call	Crlf
	exit	; exit to operating system
