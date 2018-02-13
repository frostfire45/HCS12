ONE_MS:         EQU     4000
FIVE_MS:        EQU     20000
TEN_MS:         EQU     40000
FIFTY_US:       EQU     200




REGISTOR:       EQU     PORTK

LCD_REG:        EQU     REGISTOR
INST_REG:       EQU     REGISTOR     




REGBLK:         EQU     $0
#include        C:\Users\don.husky\Documents\GitHub\HCS12\Libs\Reg9s12.h
GETCHAR:        EQU     $EE84 ;MAY HAVE ISSUES
PUTCHAR:        EQU     $EE86
STACK:          EQU     $2000

***********************************************************
                ORG     $1000
RS:             EQU     $01
E:              EQU     $02
TEMP0:          RMB     1
TEMP1:          RMB     1

E_ENABLE        DB      $01
E_DISABLE       DB      $00

RS_ENABLE:      EQU     $01
RS_DISABLE:     EQU     $00

INST_REG_ENAB:  DB      $02
LCD_REG_ENAB:   DB      $03
                
INIT_DISP:      DB      $33
                DB      $32
                DB      $28
                DB      $06
                DB      $0F
                DB      $01
                SWI
***********************************************************

                ORG     $2000
                JSR     WRITE_CMD
                ;JMP     START
;INIT_DISP:

WRITE_CMD:      PSHA
                LDAB    RS_DISABLE
                ORAB    E_ENABLE
                STAB    REGISTOR
                ANDA    #$F0
                LSRA
                LSRA
                ORAA    #$0E
                STAA    INST_REG
                JSR     DELAY_50US
                ;LDAB    E_DISABLE                
                BCLR    INST_REG,E_DISABLE
WRITE_LCD:      
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

DELAY_50US      PSHX
                LDX     #FIFTY_US
                BSR     D_250NS
                PULX
                RTS

D_250NS:        DEX
                INX
                DEX
                BNE     D_250NS
                RTS
START:          LDS     #STACK
                JSR     DELAY_10MS
                JSR     DELAY_10MS
                JSR     INIT_DISP