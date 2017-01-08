      SUBROUTINE TOTAPE (CALLER,Z)        
C        
C     THIS ROUTINE IS CALLED ONLY BY DPLTST (CALLER=1), DPLOT (CALLER=2)
C     AND/OR OFP (CALLER=3) TO COPY NUMBERS OF GINO INPUT FILES TO A    
C     SAVE FILE, INP9, FOR NEXT INTERACTIVE NASTRAN RUN (INTRA.LT.0)    
C     THE SAVE FILE CAN BE A TAPE OR DISC.        
C        
C     WRITTEN BY G.CHAN/SPERRY     NOV. 1985        
C        
C     FILE STRUCTURE IN SAVE TAPE        
C        
C     RECORD NO.   CONTENT        
C     ----------   -----------------------------------------------      
C        1           6-WORDS (3 CALLER ID WORDS AND 3 DATE WORDS)       
C                   96-WORD HEADING        
C                  100-SYSTEM WORDS        
C        2         MARK        
C        3         CALLER ID, NO. OF FILES, NO. OF PARAMETERS        
C        4         7-WORD TRAILER OF FIRST GINO INPUT FILE        
C      5 TO N      FIRST GINO INPUT FILE (IF FILE IS NOT PURGED)        
C       N+1        MARK        
C       N+2        7-WORD TRAILER OF SECOND GINO INPUT FILE        
C    N+2 TO M      SECOND GINO INPUT FILE (IF FILE IS NOT PURGED)       
C       M+1        MARK        
C    M+2 TO ..R    REPEAT FOR ADDITION FILES, TRAILER, AND MARK        
C       R+1        PARAMETERS IN /BLANK/ OF CURRENT CALLER        
C       R+2        MARK        
C       R+3        NASTRAN EOF MARK        
C    R+4 TO LAST   REPEAT 3 TO R+3 AS MANY TIMES AS NEEDED FROM THE     
C                  SAME OR A DIFFERENT CALLER AT DIFFERENT TIME        
C     LAST+1       SYSTEM EOF MARK        
C        
C     THE INTERACTIVE FLAG, INTRA, IN /SYSTEM/ WAS SET BY XCSA TO       
C         1 FOR PLOT ONLY,        
C         2 FOR OUTPUT PRINT ONLY        
C      OR 3 FOR BOTH        
C        
      IMPLICIT INTEGER (A-Z)        
      LOGICAL         DISC,     TAPBIT        
      DIMENSION       Z(3),     TAB(3,3), MARK(3),  SUB(2),   FN(2),    
     1                DATE(3),  WHO(2)        
      CHARACTER       UFM*23,   UWM*25,   UIM*29        
      COMMON /XMSSG / UFM,      UWM,      UIM        
      COMMON /BLANK / PARAM(1)        
      COMMON /SYSTEM/ KSYSTM(100)        
      COMMON /OUTPUT/ HEAD(96)        
      COMMON /NAMES / RD,       RDREW,    WRT,      WRTREW,   REW,      
     1                NOREW        
      EQUIVALENCE     (KSYSTM( 1),IBUF), (KSYSTM(15),DATE(1)),        
     1                (KSYSTM( 2),NOUT), (KSYSTM(86),INTRA  ),        
     2                (TAB(2,3) ,BLANK)        
      DATA    TAB   / 4HPLTS,   4HET  ,   2,        
     1                4HPLOT,   4H    ,   5,        
     2                4HOFP ,   4H    ,   3/        
      DATA    FILE,   NFILE,    MARK  /   4HINP9,23,  2*65536,11111  /  
      DATA    SUB /   4HTOTA,   4HPE  /        
C        
      IF (INTRA.GE.0 .OR. CALLER.LT.1 .OR. CALLER.GT.3) RETURN        
      IF (CALLER.LE.2 .AND. INTRA.EQ.-2) RETURN        
      IF (CALLER.EQ.3 .AND. INTRA.EQ.-1) RETURN        
      WHO(1) = TAB(1,CALLER)        
      WHO(2) = TAB(2,CALLER)        
      NPARAM = TAB(3,CALLER)        
      KORE   = KORSZ(Z(1))        
      IBUF1  = KORE  - IBUF        
      IBUF2  = IBUF1 - IBUF        
      KORE   = IBUF2 - 1        
      FN(1)  = FILE        
      FN(2)  = BLANK        
      DISC   = .TRUE.        
      IF (TAPBIT(FN(1))) DISC = .FALSE.        
      IF (.NOT.DISC .OR. INTRA.GT.0) GO TO 30        
C        
      CALL OPEN (*120,FILE,Z(IBUF2),RDREW)        
 10   CALL READ (*20,*20,FILE,Z(1),2,0,M)        
      CALL SKPFIL (FILE,1)        
      GO TO 10        
 20   CALL CLOSE (FILE,NOREW)        
 30   CALL OPEN (*120,FILE,Z(IBUF2),WRT)        
      IF (INTRA .LT. 0) GO TO 40        
      DO 35 I = 1,2        
      IF (INTRA.NE.I .AND. INTRA.NE.3) GO TO 35        
      FILE = TAB(3,I+1)        
      CALL WRITE (FILE,TAB(1,CALLER),3,0)        
      CALL WRITE (FILE,  DATE(1),  3,0)        
      CALL WRITE (FILE,  HEAD(1), 96,0)        
      CALL WRITE (FILE,KSYSTM(1),100,1)        
      CALL WRITE (FILE,  MARK(1),  3,1)        
 35   CONTINUE        
      INTRA = -INTRA        
      FILE  = TAB(3,CALLER)        
 40   Z(1)  = CALLER        
      Z(2)  = NFILE        
      Z(3)  = NPARAM        
      CALL WRITE (FILE,Z(1),3,1)        
      WRITE  (NOUT,50) UIM,WHO,FILE        
 50   FORMAT (A29,', THE FOLLOWING FILES WERE COPIED FROM DMAP ',A4,A2, 
     1        4H TO ,A4,5H FILE,/)        
      DO 110 I = 1,NFILE        
      INFIL = 100 + I        
      CALL OPEN (*100,INFIL,Z(IBUF1),RDREW)        
      Z(1)  = INFIL        
      CALL RDTRL (Z(1))        
      CALL WRITE (FILE,Z(1),7,1)        
      IF (Z(1) .LE. 0) GO TO 80        
 60   CALL READ (*80,*70,INFIL,Z(1),KORE,1,M)        
      CALL MESAGE (-8,0,SUB)        
 70   CALL WRITE (FILE,Z(1),M,1)        
      GO TO 60        
 80   CALL CLOSE (INFIL,REW)        
      CALL FNAME (INFIL,FN)        
      WRITE  (NOUT,90) FN        
 90   FORMAT (5X,2A4)        
 100  CALL WRITE (FILE,MARK(1),3,1)        
 110  CONTINUE        
      CALL WRITE (FILE,PARAM(1),NPARAM,1)        
      CALL WRITE (FILE,MARK(1),3,1)        
      IF (.NOT.DISC) CALL CLOSE (FILE,NOREW)        
      IF (     DISC) CALL CLOSE (FILE,  REW)        
      RETURN        
C        
 120  CALL MESAGE (-1,FILE,SUB)        
      RETURN        
      END        
