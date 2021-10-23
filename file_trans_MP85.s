;7CH PORTA Bit
;7 OUT
;6 OUT
;5 OUT
;4 OUT
;3 OUT
;2 OUT FLG            CN2外側11     7
;1 OUT
;0 OUT 送信データ        CN2外側12     6

;7DH PORTB Bit
;7 IN
;6 IN
;5 IN
;4 IN
;3 IN
;2 IN CHK             CN2外側7      9
;1 IN
;0 IN 受信データ         CN2外側4      8
;+5V                  CN2内側8
;GND                  CN2内側7

;CN2
;	  外側	内側
;1	
;2	PC1		GND
;3			GND
;4	PB0		GND
;5	PB1		GND
;6	PC2		GND
;7	PB2		GND
;8	PC0
;9	PA6		PA7
;10	PA4		PA5
;11	PA2		PA3
;12	PA0		PA1
;13			PB3

FNAME	EQU		7F34h
SADRS	EQU		7F36h
EADRS	EQU		7F4Dh
EXEAD	EQU		7F1Eh

;		ORG		0168H

;		DW		LOAD_START
;		DW		SAVE_START

        ORG		1000H

LOAD_START:
		JP		SDLOAD
SAVE_START
		JP		SDSAVE

;受信ヘッダ情報をセットし、SDカードからLOAD実行
;FNAME <- 0000H～FFFFHを入力。
;         ファイルネームは「xxxx.BTK」となる。
SDLOAD:	CALL	INIT
		LD		A,81H
		CALL	SNDBYTE    ;LOADコマンド81Hを送信
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		LD		HL,FNAME   ;FNAME送信
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		CALL	HDRCV      ;ヘッダ情報受信
		CALL	DBRCV      ;データ受信
		LD		A,(SADRS+1)
		LD		(EXEAD+1),A
		LD		A,(SADRS)
		LD		(EXEAD),A
		JP		SDSV3      ;LOAD情報表示

;送信ヘッダ情報をセットし、SDカードへSAVE実行。SAVE範囲指定
;SADRS <- 保存開始アドレス(LED ADRS 表示)
;EADRS <- 保存終了アドレス(LED DATA 表示)
;FNAME <- 0000H～FFFFHを入力。
;         ファイルネームは「xxxx.BTK」となる。

SDSAVE: CALL	INIT
		LD		A,80H
		CALL	SNDBYTE    ;SAVEコマンド80Hを送信
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		CALL	HDSEND     ;ヘッダ情報送信
		CALL	RCVBYTE    ;状態取得(00H=OK)
		AND		A          ;00以外ならERROR
		JP		NZ,SVERR
		CALL	DBSEND     ;データ送信
SDSV3:	
		CALL	0553h
		DB      08h,00h,00h,00h,5Eh,54h,79h  ;'End   '
		JP		0089H
SVERR:
		CALL	0553h
		DB      02h,00h,50h,5Ch,50h,50h,79h  ;'Error '
		JP		0089H
MONRET:	JP		0089h

;ヘッダ送信
HDSEND:	LD		B,04H
		LD		HL,FNAME   ;FNAME送信、SADRS送信
HDSD1:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DEC		B
		JP		NZ,HDSD1
		LD		HL,EADRS   ;EADRS送信
		LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		LD		A,(HL)
		CALL	SNDBYTE
		RET

;データ送信
;SADRSからEADRSまでを送信
DBSEND:	LD		HL,(EADRS)
		EX		DE,HL
		LD		HL,(SADRS)
DBSLOP:	LD		A,(HL)
		CALL	SNDBYTE
		LD		A,H
		CP		D
		JP		NZ,DBSLP1
		LD		A,L
		CP		E
		JP		Z,DBSLP2   ;HL = DE までLOOP
DBSLP1:	INC		HL
		JP		DBSLOP
DBSLP2:	RET

