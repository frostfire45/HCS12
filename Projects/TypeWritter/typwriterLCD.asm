ONE_MS:     EQU     4000
FIVE_MS:    EQU     20000
TEN_MS:     EQU     40000
FIFTY_MS:   EQU     200

DB0:            EQU     $01   ;PIN 8 DATA BUS LINE 0
DB1:            EQU     $02   ;PIN 7 DATA BUS LINE 1

LCD:            EQU     PORTK
LCD_REG:        EQU     LCD,DB1
;LCD_RS:        EQU     PORTK
;LCD_EN:        EQU     PORTK

REGBLK:         EQU     $0
#include        Reg9s12.h
GETCHAR:        EQU     $EE84 ;MAY HAVE ISSUES
PUTCHAR:        EQU     $EE86
STACK:          EQU     $2000

*****************************************************************
*
*****************************************************************
                ORG     $1000
PKIMG:          RMB     1
TEMP1:          RMB     1

LCDimg:         EQU     PKIMG
LCD_RSimg:      EQU     PKIMG
LCD_ENimg:      EQU     PKIMG

INIT_DISP:      FCB     12 ;NUMBER OF ENTRIES FOR A 4 BIT UPLOAD
                FCB     $30,$30 ;$33_byte EXCUTION TWICE
                FCB     $30,$20 ;$32_byte
                FCB     $20,$80 ;28_byte
                FCB     $00,$60 ;06_byte
                FCB     $00,$F0 ;0C_byte
                FCB     $00,$10 ;01_byte
********************************************************************
*
*******************************************************************
                ORG     $2000
                JMP     START

LCD_INIT:       LDAA    #$FF
                STAA    DDRK    ;SET K TO OUTPUT
                CLRA
                STAA    PKIMG
                STAA    PORTK
                LDX     #INIT_DISP                
                JSR     SEL_INST                
                LDAB    0,X
                INX
ONEXT:          LDAA    0,X
                JSR     NibWRITE
                INX
                JSR     DELAY_5MS
                DECB
                BNE     ONEXT
                PULB
                RTS

NibWRITE:       ANDA    #$F0
                LSRA
                LSRA
                STAA    TEMP1
                LDAA    LCDimg
                ANDA    #$03
                ORAA    TEMP1
                STAA    LCDimg
                STAA    LCD
                BSR     ENABLE_PULSE
                RTS

ByteWRITE:      PSHX
                PSHA
                ANDA    #$F0
                LSRA
                LSRA
                STAA    TEMP1
                LDAA    LCDimg
                ANDA    #$03
                ORAA    TEMP1
                STAA    LCDimg
                STAA    LCD
                BSR     ENABLE_PULSE
                PULA
                ASLA
                ASLA
                STAA    TEMP1
                LDAA    LCDimg
                ANDA    #$03
                ORAA    TEMP1
                STAA    LCDimg
                STAA    LCD
                BSR     ENABLE_PULSE
                JSR     DELAY_50MS
                PULX
                RTS

TOP_WRITER:     JSR     SEL_INST
                LDAA    #$80
                ;JSR     ByteWRITE
ENABLE_PULSE:   LDAA    LCD_ENimg
                ;ORAA    #ENABLE
                STAA    LCD_ENimg
                ;STAA    LCD_EN
                
                LDAA    LCD_ENimg
                ;ANDA    #NOT_ENABLE
                STAA    LCD_ENimg
                ;STAA    LCD_EN
                
                RTS
SEL_DATA:       PSHA
                LDAA    LCD_RSimg
                ;ORAA    #REG_SEL
                BRA     SEL_INS

SEL_INST:       PSHA
                ;BCLR LCD_RSimg REG_SEL
                LDAA    LCD_RSimg
                ;ANDA    #NOT_REG_SEL
SEL_INS:        STAA    LCD_RSimg
                ;STAA    LCD_RS
                PULA
                RTS

DELAY_5MS:      PSHX
                LDX     #FIVE_MS
                BSR     D_250NS
                PULX
                RTS

DELAY_10MS:     PSHX
                LDX     #TEN_MS
                BSR     D_250NS
                PULX
                RTS

DELAY_50MS      PSHX
                LDX     #FIFTY_MS
                BSR     D_250NS
                PULX
                RTS

D_250NS:        
                DEX
                INX
                DEX
                BNE     D_250NS
                RTS

START:          LDS     #STACK
                JSR     DELAY_10MS
                JSR     DELAY_10MS
                JSR     LCD_INIT

                JSR     SEL_INST
                LDAA    #$C0
                JSR     ByteWRITE
                JSR     SEL_DATA
                JSR     DELAY_5MS
                
                ;LDX     #NO_MESSAGE
                ;LDAB    #16
                ;JSR     TOP_WRITER
                SWI
NO_MESSAGE:     FCC     "________________"                