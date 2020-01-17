 IO8254_MODE  EQU       283H        ;8254控制寄存器端口地址
           IO8254_COUNT1  EQU       281H        ;8254计数器1端口地址
           IO8254_COUNT2  EQU       282H        ;8254计数器2端口地址
      STACK1  SEGMENT   STACK
              DW        256 DUP(?)
      STACK1  ENDS
        CODE  SEGMENT
              ASSUME    CS:CODE
      START:  MOV       DX, IO8254_MODE         ;初始化8254工作方式
              MOV       AL, 01110110B           ;计数器1，方式3
              OUT       DX, AL
                
              MOV       DX, IO8254_COUNT1       ;装入计数初值al
              MOV       AL, 0E8H    ;
              OUT       DX,AL
	 
              MOV       DX, IO8254_COUNT1       ;装入计数初值ah
              MOV       AL, 03H     ;
              OUT       DX,AL

              MOV       DX, IO8254_MODE         ;初始化8254工作方式
              MOV       AL, 10110110B           ;计数器2，方式3
              OUT       DX, AL

              MOV       DX, IO8254_COUNT2       ;装入计数初值al
              MOV       AL, 0D0H    ;	
              OUT       DX,AL
	 
              MOV       DX, IO8254_COUNT2       ;装入计数初值ah
              MOV       AL, 07H     ;
              OUT       DX,AL

              MOV       AX,4C00H    ;返回到DOS
              INT       21H
       
        CODE  ENDS
              END       START
