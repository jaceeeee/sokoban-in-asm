;Reading from a File (p. 311)
TITLE FILE READ (SIMPLFIED .EXE FORMAT)
.MODEL SMALL
;---------------------------------------------
.STACK 32
;---------------------------------------------
.DATA
  INITIAL DW 0100H

  STARTSCREEN  DB 'start.txt', 00H
  HOWSCREEN DB 'how_play.txt', 00H
  FILEHANDLE    DW ?

  ERROR1_STR    DB 'Error in opening file.$'
  ERROR2_STR    DB 'Error reading from file.$'
  ERROR3_STR    DB 'No record read from file.$'
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
;---------------------------------------------
.CODE
MAIN PROC FAR
  MOV AX, @data
  MOV DS, AX

  ;set the cursor initial cursor in the beginning
  ;calling start screen
  ;MOV DX, OFFSET RECORD_STR
  ;CPUSH DX

  PLAY:
    CALL CHOOSE_MENU

EXIT:
  MOV AH, 4CH
  INT 21H
MAIN ENDP
;---------------------------------------------------
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
		MOV	AH, 10H		;get input	MOV AH, 10H; INT 16H
		INT	16H

		MOV	INPUT, AH
    RET
_GET_KEY 	ENDP

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
      MOV BX, ARROW_POS_EXIT
      CMP ARROW_POS, BX
      JE NEW_EXIT

      MOV BX, ARROW_POS_HOW
      CMP ARROW_POS, BX
      JE HOW_INST

      NEW_EXIT:
        MOV AH, 4CH
        INT 21H
    DOWN:
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
    UP:
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

    CALL _GET_KEY
    MOV AL, INPUT

    CMP AL, LEFT_ARROW
    JE LEFT

    CMP AL, RIGHT_ARROW
    JE RIGHT

    CMP AL, ENTER_KEY
    JE CHECK_INST2

    CHECK_INST2:
      MOV AX, HOW_BACK
      CMP ARROW_POS, AX
      JE EXTRA_JMP

      JMP CHOOSE
    LEFT:
      MOV AX, HOW_START
      CMP ARROW_POS, AX
      JE LEFT_BACK
      JMP CHOOSE

      LEFT_BACK:
        CALL _CLEAR
        MOV AX, HOW_BACK
        MOV ARROW_POS, AX
        JMP CHOOSE

    RIGHT:
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
;--------------------------------------------------
_CLEAR PROC NEAR ;CLEARS THE ARROW
  MOV AX, 0600H
  MOV BH, 71H
  MOV CX, ARROW_POS
  MOV DX, ARROW_POS
  INT 10H
  RET
_CLEAR ENDP
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
