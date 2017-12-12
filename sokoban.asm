TITLE SOKOBAN (.EXE/FORMAT)
.model small
;--------------------------------------
STACKSEG SEGMENT PARA 'Stack'		
.stack 2048
STACKSEG ENDS
;--------------------------------------
DATASEG SEGMENT PARA 'Data'
	;-----------------------------------------------------------------------------
	; for menus
	;-----------------------------------------------------------------------------
	INITIAL DW 0100H
	FILEHANDLE DW ?
  	STARTSCREEN  DB 'start.txt', 00H
  	HOWSCREEN DB 'how_play.txt', 00H
	RECORD_STR    DB 2000 DUP('$'), '$'  ;length = original length of record + 1 (for $)
  	ARROW DB 175, '$'
	ARROW_POS_START DW 0E1EH
	ARROW_POS_HOW DW 101CH
	ARROW_POS_EXIT DW 121EH
	ARROW_POS DW ?
	HOW_BACK DW 170BH
	HOW_START DW 1724H

	ERASE DB 33
    ENTER_KEY DB 1CH
    LEFT_ARROW DB 4BH
    RIGHT_ARROW DB 50H
    UP_ARROW DB 48H
    DOWN_ARROW DB 50H
    INPUT DB ?	
    SCORE DB 7 DUP ('0'), '$'
  	;-----------------------------------------------------------------------------
  	; for game logic
  	;-----------------------------------------------------------------------------
	CURSOR DB "A$"
	BOX DB "B$"
	HORIZONTAL DB ?
	VERTICAL DB ?	
	DIRECTION DB ?
	ENT DB 0AH, 0DH
	TGC DB ?    						; TOTAL GOAL COUNT PER PUZZLE
	RGC DB ?							; RUNNING GOAL COUNT PER PUZZLE	
	DRAW_FIELD2 DB 78 DUP('#'), 0ah, 0dh, 21 DUP(" #", 76 DUP(' '), '#', 0AH, 0DH), ' ', 78 DUP('#'), '$'
	N_M DB ?
	SOLVED DB ?
	GOAL DB ?
	OCCUPIED DB "C$"
	LSP DW ? 							; LAST STACK POSITION
	SOP DW ? 							; goals stack position
	PLAYER_PUSHNUM DW ?
	RES DB ?	
	;-----------------------------------------------------------------------------
	; FOR FILE READING
	;-----------------------------------------------------------------------------
	PUZZLE1  DB 'puzzle1.txt', 00H	
	PUZZLE2  DB 'puzzle2.txt', 00H
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

	MOV PLAYER_PUSHNUM, 0
	PLAY:
		CALL CHOOSE_MENU	

MAIN_EXIT:	
	MOV AH, 4CH
	INT 21H	
MAIN ENDP
;----------------------------------------------------
START_PUZZLE_LOOPING PROC NEAR	
PUZZLE1_LOOP:
	MOV SOLVED, 'N'
	MOV RES, 'N'
	MOV VERTICAL, 12
	MOV HORIZONTAL, 38
	MOV DIRECTION, 04DH
	
	MOV AH, 10
	MOV AL, 38
	PUSH AX	
	MOV AH, 11
	MOV AL, 37
	PUSH AX
	MOV AH, 11
	MOV AL, 39
	PUSH AX
	MOV AH, 12
	MOV AL, 36
	PUSH AX
	MOV AH, 12
	MOV AL, 40
	PUSH AX
	MOV AH, 13
	MOV AL, 37
	PUSH AX
	MOV AH, 13
	MOV AL, 39
	PUSH AX
	MOV AH, 14
	MOV AL, 38
	PUSH AX
	MOV SOP, SP

	MOV AH, 10
	MOV AL, 38
	PUSH AX
	MOV AH, 11
	MOV AL, 37
	PUSH AX
	MOV AH, 11
	MOV AL, 38
	PUSH AX
	MOV AH, 11
	MOV AL, 39
	PUSH AX
	MOV AH, 12
	MOV AL, 36
	PUSH AX
	MOV AH, 12
	MOV AL, 40
	PUSH AX
	MOV AH, 13
	MOV AL, 37
	PUSH AX
	MOV AH, 13
	MOV AL, 39
	PUSH AX
	MOV DX, OFFSET PUZZLE1
	PUSH DX
	CALL READ_PUZZLE_FILE

	MOV TGC, 8
	MOV RGC, 0
	CALL GAME_LOOP

	MOV CX, 16
	POP_1:
		POP AX 
	LOOP POP_1
	CMP RES, 'N'
	JE PUZZLE2_LOOP
	JMP PUZZLE1_LOOP

