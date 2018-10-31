;Lauren Fowler
;Matrix Multiplication
;CSC322
;Program 4

;define EQU
X  EQU  4 ;Rows for Mat1 and Mat3
Y  EQU  3 ;Cols for Mat1 and Rows for Mat2
Z  EQU  2 ;Cols for Mat2 and Mat3

X1:  EQU  3
Y1:  EQU  3;
Z1:  EQU  3

SECTION .data
M1  dd  1, 2, 2
    dd  3, 2, 1
    dd  1, 2, 3
    dd  2, 2, 2

M2  dd  2, 4
    dd  3, 3
    dd  4, 6

M11:  dd  1, 2, 3
	  dd  4, 5, 6
	  dd  7, 8, 9

M22:  dd  10, 11, 12
	  dd  13, 14, 15
	  dd  16, 17, 18

;General Variables
m1_store:  dd  0  ;Store M1 multiplication var
m2_store:  dd  0  ;Store M2 multiplication var

sum:    dd  0  ;Store sum of row*column
M1_loc: dd  0  ;Store M1 location
M2_loc: dd  0  ;Store M2 location
M3_loc: dd  0  ;Store M3 location

M1_next:  dd  0  ;Store next M1_loc
M2_next:  dd  0  ;Store next M2_loc

M1row_incr:  dd  0 ;bits to add to move to next row
M2col_incr:  dd  0 ;bits to add to get to next col slot

tmp_store1:  dd  0
tmp_store2:  dd  0

SECTION .bss
M3  RESD  X*Z
M33 RESD  X1*Z1

SECTION .text
global _main
_main:

	;calculate incr values here
	
	;row incr:
	mov ecx, Y
	loop1:
		add [M1row_incr], dword 4
	loop loop1

	;m2 col incr:
	mov ecx, Z
	loop2:
		add [M2col_incr], dword 4
	loop loop2
	
incr:

	;loop M1 Rows
	mov ecx, X ;number of rows
	M1loop_out:

		;mov m1 loc to the next row
		mov eax, [M1_next]
		mov [M1_loc], eax
		mov eax, 0

		push ecx										;PUSH ONE
		
		;loop M2 Num of Cols
		mov ecx, Z
		M2loop_col:
	
			;reset sum var
			mov [sum], dword 0

			;set up m2_loc to move at beginning of M2loop_col loop
			mov eax, [M2_next] 
			mov [M2_loc], eax ;moves to next column in M2
			mov eax, 0	;reset eax register
		
			push ecx									;PUSH TWO
			
			;Loop M1 Cols/ M2 rows
			mov ecx, Y1
			mov eax, [M1_loc]
			mov ebx, [M2_loc]

			Mloop_12:

				mov [tmp_store1], eax
				mov [tmp_store2], ebx	

				mov eax, [M1 + eax]
				mov ebx, [M2 + ebx]

				;these will hold two parameters for nested for loop to multiply
				mov [m1_store], eax
				mov [m2_store], ebx

				push ecx								;PUSH THREE
				
				;perform the multiplication
				mov ecx, [m1_store]
				mult_out:
					push ecx								;PUSH FOUR
					mov ecx, [m2_store]
					mult_in:
						inc dword [sum]
					loop mult_in
					pop ecx								;POP FOUR
				loop mult_out				

				;move stored values back into eax and ebx
				mov eax, [tmp_store1]
				mov ebx, [tmp_store2]	
				
				;this is where I increment m1 and m2 values to move
				add eax, 4 ;add 4 to move to next column in row
				add ebx, [M2col_incr] ;add m2col_incr to move to next row in col
				
				pop ecx									;POP THREE

			loop Mloop_12
			;reset eax and ebx
			mov eax, 0
			mov ebx, 0	
			
			;store sum in M3 and reset sum
			mov eax, [sum]
			mov ebx, [M3_loc]
			mov [M3 + ebx], eax
			add [M3_loc], dword 4

			;return to M2 cols loop
			pop ecx										;POP TWO
			add [M2_next], dword 4  ;gets next column
			dec ecx
		jnz M2loop_col

		;return to M1 rows loop
		pop ecx											;POP ONE
		
		;move to start of next row
		mov eax, [M1row_incr]
		add [M1_next], eax
		mov eax, 0

		;move back to start of m1 cols
		mov [M2_next], dword 0

		dec ecx
	jnz M1loop_out
				
done:




mov eax, 1
mov ebx, 0
int 80h






