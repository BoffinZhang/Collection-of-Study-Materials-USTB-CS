IO8254_MODE  	EQU   283H     ;8254���ƼĴ����˿ڵ�ַ
IO8254_COUNT1	EQU   281H     ;8254������1�˿ڵ�ַ
                            
STACK1 SEGMENT STACK
        DW 256 DUP(?)
STACK1 ENDS
CODE SEGMENT
        ASSUME CS:CODE
START: MOV DX, IO8254_MODE       ;��ʼ��8254������ʽ
       MOV AL, 01010000b          ;������1����ʽ0�����1��
	 ;MOV AL, 01010110b          ;������1����ʽ3�����1��
       OUT DX, AL
                
       MOV DX, 281H        ;װ�������ֵ�����2��
       MOV AL, 7				;�����3��
       OUT DX,AL

       MOV AX,4C00H               ;���ص�DOS
       INT 21H
       
CODE ENDS
     END START
