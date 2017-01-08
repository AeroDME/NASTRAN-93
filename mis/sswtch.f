      SUBROUTINE SSWTCH (NBIT,L)        
C        
C     PURPOSE OF THIS ROUTINE IS TO SET L = 1 IF SENSE SWITCH BIT IS    
C     ON, OTHERWISE L = 0.        
C        
C     SENSE SWITCH DEFINITION        
C      1 = DUMP CORE WHEN SUBROUTINE DUMP OR PDUMP(NO ARGUMENTS) IS     
C          CALLED        
C      2 = DUMP FIAT TABLE AFTER ALLOCATION        
C      3 = DUMP DATA POOL DICTIONARY AFTER ALLOCATION        
C      4 = DUMP OSCAR FILE AT END OF XGPI        
C      5 = CONSOLE MESSAGE DESIRED (BEGIN)        
C      6 = CONSOLE MESSAGE DESIRED (END)        
C      7 = EIGENVALUE EXTRACTION DIAGNOSTICS        
C          (DETERMINANT AND INVERSE POWER)        
C      8 = TRACES NPTP ON 1108        
C      9 = TURNS ON PRINTER PLOTTER FOR ANY XYPLOT REQUESTS        
C     10 = USES ALTERNATE ALGORITHUM FOR NON LINEAR LOADS SEE SPR 153   
C     11 = ACTIVE ROW AND COLUMN TIME PRINTS        
C     12 = CONPLEX EIGENVALUE EXTRACTION DIAGNOSTICS        
C          (INVERSE POWER)        
C     28 = PUNCHES OUT LINK SPECIFICATION TABLE - DECK XBSBD        
C     29 = PROCESS LINK SPECIFICATION UPDATE DECK        
C     30 = PUNCHES OUT ALTERS TO XSEM-S FOR SWITCHES 1-15        
C     31 = PRINT LINK SPECIFICATION TABLE        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF        
      INTEGER         SWITCH,ANDF,RSHIFT,RENTER        
      COMMON /SYSTEM/ XSYS(78),SWITCH(3)        
      COMMON /XLINK / LXLINK,MAXLNK        
      COMMON /SEM   / DUMMY(3),NS(1)        
      DATA    RENTER/ 4HREEN /        
C        
      L = 0        
      IF (IRET .EQ.  1) RETURN        
      IF (NBIT .GT. 31) GO TO 10        
      IF (ANDF(LSHIFT(1,NBIT-1),SWITCH(1)) .NE. 0) L = 1        
      RETURN        
C        
   10 NBIT2 = NBIT - 31        
      IF (ANDF(LSHIFT(1,NBIT2-1),SWITCH(2)) .NE. 0) L = 1        
      RETURN        
C        
C        
      ENTRY PRESSW (NBIT,L)        
C     =====================        
C        
C     PRESSW IS CALLED ONLY BY BGNSYS AND XCSA TO SETUP DIAGNOSTIC BITS 
C     FOR A PARTICULAR LINK.        
C     BITS  0 THRU 47 ARE USED FOR 48 DIAGNOSTICS        
C     BITS 49 THRU 63 ARE RESERVED FOR 15 LINK NOS.        
C     NBIT HERE (INPUT) CONTAINS BCD WORD NSXX WHERE XX IS LINK NO.     
C        
      IRET = 0        
      IF (NBIT .EQ. RENTER) RETURN        
      IF (SWITCH(3)+SWITCH(2) .EQ. 0) IRET = 1        
      I = 32 - MAXLNK        
      IF (RSHIFT(SWITCH(2),I) .EQ. 0) GO TO 40        
      DO 20 I = 1,MAXLNK        
      IF (NBIT .EQ. NS(I)) GO TO 30        
   20 CONTINUE        
      GO TO 40        
   30 NBIT2 = I + 31 - MAXLNK        
      IF (ANDF(LSHIFT(1,NBIT2),SWITCH(2)) .EQ. 0) IRET = 1        
   40 IF (IRET .EQ. 0) SWITCH(1) = SWITCH(3)        
      RETURN        
      END        
