; 测试中断服务程序
; 用来测试时钟信号是否正常
; 280H-287H: 0000 0010 1000 0000
; 288H-28FH: 0000 0010 1000 1000
; 290H-297H: 0000 0010 1001 0000
; 298H-29FH: 0000 0010 1001 1000
; 2A0H-2A7H: 0000 0010 1010 0000
; 2A8H-2AFH: 0000 0010 1010 1000
; 2B0H-2B7H: 0000 0010 1011 0000
; 2B8H-2BFH: 0000 00a10 1011 1000

IO8255_MODE  EQU  286H      
IO8255_A     EQU  280H
IO8255_B     EQU  282H
IO8255_C     EQU  284H

IO8254_MODE  EQU  2A6H
IO8254_0     EQU  2A0H
IO8254_1     EQU  2A2H
IO8254_2     EQU  2A4H

I8259_1      EQU   2B4H       ; 8259的ICW1端口地址
I8259_2      EQU   2B3H       ; 8259的ICW2端口地址
I8259_3      EQU   2B6H       ; 8259的ICW3端口地址
I8259_4      EQU   2B5H       ; 8259的ICW4端口地址
O8259_1      EQU   2B1H       ; 8259的OCW1端口地址
O8259_2      EQU   2B0H       ; 8259的OCW2端口地址
O8259_3      EQU   2B2H       ; 8259的OCW3端口地址


; 每个点由8个字节表示
ROW         EQU    IO8255_B
COL         EQU    IO8255_A

DATA SEGMENT 'DATA'
    buffer  DB  00000000B
            DB  00000000B
            DB  00000000B
            DB  00000000B
            DB  00000000B
            DB  00000000B
            DB  00000000B
            DB  00000000B
	    
    glider  DB  00000000B
            DB  00100000B
            DB  00010000B
            DB  01110000B
            DB  00000000B
            DB  00000000B
            DB  00000000B
            DB  00000000B

   exploder DB  00000000B
            DB  00000000B
            DB  00001000B
            DB  00011100B
            DB  00010100B
            DB  00001000B
            DB  00000000B
            DB  00000000B

    temp    DB  00000000B
            DB  00000000B
	        DB  00000000B
            DB  00001100B
            DB  00011110B
            DB  00001100B
            DB  00000000B
            DB  00000000B

DATA ENDS

MYSTACK SEGMENT 'STACK'
	dw	128 dup (0)
MYSTACK ENDS

CODE SEGMENT 'CODE'
   ASSUME CS:CODE, DS:DATA, SS:MYSTACK
START:
        MOV AX, DATA
        MOV DS, AX
        
        ; 初始化8259
        MOV DX, I8259_1         ;初始化8259的ICW1
        MOV AL, 00010011b       ;边沿触发、单片8259、需要ICW4
        OUT DX,AL

        MOV DX,I8259_2          ;初始化8259的ICW2
        MOV AL,0B0H            
        OUT DX,AL
        MOV AL,03H
        OUT DX,AL
        MOV DX, O8259_1         ;初始化8259的中断屏蔽操作命令字OCW1
        MOV AL, 00H             ;打开屏蔽位
        OUT DX,AL

        ; 初始化8255: A、B输出
        MOV DX, IO8255_MODE     
        MOV AL, 80H       
        OUT DX, AL

        MOV DX,ROW
        MOV AL,03H
        OUT DX,AL

        MOV DX,COL
        MOV AL,0F1H
        OUT DX,AL

        ; 初始化8254工作模式
        MOV DX, IO8254_MODE
        MOV AL, 00010000B       ; 计数器0，方式3
        OUT DX, AL
        MOV DX, IO8254_0
        MOV AL, 05H
        OUT DX, AL
        MOV DX, IO8254_0
        MOV AL, 03H
        OUT DX, AL
        ; 加载初始图案
	    call load_pattern
QUERY:  

	    MOV CX,008FH