PUZZLE2_LOOP:
	MOV SOLVED, 'N'
	MOV RES, 'N'
  	MOV VERTICAL, 14  	 ;vertical position coordinates
	MOV HORIZONTAL, 40  ;horizontal position coordinates
	MOV DIRECTION, 04DH  	;which direction is it going to go
	
	;GOALS for puzzle 2
	MOV AH, 13
	MOV AL, 38
	PUSH AX
	MOV AH, 12
	MOV AL, 40
	PUSH AX
	MOV AH, 11
	MOV AL, 39
	PUSH AX
	MOV AH, 11
	MOV AL, 38
	PUSH AX
	MOV AH, 11
	MOV AL, 37
	PUSH AX
	MOV SOP, SP

	;BOXES FOR PUZZLE 2
	MOV AH, 13
	MOV AL, 39
	PUSH AX
	mov ah, 13
	mov al, 37
	PUSH AX
	MOV AH, 12
	MOV AL, 40
	PUSH AX	
	MOV AH, 12
	MOV AL, 41
	PUSH AX
	MOV AH, 10
	MOV AL, 39
	PUSH AX

	MOV DX, OFFSET PUZZLE2
	PUSH DX
	CALL READ_PUZZLE_FILE

	MOV TGC, 5
	MOV RGC, 0
	CALL GAME_LOOP

	MOV CX, 10
	POP_2:
		POP AX
	LOOP POP_2

	CMP RES, 'N'
	JE MAIN_LOOP_EXIT
	JMP PUZZLE2_LOOP

	MAIN_LOOP_EXIT:
	JMP MAIN_EXIT
START_PUZZLE_LOOPING ENDP
;----------------------------------------------------
DRAW_SCORE PROC NEAR
	MOV DH, 23
	MOV DL, 10
	PUSH DX 
	CALL SET_CURSOR	
	MOV AH, 09H
	LEA DX, SCORE
	INT 21H
	RET
DRAW_SCORE ENDP
;----------------------------------------------------
; STORE_GOALS PROC NEAR
; 	MOV DH, 6
; 	MOV DL, 25
; 	MOV CX, 12	
; 	  LOOP1:
; 	    PUSH CX
; 	    MOV DH, 6
; 	    MOV BH, CX
; 	    SUB 
;         MOV CX, 30
;           LOOP2:	        
;             ADD DH, BH 
;             ADD DL, BL
;             MOV AH, 08H
;             INT 10H
;             CMP AL, '%'

;             INC BL
; 	      LOOP LOOP2:
; 	    POP CX
; 	    INC BH
; 	  LOOP LOOP1
; 	RET
; STORE_GOALS ENDP
;----------------------------------------------------
; STORE_BOXES PROC NEAR
; 	MOV CX, 12
; 	  LOOP1:
; 	    PUSH CX
;         MOV CX, 30
;           LOOP2:	        

; 	      LOOP LOOP2:
; 	    POP CX

; 	  LOOP LOOP1
; 	RET
; STORE_BOXES ENDP
;----------------------------------------------------
INITIAL_CURSOR PROC NEAR
  MOV DX, OFFSET INITIAL
  PUSH DX
  CALL SET_CURSOR
  RET
INITIAL_CURSOR ENDP
;----------------------------------------------------
OPEN_FILE PROC NEAR
  POP BX
  POP DX
  PUSH BX

  MOV AH, 3DH           ;requst open file
  MOV AL, 00            ;read only; 01 (write only); 10 (read/write)
  INT 21H
  JC DISPLAY_ERROR1
  MOV FILEHANDLE, AX

  ;POP BX
  ;POP DX
  ;PUSH BX
  ;read file
  MOV AH, 3FH           ;request read record
  MOV BX, FILEHANDLE    ;file handle
  MOV CX, 2000          ;record length
  MOV DX, OFFSET RECORD_STR
  INT 21H
  JC DISPLAY_ERROR2
  CMP AX, 00            ;zero bytes read?
  JE DISPLAY_ERROR3

  ;display record
  MOV DX, OFFSET RECORD_STR
  MOV AH, 09
  INT 21H

  ;close file handle
  MOV AH, 3EH           ;request close file
  MOV BX, FILEHANDLE    ;file handle
  INT 21H
  RET

  DISPLAY_ERROR1:
  MOV DX, OFFSET ERROR1_RSTR
  MOV AH, 09
  INT 21H

  JMP MAIN_EXIT

  DISPLAY_ERROR2:
  MOV DX, OFFSET ERROR2_RSTR
  MOV AH, 09
  INT 21H

  JMP MAIN_EXIT

  DISPLAY_ERROR3:
  MOV DX, OFFSET ERROR3_RSTR
  MOV AH, 09
  INT 21H

  JMP MAIN_EXIT
