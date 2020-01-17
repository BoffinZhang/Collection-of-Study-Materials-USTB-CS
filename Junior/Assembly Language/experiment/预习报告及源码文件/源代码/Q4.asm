; 学长挑战题：质因数分解

assume cs:code,ds:data,ss:stack
data segment
    n       db      0
    buf     db      200 dup(0)
    outbuf  db      200 dup(0)
    hello   db      "hello world!$"
data ends

stack segment
    dw 128 dup (0)
stack ends

code segment
start:
    mov bx,data
    mov ds,bx
    mov si,0
    mov bx,stack
    mov ss,bx
    mov bx,0
    call getInt     ; 读入N到al中
    mov n,al
    mov ah,0
    mov cx,2        ; 质因数从2开始
calNext:            ; 计算ax的下一个质因数
    push ax
    cmp ax,1
    jbe calNext_end  ; 若ax<=1，则直接返回

    div cl          ; 商在al中，余数在ah中，若余数为0，说明是质因数
    cmp ah,0
    jne calNext_else
calNext_if:         ; if ah==0
    mov ax,cx
    call putInt
    mov ah,0
    mov al,' '
    call putchar

    pop ax 
    div cl          ; ax = ax/cl
    mov ah,0
    jmp calNext
calNext_else:       ; 找到下一个质数，放到cl中
    inc cx
    mov ax,cx       
    call isPrime
    cmp ax,0
    je calNext_else

    pop ax
    jmp calNext
calNext_end:
    mov ax,4c00h
    int 21h


isPrime:            ; 检验ax中的数值是否为质数，如果是质数，返回ax=1
    push bx
    push cx
    push dx
    mov bx,2
isPrime_loop:
    push ax
    div bl
    cmp ah,0        ; 若余数为0，说明整除，返回ax = 0
    je isPrime_falseRet
    inc bx
    pop ax
    cmp ax,bx
    je isPrime_trueRet 
    jmp isPrime_loop
isPrime_falseRet:
    pop ax
    mov ax,0
    jmp isPrime_ret
isPrime_trueRet:
    mov ax,1
    jmp isPrime_ret
isPrime_ret:
    pop dx
    pop cx
    pop bx
    ret


putchar:                ; 把dl中的字符输出
    push ax
	push dx
	mov dx,ax
	mov ah,02h
	int 21h
	pop dx
    pop ax
	ret


putInt:             ; 将ax中的16位整数输出到屏幕上
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