DIS_LOOP:
        CALL DISP
        CALL DELAY
        LOOP DIS_LOOP
        
        MOV DX, O8259_3        ;向8259发送查询命令(填空）
        MOV AL, 0CH		       ;设置查询方式（填空）
        OUT DX,AL
        IN AL,DX               ;读出查询字
        TEST AL,80H            ;判断中断是否已响应
        JZ QUERY               ;没有响应则继续查询

       call generator
EOI:  
        MOV DX,O8259_2          ; 向8259发送中断结束命令（填空）
        MOV AL,20H		        ; 普通的EOI命令（填空）
        OUT DX,AL		        ; 填空
        JMP QUERY

ENDLESS:
        JMP ENDLESS

	
	
load_pattern proc
        push ax
        push cx
        push si
        mov si,0
        mov cx,8
load_l1: 
        ; mov al,byte ptr glider[si]    ; 复制temp到buffer\
	mov al, byte ptr exploder[si]    ; 复制temp到buffer
        mov byte ptr buffer[si],al

        inc si
        loop load_l1
        pop si
        pop cx
        pop ax
        ret
load_pattern endp

generator   proc              ; 刷新画面，更新buffer
    mov si,0
    mov di,0
    call judge
    mov si,0
    mov di,1
    call judge
    mov si,0
    mov di,2
    call judge
    mov si,0
    mov di,3
    call judge
    mov si,0
    mov di,4
    call judge
    mov si,0
    mov di,5
    call judge
    mov si,0
    mov di,6
    call judge
    mov si,0
    mov di,7
    call judge
    mov si,1
    mov di,0
    call judge
    mov si,1
    mov di,1
    call judge
    mov si,1
    mov di,2
    call judge
    mov si,1
    mov di,3
    call judge
    mov si,1
    mov di,4
    call judge
    mov si,1
    mov di,5
    call judge
    mov si,1
    mov di,6
    call judge
    mov si,1
    mov di,7
    call judge
    mov si,2
    mov di,0
    call judge
    mov si,2
    mov di,1
    call judge
    mov si,2
    mov di,2
    call judge
    mov si,2
    mov di,3
    call judge
    mov si,2
    mov di,4
    call judge
    mov si,2
    mov di,5
    call judge
    mov si,2
    mov di,6
    call judge
    mov si,2
    mov di,7
    call judge
    mov si,3
    mov di,0
    call judge
    mov si,3
    mov di,1
    call judge
    mov si,3
    mov di,2
    call judge
    mov si,3
    mov di,3
    call judge
    mov si,3
    mov di,4
    call judge
    mov si,3
    mov di,5
    call judge
    mov si,3
    mov di,6
    call judge
    mov si,3
    mov di,7
    call judge
    mov si,4
    mov di,0
    call judge
    mov si,4
    mov di,1
    call judge
    mov si,4
    mov di,2
    call judge
    mov si,4
    mov di,3
    call judge
    mov si,4
    mov di,4
    call judge
    mov si,4
    mov di,5
    call judge
    mov si,4
    mov di,6
    call judge
    mov si,4
    mov di,7
    call judge
    mov si,5
    mov di,0
    call judge
    mov si,5
    mov di,1
    call judge
    mov si,5
    mov di,2
    call judge
    mov si,5
    mov di,3
    call judge
    mov si,5
    mov di,4
    call judge
    mov si,5
    mov di,5
    call judge
    mov si,5
    mov di,6
    call judge
    mov si,5
    mov di,7
    call judge
    mov si,6
    mov di,0
    call judge
    mov si,6
    mov di,1
    call judge
    mov si,6
    mov di,2
    call judge
    mov si,6
    mov di,3
    call judge
    mov si,6
    mov di,4
    call judge
    mov si,6
    mov di,5
    call judge
    mov si,6
    mov di,6
    call judge
    mov si,6
    mov di,7
    call judge
    mov si,7
    mov di,0
    call judge
    mov si,7
    mov di,1
    call judge
    mov si,7
    mov di,2
    call judge
    mov si,7
    mov di,3
    call judge
    mov si,7
    mov di,4
    call judge
    mov si,7
    mov di,5
    call judge
    mov si,7
    mov di,6
    call judge
    mov si,7
    mov di,7
    call judge
    call copy_to_buffer
generator   endp

; DIPS实现Buffer的点阵输出
; 在仿真时，R=1,W=0，对应的点才会亮
DISP    PROC   
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        MOV CX,8
        MOV BL,1
        MOV SI,0
DISP_L1:

        MOV DX,ROW
	MOV AL,BL
        OUT DX,AL
	

        MOV DX,COL
	MOV AL,[si]
	NOT AL
        OUT DX,AL
        SHL BL,1
        INC SI
	CALL DELAY
        LOOP DISP_L1
      
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
	RET
DISP    ENDP


; 延时子程序
; 调节CX大小可以控制时长
DELAY   PROC
        PUSH CX
        MOV CX,000FH
DL1:    LOOP DL1
	POP CX
	RET
DELAY   ENDP




; 将temp的内容复制给buffer，并将temp清空
copy_to_buffer  proc
        push ax
        push cx
        push si
        mov si,0
        mov cx,8
cpt_l1: 
        mov al,byte ptr temp[si]    ; 复制temp到buffer
        mov byte ptr buffer[si],al

        inc si
        loop cpt_l1
        pop si
        pop cx
        pop ax
        ret
copy_to_buffer  endp



; 依据周围8格的值设置temp[si][di]
judge proc     
        mov ax,0
cmp_1:
        ; 左上
        cmp si,0
        je cmp_2
        cmp di,0
        je cmp_2
        push si
        push di
        dec si
        dec di
        call get_buffer    
        add ax,bx
        pop di
        pop si

cmp_2:  ; 上
        cmp si,0
        je cmp_3
        push si
        push di
        dec si
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_3:
        ; 右上
        cmp si,0
        je cmp_4
        cmp di,7
        je cmp_4
        push si
        push di
        dec si
        inc di
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_4:
        ; 左
        cmp di,0
        je cmp_5
        push si
        push di
        dec di
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_5:
        ; 右
        cmp di,7
        je cmp_6
        push si
        push di
        inc di
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_6:
        ; 左下
        cmp si,7
        je cmp_7
        cmp di,0
        je cmp_7
        push si
        push di
        inc si
        dec di
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_7:
        ; 下
        cmp si,7
        je cmp_8
        push si
        push di
        inc si
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_8:
        ; 右下
        cmp di,7
        je cmp_end
        cmp si,7
        je cmp_end
        push si
        push di
        inc si
	inc di
        call get_buffer
        add ax,bx
        pop di
        pop si

cmp_end:
        ; 结束判断，为buffer[si][di]赋值
        ; 若buffer[si][di]为1，则当
        mov bl,buffer[si]   ; bx = buffer[si]
        mov cx,7            ; cx = 7-di
        sub cx,di           
        shr bl,cl           
        and bx,1            ; 当buffer[si][di]为1时，bx = 1
        cmp bx,1
        jne cmp_die
cmp_live:
        cmp ax,2
        jl is_die           ; 活细胞邻居少于2，死掉
        cmp ax,4
        jl is_live          ; 活细胞邻居是2或3，存活
        jmp is_die          ; 大于等于4个，死掉
cmp_die:
        cmp ax,3
        je is_live          ; 繁殖
        jmp is_die          
is_live:
        call set_temp       ; 置1
        jmp re_end
is_die:
        call reset_temp     ; 置0
        jmp re_end

re_end:
        ret
judge   endp
        

; 获取buffer[si][di]的值，并存放在bx当中
get_buffer  proc
        mov bl,buffer[si]   ; bx = buffer[si]
        mov cx,7            ; cx = 7-di
        sub cx,di           
        shr bl,cl
        and bx,1            ; 当buffer[si][di]为1时，bx = 1
	    ret
get_buffer  endp
        
; 将buffer[si][di]的值设置为1
set_temp    proc
        push ax
        push bx
        push cx
        push dx
        
        mov al,temp[si]
        mov cx,7
        sub cx,di
        mov bl,1
        shl bl,cl
        or  al,bl
        mov temp[si],al

        pop dx
        pop cx
        pop bx
        pop ax
	  
	  ret
set_temp    endp


; 将buffer[si][di]的值设置为0
reset_temp    proc
        push ax
        push bx
        push cx
        push dx
        
        mov al,temp[si]
        mov cx,7
        sub cx,di
        mov bl,1
        shl bl,cl
        not bl
        and al,bl
        mov temp[si],al
        
        pop dx
        pop cx
        pop bx
        pop ax
	    ret
reset_temp    endp

        
CODE ENDS
    END START