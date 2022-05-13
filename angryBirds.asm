[org 0x100] 

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
title: 
	call printTitle
	mov ah, 0 			; service 0 – get keystroke 
	int 0x16 			; call BIOS keyboard service 
 	cmp al, 13			; is the Esc key pressed 
 	jne title 			; if no, check for next key 
	jmp start
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printTitle:
	push es
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax 			; point es to video base
	xor di, di 			; point di to top left column
	mov ax, 0x0720 			; space char in normal attribute
	mov cx, 2080 			; number of screen locations
	cld 				; auto increment mode
	rep stosw 			; clear the whole screen

	call bigB
	pop di
	pop cx
	pop ax
	pop es
	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bigB:
	
	PushA

	mov ax, 0xb800
	mov es, ax
	mov cx, 2000
	mov ax, 0x0020
	mov di, 0
	cld
	rep stosw
	
	;big square
	push word 0x4F20	;color attribute
	push word 20		;height
	push word 40		;width
	push word 5		;top margin
	push word 20		;left margin
	call printRectangle

	push word 0x4020	;color attribute
	push word 1		;height
	push word 8		;width
	push word 4		;top margin
	push word 36		;left margin
	call printRectangle

	push word 0x4020	;color attribute
	push word 1		;height
	push word 8		;width
	push word 3		;top margin
	push word 38		;left margin
	call printRectangle

	push word 0x4020	;color attribute
	push word 1		;height
	push word 8		;width
	push word 2		;top margin
	push word 40		;left margin
	call printRectangle
	
	;eyebrows
	push word 0x0020	;color attribute
	push word 1		;height
	push word 14		;width
	push word 9		;top margin
	push word 25		;left margin
	call printRectangle

	push word 0x0020	;color attribute
	push word 1		;height
	push word 14		;width
	push word 9		;top margin
	push word 40		;left margin
	call printRectangle

	;eyes
	push word 0xFF20	;color attribute
	push word 4		;height
	push word 12		;width
	push word 10		;top margin
	push word 27		;left margin
	call printRectangle

	push word 0xFF20	;color attribute
	push word 4		;height
	push word 12		;width
	push word 10		;top margin
	push word 40		;left margin
	call printRectangle

	;eyeballs
	push word 0x0020	;color attribute
	push word 4		;height
	push word 9		;width
	push word 10		;top margin
	push word 29		;left margin
	call printRectangle

	push word 0x0020	;color attribute
	push word 4		;height
	push word 9		;width
	push word 10		;top margin
	push word 41		;left margin
	call printRectangle
	
	push word 0x77B3	;color attribute
	push word 1		;height
	push word 2		;width
	push word 10		;top margin
	push word 31		;left margin
	call printRectangle

	push word 0x7720	;color attribute
	push word 1		;height
	push word 2		;width
	push word 10		;top margin
	push word 43		;left margin
	call printRectangle

	;Body print
	push word 0x7720	;color attribute
	push word 4		;height
	push word 20		;width
	push word 19		;top margin
	push word 30		;left margin
	call printRectangle

	push word 0x7720	;color attribute
	push word 3		;height
	push word 30		;width
	push word 20		;top margin
	push word 25		;left margin
	call printRectangle

	push word 0x7720	;color attribute
	push word 2		;height
	push word 35		;width
	push word 21		;top margin
	push word 22		;left margin
	call printRectangle

	push word 0x7720	;color attribute
	push word 4		;height
	push word 40		;width
	push word 22		;top margin
	push word 20		;left margin
	call printRectangle

	;Peak
	push word 0xEE20	;color attribute
	push word 2		;height
	push word 12		;width
	push word 16		;top margin
	push word 34		;left margin
	call printRectangle

	push word 0xEE20	;color attribute
	push word 2		;height
	push word 10		;width
	push word 18		;top margin
	push word 35		;left margin
	call printRectangle

	;Teeth
	push word 0x7720	;color attribute
	push word 1		;height
	push word 8		;width
	push word 18		;top margin
	push word 36		;left margin
	call printRectangle

	PopA

	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
copyMap:

	push bp
	mov bp, sp
	push es
	push di
	push si
	push ax
	push cx
	
	mov ax, 0xb800
	mov es, ax
	mov di, 0
	mov si, MapRow1
	mov cx, 2000

	copNext:
		
		mov ax, [es:di]
		mov [si], ax
		add di, 2
		add si, 2
		dec cx
		cmp cx, 0
		jne copNext

	pop cx
	pop ax
	pop si
	pop di
	pop es
	pop bp
	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
