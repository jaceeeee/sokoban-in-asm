TITLE SOKOBAN (.EXE/FORMAT)
;--------------------------------------
STACKSEG SEGMENT PARA 'Stack'	
STACKSEG ENDS
;--------------------------------------
DATASEG SEGMENT PARA 'Data'
	CURSOR DB "A$"
	BOX DB "B$"
	HORIZONTAL DB ?
	VERTICAL DB ?	
	DIRECTION DB ?
	ENT DB 0AH, 0DH
	TGC DB ?    ;TOTAL GOAL COUNT PER PUZZLE
	RGC DB ?	;RUNNING GOAL COUNT PER PUZZLE	
	DRAW_FIELD2 DB 78 DUP('#'), 0ah, 0dh, 21 DUP(" #", 76 DUP(' '), '#', 0AH, 0DH), ' ', 78 DUP('#'), '$'

	;FOR FILE READING
	;--------------------------------------------------------------------------
	PUZZLE1  DB 'puzzle2.txt', 00H	
	FILEHANDLE1	  DW ?	
	PUZZLE_STR    DB 1001d DUP('$') ;length = original length of record + 1 (for $)
 	ERROR1_RSTR    DB 'Error in opening file.$'
    ERROR2_RSTR    DB 'Error reading from file.$'
    ERROR3_RSTR    DB 'No record read from file.$'    
;--------------------------------------
CODESEG SEGMENT PARA 'Code'
	ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG
MAIN PROC FAR
	MOV AX, DATASEG
	MOV DS, AX
	MOV ES, AX
	
  	MOV VERTICAL, 8H  	 ;vertical position coordinates
	MOV HORIZONTAL, 15  ;horizontal position coordinates
	MOV DIRECTION, 04DH  	;which direction is it going to go

	MOV AH, 0cH
	MOV AL, 3
	PUSH AX
	mov ah, 0ch
	mov al, 10
	push ax
	mov ah, 0ch
	mov al, 15
	push ax	

	; MOV DX, OFFSET PUZZLE1
	; PUSH DX
	; CALL READ_PUZZLE_FILE

	MOV TGC, 3
	MOV RGC, 0
	CALL GAME_LOOP
MAIN_EXIT:	
	MOV AH, 4CH
	INT 21H	
MAIN ENDP
;----------------------------------------------------
GAME_LOOP PROC NEAR	
	ITERATE:
	  MOV BP, SP	  
	  CALL CLEAR_SCREEN	  
	  mov DH, 01h	  
	  mov DL, 01h
	  push dx	  	
	  call SET_CURSOR	  
	  lea dx, DRAW_FIELD2
	  mov ah, 09h
	  int 21h
	  CALL DRAW_BOXES 
	  MOV DL, HORIZONTAL
	  MOV DH, VERTICAL
	  PUSH DX
	  CALL SET_CURSOR

	  LEA DX, CURSOR
	  PUSH DX	 
	  CALL DISPLAY
	  ; insert the checking of the boxes-slots here	  
	  ; if complete, jmp puzzle_exit	  
	  
	  CALL GET_KEY
	  MOV DL, HORIZONTAL
	  MOV DH, VERTICAL
	  CMP DIRECTION, 4DH
	  JE RIGHT
	  CMP DIRECTION, 4BH
	  JE LEFT
	  CMP DIRECTION, 48H
	  JE UP
	  CMP DIRECTION, 50H
	  JE DOWN
	  CMP AL, 1BH
	  JNE TEMP_PROC
	  JMP PUZZLE_EXIT
TEMP_PROC:
	  CALL CLEAR_SCREEN
	  mov dl, 1
	  mov dh, 1
	  call SET_CURSOR
	  lea dx, DRAW_FIELD2
	  mov ah, 09h
	  int 21h	  
	  JMP ITERATE	  
RIGHT:
	add dl, 1
	push dx 
	call SET_CURSOR
	mov ah, 08h
	int 10h
	cmp al, '#'
	je	right_proceed		
	cmp al, 'B'
	JE ATTEMPT_RIGHT	
	; JMP PROC_RIGHT
	ATTEMPT_RIGHT:				
		CALL BLOCK_MOVEMENTS
	PROC_RIGHT:
	INC HORIZONTAL
	right_proceed:
	JMP ITERATE
LEFT:	
	SUB DL, 1
	PUSH DX
	CALL SET_CURSOR
	MOV AH, 08H
	INT 10H
	CMP AL, '#'
	JE LEFT_PROCEED
	CMP AL, 'B'
	JE ATTEMPT_LEFT
	JMP PROC_LEFT
	ATTEMPT_LEFT:		
		CALL BLOCK_MOVEMENTS
	PROC_LEFT:
	DEC HORIZONTAL
	LEFT_PROCEED:
	JMP ITERATE	
