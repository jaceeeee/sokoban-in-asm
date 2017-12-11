TITLE TEST1 (.EXE MODEL / FORMAT)
;--------------------------------------
STACKSEG SEGMENT PARA 'Stack'	
STACKSEG ENDS
;--------------------------------------
DATASEG SEGMENT PARA 'Data'
	total db 1
	total2 db 3
DATASEG ENDS
;--------------------------------------
CODESEG SEGMENT PARA 'Code'
	ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG
MAIN PROC FAR
	MOV AX, DATASEG
	MOV DS, AX
	MOV ES, AX

	mov ah, 08h
	int 10h
	
	inc total
	mov al, total
	
	MOV AH, 12
	MOV AL, 04	

	CALL ENTER_FN	

	mov al, total
	cmp al, total		
	je EXIT	
EXIT:
	MOV AH, 4CH
	INT 21H
MAIN ENDP
;----------------------------
ENTER_FN PROC NEAR
	MOV BP, SP
	MOV AX, [BP]

	ADD BP, 2
	MOV AX, [BP]

	MOV AX, [10H]
	MOV [BP], AX

	MOV BX, [BP]

	RET
ENTER_FN ENDP

CODESEG ENDS
END MAIN