clrscr:
	push es
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax 			; point es to video base
	xor di, di 			; point di to top left column
	mov ax, 0x3020 			; space char in sky blue attribute
	mov cx, 2000 			; number of screen locations
	cld 				; auto increment mode
	rep stosw 			; clear the whole screen
	call printCloud
	call printMountains
	call printTrees
	call printGrass
	call printBricks
	call printEnemies
	call printLauncher
	push word [totalScore]
	call printScore
	push word [totalTries]
	call printTries

	pop di
	pop cx
	pop ax
	pop es
	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sleep:

	push cx
	mov cx, 0x0fff
	slow:
		dec cx
		cmp cx, 0
		jne slow
	pop cx
	ret


;zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzPrinting Sectionzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
timer: 
	push ax 
	push bx
	push dx
	push es

	mov bx, 18
	mov dx, 0

 	inc word [cs:tickcount]			; increment tick count 
	mov ax, [cs:tickcount]
	div bx
	cmp dx, 0
	jne skip
	sub [cs:seconds], word 1
	cmp [cs:seconds], word 0xffff
	jne skip
	mov [cs:seconds], word 30
	sub [totalTries], word 1
	mov ax, 0xb800
	mov es, ax
	mov [es:144], word 0x3020
	push word [totalTries]
	call printTries

	skip:
		push word [cs:seconds]
 		call printime 

 	mov al, 0x20 
 	out 0x20, al 				; end of interrupt 

	pop es
	pop dx
	pop bx
 	pop ax 
 	iret 					; return from interrupt
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printime: 
	push bp 
 	mov bp, sp 
 	push es 
	push ax 
	push bx 
 	push cx 
 	push dx 
 	push di 
 	mov ax, 0xb800 
 	mov es, ax 				; point es to video base 
	mov [es:76], word 0x3020
	mov [es:78], word 0x3020

 	mov ax, [bp+4] 				; load number in ax 
 	mov bx, 10 				; use base 10 for division 
 	mov cx, 0 				; initialize count of digits 
	nextdigit1: 
		mov dx, 0 			; zero upper half of dividend 
 		div bx 				; divide by 10 
 		add dl, 0x30 			; convert digit into ascii value 
 		push dx 			; save ascii value on stack 
 		inc cx 				; increment count of values 
 		cmp ax, 0 			; is the quotient zero 
 		jnz nextdigit1 			; if no divide it again 
 		mov di, 76 			; point di to 70th column 
		nextpos: 
			pop dx 			; remove a digit from the stack 
 			mov dh, 0x30 		; use normal attribute 
 			mov [es:di], dx 	; print char on screen 
 			add di, 2 		; move to next screen location 
 			loop nextpos 		; repeat for all digits on stack 
 	pop di 
 	pop dx 
 	pop cx 
 	pop bx 
 	pop ax 
	pop es 
 	pop bp 
 	ret 2 


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printBird:

	push bp
	mov bp, sp
	push di
	push ax
	push es
	push si
	
	mov si, birdArea			;birdArea in si
	mov ax, 0xb800
	mov es, ax
	mov di, [bp + 4]			;location of bird
	sub di, 160

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Bird Top ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov [si], di
	mov word [es:di], 0x4F20
	add di, 2
	add si, 2

	mov [si], di
	mov word [es:di], 0xCFFE	
	add di, 2
	add si, 2

	mov [si], di
	mov word [es:di], 0xCFFE
	add di, 2
	add si, 2

	mov [si], di
	mov word [es:di], 0x4F20
	mov di, [bp + 4]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Bird Bottom ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov [si], di
	mov word [es:di], 0x4FDC
	add di, 2
	add si, 2

	mov [si], di
	mov word [es:di], 0x7EDF
	add di, 2
	add si, 2

	mov [si], di
	mov word [es:di], 0x7EDF
	add di, 2
	add si, 2

	mov [si], di
	mov word [es:di], 0x4FDC
	
	pop si
	pop es
	pop ax
	pop di
	pop bp
	ret 2
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printstr: 

	push bp 
 	mov bp, sp 
 	push es 
 	push ax 
 	push cx 
 	push si 
 	push di 
 	push ds 
 	pop es 			; load ds in es 
 	mov di, [bp+4] 		; point di to string 
 	mov cx, 0xffff 		; load maximum number in cx 
 	xor al, al 		; load a zero in al 
 	repne scasb 		; find zero in the string 
 	mov ax, 0xffff 		; load maximum number in ax 
 	sub ax, cx 		; find change in cx 
 	dec ax 			; exclude null from length 
 	jz exit 		; no printing if string is empty
 	mov cx, ax 		; load string length in cx 
 	mov ax, 0xb800 
 	mov es, ax 		; point es to video base 
 	mov al, 80 		; load al with columns per row 
 	mul byte [bp+8] 	; multiply with y position 
 	add ax, [bp+10] 	; add x position 
 	shl ax, 1 		; turn into byte offset 
 	mov di,ax 		; point di to required location 
 	mov si, [bp+4] 		; point si to string 
 	mov ah, [bp+6] 		; load attribute in ah 
 	cld 			; auto increment mode 
	nextchar: 
		lodsb 		; load next char in al 
 		stosw 		; print char/attribute pair 
 		loop nextchar 	; repeat for the whole string 
	exit: 
		pop di 
 		pop si 
 		pop cx 
 		pop ax 
 		pop es 
 		pop bp 
 		ret 8
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printTries:
	push bp
	mov bp, sp
	push ax
	push cx
	push bx
	push di
	push dx
	push es

	push word 60 		; push x position  
 	push word 0 		; push y position  
 	push word 0x30 		; push attribute 
 	push trieslabel 	; push address of message 
 	call printstr

	mov ax, 0
	mov di, 0
	mov bx, 10
	mov cx, 0
	mov ax, 0xb800				;storing vm address in ax
	mov es, ax				;pointing es to vm start
	mov ax, [bp + 4]			;integer in ax
	add di, 142

	nextdigit:
		mov dx, 0
		div bx
		push dx				;separated digit pushed in stack
		add cx, 1			;count for digit
		cmp ax, 0			;if quotient is zero than end the loop
		jne nextdigit

	outputdigit:
		pop ax
		add ax, 48
		mov ah, 30h
		mov [es:di], ax
		add di, 2
		sub cx, 1
		cmp cx, 0
		jne outputdigit

	pop es
	pop dx
	pop di
	pop bx
	pop cx
	pop ax
	pop bp
	ret 2

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printScore:

	push bp					;saving the value of bp
	mov bp, sp
	push ax					;saving the value of ax
	push cx					;saving the value of cx
	push bx					;saving the value of bx
	push di					;saving the value of di
	push dx
	push es

	push word 0 				; push x position  
 	push word 0 				; push y position  
 	push word 0x30 				; push attribute 
 	push scorelabel 			; push address of message 
 	call printstr


	mov ax, 0
	mov di, 0
	mov bx, 10
	mov cx, 0
	mov ax, 0xb800				;storing vm address in ax
	mov es, ax				;pointing es to vm start
	mov ax, [bp + 4]			;integer in ax
	add di, 12

	nextdig:
		mov dx, 0
		div bx
		push dx				;separated digit pushed in stack
		add cx, 1			;count for digit
		cmp ax, 0			;if quotient is zero than end the loop
		jne nextdig
	output:
		pop ax
		add ax, 48
		mov ah, 30h
		mov [es:di], ax
		add di, 2
		sub cx, 1
		cmp cx, 0
		jne output
	
	pop es
	pop dx
	pop di					;restoring the value of di
	pop bx					;restoring the value of bx
	pop cx					;restoring the value of cx
	pop ax					;restoring the value of ax
	pop bp					;restoring the value of bp			
	ret 2

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printCloud:
	
	;cloud1
	push word 0x7FB2	 		;color attribute
	push word 1				;height
	push word 6				;width
	push word 2 				;top margin
	push word 11				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 8				;width
	push word 3 				;top margin
	push word 10				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 10				;width
	push word 4 				;top margin
	push word 9				;left margin
	call printRectangle

	;cloud2
	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 6				;width
	push word 5 				;top margin
	push word 78				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 8				;width
	push word 6 				;top margin
	push word 77				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 10				;width
	push word 7 				;top margin
	push word 76				;left margin
	call printRectangle

	;cloud3
	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 6				;width
	push word 6 				;top margin
	push word 34				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 8				;width
	push word 7 				;top margin
	push word 33				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 10				;width
	push word 8 				;top margin
	push word 32				;left margin
	call printRectangle

	;cloud4
	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 6				;width
	push word 3 				;top margin
	push word 59				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 8				;width
	push word 4 				;top margin
	push word 58				;left margin
	call printRectangle

	push word 0x7FB2			;color attribute
	push word 1				;height
	push word 10				;width
	push word 5 				;top margin
	push word 57				;left margin
	call printRectangle

	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printGrass:


	push word 0x20B1			;color
	push word 4				;height
	push word 80				;width
	push word 22				;top margin
	push word 0				;left margin
	call printRectangle
	push bx
	mov bx, 1
	L3:
		push word 0x60B2		;color attribute
		push word 2			;height of triangle
		push 23				;top margin
		push bx				;left margin
		call printTriangle
		add bx, 3
		cmp bx, 82
		jne L3	

	pop bx
	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printRectangle:

	push bp
	mov bp, sp
	sub sp, 4
	push ax
	push bx
	push cx
	push dx
	
	mov ax, 0xb800
	mov es, ax

	mov ax, [bp + 6]			;top in ax
	mov bx, 160
	mul bx
	mov [bp - 2], ax			;top in [bp - 2]
	
	mov ax, [bp + 4]			;left in ax
	shl ax, 1
	mov [bp - 4], ax			;left in [bp - 4]

	mov di, word [bp - 2]	
	add di, word [bp - 4]
	mov ax, [bp + 12]

	L2:					;this loop prints a line of rectangle's width size
		mov cx, [bp + 8]		;width in cx
		rep stosw			;printing ax on screen cx times
		mov cx, [bp + 8]
		shl cx, 1
		add di, 160
		sub di, cx
		shr cx, 1
		sub [bp + 10], word 1
		mov dx, [bp + 10]
		cmp dx, 0
		jne L2
	
	pop dx
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret 10
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printTriangle:

	push bp
	mov bp, sp
	sub sp, 4
	push ax
	push bx
	push cx
	push dx
	
	mov ax, 0xb800
	mov es, ax

	mov ax, [bp + 6]			;top in ax
	mov bx, 160
	mul bx
	mov [bp - 2], ax			;top in [bp - 2]
	
	mov ax, [bp + 4]			;left in ax
	shl ax, 1
	mov [bp - 4], ax			;left in [bp - 4]

	mov di, word [bp - 2]	
	add di, word [bp - 4]			;top of triangle
	mov ax, [bp + 10]			;attribute
	mov bx, 1
	mov cx, 1

	L1:
		rep stosw
		add di, 160
		shl bx, 1
		sub di, bx
		sub di, 2
		shr bx, 1
		add bx, 2
		mov cx, bx
		sub [bp + 8], word 1
		mov dx, [bp + 8]
		cmp dx, 0
		jne L1
		
	pop dx
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret 8
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printTriangularTree:

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov dx, 0
	mov ax, [bp + 8]			;height of tree in ax
	mov bx, 2
	div bx
	mov cx, ax
	shl ax, 1
	add ax, 1
	mov bx, ax
	sub bx, 1				;difference of margins

	push word 0x20B1			;color attribute
	push ax					;height of triangle
	push word [bp + 4] 			;top margin
	push word [bp + 6] 			;left margin
	call printTriangle

	add [bp + 4], bx
	add ax, 1
	push word 0x20B1			;color attribute
	push ax					;height of triangle
	push word [bp + 4] 			;top margin
	push word [bp + 6] 			;left margin
	call printTriangle

	add [bp + 4], ax
	push word 0x6020			;color
	push cx					;height
	push word 1				;width
	push word [bp + 4]			;top margin
	push word [bp + 6]			;left margin
	call printRectangle

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret 6
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printEnemy:

	push bp
	mov bp, sp
	push di
	push ax
	push es
	push si
	
	mov si, [bp + 6]			;enemyArea in si
	mov ax, 0xb800
	mov es, ax
	mov di, [bp + 4]			;location of enemy
	sub di, 160

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemy Top ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov [si], di
	mov word [es:di], 0x2020
	add di, 2

	mov [si + 2], di
	mov word [es:di], 0xAFFE	
	add di, 2

	mov [si + 4], di
	mov word [es:di], 0xAFFE
	add di, 2

	mov [si + 6], di
	mov word [es:di], 0x2020
	mov di, [bp + 4]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemy Bottom ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov [si + 8], di
	mov word [es:di], 0x2020
	add di, 2

	mov [si + 10], di
	mov word [es:di], 0x20DF
	add di, 2

	mov [si + 12], di
	mov word [es:di], 0x20DF
	add di, 2

	mov [si + 14], di
	mov word [es:di], 0x2020
	
	pop si
	pop es
	pop ax
	pop di
	pop bp
	ret 4
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printEnemies:

	Enemy00:

		cmp [enemys + 0], word 1
		jne Enemy01

		push enemy0Locs
		push 1728
		call printEnemy

	Enemy01:

		cmp [enemys + 2], word 1
		jne Enemy02

		push enemy1Locs
		push 2368
		call printEnemy


	Enemy02:

		cmp [enemys + 4], word 1
		jne Enemy03

		push enemy2Locs
		push 3488
		call printEnemy

	Enemy03:

		ret	
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
printTrees:

	push word 3	;treeHeight
	push word 15	;left margin
	push word 15	;top margin
	call printTriangularTree

	push word 4	;treeHeight
	push word 30	;left margin
	push word 10	;top margin
	call printTriangularTree

	push word 2	;treeHeight
	push word 45	;left margin
	push word 15	;top margin
	call printTriangularTree

	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printBrick:

	push bp
	mov bp, sp
	sub sp, 2
	push ax
	push bx
	push cx
	push si
	push di
	push es
	
	mov si, [bp + 4]			;brick in si
	mov bx, [si + 2]			;height in bx
	mov ax, 0xb800
	mov es, ax
	
	mov cx, [si + 4]			;width in cx
	mov [bp - 2], cx
	mov di, [si + 6] 			;location in di
	mov ax, [si]				;attribute in ax
	
	mov si, [bp + 6]			;brick locations array in si

	nextRow:				;this loop prints a line of rectangle's width size
		mov cx, [bp - 2]		;width in cx

		nextCol:
			mov [si], di
			add si, 2
			mov [es:di], ax
			add di, 2
			dec cx
			cmp cx, 0
			jne nextCol

		mov cx, [bp - 2]
		shl cx, 1
		add di, 160
		sub di, cx
		shr cx, 1
		sub bx, 1
		cmp bx, 0
		jne nextRow

	pop es
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret 4
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
printBricks: 

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

	mov si, struct
	mov bx, 0


	Brick00:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick01

		push brick0Locs
		push brick0
		call printBrick

	Brick01:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick02

		push brick1Locs
		push brick1
		call printBrick

	Brick02:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick03

		push brick2Locs
		push brick2
		call printBrick

	Brick03:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick04

		push brick3Locs
		push brick3
		call printBrick

	Brick04:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick05

		push brick4Locs
		push brick4
		call printBrick	  

	Brick05:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick06

		push brick5Locs
		push brick5
		call printBrick

	Brick06:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick07

		push brick6Locs
		push brick6
		call printBrick

	Brick07:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick08

		push brick7Locs
		push brick7
		call printBrick	  

	Brick08:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick09

		push brick8Locs
		push brick8
		call printBrick

	Brick09:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick10

		push brick9Locs
		push brick9
		call printBrick

	Brick10:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick11

		push brick10Locs	
		push brick10
		call printBrick  

	Brick11:
		mov ax, [si + bx]
		add bx, 2
		cmp ax, 1
		jne Brick12

		push brick11Locs	
		push brick11
		call printBrick

	Brick12:
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printLauncher:
	
	push word 0x6020	;color
	push word 2		;height
	push word 2		;width
	push word 20		;top margin
	push word 5		;left margin
	call printRectangle

	push word 0x6020	;color
	push word 1		;height
	push word 1		;width
	push word 19		;top margin
	push word 4		;left margin
	call printRectangle

	push word 0x60DF	;color
	push word 1		;height
	push word 1		;width
	push word 18		;top margin
	push word 3		;left margin
	call printRectangle

	push word 0x6020	;color
	push word 1		;height
	push word 1		;width
	push word 19		;top margin
	push word 7		;left margin
	call printRectangle

	push word 0x60DF	;color
	push word 1		;height
	push word 1		;width
	push word 18		;top margin
	push word 8		;left margin
	call printRectangle

	ret
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printMountains:
	
	push word 0x7020	;color attribute
	push word 4		;height of triangle
	push word 18 		;top margin
	push word 3 		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 6		;height of triangle
	push word 16	 	;top margin
	push word 12		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 5		;height of triangle
	push word 17	 	;top margin
	push word 20		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 4		;height of triangle
	push word 18	 	;top margin
	push word 28		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 6		;height of triangle
	push word 16	 	;top margin
	push word 35		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 5		;height of triangle
	push word 17	 	;top margin
	push word 44		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 8		;height of triangle
	push word 14	 	;top margin
	push word 54		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 5		;height of triangle
	push word 17	 	;top margin
	push word 65		;left margin
	call printTriangle

	push word 0x7020	;color attribute
	push word 6		;height of triangle
	push word 16	 	;top margin
	push word 75		;left margin
	call printTriangle
	ret 
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
printPath:

	push bp
	mov bp, sp
	push ax
	push es
	push cx
	push di
	push si
	push bx
	push dx

	mov bx, 2
	mov dx, 0

	mov ax, 0xb800
	mov es, ax
	mov ax, [bp + 4]	;length in cx
	div bx

	mov cx, ax
	mov si, [bp + 6]	;path in si

	cmp si, 0
	je endPrintPath
	mov ax, [si]
	add di, ax
	add si, 2
	sub cx, 1	
	nextStep:
		mov ax, [si]
		add di, ax
		mov [es:di], byte '*'
		add si, 2
		dec cx
		jne nextStep

	endPrintPath:

		pop dx
		pop bx
		pop si
		pop di
		pop cx
		pop es
		pop ax
		pop bp
		ret 4

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
selectPath:

	push bp
	mov bp, sp
	push ax
	push dx

	mov ax, 0
	mov dx, 0
	
	push ax
	push dx
	call givePath
	pop ax			;desired path
	pop dx			;length of desired path

	push 10
	push ax
	push dx
	call float

	pop dx
	pop ax
	pop bp
	ret


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
givePath:

	push bp
	mov bp, sp
	push ax
	push dx

	mov ax, 0
	mov dx, 0

	path0:

		cmp cx, 0
		jne path2

		cmp bx, 4
		jne P03

		mov ax, path04
		mov dx, [length04]

		jmp path2

		P03:
			cmp bx, 3
			jne P02

			mov ax, path03
			mov dx, [length03]

			jmp path2

		P02:
			cmp bx, 2
			jne P01

			mov ax, path02
			mov dx, [length02]

			jmp path2

		P01:
			cmp bx, 1
			jne P00

			mov ax, path01
			mov dx, [length01]

			jmp path2

		P00:
			cmp bx, 0
			jne path2

			mov ax, path00
			mov dx, [length00]

			jmp path2

	path2:

		cmp cx, 2
		jne path4

		cmp bx, 4
		jne P13

		mov ax, path14
		mov dx, [length14]

		jmp path4

		P13:
			cmp bx, 3
			jne P12

			mov ax, path13
			mov dx, [length13]

			jmp path4

		P12:
			cmp bx, 2
			jne P11

			mov ax, path12
			mov dx, [length12]

			jmp path4

		P11:
			cmp bx, 1
			jne P10

			mov ax, path11
			mov dx, [length11]

			jmp path4

		P10:
			cmp bx, 0
			jne path4

			mov ax, path10
			mov dx, [length10]

	path4:

		mov [bp + 4], ax
		mov [bp + 6], dx

		pop dx
		pop ax
		pop bp
		ret
;zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz



;zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzFlying Sectionzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
popEnemy:

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	push si
	
	call restore
	mov ax, [bp + 4]			;index of colision
	mov si, enemy0Locs
	mov dx, 0

	nextEnemy:

		mov cx, 8
		mov bx, 0

		nextEnemyPixel:
			cmp ax, [si + bx]
			je enemyFound
			add bx, 2
			loop nextEnemyPixel

		add si, 16 
		add dx, 2
		cmp dx, 6
		jne nextEnemy
		jmp enemyNotFound

	enemyFound:
		
		mov si, enemys
		mov bx, dx
		mov [si + bx], word 0
		add [totalScore], word 10
		call clrscr
		call copyMap

	enemyNotFound:

		pop si
		pop di	
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

popBrick:

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	push si
	
	call restore
	mov ax, [bp + 4]			;index of colision
	mov bx, 0
	mov si, brick0Locs
	mov dx, 0

	nextBrick:

		mov bx, dx
		mov cx, [brickSizes + bx]
		mov bx, 0

		nextBrickPixel:
			cmp ax, [si + bx]
			je brickFound
			add bx, 2
			loop nextBrickPixel
		
		mov bx, dx
		mov cx, [brickSizes + bx]
		shl cx, 1
		add si, cx			;moving to next brick locations array
		add dx, 2
		cmp dx, [totalBricks]
		jne nextBrick
		jmp brickNotFound

	brickFound:
		
		mov si, struct
		mov bx, dx
		mov [si + bx], word 0
		add [totalScore], word 10
		call clrscr
		call copyMap

	brickNotFound:

		pop si
		pop di	
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 2

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
check:

	push bp
	mov bp, sp
	sub sp, 8
	push ax
	push bx
	push cx
	push dx
	push di
	push es
	push si

	mov si, MapRow1
	add si, di
	mov bx, di
	mov cx, 4
	birdTop:
		mov ax, [si]
		nextColor0:

			cmp ax, 0x0720
			jne nextColor1
			push bx
			call popBrick
			jmp found
		
		nextColor1:
			cmp ax, 0x60B8
			jne nextColor2
			push bx
			call popBrick
			jmp found

		nextColor2:
			cmp ax, 0x60B1
			jne nextColor3
			push bx
			call popBrick
			jmp found

		nextColor3:
			cmp ax, 0x2020
			jne nextColor4
			push bx
			call popEnemy
			jmp found

		nextColor4:
			add si, 2
			add bx, 2
			loop birdTop
	
	sub si, 168
	sub bx, 168
	mov cx, 4	
	birdBottom:
		mov ax, [si]
		nextColor5:

			cmp ax, 0x0720
			jne nextColor6
			push bx
			call popBrick
			jmp found

		nextColor6:
			cmp ax, 0x60B8
			jne nextColor7
			push bx
			call popBrick
			jmp found

		nextColor7:
			cmp ax, 0x60B1
			jne nextColor8
			push bx
			call popBrick
			jmp found
		
		nextColor8:
			cmp ax, 0x2020
			jne nextColor9
			push bx
			call popEnemy
			jmp found

		nextColor9:
			add si, 2
			add bx, 2
			loop birdBottom
	
	jmp notFound
	found:

		mov [bp + 4], word 1

	notFound:

	pop si
	pop es
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret
	
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float:

	push bp
	mov bp, sp
	sub sp, 2
	push ax
	push bx
	push cx
	push dx 
	push si

	mov ax, 0xb800
	mov es, ax
	mov si, [bp + 6]
	mov cx, [bp + 4]
	mov bx, 0		

	Lo1:
		mov dx, [bp + 8]		;speed in dx
		call restore
		add di, [si + bx]
		push di
		call printBird
		push 0
		call check
		pop ax
		cmp ax, 1
		je endFloat

		speed:
			call sleep
			dec dx
			cmp dx, 0
			jne speed

		add bx, 2
		dec cx
		cmp cx, 0
		jne Lo1

	endFloat:
		call restore
		mov di, 2728				;initial position of the bird
		push di
		call printBird

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	mov sp, bp
	pop bp
	mov cx, 4
	mov bx, 4
	ret 6

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
restore:

	push bp
	mov bp, sp
	push ax
	push bx
	push es
	push si
	push di
	push cx

	mov ax, 0xb800
	mov es, ax

	mov si, MapRow1
	add si, di
	mov cx, 4

	restoreLoop1:

			mov ax, [si]
			mov [es:di], ax
			add di, 2
			add si, 2
			dec cx
			cmp cx, 0
			jne restoreLoop1
			
	sub di, 8
	sub di, 160
	mov si, MapRow1
	add si, di
	mov cx, 4

	restoreLoop2:

			mov ax, [si]
			mov [es:di], ax
			add di, 2
			add si, 2
			dec cx
			cmp cx, 0
			jne restoreLoop2

	pop cx
	pop di
	pop si
	pop es
	pop bx
	pop ax
	pop bp
	ret
;zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz



;zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzLaunching Sectionzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
kbisr: 
	push ax 
 	push es 
	push dx

	push ax
	push dx
	call givePath
	pop ax
	pop dx

	push ax
	push dx
	call printPath
	

 	mov ax, 0xb800 
 	mov es, ax 				; point es to video memory 
	
 	in al, 0x60 				; read a char from keyboard port 
 	cmp al, 0x4B 				; is the key left arrow
 	jne nextcmp1 				; no, try next comparison
	cmp cx, 0
	je nomatch
	sub cx, 2
	call clrscr 				; clear previous location
	sub di, 4 
	push di
	call printBird

 	jmp nomatch 				; leave interrupt routine 	 

	nextcmp1:
		cmp al, 0x48
		jne nextcmp2
		cmp bx, 4
		je nomatch
		add bx, 1 
		call clrscr 			; clear previous location
		sub di, 160
		push di
		call printBird			

	nextcmp2:
		cmp al, 0x50
		jne nextcmp3
		cmp bx, 0
		je nomatch
		cmp cx, 4
		je nomatch
		sub bx, 1
		call clrscr 			; clear previous location 
		add di, 160
		push di
		call printBird

	nextcmp3:
		cmp al, 0x4D  ;0x1C
		jne nomatch
		cmp cx, 4
		je nomatch
		sub [totalTries], word 1	;one try has been made
		call selectPath
		mov [seconds], word 30
		cmp [totalTries], word 0
		je endGame
		
		
	nomatch: 	
		pop dx
 		pop es 
 		pop ax 
 		jmp far [cs:oldisr] 		; call the original ISR 
;zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

start: 
	call clrscr				;clear the whole screen
	call copyMap				;it will copy the whole map in data segment

	mov cx, 4				;max launch width
	mov bx, 4				;max launch height
	mov ax, 0xb800 
 	mov es, ax
	mov [es:di], byte 'o'
	mov di, 2728				;initial position of the bird
	push di
	call printBird				;printing bird at initial position		

	xor ax, ax 
 	mov es, ax 				; point es to IVT base 
 	mov ax, [es:9*4] 
 	mov [oldisr], ax 			; save offset of old routine 
 	mov ax, [es:9*4+2] 
 	mov [oldisr+2], ax 			; save segment of old routine 
 	cli 					; disable interrupts 
 	mov word [es:9*4], kbisr 		; store offset at n*4 
 	mov [es:9*4+2], cs 			; store segment at n*4+2 
	mov word [es:8*4], timer ; store offset at n*4 
 	mov [es:8*4+2], cs ; store segment at n*4+ 
 	sti 

	l1: 
		mov ah, 0 			; service 0 – get keystroke 
 		int 0x16 			; call BIOS keyboard service 
 		cmp al, 27 			; is the Esc key pressed 
 		jne l1 				; if no, check for next key 
			
	endGame:

		
 	mov ax, 0x4c00 				; terminate program 
 	int 0x21 