OPEN_FILE ENDP
;------------------------------------------------------------
GAME_LOOP PROC NEAR	
	ITERATE:
	  MOV BP, SP
	  MOV LSP, BP
	  CALL CLEAR_SCREEN	  
	  mov DH, 6	  
	  mov DL, 25
	  push dx	  	
	  call SET_CURSOR	  
	  lea dx, PUZZLE_STR
	  mov ah, 09h
	  int 21h
	  CALL DRAW_BOXES
	  CALL DRAW_GOALS
	  
	  MOV DL, RGC 
	  CMP DL, TGC
	  JE PUZZLE_EXIT
	  JMP GL_PROC1
	PUZZLE_EXIT:
	  MOV DX, 184FH
	  PUSH DX
	  CALL SET_CURSOR
	  RET
	  GL_PROC1:
	  MOV DL, HORIZONTAL
	  MOV DH, VERTICAL
	  PUSH DX
	  CALL SET_CURSOR
	  CALL DRAW_SCORE
	  LEA DX, CURSOR
	  PUSH DX	 
	  CALL DISPLAY
	  ; insert the checking of the boxes-slots here	  
	  ; if complete, jmp puzzle_exit	  
	  CALL DELAY
	  MOV N_M, 'Y'
	  CALL GET_KEY
	  MOV DL, HORIZONTAL
	  MOV DH, VERTICAL
	  CMP DIRECTION, 4DH
	  JE RIGHT
	  CMP DIRECTION, 4BH
	  JE LEFT
	  CMP DIRECTION, 48H
	  JE U_EXTENS
	  CMP DIRECTION, 50H
	  JE D_EXTENS
	  CMP AL, 'R'
	  JE RESET
	  CMP AL, 'r'
	  JE RESET
	  CMP AL, 1BH
	  JNE TEMP_PROC
	  JMP PUZZLE_EXIT
RESET: 
	MOV RES, 'Y'
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
	U_EXTENS:
		JMP UP
RIGHT:
	ADD DL, 1
	PUSH DX
	CALL SET_CURSOR
	MOV AH, 08H
	INT 10H
	CMP AL, '#'
	JE	RIGHT_PROCEED		
	cmp al, 'B'
	JE ATTEMPT_RIGHT	
	CMP AL, 'C'
	JE ATTEMPT_RIGHT
	JMP PROC_RIGHT	
	ATTEMPT_RIGHT:				
		CALL BLOCK_MOVEMENTS
		CMP N_M, 'N'
		JE RIGHT_PROCEED
	PROC_RIGHT:
	INC HORIZONTAL
	RIGHT_PROCEED:
	JMP ITERATE
	D_EXTENS:
		JMP DOWN
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
	CMP AL, 'C'
	JE ATTEMPT_LEFT
	JMP PROC_LEFT
	ATTEMPT_LEFT:		
		CALL BLOCK_MOVEMENTS
		CMP N_M, 'N'
		JE LEFT_PROCEED
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
	CMP AL, 'C'
	JE ATTEMPT_UP
	JMP PROC_UP
	ATTEMPT_UP:		
		CALL BLOCK_MOVEMENTS		
		CMP N_M, 'N'
		JE UP_PROCEED
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
	CMP AL, 'C'
	JE ATTEMPT_DOWN
	JMP PROC_DOWN	
	ATTEMPT_DOWN:		
		CALL BLOCK_MOVEMENTS
		CMP N_M, 'N'
		JE DOWN_PROCEED
	PROC_DOWN:
	INC VERTICAL
	DOWN_PROCEED:
	JMP ITERATE
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
  MOV BP, LSP    
  BLOCK_LOOP:    	
  	CMP DX, [BP]  	;BP SHOULD BE PUSHED ONE MORE TIME SO IT DOESN'T ACCIDENTALLY MESS UP STACK
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
  	JMP EXTENS1
  BLOCK_RIGHT:  
	INC DL 			
  	PUSH DX
  	CALL SET_CURSOR
  	MOV AH, 08H
  	INT 10H  	  	
  	CMP AL, ' '
  	JNE SP_R
  	JE PROC_RIGHT2
  	SP_R:
  	CMP AL, '%'
  	JNE EXIT_EXTENS
  	PROC_RIGHT2:
  	POP BX
  	INC BL   	
  	JMP B_MOV
  BLOCK_LEFT:
  	DEC DL 
  	PUSH DX 
  	CALL SET_CURSOR 
  	MOV AH, 08H
  	INT 10H
  	CMP AL, ' '
  	JNE SP_L
  	JE PROC_LEFT2
  	SP_L:
  	CMP AL, '%'
  	JNE EXIT_EXTENS
  	PROC_LEFT2:
  	POP BX
  	DEC BL
  	JMP B_MOV
  EXTENS1:
  	CMP DIRECTION, 48H
  	JE BLOCK_UP
  	CMP DIRECTION, 50H
  	JE BLOCK_DOWN  
  EXIT_EXTENS:
  	POP BX
  	MOV N_M, 'N'
  	JMP EXIT_BLOCK_LOOP	
  BLOCK_UP:
  	DEC DH
  	PUSH DX 
  	CALL SET_CURSOR
  	MOV AH, 08H
  	INT 10H
  	CMP AL, ' '
  	JNE SP_U
  	JE PROC_UP2
  	SP_U:
  	CMP AL, '%'  	
  	JNE EXIT_EXTENS
  	PROC_UP2:
  	POP BX
  	DEC BH
  	JMP B_MOV
  BLOCK_DOWN:
  	INC DH
  	PUSH DX 
  	CALL SET_CURSOR
  	MOV AH, 08H
  	INT 10H
  	CMP AL, ' '
  	JNE SP_D
  	JE PROC_DOWN2
  	SP_D:
  	CMP AL, '%'
  	JNE EXIT_EXTENS
  	PROC_DOWN2:
  	POP BX
  	INC BH   	
  B_MOV:  	  	
  	INC PLAYER_PUSHNUM  	
  	MOV [BP], BX
  EXIT_BLOCK_LOOP:
  	MOV DH, VERTICAL
  	MOV DL, HORIZONTAL
  	PUSH DX
  	CALL SET_CURSOR  	  	
  	RET  
