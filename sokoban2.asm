;Reading from a File (p. 311)
TITLE FILE READ (SIMPLFIED .EXE FORMAT)
.MODEL SMALL
;---------------------------------------------
.STACK 32
;---------------------------------------------
.DATA
  INITIAL DW 0100H

  PATHFILENAME  DB 'testing.txt', 00H
  FILEHANDLE    DW ?

  ERROR1_STR    DB 'Error in opening file.$'
  ERROR2_STR    DB 'Error reading from file.$'
  ERROR3_STR    DB 'No record read from file.$'
  RECORD_STR    DB 1000 DUP('$'), '$'  ;length = original length of record + 1 (for $)

  ARROW DB 175, '$'
  ARROW_POS_START DW 0A1EH
  ARROW_POS_HOW DW 0C1CH
  ARROW_POS_EXIT DW 0E1EH
  ARROW_POS DW 0A1EH

  ERASE DB ' ', '$'
  ENTER_KEY DB 0AH
  UP_ARROW DB 48H
  DOWN_ARROW DB 50H
  INPUT DB ?
;---------------------------------------------
.CODE
MAIN PROC FAR
  MOV AX, @data
  MOV DS, AX

  ;set the cursor initial cursor in the beginning
  MOV DX, OFFSET INITIAL
  PUSH DX
  CALL SET_CURSOR

  CALL _CLEAR_SCREEN
  CALL OPEN_FILE

  PLAY:
    CALL CHOOSE_MENU

EXIT:
  MOV AH, 4CH
  INT 21H
MAIN ENDP
;----------------------------------------------------
OPEN_FILE PROC NEAR
  MOV AH, 3DH           ;requst open file
  MOV AL, 00            ;read only; 01 (write only); 10 (read/write)
  MOV DX, OFFSET PATHFILENAME
  INT 21H
  JC DISPLAY_ERROR1
  MOV FILEHANDLE, AX

  ;read file
  MOV AH, 3FH           ;request read record
  MOV BX, FILEHANDLE    ;file handle
  MOV CX, 1000          ;record length
  MOV DX, OFFSET RECORD_STR    ;address of input area
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
  MOV DX, OFFSET ERROR1_STR
  MOV AH, 09
  INT 21H

  JMP EXIT

  DISPLAY_ERROR2:
  MOV DX, OFFSET ERROR2_STR
  MOV AH, 09
  INT 21H

  JMP EXIT

  DISPLAY_ERROR3:
  MOV DX, OFFSET ERROR3_STR
  MOV AH, 09
  INT 21H

  JMP EXIT
OPEN_FILE ENDP
;----------------------------------------------------
_GET_KEY	PROC	NEAR
		MOV	AH, 01H		;check for input
		INT	16H

    JZ	GETTING_INP

		MOV	AH, 00H		;get input	MOV AH, 10H; INT 16H
		INT	16H

		MOV	INPUT, AH
    RET
_GET_KEY 	ENDP

;----------------------------------------------------
CHOOSE_MENU PROC NEAR
  CHOOSING:
    CALL _DELAY
    MOV DX, ARROW_POS
    PUSH DX
    CALL SET_CURSOR

    MOV AH, 09H
    MOV DX, OFFSET ARROW
    INT 21H

    GETTING_INP:
      MOV AH, 0
      CALL _GET_KEY
      MOV AL, INPUT

      CMP AL, DOWN_ARROW
      JE DOWN

      CMP AL, UP_ARROW
      JE UP

      CMP AL, ENTER_KEY
      JE CHECK_INST

      JMP GETTING_INP

    CHECK_INST:
      ; MOV BL, 1EH
      ; MOV AL, 02
      ; MOV DL, ARROW
      ; INT 21h
      ; MOV AH, 03H
      ; INT 10H
      ; DEC DL

      MOV BX, ARROW_POS_EXIT
      CMP ARROW_POS, DX
      JE NEW_EXIT

      NEW_EXIT:
        MOV AH, 4CH
        INT 21H
    DOWN:
      CMP ARROW_POS, 0A1EH ;OFFSET ARROW_POS_START
      JE DOWN_HOW
      CMP ARROW_POS, 0C1CH ;OFFSET ARROW_POS_HOW
      JE DOWN_EXIT

      DOWN_HOW:
        MOV DX, ARROW_POS_START
        PUSH DX 
        CALL SET_CURSOR
        MOV AH, 02H
        MOV DL, ' '
        INT 09H
        MOV AX, ARROW_POS_HOW
        MOV ARROW_POS, AX
        JMP CLEAR

      DOWN_EXIT:
        MOV DX, ARROW_POS_HOW 
        PUSH DX 
        CALL SET_CURSOR
        MOV AH, 02H
        MOV DL, ' '
        INT 09H
        MOV AX, ARROW_POS_EXIT
        MOV ARROW_POS, AX
        JMP CLEAR

    UP:
      CMP ARROW_POS, 0E1EH ;OFFSET ARROW_POS_EXIT
      JE UP_HOW

      CMP ARROW_POS, 0C1CH ;OFFSET ARROW_POS_HOW
      JE UP_START

      UP_HOW:
        MOV DX, ARROW_POS_EXIT
        PUSH DX 
        CALL SET_CURSOR
        MOV AH, 02H
        MOV DL, ' '
        INT 09H
        MOV AX, ARROW_POS_HOW
        MOV ARROW_POS, AX
        JMP CLEAR

      UP_START:
        MOV DX, ARROW_POS_HOW 
        PUSH DX 
        CALL SET_CURSOR
        MOV AH, 02H
        MOV DL, ' '
        INT 09H
        MOV AX, ARROW_POS_START
        MOV ARROW_POS, AX
        JMP CLEAR

      CLEAR:

      JMP CHOOSING
  RET
CHOOSE_MENU ENDP
;----------------------------------------------------
_DELAY PROC	NEAR
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
_DELAY ENDP
;----------------------------------------------------
SET_CURSOR PROC NEAR
  POP BX
  POP DX
  PUSH BX
  MOV AH, 02H   ;function code to request for set cursor
  MOV BH, 00    ;page number 0, i.e. current screen
  INT 10H
  RET
SET_CURSOR ENDP
;----------------------------------------------------
_CLEAR_SCREEN PROC	NEAR
    MOV		AX, 0600H
    MOV		BH, 71H
    MOV 	CX, 0000H
    MOV		DX, 184FH
    INT		10H
    RET
_CLEAR_SCREEN ENDP

END MAIN