;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

youwon:dw 'You Won', 0
struct: dw 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0	;1's mean brick should be printed 0's mean bricks should not be printed
enemys: dw 1, 1, 1
totalEnemies: dw 3
enemy0Locs: dw 0, 0, 0, 0, 0, 0, 0, 0
enemy1Locs: dw 0, 0, 0, 0, 0, 0, 0, 0
enemy2Locs: dw 0, 0, 0, 0, 0, 0, 0, 0

totalBricks: dw 24
brickSizes: dw 6, 6, 10, 4, 4, 12, 6, 6, 18, 6, 6, 6

brick0Locs: dw 0, 0, 0, 0, 0 ,0
brick1Locs: dw 0, 0, 0, 0, 0 ,0
brick2Locs: dw 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0
brick3Locs: dw 0, 0, 0, 0
brick4Locs: dw 0, 0, 0, 0
brick5Locs: dw 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0
brick6Locs: dw 0, 0, 0, 0, 0 ,0
brick7Locs: dw 0, 0, 0, 0, 0 ,0
brick8Locs: dw 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
brick9Locs: dw 0, 0, 0, 0, 0 ,0
brick10Locs: dw 0, 0, 0, 0, 0 ,0
brick11Locs: dw 0, 0, 0, 0, 0 ,0

