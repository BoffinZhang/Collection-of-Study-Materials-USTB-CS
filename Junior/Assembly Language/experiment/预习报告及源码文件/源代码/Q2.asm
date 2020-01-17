; 将data段中的数据以十进制的形式显示出来
; 首先计算1-150的和，放入ax
; 调用dtoc，将ax转化十进制数的ASCII码，放入buffer
; 调用show_str，将结果以绿色字体输出
assume cs:code, ds:data, ss:stack
data segment
    buffer  dw 10 dup (0)
data ends

stack segment
    dw 256 dup (0)
stack ends

code segment
start:
    ; 初始化
    mov bx,data
    mov ds,bx
    mov si,0
    mov bx,stack
    mov ss,bx
    mov cx,150
    ; 计算1-150的和，结果放入ax
cal_ax:
    add ax,cx
    loop cal_ax
    call dtoc

    mov dh,8
    mov dl,3
    mov cl,2
    mov si,0
    call show_str
    
    mov ax,4c00h
    int 21h

; ------ dtoc ------
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
    mov al,0
    mov [si],al     ; 最后一位放0（虽然本来初始化的时候就已经是0了）

    pop si
    pop dx
    pop cx
    pop di
    pop ax
    ret
; ------ end dtoc ------


; ------ show_str ------
show_str:
    push cx
    push dx
    mov ax,0b800h
    mov es,ax       ; 用es储存显存段地址
    ; 计算行偏移
    sub dh,1        ; dh-1
    mov bl,10
    mov al,dh  
    mul bl          ; 计算出起始行位置，存在ax中
    mov bl,16
    mul bl
    mov bp,ax       ; 行地址暂存在bp中
    ; 计算列偏移
    sub dl,1
    mov al,2
    mul dl
    add ax,bp
    mov di,ax       ; 显示偏移地址放到di中
    mov bp,0        ; 清空bp
    mov bl,cl       ; 字体颜色放到bl中
show:
    mov al,ds:[si]  ; 把字符串中的一个字节放到al
    mov ah,0
    mov cx,ax       ; 把每个数据都放到cx中检验是否为0
    jcxz ok
    mov byte ptr es:[di],al    ; 显示字符
    mov byte ptr es:[di+1],bl  ; 显示颜色
    add di,2        ; 显存指针每次+2
    inc si          ; 字符串指针每次+1
    jmp show
ok:
    pop dx
    pop cx
    ret
; ------ end show_str ------
code ends
    end start