BLOCK_MOVEMENTS ENDP
;----------------------------------------------------
DRAW_BOXES PROC NEAR
  MOV BP, LSP
  MOV CX, 0			
  MOV CL, TGC 			; SET COUNTER TO NUMBER OF BOXES

  D_B:					; ITERATE OVER ALL THE BOXES
  	add bp, 2
  	MOV DX, [BP]
  	PUSH DX  	
  	CALL SET_CURSOR
  	MOV SI, OFFSET BOX
  	MOV DL, [SI]
  	MOV AH, 02H
  	INT 21H
  LOOP D_B

  RET
DRAW_BOXES ENDP
;----------------------------------------------------
DRAW_GOALS PROC NEAR
  MOV BP, SOP
  MOV CX, 0
  MOV CL, TGC 			;SET COUNTER TO NUMBER OF BOXES
  MOV RGC, 0

  D_G2:					; ITERATE OVER ALL THE GOALS
  	MOV DX, [BP]
  	ADD BP, 2
  	PUSH DX 
  	CALL SET_CURSOR
  	CALL CHECK_GOALS
  LOOP D_G2 
  
  RET
DRAW_GOALS ENDP
;----------------------------------------------------
CHECK_GOALS PROC NEAR
	MOV AH, 08H
	INT 10H
	CMP AL, 'B'
	JE COMPLETE	
	JMP NC
	COMPLETE:
	  INC RGC	  
	  MOV GOAL, 'C'
	  JMP R_CG
	NC:
	  MOV GOAL, '%'
	R_CG:
	  MOV SI, OFFSET GOAL
	  MOV DL, [SI]
	  MOV AH, 02H
	  INT 21H
	RET 
CHECK_GOALS ENDP
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
	MOV 	INPUT, AH

	__LEAVETHIS:
		RET	
GET_KEY ENDP
;---------------------------------------------------
DELAY PROC	NEAR
	mov di, 2 ;lower value faster
	mov si, 2 ;lower value faster
	
	delay2:
		dec di
		nop
		jnz delay2
		dec si
		cmp si,0
		jnz delay2
		RET