brick0: dw 60B1h, 3, 2, 3160 			;color, height, width, position
brick1: dw 60B1h, 3, 2, 3180 			;color, height, width, position
brick2: dw 60B8h, 1, 10, 3002 			;color, height, width, position
brick3: dw 0720h, 2, 2, 2686 			;color, height, width, position
brick4: dw 0720h, 2, 2, 2694 			;color, height, width, position
brick5: dw 60B8h, 1, 12, 2520 			;color, height, width, position
brick6: dw 60B1h, 3, 2, 2040 			;color, height, width, position
brick7: dw 60B1h, 3, 2, 2060 			;color, height, width, position
brick8: dw 60B8h, 1, 18, 1874 			;color, height, width, position
brick9: dw 60B1h, 3, 2, 1400 			;color, height, width, position
brick10: dw 60B1h, 3, 2, 1420 			;color, height, width, position
brick11: dw 60B1h, 3, 2, 940 			;color, height, width, position

;------------------------------------------------------------------------------------------------------------------------------------------
tickcount: dw 0 
seconds: dw 30
totalTries: dw 10
totalScore: dw 0
scorelabel: db 'score: ', 0
trieslabel: db 'tries left: ', 0

birdArea: dw 0, 0, 0, 0, 0, 0, 0, 0
MapRow1: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow2: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow3: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow4: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow5: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

