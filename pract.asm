TITLE TEST1 (.EXE MODEL / FORMAT)
;--------------------------------------
STACKSEG SEGMENT PARA 'Stack'	
STACKSEG ENDS
;--------------------------------------
DATASEG SEGMENT PARA 'Data'
	total db 1
	total2 db 3
	FILEHANDLE DW ?
	WRITEPATHFILENAME 	DB 	'how_play', 00H
	WRITEFILEHANDLE	  DW ?	
	ERROR1_WSTR    DB 'Error in creating file.$'
 	ERROR2_WSTR    DB 'Error writing in file.$'
	ERROR3_WSTR    DB 'Record not written properly.$'
	ERROR1_RSTR    DB 'Error in opening file.$'
    ERROR2_RSTR    DB 'Error reading from file.$'
    ERROR3_RSTR    DB 'No record read from file.$' 	

    CTR 	DW 	7
    SCORE DB 7 DUP ('0'), '$'
	BES_SCORE DW ?
	RECORD_STR    DB 2000 DUP('$'), '$'  ;length = original length of record + 1 (for $)
	BES_SCORE_STR DB 7 DUP ('0'), '$'
DATASEG ENDS
;--------------------------------------
CODESEG SEGMENT PARA 'Code'
	ASSUME SS:STACKSEG, DS:DATASEG, CS:CODESEG
MAIN PROC FAR
	MOV AX, DATASEG
	MOV DS, AX
	MOV ES, AX

	LEA DX, WRITEPATHFILENAME
	PUSH DX
	CALL OPEN_FILE

	MOV AH, 09H
	MOV DX, OFFSET RECORD_STR
	INT 21H
EXIT:
	MOV AH, 4CH
	INT 21H
MAIN ENDP
;-----------------------------------------------
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
;----------------------------------------------------
WRITE_SCORE PROC NEAR
CREATE_FILE:	;create file		
	MOV AH, 3CH           ;request create file
	MOV CX, 00            ;normal attribute
	LEA DX, WRITEPATHFILENAME  ;load path and file name
	INT 21H
	JC WDISPLAY_ERROR1     ;if there's error in creating file, carry flag = 1, otherwise 0
	MOV WRITEFILEHANDLE, AX	
	MOV AH, 40H           ;request write record
	MOV BX, WRITEFILEHANDLE    ;file handle
	MOV CX, CTR            ;record length
	LEA DX, SCORE    ;address of output area
	INT 21H
	JC WDISPLAY_ERROR2     ;if carry flag = 1, there's error in writing (nothing is written)
	CMP AX, CTR            ;after writing, set AX to size of chars nga na write
	JNE WDISPLAY_ERROR3	
	MOV AH, 3EH           ;request close file
	MOV BX, WRITEFILEHANDLE  ;file handle
	INT 21H
	JMP EX_WRITE
WDISPLAY_ERROR1:
	LEA DX, ERROR1_WSTR	
	JMP WERR_DISPLAY
WDISPLAY_ERROR2:
	LEA DX, ERROR2_WSTR	
	JMP WERR_DISPLAY
WDISPLAY_ERROR3:
	LEA DX, ERROR3_WSTR	
	JMP WERR_DISPLAY
WERR_DISPLAY:
	MOV AH, 09H
	INT 21H
EX_WRITE:
	RET
WRITE_SCORE ENDP
;----------------------------------------------------
GET_BEST_SCORE PROC NEAR
	MOV DX, OFFSET WRITEPATHFILENAME
	PUSH DX
	CALL OPEN_FILE

	CLD               ;clear direction flag (left to right)
    MOV CX, 16        ;initializes CX (counter) to 16 bytes
    LEA DI, BES_SCORE_STR  ;initialize receiving/destination address
    LEA SI, RECORD_STR  ;initialize sending/source address
    REP MOVSB         ;copy MESSAGE1 to MESSAGE2 byte by byte (repeatedly for 16 times)                    
	RET
GET_BEST_SCORE ENDP
;----------------------------------------------------
CONVERT_SCORE_FROM_FILE PROC NEAR
	MOV SI, OFFSET BES_SCORE_STR + 1
	MOV CL, [SI]
	MOV CH, 0	
	ADD SI, CX
	MOV BX, 0
	MOV BP, 1
	MOV DI, OFFSET BES_SCORE_STR + 1
	MOV [DI], AL
	INC CX
rpt:
	MOV AL, [SI]
	SUB AL, 48
	MOV AH, 0
	MUL BP
	ADD BX, AX
	MOV AX, BP
	MOV BP, 10
	MUL BP
	MOV BP, AX
	DEC SI
	LOOP RPT
	RET
CONVERT_SCORE_FROM_FILE ENDP
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
  ; MOV DX, OFFSET RECORD_STR
  ; MOV AH, 09
  ; INT 21H

  ;close file handle
  MOV AH, 3EH           ;request close file
  MOV BX, FILEHANDLE    ;file handle
  INT 21H
  MAIN_EXIT:  
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
;--------------------------------------------
CODESEG ENDS
END MAIN
