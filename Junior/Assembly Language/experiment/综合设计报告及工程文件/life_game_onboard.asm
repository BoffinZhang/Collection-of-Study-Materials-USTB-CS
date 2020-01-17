IO8255_MODE  EQU  286H      
IO8255_A     EQU  280H
IO8255_B     EQU  282H
IO8255_C     EQU  284H

IO8254_MODE  EQU  2A6H
IO8254_0     EQU  2A0H
IO8254_1     EQU  2A2H
IO8254_2     EQU  2A4H

I8259_1      EQU   2B4H       ; 8259��ICW1�˿ڵ�ַ
I8259_2      EQU   2B3H       ; 8259��ICW2�˿ڵ�ַ
I8259_3      EQU   2B6H       ; 8259��ICW3�˿ڵ�ַ
I8259_4      EQU   2B5H       ; 8259��ICW4�˿ڵ�ַ
O8259_1      EQU   2B1H       ; 8259��OCW1�˿ڵ�ַ
O8259_2      EQU   2B0H       ; 8259��OCW2�˿ڵ�ַ
O8259_3      EQU   2B2H       ; 8259��OCW3�˿ڵ�ַ


; ÿ������8���ֽڱ�ʾ
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
        
        ; ��ʼ��8259
        MOV DX, I8259_1         ;��ʼ��8259��ICW1
        MOV AL, 00010011b       ;���ش�������Ƭ8259����ҪICW4
        OUT DX,AL

        MOV DX,I8259_2          ;��ʼ��8259��ICW2
        MOV AL,0B0H            
        OUT DX,AL
        MOV AL,03H
        OUT DX,AL
        MOV DX, O8259_1         ;��ʼ��8259���ж����β���������OCW1
        MOV AL, 00H             ;������λ
        OUT DX,AL

        ; ��ʼ��8255: A��B���
        MOV DX, IO8255_MODE     
        MOV AL, 80H       
        OUT DX, AL

        MOV DX,ROW
        MOV AL,03H
        OUT DX,AL

        MOV DX,COL
        MOV AL,0F1H
        OUT DX,AL

        ; ******** �����ô��� *********
        ; ��ʼ��8254����ģʽ
        ; ������0����ʽ3
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
    
        ; ******** �ϰ��ô��� *********
        ; ��ʼ��8254����ģʽ
        ; ������0����ʽ3
        MOV DX, IO8254_MODE
	    MOV AL, 00110110B 
        OUT DX, AL
	    MOV DX, IO8254_0
	    MOV AL, 058H
 	    OUT DX, AL
        MOV DX, IO8254_0
        MOV AL, 00H
        OUT DX, AL

        ; ������1����ʽ0
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
        
        ; ���س�ʼͼ��
	    call load_pattern

; --- ��ѭ��
QUERY:  
        ; �趨ÿˢ�¶��ٴΣ���ѯһ���ж��ź�
	    MOV CX,008FH            
DIS_LOOP:
        CALL DISP
	    LOOP DIS_LOOP

        ; ��ѯ�ж�
        MOV DX, O8259_3        ;��8259���Ͳ�ѯ����(��գ�
        MOV AL, 0CH		       ;���ò�ѯ��ʽ����գ�
        OUT DX,AL
        IN AL,DX               ;������ѯ��
        TEST AL,80H            ;�ж��ж��Ƿ�����Ӧ
        JZ QUERY               ;û����Ӧ�������ѯ

        ; �����ѯ���жϣ���ˢ�»���
        call generator

        ; ����8254������1�ļ�����ֵ
	    MOV DX, IO8254_1
        MOV AL, 04H
        OUT DX, AL
	    MOV DX, IO8254_1
        MOV AL, 014H
        OUT DX, AL
EOI:  
        ; ��8259�����жϽ�������
        MOV DX,O8259_2          
        MOV AL,20H		       
        OUT DX,AL		        
        JMP QUERY

ENDLESS:
        JMP ENDLESS

	
	
; --- ������Ԥ����ͼ��
; ���ú����м��ص�al�����ݿ��Ը��ĳ�ʼͼ��
load_pattern proc
        push ax
        push cx
        push si
        mov si,0
        mov cx,8
load_l1: 
         mov al,byte ptr glider[si]         ; ����temp��buffer\
	    ;mov al, byte ptr exploder[si]      ; ����temp��buffer
	    ;mov al, byte ptr light_spaceship[si]

        mov byte ptr buffer[si],al
        inc si
        loop load_l1	
        pop si
        pop cx
        pop ax
        ret
load_pattern endp

; --- ������ˢ�»���
; ����8*8��ÿ�����ӣ�����judge
; ���ɵ���һʱ��״̬�洢��temp��
; TODO����ѭ����д���
generator   proc              ; ˢ�»��棬����buffer
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

; --- ����DISP����buffer�����LED
; �ڷ���ʱ��R=1,C=0����Ӧ�ĵ�Ż���
; ���ϰ�ʱ��R=1,C=1����Ӧ�ĵ�Ż���
; ���ϰ廹�Ƿ��棬ע�͵������е�һ�д���
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
        ; ********** ����ʱע�͵��ⲿ�� ************
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


; --- ����DELAY: ��ʱ�ӳ���
; ����CX��С���Կ���ʱ��
DELAY   PROC
        PUSH CX
        MOV CX,000FH
DL1:    LOOP DL1
	    POP CX
	    RET
DELAY   ENDP



; --- ����copy_to_buffer
; ��temp�����ݸ��Ƹ�buffer
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


; --- ����judge
; ������Χ8���ֵ����temp[si][di]��״̬
judge proc     
        mov ax,0
cmp_1:
        ; ����
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

cmp_2:  ; ��
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
        ; ����
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
        ; ��
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
        ; ��
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
        ; ����
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
        ; ��
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
        ; ����
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
        ; �����жϣ�Ϊbuffer[si][di]��ֵ
        mov bl,buffer[si]   ; bx = buffer[si]
        mov cx,7            ; cx = 7-di
        sub cx,di           
        shr bl,cl           
        and bx,1            ; ��buffer[si][di]Ϊ1ʱ��bx = 1
        cmp bx,1            ; �ж�buffer[si][di]��������
        jne cmp_die
cmp_live:
        cmp ax,2
        jl is_die           ; ��ϸ���ھ�����2������
        cmp ax,4
        jl is_live          ; ��ϸ���ھ���2��3�����
        jmp is_die          ; ���ڵ���4��������
cmp_die:
        cmp ax,3            ; ��ϸ���ھ�=3
        je is_live          ; ��ֳ
        jmp is_die          
is_live:
        call set_temp       ; ��1
        jmp re_end
is_die:
        call reset_temp     ; ��0
        jmp re_end
re_end:
        ret
judge   endp
        
; --- ����get_buffer
; ��ȡbuffer[si][di]��ֵ���������bx����
get_buffer  proc
        mov bl,buffer[si]   ; bx = buffer[si]
        mov cx,7            ; cx = 7-di
        sub cx,di           
        shr bl,cl
        and bx,1            ; ��buffer[si][di]Ϊ1ʱ��bx = 1
	    ret
get_buffer  endp
        
; --- ����set_temp
; ��temp[si][di]��ֵ����Ϊ1
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

; --- ����reset_temp
; ��temp[si][di]��ֵ����Ϊ0
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