UP:	
	SUB DH, 1
	PUSH DX
	CALL SET_CURSOR
	MOV AH, 08H
	INT 10H
	CMP AL, '#'	
	JE UP_PROCEED	
	CMP AL, 'B'
	JE ATTEMPT_UP
	JMP PROC_UP
	ATTEMPT_UP:		
		CALL BLOCK_MOVEMENTS		
	PROC_UP:
	DEC VERTICAL	
	UP_PROCEED:
	JMP ITERATE
DOWN:	  
	ADD DH, 1
	PUSH DX
	CALL SET_CURSOR
	MOV AH, 08H
	INT 10H
	CMP AL, '#'	
	JE DOWN_PROCEED
	CMP AL, 'B'
	JE ATTEMPT_DOWN
	JMP PROC_DOWN
	ATTEMPT_DOWN:		
		CALL BLOCK_MOVEMENTS
	PROC_DOWN:
	INC VERTICAL
	DOWN_PROCEED:
	JMP ITERATE
PUZZLE_EXIT:
	MOV DX, 184FH
	PUSH DX
	CALL SET_CURSOR
	RET
GAME_LOOP ENDP
;---------------------------------------------------
READ_PUZZLE_FILE PROC NEAR
	pop bx 
	pop dx 
	push bx
	MOV AH, 3DH           
	MOV AL, 00            
	INT 21H	
	JC RDISPLAY_ERROR1
	MOV FILEHANDLE1, AX	
	MOV AH, 3FH           
	MOV BX, FILEHANDLE1   
	MOV CX, 1000          
	LEA DX, PUZZLE_STR    
	INT 21H
	JC RDISPLAY_ERROR2
	CMP AX, 00            
	JE RDISPLAY_ERROR3	
  	MOV AH, 3EH           
  	MOV BX, FILEHANDLE1   
  	INT 21H
  	JMP CLOSE_FILE  	
RDISPLAY_ERROR1:
  	LEA DX, ERROR1_RSTR  	
  	JMP ERR_DISPLAY
RDISPLAY_ERROR2:
  	LEA DX, ERROR2_RSTR	
	JMP ERR_DISPLAY
RDISPLAY_ERROR3:
	LEA DX, ERROR3_RSTR	
	JMP ERR_DISPLAY
ERR_DISPLAY:	
	MOV AH, 09H
	INT 21H
CLOSE_FILE:
	ret
READ_PUZZLE_FILE ENDP
;----------------------------------------------------
BLOCK_MOVEMENTS PROC NEAR    
  BLOCK_LOOP:    	
  	CMP DX, [BP]  	
  	JE BLOCK_PROCEED  	
  	ADD BP, 2	
  	JMP BLOCK_LOOP
  BLOCK_PROCEED:
  	MOV BX, [BP]
  	PUSH BX
  	CMP DIRECTION, 4DH
  	JE BLOCK_RIGHT
  	CMP DIRECTION, 4BH
  	JE BLOCK_LEFT
  	CMP DIRECTION, 48H
  	JE BLOCK_UP
  	CMP DIRECTION, 50H
  	JE BLOCK_DOWN
  BLOCK_RIGHT:  
	INC DL 	
  	PUSH DX
  	CALL SET_CURSOR
  	MOV AH, 08H
  	INT 10H  	  	
  	CMP AL, ' '
  	JNE EXIT_BLOCK_LOOP
  	POP BX
  	INC BL   	
  	JMP B_MOV
  BLOCK_LEFT:  	
  	POP BX
  	DEC BL   	
  	JMP B_MOV
  BLOCK_UP:
  	POP BX
  	DEC BH
  	JMP B_MOV
  BLOCK_DOWN:
  	POP BX
  	INC BH 
  	JMP B_MOV
  B_MOV:  	  	  	
  	MOV [BP], BX
  EXIT_BLOCK_LOOP:
  	RET  
BLOCK_MOVEMENTS ENDP
;----------------------------------------------------
DRAW_BOXES PROC NEAR
  MOV CX, 0
  MOV CL, TGC
  D_B:
  	add bp, 2
  	MOV DX, [BP]
  	PUSH DX
  	; inc dx 
  	; mov [bp], dx
  	CALL SET_CURSOR
  	LEA DX, BOX
  	MOV AH, 09H
  	INT 21H
  	LOOP D_B
  MOV CL, TGC
  DEC CL
  R_B:
  	SUB BP, 2
  	LOOP R_B
  RET
DRAW_BOXES ENDP
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
GET_KEY	PROC NEAR
	MOV		AH, 10H
	INT		16H

	MOV		DIRECTION, AH

	__LEAVETHIS:
		RET	
GET_KEY ENDP

CODESEG ENDS
END MAIN