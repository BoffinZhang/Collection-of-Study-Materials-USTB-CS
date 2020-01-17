datasg segment
	shape			db		3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
	IO8255_MODE		equ		28BH
	IO8255_A		equ		288H
	IO8255_B		equ		289H
	IO8255_C		equ		28AH
datasg ends

mystack segment
	dw 128 dup (0)
mystack ends

code segment
	assume ds:datasg,cs:code,ss:mystack
start:
	mov	ax,datasg		; 初始化
	mov	ds,ax
	mov	ax,mystack
	mov	ss,ax
	mov	cx,0
	mov	si,0

	mov	dx,IO8255_MODE
	mov	al,80H		; 端口ABC输出
	out	dx,al

	mov	dx,IO8255_B
	mov	al,0FFH
	out	dx,al

	mov	dx,IO8255_A
	mov	al,06h
	out	dx,al

change_num_loop:
	mov	dx,IO8255_A
	mov	al,shape[si]
	out	dx,al
	inc	si			; si++

	push	ax
	mov	ax,si			; si = si%10
	mov	bx,10
	div	bl
	mov	al,ah
	mov	ah,0
	mov	si,ax
	pop	ax
	
	mov 	cx,5H
delay_1:
	call waitf
	loop delay_1
	jmp	change_num_loop

;	------- wait_loop start ------
waitf   proc near			; 延时700ms
      push cx
      push ax

	mov  cx,0FFFFH
waitf_loop:
      in   al, 61h
      and  al, 10h
      cmp  al, ah
      je   waitf_loop
      mov  ah, al
      loop waitf_loop

      pop  ax
      pop  cx
      ret
waitf   endp
;	------- wait_loop end ------

code ends
	end start