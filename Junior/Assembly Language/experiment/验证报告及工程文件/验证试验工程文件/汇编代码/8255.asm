ASSUME CS: CODE ,DS:DATA
DATA SEGMENT
	IO8255_MODE		EQU   28BH
	IO8255_A		EQU   288H
	IO8255_B		EQU   289H
	IO8255_C        EQU   28AH
DATA ENDS

; ��ѧ��Ϊ41724081����A�����룬B�����
CODE SEGMENT
	    ASSUME CS: CODE
START:  MOV DX, IO8255_MODE    ; 8255��ʼ��
	  	MOV AL,10010000B 	   ;����գ��˿�A��ʽ0���˿�A���룬�˿�C���ܣ��˿�B��ʽ0���˿�B������˿�C����
	  	OUT DX, AL
INOUT:  MOV DX,IO8255_A        ;����գ���������
	  	IN AL,DX
	  	MOV DX,IO8255_B        ;����գ��������
		OUT DX,AL              ;����գ�     
	  	MOV DL,0FFH            ; �ж��Ƿ��а���
	  	MOV AH,06H
	  	INT 21H
	  	JZ INOUT               ;����,�����

	  	MOV AH,4CH             ;���򷵻�
	  	INT 21H

CODE ENDS
	END START
