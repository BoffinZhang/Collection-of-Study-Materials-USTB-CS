; 第一行输入N
; 第二行开始的N行，每行输入一个小于256的正整数
; 排序后输出结果
assume cs:code,ds:data,ss:stack
data segment
    buf     db      200 dup(0)
    n       db      0
    outbuf  db      200 dup(0)
    hello   db      "hello world!$"
data ends

stack segment
    dw 128 dup (0)
stack ends

code segment
; TODO: 排序，输出
start:
    ; 初始化
    mov ax,data
    mov ds,ax
    mov sp,128
    call getInt     ; 读入N
    mov n,al
    mov bx,0
    mov ch,0
    mov cl,al
read_n_nums:
    ; 读入n个数
    push cx
    call getInt
    mov buf[bx],al
    inc bx
    pop cx
    loop read_n_nums
    mov bx,0

lp1:
    mov di,bx
    inc di  
lp2:
    mov al,buf[bx]
    mov cl,buf[di]
    cmp al,cl
        jae els
        mov buf[bx],cl
        mov buf[di],al
els:
    inc di
    mov ax,di
    mov ah,n
    cmp ah,al
    jae lp2
    inc bx
    cmp bl,n
    jb lp1

    mov ch,0
    mov cl,n
    mov bx,0

output:
    mov ah,0
    mov al,buf[bx]
    call putInt
    mov al,' '
    call putchar
    inc bx
    cmp bx,cx
    jb  output

    mov ah,4ch
    int 21h

putchar:
    ; 把dx地址中的字符输出
	push dx
	mov dx,ax
	mov ah,02h
	int 21h
	pop dx
	ret


getInt:
    push bx
    push cx
    push dx
    mov ax,0
    mov bx,0
    mov cx,0
    mov dx,0
getInt_getchar:
    ; 读入一个字符
    mov ah,01h
    int 21h
    cmp al,0dh      ; 判断是否为回车符
    jz  getInt_ret  ; 判断是回车符，跳转出
    
    cmp al,30h      ; <'0'
    jb getInt_getchar
    cmp al,39h      ; >'0'<='9'
    jbe getInt_SumToAx
    jmp getInt_getchar
getInt_SumToAx:
    mov ah,0
    push ax

    mov ax,cx       ; ax = ax*10 + al
    mov bx,10
    mul bx
    mov dx,0
    mov cx,ax
    pop ax

    sub al,30h      ; ascii码需要-30h才是数字
    add cx,ax
    jmp getInt_getchar
getInt_ret:
    mov ax,cx
    pop dx
    pop cx
    pop bx
    ret



putInt:
    push si
    push dx
    mov dx,0
    mov si,offset outbuf
    call dtoc
    mov dx,offset outbuf
    mov ah,9
    int 21h
    pop dx
    pop si
    ret

dtoc:
    ; 逐次取余数，并入栈，最后再倒序拿出来，在buffer最后放0
    push ax
    push di
    push cx
    push dx
    push si
    mov di,0        ; 记录入栈次数

dtoc_s1:
    mov cx,10
    mov dx,0
    div cx
    
    mov cx,ax       ; 如果商为0，则求值完成
    jcxz dtoc_s2

    add dx,30h
    push dx         ; 求得的ASCII码入栈
    inc di
    jmp dtoc_s1

dtoc_s2:
    add dx,30h
    push dx
    inc di
    mov cx,di       ; cx为转化后的字符串长度
dtoc_s3:
    pop ax
    mov [si],al
    inc si
    loop dtoc_s3    ; 将ASCII码出栈
    mov al,"$"
    mov [si],al     ; 最后一位放$（虽然本来初始化的时候就已经是0了）
    pop si
    pop dx
    pop cx
    pop di
    pop ax
    ret

code ends
end start
