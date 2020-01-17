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

        ; ******** 仿真用代码 *********
        ; 初始化8254工作模式
        ; 计数器0，方式3
        MOV DX, IO8254_MODE
        MOV AL, 00010000B       
        OUT DX, AL
        MOV DX, IO8254_0
        MOV AL, 05H
        OUT DX, AL
        MOV DX, IO8254_0
        MOV AL, 03H
        OUT DX, AL
        ; *****************************
    
        ; ******** 上板用代码 *********
        ; 初始化8254工作模式
        ; 计数器0，方式3
        MOV DX, IO8254_MODE
	    MOV AL, 00110110B 
        OUT DX, AL
	    MOV DX, IO8254_0
	    MOV AL, 058H
 	    OUT DX, AL
        MOV DX, IO8254_0
        MOV AL, 00H
        OUT DX, AL

        ; 计数器1，方式0
        MOV DX, IO8254_MODE
	    MOV AL, 01110000B
        OUT DX, AL
        MOV DX, IO8254_1
        MOV AL, 04H
        OUT DX, AL
	    MOV DX, IO8254_1
        MOV AL, 014H
        OUT DX, AL
        ; *****************************
        
        ; 加载初始图案
	    call load_pattern

; --- 主循环
QUERY:  
        ; 设定每刷新多少次，查询一次中断信号
	    MOV CX,008FH            
DIS_LOOP:
        CALL DISP
	    LOOP DIS_LOOP

        ; 查询中断
        MOV DX, O8259_3        ;向8259发送查询命令(填空）
        MOV AL, 0CH		       ;设置查询方式（填空）
        OUT DX,AL
        IN AL,DX               ;读出查询字
        TEST AL,80H            ;判断中断是否已响应
        JZ QUERY               ;没有响应则继续查询

        ; 如果查询到中断，则刷新画面
        call generator

        ; 设置8254计数器1的计数初值
	    MOV DX, IO8254_1
        MOV AL, 04H
        OUT DX, AL
	    MOV DX, IO8254_1
        MOV AL, 014H
        OUT DX, AL
EOI:  
        ; 向8259发送中断结束命令
        MOV DX,O8259_2          
        MOV AL,20H		       
        OUT DX,AL		        
        JMP QUERY

ENDLESS:
        JMP ENDLESS

	
	
; --- 函数：预加载图案
; 设置函数中加载到al的内容可以更改初始图形
load_pattern proc
        push ax
        push cx
        push si
        mov si,0
        mov cx,8
load_l1: 
         mov al,byte ptr glider[si]         ; 复制temp到buffer\
	    ;mov al, byte ptr exploder[si]      ; 复制temp到buffer
	    ;mov al, byte ptr light_spaceship[si]

        mov byte ptr buffer[si],al
        inc si
        loop load_l1	
        pop si
        pop cx
        pop ax
        ret
load_pattern endp

; --- 函数：刷新画面
; 对于8*8的每个格子，调用judge
; 生成的下一时刻状态存储在temp中
; TODO：用循环重写这段
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

; --- 函数DISP：将buffer输出给LED
; 在仿真时，R=1,C=0，对应的点才会亮
; 在上板时，R=1,C=1，对应的点才会亮
; 视上板还是仿真，注释掉程序中的一行代码
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
	    CALL DELAY
        MOV DX,COL
	    MOV AL,[si]
        ; ********** 仿真时注释掉这部分 ************
	    ;NOT AL                 
        ; *****************************************
        OUT DX,AL
	    CALL DELAY
        SHL BL,1
        INC SI
        LOOP DISP_L1
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
	    RET
DISP    ENDP


; --- 函数DELAY: 延时子程序
; 调节CX大小可以控制时长
DELAY   PROC
        PUSH CX
        MOV CX,000FH
DL1:    LOOP DL1
	    POP CX
	    RET
DELAY   ENDP



; --- 函数copy_to_buffer
; 将temp的内容复制给buffer
copy_to_buffer  proc
        push ax
        push cx
        push si
        mov si,0
        mov cx,8
cpt_l1: 
        mov al,byte ptr temp[si]    
        mov byte ptr buffer[si],al
        inc si
        loop cpt_l1

        pop si
        pop cx
        pop ax
        ret
copy_to_buffer  endp


; --- 函数judge
; 依据周围8格的值设置temp[si][di]的状态
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
        mov bl,buffer[si]   ; bx = buffer[si]
        mov cx,7            ; cx = 7-di
        sub cx,di           
        shr bl,cl           
        and bx,1            ; 当buffer[si][di]为1时，bx = 1
        cmp bx,1            ; 判断buffer[si][di]是死、活
        jne cmp_die
cmp_live:
        cmp ax,2
        jl is_die           ; 活细胞邻居少于2，死掉
        cmp ax,4
        jl is_live          ; 活细胞邻居是2或3，存活
        jmp is_die          ; 大于等于4个，死掉
cmp_die:
        cmp ax,3            ; 死细胞邻居=3
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
        
; --- 函数get_buffer
; 获取buffer[si][di]的值，并存放在bx当中
get_buffer  proc
        mov bl,buffer[si]   ; bx = buffer[si]
        mov cx,7            ; cx = 7-di
        sub cx,di           
        shr bl,cl
        and bx,1            ; 当buffer[si][di]为1时，bx = 1
	    ret
get_buffer  endp
        
; --- 函数set_temp
; 将temp[si][di]的值设置为1
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

; --- 函数reset_temp
; 将temp[si][di]的值设置为0
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