;ヘッダ受信
HDRCV:	LD		HL,SADRS+1 ;SADRS取得
		CALL	RCVBYTE
		LD		(HL),A
		DEC		HL
		CALL	RCVBYTE
		LD		(HL),A
		LD		HL,EADRS+1 ;EADRS取得
		CALL	RCVBYTE
		LD		(HL),A
		DEC		HL
		CALL	RCVBYTE
		LD		(HL),A
		RET

;データ受信
DBRCV:	LD		HL,(EADRS)
		EX		DE,HL
		LD		HL,(SADRS)
DBRLOP:	CALL	RCVBYTE
		LD		(HL),A
		LD		A,H
		CP		D
		JP		NZ,DBRLP1
		LD		A,L
		CP		E
		JP		Z,DBRLP2   ;HL = DE までLOOP
DBRLP1:	INC		HL
		JP		DBRLOP
DBRLP2:	RET
		
;1BYTE送信
;Aレジスタの内容を下位BITから送信
SNDBYTE:PUSH 	BC
		LD		B,08H
SBLOP1:	RRCA               ;最下位BITをCフラグへ
		PUSH	AF
		JP		NC,SBRES   ;Cフラグ = 0
SBSET:	LD		A,01H      ;Cフラグ = 1
		JP		SBSND
SBRES:	LD		A,00H
SBSND:	CALL	SND1BIT    ;1BIT送信
		POP		AF
		DEC		B
		JP		NZ,SBLOP1  ;8BIT分LOOP
		POP		BC
		RET
		
;1BIT送信
;Aレジスタ(00Hor01H)を送信する
SND1BIT:
		OUT		(7CH),A    ;PORTA BIT0 <- A(00H or 01H)
		OR		04H
		OUT		(7CH),A    ;PORTA BIT2 <- 1
		CALL	F1CHK      ;PORTB BIT2が1になるまでLOOP
		AND		01H
		OUT		(7CH),A    ;PORTA BIT2 <- 0
		CALL	F2CHK
		RET
		
;1BYTE受信
;受信DATAをAレジスタにセットしてリターン
RCVBYTE:PUSH 	BC
		LD		C,00H
		LD		B,08H
RBLOP1:	CALL	RCV1BIT    ;1BIT受信
		AND		A          ;A=0?
		LD		A,C
		JP		Z,RBRES    ;0
RBSET:	INC		A          ;1
RBRES:	RRCA               ;Aレジスタ右SHIFT
		LD		C,A
		DEC		B
		JP		NZ,RBLOP1  ;8BIT分LOOP
		LD		A,C        ;受信DATAをAレジスタへ
		POP		BC
		RET
		
;1BIT受信
;受信BITをAレジスタに保存してリターン
RCV1BIT:CALL	F1CHK      ;PORTB BIT2が1になるまでLOOP
		OR		04H
		OUT		(7CH),A    ;PORTA BIT2 <- 1
		IN		A,(7DH)    ;PORTB BIT0
		AND		01H
		PUSH	AF
		CALL	F2CHK      ;PORTB BIT2が0になるまでLOOP
		AND		01H
		OUT		(7CH),A    ;PORTA BIT2 <- 0
		POP		AF         ;受信DATAセット
		RET
		
;BUSYをCHECK(1)
; 7DH BIT2が1になるまでLOP
F1CHK:	IN		A,(7DH)
		AND		04H        ;PORTB BIT2 = 1?
		JP		Z,F1CHK
		RET

;BUSYをCHECK(0)
; 7DH BIT2が0になるまでLOOP
F2CHK:	IN		A,(7DH)
		AND		04H        ;PORTB BIT2 = 0?
		JP		NZ,F2CHK
		RET

;8255初期化
;PORTA下位BITをOUTPUT、PORTB下位BITをINPUT
INIT:	
;出力BITをリセット(PORTA)
INIT2:	LD		A,00H      ;PORTA <- 0
		OUT		(7CH),A
		RET
		END
