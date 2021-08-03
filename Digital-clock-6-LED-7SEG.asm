GIO EQU 7FH ;GIAY
    PHUT EQU 7EH ;PHUT
    GIAY EQU 7DH ;GIO
    
    SCL BIT P3.6 ;CHAN SCL NOI DEN ROM
    SDA BIT P3.7 ;CHAN SDA NOI DEN ROM

    W1307 EQU 0D0H ;HANG SO VIET VAO DS1307
    R1307 EQU 0D1H ;HANG S0 DOC    TU DS1307

    G  BIT P2.0 ;NUT NHAN TANG GIO
    PH  BIT P2.1 ;NUT NHAN TANG PHUT
    GI  BIT P2.2 ;NUT NHAN TANG GIAY

        
    ORG 0 ;DIEM NHAP CUA RESET
;====================
MAIN: ;CHUONG TRINH CHINH
    ACALL KHOIDONGRTC ;KHOI DONG RTC
MAIN1: 
    ACALL DOCTG ;DOC THOI GIAN TU RTC
    ACALL HIENTHI ;HIEN THI QUET LED 7 DOAN
    CALL NN ;GOI CHUONG TRINH NUT NHAN CHINH THOI GIAN
    SJMP  MAIN1 ;LAP LAI CHUONG TRINH
;====================
NN: ;CHUONG TRINH NUT NHAN CHINH THOI GIAN
    JB 2FH.0,XLKNN ;
    JB GI,XLNN1
    SETB 2FH.0
    CALL TGIAY ;GOI CHUONG TRINH TANG GIAY
    CALL NAPTG
    JMP TXLNN
XLNN1:
    JB PH,XLNN2
    SETB 2FH.0
    CALL TP
    CALL NAPTG ;GOI CHUONG TRINH TANG PHUT
    JMP TXLNN
XLNN2:
    JB G,XLKNN
    SETB 2FH.0
    CALL TG
    CALL NAPTG ;GOI CHUONG TRINH TANG GIO
    JMP TXLNN
XLKNN: ;XU LY KHONG NHAN NUT
    JNB G,TXLNN ;THOAT KHI VAN CON GIU PHIM
    JNB PH,TXLNN ;THOAT KHI VAN CON GIU PHIM
    JNB GI,TXLNN ;THOAT KHI VAN CON GIU PHIM
    CLR 2FH.0 ;CHO PHEP PHIM NHAN TRO LAI KHI KHONG CON PHIM NAO GIU
TXLNN: ;THOAT XU LY NUT NHAN
    RET
;=====================
TGIAY: ;TANG GIAY
    MOV A,GIAY ;NAP GIAY VAO A
    ADD A,#1 ;CONG THANH GHI A THEM 1
    DA A ;HIEU CHINH THAP PHAN THANH GHI A
    CJNE A,#60H,TGIAY1
    MOV A,#00H ;GIOI HAN 00 - 59
TGIAY1:
    MOV GIAY,A
    RET
;====================
TP: ;TANG PHUT
    MOV A,PHUT
    ADD A,#1
    DA A
    CJNE A,#60H,TP1
    MOV A,#00H ;GIOI HAN 00 - 59
TP1:
    MOV PHUT,A
    RET
;====================
TG:
    MOV A,GIO
    ADD A,#1
    DA A
    CJNE A,#24H,TG3
    MOV A,#00H ;GIOI HAN 00 - 23
TG3:
    MOV GIO,A
    RET
;====================
;QUET HIEN THI LAN LUOT TUNG LED 7 DOAN
;TAI 1 THOI DIEM CHI SANG 1 LED
;==========================
HIENTHI:
    MOV A,GIO ;NAP GIO VAO A 
    SWAP A ;HOAN DOI CAO THAP THANH GHI A
    ANL A,#0FH ;XOA BO 4 BIT CAO
    CALL BCD7 ;DOI MA BCD SANG MA 7 DOAN
    MOV P0,A ;XUAT MA 7 DOAN RA PORT 0
    MOV P1,#11111110B ;XUAT MA QUET LET HANG CHUC GIO
    CALL TRELED ;TOA THOI GIAN TRE QUET LED
    MOV P1,#0FFH ;XOA PORT QUET LED
    
    MOV A,GIO
    ANL A,#0FH
    CALL BCD7
    MOV P0,A
    MOV P1,#11111101B
    CALL TRELED
    MOV P1,#0FFH

    MOV A,PHUT
    SWAP A
    ANL A,#0FH
    CALL BCD7
    MOV P0,A
    MOV P1,#11111011B
    CALL TRELED
    MOV P1,#0FFH

    MOV A,PHUT
    ANL A,#0FH
    CALL BCD7
    MOV P0,A
    MOV P1,#11110111B
    CALL TRELED
    MOV P1,#0FFH

    MOV A,GIAY
    SWAP A
    ANL A,#0FH
    CALL BCD7
    MOV P0,A
    MOV P1,#11101111B
    CALL TRELED
    MOV P1,#0FFH

    MOV A,GIAY
    ANL A,#0FH
    CALL BCD7
    MOV P0,A
    MOV P1,#11011111B
    CALL TRELED
    MOV P1,#0FFH

    RET 
