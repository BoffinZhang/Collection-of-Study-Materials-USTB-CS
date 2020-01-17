ASSUME CS: CODE ,DS:DATA
DATA SEGMENT
	IO8255_MODE		EQU   28BH
	IO8255_A		EQU   288H
	IO8255_B		EQU   289H
	IO8255_C        EQU   28AH
DATA ENDS

; 我学号为41724081，用A口输入，B口输出
CODE SEGMENT
	    ASSUME CS: CODE
START:  MOV DX, IO8255_MODE    ; 8255初始化
	  	MOV AL,10010000B 	   ;（填空）端口A方式0，端口A输入，端口C不管，端口B方式0，端口B输出，端口C不管
	  	OUT DX, AL
INOUT:  MOV DX,IO8255_A        ;（填空）读入数据
	  	IN AL,DX
	  	MOV DX,IO8255_B        ;（填空）输出数据
		OUT DX,AL              ;（填空）     
	  	MOV DL,0FFH            ; 判断是否有按键
	  	MOV AH,06H
	  	INT 21H
	  	JZ INOUT               ;若无,则继续

	  	MOV AH,4CH             ;否则返回
	  	INT 21H

CODE ENDS
	END START
