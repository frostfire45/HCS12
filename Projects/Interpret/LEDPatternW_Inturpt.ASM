*******************************************************************************
*                                Inturpt LED Display
*******************************************************************************
* Overviuew: This program will use inturpts to display different patterns,
*            which will be based on the push buttons 0-4.
*
*******************************************************************************

#include C:\Dragon12P\Examples\reg9s12.h
*******************************************************************************
*       Program Main
*******************************************************************************
*       IRQAD: is the Memory location in which is used to initiate port H
*       Hndler: The memory locaton of the inturpt vectors
*       PIEH: The setting to enable port H to allow ph0 - ph3
*       DDRH: Sets H to allow them to act like inputs for the inturputs
*******************************************************************************
        ORG     $1000
        MOVW    #HNDLER,IRQAD
        CLR     COUNT           ; Initializing Count
        LDAA    #$FF            ; Places one's in the accumlator
        STAA    DDRB            ; make port B output, Using Acumalator A
        STAA    DDRP            ; Making port P output
        STAA    PTP             ; Makes Port P Data Registry Port
        BSET    DDRJ,$02        ; connect port B to LEDs
        BCLR    PTJ,$02         ; Makes Port J a data Register port
        CLR     DDRH            ; enable PORT H AN INPUT PORT, ph0-ph3
        BSET    PIEH,$0F
        BSET    PIFH,$0F
        CLI                     ; Enables Global Inturpts

FOREVER BRA     FOREVER         ; Holds the program

********************************************************************************
*               Inturpt Handler
********************************************************************************
*       Uses ph0 - ph3 and determines which patteren to be called              *
*       Inturpts: ph0 is Counter  will count up in binary                      *
*                 ph1 is n_rider  shows LEDs                                   *
*                 ph2 is scrolls LED to the right                              *
*                 ph3 scrolls the leds 1 at a time from left to right          *
********************************************************************************

HNDLER  BRSET   PIFH,$01,FIRST
        BRSET   PIFH,$02,SECND
        BRSET   PIFH,$04,THIRD
        BRSET   PIFH,$08,FOURTH
        RTI

FIRST   BSET    PIFH,$01
        MOVW    #COUNTER,7,SP   ; Sets the pattern memory location
        RTI
        
SECND   BSET    PIFH,#02
        MOVW    #N_RIDER,7,SP   ; Sets the pattern memory location
        RTI
        
THIRD   BSET    PIFH,#04
        MOVW    #SCROLL,7,SP    ; Sets the pattern memory location
        RTI
        
FOURTH  BSET    PIFH,#08
        MOVW    #LRSCRL,7,SP    ; Sets teh pattern memory locaton
        RTI
********************************************************************************
*               Patters to be displayed                                        *
********************************************************************************
COUNTER LDAA    $0
C_CONT  INCA
        STAA    PORTB
        JSR     D_100MS
        BRA     C_CONT

***************************************
*          N_Rider Pattern            *
***************************************
N_RIDER ldaa   	#1
LOOP0   LDX	#PAT
LOOP    MOVB    1,X+,PORTB
        JSR     D_100MS
        CPX     #PAT+5
        BLS     LOOP                ; delay between counts
        JMP     LOOP0
***************************************
*          Scroll Pattern             *
***************************************
SCROLL  LDX     #SCR              ; 1,2,4,8,16,32,64,128
C_SCRL  LDAA    1,X+
        STAA    PORTB
        JSR     D_100MS
        CMPA    #0
        BHI     C_SCRL
        JMP     SCROLL
****************************************
*          Scroll Left to Right        *
****************************************
LRSCRL  LDX     #SCR              ; 1,2,4,8,16,32,64,128
LRUP    LDAA    1,X+
        STAA    PORTB
        JSR     D_100MS
        CPX     #SCR+6
        BLE     LRUP
LRDWN   LDAA    1,X-
        STAA    PORTB
        JSR     D_100MS
        CPX     #SCR
        BHI     LRDWN
        JMP     LRSCRL

********************************************************************************
*                       JSR D_100MS                                            *
********************************************************************************
*       This subroutine will delay the program by 100 ms                       *
********************************************************************************
D_100ms
DLY1    LDY     #6000        ; 6000 x 4 = 24,000 cycles = 1ms
DLY     DEY                ; 1 cycle
        BNE     DLY        ; 3 cycles
        DBNE    B,DLY1	 ; continue till it is 100 ms
        RTS
********************************************************************************


COUNT   RMB     1
PULSE   RMB     1
IRQAD   EQU     $3E4C
PAT     DB      $81,$42,$24,$18,$24,$42
SCR     DB      $80,$40,$20,$10,$8,$4,$2,$1