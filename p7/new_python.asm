; NAME:  Lauren Fowler
; Assignment: Happy Python
; Date: Fall 2018

; Define Structure for character on screen
STRUC mStruct
	.esc	RESB 2  ; space for <esc>[
	.row:	RESB 2  ; two digit number (characters)
	.semi	RESB 1  ; space for ;
	.col:	RESB 2  ; two digit number (characters)
	.H	RESB 1  ; space for the H
	.char:	RESB 1  ; space for THE character
	.size:
ENDSTRUC

;define macro
%macro print_to_screen 3
	;pusha
	mov eax, 4
	mov ebx, 1
	mov ecx, %1 ;start of screen
	add ecx, %2
	mov edx, %3
	int 80h
	;popa
%endmacro

SECTION .data
; Create an array of structs: formatted like the print interrupt uses.
theMessage:	db "@********> "
msgSize:	dd $-theMessage
msgLoc:		dw 0


byebye:		ISTRUC mStruct
		AT mStruct.esc,  db 1bh,'['
		AT mStruct.row,  db '20'
		AT mStruct.semi, db ';'
		AT mStruct.col,  db '00'
		AT mStruct.H,    db 'H'
		AT mStruct.char, db ' '
		IEND


;screen Pattern
screen: db      "********************************************************************************",0ah
        db      "*                          *                           *                       *",0ah
        db      "*      *************       *        *************      *       *********       *",0ah
        db      "*                          *                           *                       *",0ah
        db      "*                          *                           *                       *",0ah
        db      "*                          *                           *                       *",0ah
        db      "*                                                                              *",0ah
        db      "*           **************************        ***********************          *",0ah
        db      "*                                *               *                             *",0ah
        db      "*                                *     ***********                             *",0ah
        db      "*                          *     *               *     *                       *",0ah
        db      "*                          *     **********      *     *                       *",0ah
        db      "*                          *     *               *     *                       *",0ah
        db      "*                          *     *      **********     *                       *",0ah
        db      "*                          *                           *                       *",0ah
        db      "*                                                                              *",0ah
        db      "*           ***   ***   ***   ***   ***   ***   ***   ***   ***   ***          *",0ah
        db      "*                                                                              *",0ah
        db      "*            *     *     *     *     *     *     *     *     *     *           *",0ah
        db      "*               *     *     *     *     *     *     *     *     *              *",0ah
        db      "*            *     *     *     *     *  W  *     *     *     *     *           *",0ah
        db      "*               *     *     *     *     *     *     *     *     *              *",0ah
        db      "*            *     *     *     *     *     *     *     *     *     *           *",0ah
        db      "*               *     *     *     *     *     *     *     *     *              *",0ah
        db      "********************************************************************************",0ah

screenSize:     dd $-screen
screen_offset:  dd 0


SECTION .bss
message:	RESB mStruct.size*(msgSize-theMessage)

SECTION .text
global _main
_main:

	;put board on screen
	mov ecx, 25
	out_loop:
		push ecx
		mov ecx, 81
		in_loop:
			push ecx
			print_to_screen screen, [screen_offset], 1
			add dword [screen_offset], 1
			pop ecx
		loop in_loop
		pop ecx
	loop out_loop
	;board put on screen

; Move cursor to bottom of page
	mov	eax,4
	mov	ebx,1
	mov	ecx,byebye
	mov	edx,9
	int	80h

	mov word ax, 80	
	mov bx, [msgSize]
	sub ax, bx
	shr ax, 1
	mov [msgLoc], ax	

;;;;;;;;; LOAD message from theMessage
	mov	ax,[msgLoc]  ;;;; Column on screen for first char when right justified
	mov	ebx,message		  ;;;; pointer in message array of structs
	mov	ecx,[msgSize]		  ;;;; loop count of characters in string
	mov	edx,theMessage		  ;;;; pointer into the original message
loadTop:
	mov	BYTE [ebx],1bh
	mov	BYTE [ebx+1],'['
	mov	WORD [ebx+2],"05"  ;;;; ROW might need to swap these
	mov	BYTE [ebx+4],';'
	push	eax		   ;;;; Save this for next loop
	call	_toAscii	   ;;;  Pass in int in ax, returns two ascii digits in ax
	mov	WORD [ebx+5],ax
	pop	eax		   ;;;; Restore the screen col number
	mov	BYTE [ebx+7],'H'
	push	ecx
	mov	cl,[edx]	   ;;;; Get next char from string
	mov	[ebx+8],cl
	pop	ecx
	add	ebx,mStruct.size
	inc	edx
	inc	ax
	loop loadTop

; Demonstrate function calls which uses an array of structs
	mov	ecx,80-(msgSize-theMessage)
 	call	_displayMessage


; Normal termination code
mov eax, 1
mov ebx, 0
int 80h
;;;;;;;;;;;;;;;;;;;;; END OF MAIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;  Function to convert int to two digits of ascii
;;;;;;;;;;;;  Pass in int in ax, return two chars in ax
_toAscii:
	push	ebx

        mov     bl,10
        div     bl      ;; puts ax/10 in al, remainder in ah
        add     ah,'0'
        add     al,'0'

	pop	ebx
	ret

;;;;;;;;;;;   Function to print the array of structs of message
_displayMessage:
	pusha
	mov	ebx,message
	mov	ecx,[msgSize]

_dmTop:	push	ecx
	push	ebx
	mov	eax,4  ; system print
	mov	ecx,ebx ; points to string to print
	mov	ebx,1   ; standard out
	mov	edx,9   ; num chars to print
	int	80h

	pop	ebx
	add	ebx,mStruct.size
	pop	ecx
	loop	_dmTop
	popa
	ret


;;;;;;;;;;;;;  Function to sleep short period of time ;;;;;;;;;;;
_pause: 
	pusha
	mov	eax,162
	mov	ebx,seconds
	mov	ecx,0
	int	80h
	popa
	ret

;;;;;;;;;;;;	Tricky use of ram.... put some data here for _pause to use
seconds: dd	0,25000000  ;;;  seconds, nanoseconds