;===============================
BCD7: ;DOI MA BCD SANG MA 7 DOAN 
    MOV DPTR,#MA7DOAN
    MOVC A,@A+DPTR
    RET
MA7DOAN: ;BANG MA 7 DOAN
    DB 0C0H,0F9H,0A4H,0B0H,99H
    ;   0    1    2    3    4 
    DB 92H,82H,0F8H,80H,90H,0FFH 
    ;   5   6   7    8   9 
    DB 0C6H
    ;    C 
;================================
;=======================    
TRELED:    ;TAO TRE CHO LED KHI QUET
    PUSH 0
    PUSH 1
    MOV R1,#2
TL:
    MOV R0,#250
    DJNZ R0,$
    DJNZ R1,TL ; uS
    POP 1
    POP 0
    RET
;============================
;CAC CTC GIAO TIEP DS1307
;============================
KHOIDONGRTC: ;KHOI DONG RTC
            ;XOA BIT THU 7 BYTE 0 TRONG TRC KHONG LAM THAY DOI THOI GIAN
;GHI DIA CHI VAO RTC
    CALL STARTB
    MOV  A,#W1307
    CALL SBYTE
       MOV  A,#00H
    CALL SBYTE
    CALL STOPB
;DOC BYTE DAU TIEN
    CALL STARTB
    MOV  A,#R1307
    CALL SBYTE
    CALL RBYTE
    CLR  ACC.7 ;XOA BIT DAO DONG ( CHO PHEP TRC HOAT DONG )
    MOV  R1,A
    CALL STOPB
;GHI NGUOC VAO RTC
    CALL STARTB
    MOV  A,#W1307
    CALL SBYTE
    MOV     A,#00H
    CALL SBYTE
    MOV  A,R1
    CALL SBYTE
    CALL STOPB

    RET
;==================
NAPTG: ;NAP THOI GIAN VAO RTC
    CALL STARTB    ;GOI STATR BIT
    MOV   A,#W1307 ;NAP CHE DO GHI VAO RTC
    CALL SBYTE ;GHI BYTE VAO TRC
    MOV      A,#00H ;NAP DIA CHI VAO RTC
    CALL SBYTE
    MOV   A,GIAY ;NAP GIAY VAO RTC
    CALL SBYTE ;GHI BYTE VAO TRC TU DONG TANG DIA CHI
    MOV      A,PHUT ;NAP PHUT VAO RCT
    CALL SBYTE
    MOV      A,GIO
    CALL SBYTE
    CALL STOPB ;GOI STOP BIT
    RET
;==================
;CTC DOC CAC GIA TRI THOI GIAN
;============================
DOCTG: ;DOC THOI GIAN
    PUSH 4
    MOV    R4,#0 ;NAP DIA CHI 0
    CALL DOCBYTE ;DOC BYTE THEO DIA CHI
    MOV    GIAY,A 

    MOV    R4,#1
    CALL DOCBYTE
    MOV    PHUT,A

    MOV    R4,#2
    CALL DOCBYTE
     MOV    GIO,A

    POP 4
    RET
;========================
;BIT START
;==============
STARTB:
    SETB SDA
    SETB SCL
    CLR SDA
    CLR SCL
    RET
;===============
;BIT STOP
;===============
STOPB:                   
    CLR    SDA
    SETB SCL
    NOP
    SETB SDA
    RET
;===============
ACKB:
    SETB SDA
    SETB SCL
    CLR    SCL
    RET
;=======================
;CTC GUI 1 BYTE DU LIEU
;=======================
SBYTE:
    PUSH 7
    MOV R7,#08
SB:
    CLR SCL
    JB ACC.7,ACC7
    CLR SDA
    SJMP FINISH
ACC7:
    SETB SDA
FINISH:
    SETB SCL
    CLR SCL
    RL A
    DJNZ R7,SB
    SETB SDA
    SETB SCL
    CLR SCL
    POP 7
    RET
;=======================
;CHUONG TRINH  DOC 1 BYTE DU LIEU        
;=======================
RBYTE:
    PUSH 7                     
    MOV R7,#8
RB:
    SETB SCL
    MOV C,SDA
    CLR SCL
    RLC A
    DJNZ R7,RB
    ACALL ACKB
    POP 7
    RET
;=======================
DOCBYTE:
    CALL STARTB
    MOV     A,#W1307
    CALL SBYTE
    MOV     A,R4
    CALL SBYTE
    CALL STOPB
    CALL STARTB
    MOV A,#R1307
    CALL SBYTE
    CALL RBYTE
    CALL STOPB
    RET
;====================
       END