DELAY ENDP
;----------------------------------------------------
CHOOSE_MENU PROC NEAR
  CALL INITIAL_CURSOR
  CALL _CLEAR_SCREEN

  MOV DX, OFFSET STARTSCREEN
  PUSH DX
  CALL OPEN_FILE

  MOV AX, ARROW_POS_START
  MOV ARROW_POS, AX
  CHOOSING:
    MOV AX, 0
    MOV BX, 0
    MOV CX, 0
    MOV DX, 0
    MOV DX, ARROW_POS
    PUSH DX
    CALL SET_CURSOR

    MOV AL, 02H
    MOV DL, ARROW
    INT 21H

    GETTING_INP:
      MOV AH, 0
      CALL GET_KEY
      MOV AL, INPUT

      CMP AL, DOWN_ARROW
      JE DOWN_MKEY

      CMP AL, UP_ARROW
      JE UP_MKEY

      CMP AL, ENTER_KEY
      JE CHECK_INST

      JMP GETTING_INP

    GOTO_START:						; LONG RANGE JUMP TO START PUZZLE
   	  JMP START_PUZZLE_LOOPING

    CHECK_INST:
      MOV BX, ARROW_POS_START
      CMP ARROW_POS, BX
      JE GOTO_START

      MOV BX, ARROW_POS_EXIT
      CMP ARROW_POS, BX
      JE NEW_EXIT

      MOV BX, ARROW_POS_HOW
      CMP ARROW_POS, BX
      JE HOW_INST

      NEW_EXIT:
        MOV AH, 4CH
        INT 21H
    DOWN_MKEY:
      MOV AX, ARROW_POS_START
      CMP ARROW_POS, AX ;OFFSET ARROW_POS_START
      JE DOWN_HOW
      MOV AX, ARROW_POS_HOW
      CMP ARROW_POS, AX ;OFFSET ARROW_POS_HOW
      JE DOWN_EXIT
      JMP GETTING_INP

      DOWN_HOW:
        CALL _CLEAR
        MOV AX, ARROW_POS_HOW
        MOV ARROW_POS, AX
        JMP CHOOSING
      DOWN_EXIT:
        CALL _CLEAR
        MOV AX, ARROW_POS_EXIT
        MOV ARROW_POS, AX
        JMP CHOOSING
    UP_MKEY:
      MOV AX, ARROW_POS_EXIT
      CMP ARROW_POS, ax ;OFFSET ARROW_POS_EXIT
      JE UP_HOW
      MOV AX, ARROW_POS_HOW
      CMP ARROW_POS, AX ;OFFSET ARROW_POS_HOW
      JE UP_START
      JMP GETTING_INP

      UP_HOW:
        CALL _CLEAR
        MOV AX, ARROW_POS_HOW
        MOV ARROW_POS, AX
        JMP CHOOSING

      UP_START:
        CALL _CLEAR
        MOV AX, ARROW_POS_START
        MOV ARROW_POS, AX
        JMP CHOOSING

  EXTRA_JMP:
    JMP CHOOSE_MENU
CHOOSE_MENU ENDP
;---------------------------------------------------
HOW_INST PROC NEAR
  CALL INITIAL_CURSOR
  CALL _CLEAR_SCREEN
  MOV DX, OFFSET HOWSCREEN
  PUSH DX
  CALL OPEN_FILE

  MOV AX, HOW_BACK
  MOV ARROW_POS, AX
  CHOOSE:
    MOV DX, ARROW_POS
    PUSH DX
    CALL SET_CURSOR

    MOV AL, 02H
    MOV DL, ARROW
    INT 21H

    CALL GET_KEY
    MOV AL, INPUT

    CMP AL, LEFT_ARROW
    JE LEFT_INST

    CMP AL, RIGHT_ARROW
    JE RIGHT_INST

    CMP AL, ENTER_KEY
    JE CHECK_INST2

    CHECK_INST2:
      MOV AX, HOW_BACK
      CMP ARROW_POS, AX
      JE EXTRA_JMP

      JMP CHOOSE
    LEFT_INST:
      MOV AX, HOW_START
      CMP ARROW_POS, AX
      JE LEFT_BACK
      JMP CHOOSE

      LEFT_BACK:
        CALL _CLEAR
        MOV AX, HOW_BACK
        MOV ARROW_POS, AX
        JMP CHOOSE

    RIGHT_INST:
      MOV AX, HOW_BACK
      CMP ARROW_POS, AX
      JE RIGHT_START
      JMP CHOOSE

      RIGHT_START:
        CALL _CLEAR
        MOV AX, HOW_START
        MOV ARROW_POS, AX
        JMP CHOOSE

HOW_INST ENDP
;---------------------------------------------------
_CLEAR PROC NEAR 					;CLEARS THE ARROW
  MOV AX, 0600H
  MOV BH, 71H
  MOV CX, ARROW_POS
  MOV DX, ARROW_POS
  INT 10H
  RET
_CLEAR ENDP
;---------------------------------------------------
_CLEAR_SCREEN PROC	NEAR
    MOV		AX, 0600H
    MOV		BH, 71H
    MOV 	CX, 0000H
    MOV		DX, 184FH
    INT		10H
    RET
_CLEAR_SCREEN ENDP
;---------------------------------------------------
CODESEG ENDS
END MAIN