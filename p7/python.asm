;Lauren Fowler
;CSC 322
;12-11-18
;Happy Snek Program
;This Snek does not make Lauren happy

;snek == python

;define struct
STRUC snekStruct
	.esc:  RESB 2 ;space for <esc>[
	.row:  RESB 2 ;two digit # characters
	.semi: RESB 1 ;space for ;
	.col:  RESB 2 ; two digit # characters
	.H:	   RESB 1 ;space for H
	.char: RESB	1 ;space for the character
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


section .data
;;;;;;; Screen Pattern
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

;define the snek
snek:      db "@*******> "
snekSize:  dd $-snek

screen_offset:  dd 0
snekHead:		dw 0


screen_snek: ISTRUC snekStruct
			 AT snekStruct.esc,  db 1bh,'['
			 AT snekStruct.row,  db '07'
			 AT snekStruct.semi, db ';'
			 AT snekStruct.col,  db '00'
			 AT snekStruct.H, 	 db 'H'
			 AT snekStruct.char, db ' '			
			 IEND

section .bss
reserve_snek:  RESB snekStruct.size*(snekSize - snek)

section .text 
global _main
_main:

	;put board on screen
;	mov ecx, 25
;	out_loop:
;		push ecx
;		mov ecx, 81
;		in_loop:
;			push ecx
;			print_to_screen screen, [screen_offset], 1
;			add dword [screen_offset], 1
;			pop ecx
;		loop in_loop
;		pop ecx
;	loop out_loop
	;board put on screen

	
	;calculate snek head position
;	mov ax, [snekSize] 
;	mov bx, 80
;	sub bx, ax
;	shr bx, 1 ;divides by 2
;	mov [snekHead], bx

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	;load snek
	mov ax, 80-(snekSize-snek) ;[snekHead]	  ;first column on screen
	mov ebx, reserve_snek ;pointer to reserve snek
	mov ecx, [snekSize]	  ;number of characters in string
	mov edx, snek 		  ;pointer to original snek

	loadTop:
		mov	BYTE [ebx],1bh
		mov	BYTE [ebx+1],'['
		mov	WORD [ebx+2],'07'  ;;;; ROW might need to swap these
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
		add	ebx,snekStruct.size
		inc	edx
		inc	ax
		loop loadTop

	call	_displayMessage


;Normal termination code
mov eax, 1
mov ebx, 0
int 80h


;functions
_toAscii:
	push ebx
	mov bl, 10
	div bl	;push ax/10 in al, remainder in ah
	add al, '0'
	add al, '0'
	pop ebx
	ret
		
;;;;;;;;;;;   Function to print the array of structs of message
_displayMessage:
	pusha
	mov	ebx, reserve_snek
	mov	ecx,[snekSize]

_dmTop:	push	ecx
	push	ebx
	mov	eax,4  ; system print
	mov	ecx,ebx ; points to string to print
	mov	ebx,1   ; standard out
	mov	edx,9   ; num chars to print
	int	80h

	pop	ebx
	add	ebx,snekStruct.size
	pop	ecx
	loop	_dmTop
	popa
	ret