MapRow6: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow7: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow8: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow9: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow10: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

MapRow11: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow12: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow13: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow14: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow15: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

MapRow16: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow17: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow18: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow19: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow20: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

MapRow21: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow22: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow23: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow24: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
MapRow25: dw 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

oldisr: dd 0 ; space for saving old isr 
path04: dw 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
path03: dw -156, -156, -156, -156, -156, -156, -156, -156, -154, -154, -154, -154, -150, 6, 6, 6, 6, 6, 6, 170, 166, 166, 166, 166, 164, 164, 164, 164
path02: dw -158, -158, -158, -158, -158, -316, -156, -156, -152, -150, -150, 6, 6, 6, 6, 6, 6, 170, 170, 168, 164, 164, 162, 162, 162, 162, 162, 162, 162, 162, 162
path01: dw -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -316, -156, -156, -152, -150, -150, 6, 6, 6, 6, 170, 170, 168, 164, 164, 324, 162, 162, 162, 162, 162, 162, 162, 162, 162, 162
path00: dw -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -316, -156, -156, -152, -150, -150, 6, 6, 6, 6, 6, 6, 6, 6, 170, 170, 168, 164, 164

path14: dw 4, 4, 4, 4, 4, 4, 162 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 162, 4, 4, 4, 4, 4, 4, 4, 4, 4, 162, 4, 4, 4, 4, 4, 4, 4, 4
path13: dw -156, -156, -156, -156, -156, -154, -154, -154, -154, -150, 6, 6, 6, 170, 166, 166, 166, 166, 164, 164, 164, 164, 164, 164, 164, 164
path12: dw -158, -158, -158, -158, -158, -316, -156, -156, -152, -150, -150, 6, 6, 6, 170, 170, 168, 164, 164, 162, 162, 162, 162, 162, 162, 162, 162, 162
path11: dw -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -316, -156, -156, -152, -150, -150, 6, 170, 170, 168, 164, 164, 324, 162, 162, 162, 162, 162, 162, 162, 162, 162, 162, 162
path10: dw -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -158, -316, -156, -156, -152, -150, -150, 6, 6, 170, 170, 168, 164, 164, 324, 162, 162, 162, 162, 162, 162, 162, 162, 162, 162, 162, 162

length04: dw 38
length03: dw 28
length02: dw 31
length01: dw 36
length00: dw 31

length14: dw 39
length13: dw 26
length12: dw 28
length11: dw 34
length10: dw 38