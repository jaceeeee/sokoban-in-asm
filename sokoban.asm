TITLE SOKOBAN (.EXE/FORMAT)
;--------------------------------------
STACKSEG SEGMENT PARA 'Stack'	
STACKSEG ENDS
;--------------------------------------
DATASEG SEGMENT PARA 'Data'
	CURSOR DB "A$"	
	HORIZONTAL DB ?
	VERTICAL DB ?	
	DIRECTION DB ?
	ENT DB 0AH, 0DH
	; DRAW_FIELD1 DB 78 DUP('*'), 0AH, 0DH, "*", 76 DUP(' '), "*", 0AH, 0DH, "*", 76 DUP(' '), "*", 0AH, 0DH, "*", 76 DUP(' '), "*", 0AH, 0DH, "*", 76 DUP(' '), "*", 0AH, 0DH, "*", 76 DUP(' '), "*", 0AH, 0DH, "*", 76 DUP(' '), "*", 0AH, 0DH, '$'
	DRAW_FIELD2 DB 78 DUP('*'), 2 DUP('*', 78 DUP(' '), '*', 0AH, 0DH), 78 DUP('*'), '$'

;--------------------------------------
CODESEG SEGMENT PARA 'Code'
	ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG
MAIN PROC FAR
	MOV AX, DATASEG
	MOV DS, AX
	MOV ES, AX

	MOV HORIZONTAL, 01  ;horizontal position coordinates
  	MOV VERTICAL, 0CH   ;vertical position coordinates
	MOV DIRECTION, 04DH  	;which direction is it going to go
	LEA DX, DRAW_FIELD2
	MOV AH, 09
	INT 21H
	JMP EXIT
	ITERATE:	  
	  CALL CLEAR_SCREEN	  

	  MOV DL, HORIZONTAL
	  MOV DH, VERTICAL
	  PUSH DX
	  CALL SET_CURSOR

	  LEA DX, CURSOR
	  PUSH DX
	  CALL DISPLAY

	  CALL DELAY


	  CALL GET_KEY
	  CMP DIRECTION, 4DH
	  JE RIGHT
	  CMP DIRECTION, 4BH
	  JE LEFT
	  CMP DIRECTION, 48H
	  JE UP
	  CMP DIRECTION, 50H
	  JE DOWN
	  CMP AL, 1BH
	  JE EXIT

	  CALL CLEAR_SCREEN
	  JMP ITERATE
	  
RIGHT_WRAP:
	MOV HORIZONTAL, 1	
	JMP ITERATE
LEFT_WRAP:
	MOV HORIZONTAL, 04EH
	JMP ITERATE
TOP_WRAP:
	MOV VERTICAL, 017H
	JMP ITERATE
BOTTOM_WRAP:	
	MOV VERTICAL, 1  
	JMP ITERATE

RIGHT:
	INC HORIZONTAL
	CMP HORIZONTAL, 04EH	
	JE RIGHT_WRAP
	JMP ITERATE
LEFT:
	DEC HORIZONTAL
	CMP HORIZONTAL, 1
	JE LEFT_WRAP
	JMP ITERATE	
UP:
	DEC VERTICAL
	CMP VERTICAL, 1	
	JE TOP_WRAP
	JMP ITERATE
DOWN:	  
	INC VERTICAL
	CMP VERTICAL, 017H	
	JE BOTTOM_WRAP
	JMP ITERATE
EXIT:
	MOV DX, 184FH
	PUSH DX
	CALL SET_CURSOR
	
	MOV AH, 4CH
	INT 21H	
MAIN ENDP
;----------------------------------------------------
CLEAR_SCREEN PROC NEAR
  MOV AX, 0600H   
  MOV BH, 01H     
  MOV CX, 0000H   
  MOV DX, 1950H   
  INT 10H

  MOV AX, 0600H
  MOV BH, 17H
  MOV CX, 0101H
  MOV DX, 174EH
  INT 10H

  RET
CLEAR_SCREEN ENDP
;---------------------------------------------------
SET_CURSOR PROC NEAR
  POP BX
  POP DX
  PUSH BX
  MOV AH, 02H   
  MOV BH, 00   

  INT 10H

  RET
SET_CURSOR ENDP
;---------------------------------------------------
DISPLAY PROC NEAR
  POP BX
  POP DX
  PUSH BX
  MOV AH, 9
  INT 21H

  RET
DISPLAY ENDP
;---------------------------------------------------
DELAY PROC	NEAR
	mov bp, 2 ;lower value faster
	mov si, 2 ;lower value faster
	
	delay2:
		dec bp
		nop
		jnz delay2
		dec si
		cmp si,0
		jnz delay2
		RET
DELAY ENDP
;---------------------------------------------------
GET_KEY	PROC NEAR
	MOV		AH, 10H
	INT		16H

	MOV		DIRECTION, AH


	__LEAVETHIS:
		RET	
GET_KEY ENDP

CODESEG ENDS
END MAIN