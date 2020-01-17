IO8254_MODE  	EQU   283H     ;8254控制寄存器端口地址
IO8254_COUNT1	EQU   281H     ;8254计数器1端口地址
                            
STACK1 SEGMENT STACK
        DW 256 DUP(?)
STACK1 ENDS
CODE SEGMENT
        ASSUME CS:CODE
START: MOV DX, IO8254_MODE       ;初始化8254工作方式
       MOV AL, 01010000b          ;计数器1，方式0（填空1）
	 ;MOV AL, 01010110b          ;计数器1，方式3（填空1）
       OUT DX, AL
                
       MOV DX, 281H        ;装入计数初值（填空2）
       MOV AL, 7				;（填空3）
       OUT DX,AL

       MOV AX,4C00H               ;返回到DOS
       INT 21H
       
CODE ENDS
     END START
