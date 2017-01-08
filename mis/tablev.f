      SUBROUTINE TABLE V (*,IN,LL,TRL,NAME,P4,IBUF,Z5)        
C        
C     TABLE-V IS CALLED ONLY BY INPUT5 TO GENERATE A GINO TABLE        
C     DATA BLOCK IN 'OUT' FROM AN INPUT FILE 'IN' - A REVERSE PROCESS   
C     OF TABLE-5.        
C     THE INPUT FILE WAS FORTRAN WRITTEN, FORMATTED OR UNFORMATTED      
C        
C     IN     = INPUT FILE, INTEGERS        
C     LL     = (200+LL) IS THE OUTPUT FILE, INTEGER        
C     TRL    = AN ARRAY OF 7 WORDS FOR TRAILER        
C     NAME   = ORIGINAL FILE NAME FROM INPUT FILE, 2 BCD WORDS, PLUS 1  
C     P4     = 0, INPUT FILE WAS WRITTEN UNFORMATTED, BINARY, INTEGER   
C            = 1, INPUT FILE WAS WRITTEN FORMATTED, ASCII, INTEGER      
C     IBUF   = OPEN CORE AND GINO BUFFER POINTER, INTEGER        
C        
      LOGICAL          DEBUG        
      INTEGER          SYSBUF,P4,Z,TRL(7),OUT,NAME(3),NAMEX(2),SUB(2),  
     1                 END,TBLE,FUF,FU(2)        
      REAL             RZ(1),Z4(2)        
      DOUBLE PRECISION DZ        
      CHARACTER*1      Z1,I1,R1,B1,D1,F1        
      CHARACTER*5      Z5(1),Z5L,END5        
      CHARACTER*10     Z10        
      CHARACTER*15     Z15        
      COMMON /SYSTEM/  SYSBUF,NOUT        
CZZ   COMMON /ZZINP5/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      EQUIVALENCE      (Z1,Z5L), (Z(1),RZ(1)), (DZ,Z4(1))        
      DATA    I1,R1,   B1,D1,F1  / 'I', 'R', '/', 'D', 'X'    /        
      DATA    FU,      END,END5  / 2H  ,2HUN, 4H*END, ' *END' /        
      DATA    SUB,     TBLE      / 4HTABL,4HEV  ,     4HTBLE  /        
      DATA    DEBUG              / .FALSE.                    /        
C        
      IF (DEBUG) WRITE (NOUT,10)        
 10   FORMAT (///,' *** IN TABLE-V, DEBUG ***')        
      KORE  = IBUF-1        
      KORE9 = (KORE/9)*9        
      OUT   = 200+LL        
      LL    = LL+1        
      KOUNT = 0        
C        
C     OPEN GINO OUTPUT FILE AND WRITE A FILE HEADER        
C        
      CALL OPEN (*180,OUT,Z(IBUF),1)        
      CALL FNAME (OUT,NAMEX)        
      CALL WRITE (OUT,NAMEX,2,1)        
      IF (DEBUG) WRITE (NOUT,20) NAMEX        
 20   FORMAT (/5X,'GENERATING...',2A4,/)        
      NAME(3) = TBLE        
      IF (P4 .EQ. 1) GO TO 40        
C        
C     UNFORMATED READ        
C        
 30   READ (IN,ERR=150,END=130) LN,(Z(J),J=1,LN)        
      IF (LN .GT. KORE) GO TO 170        
      IF (LN.EQ.1 .AND. Z(1).EQ.END) GO TO 130        
      CALL WRITE  (OUT,Z(1),LN,1)        
      KOUNT = KOUNT+1        
      GO TO 30        
C        
C     FORMATTED READ        
C        
 40   READ  (IN,50,ERR=150,END=130) LN,(Z5(J),J=1,LN)        
 50   FORMAT (I10,24A5,/,(26A5))        
      IF (LN .GT. KORE) GO TO 170        
      IF (LN.EQ.1 .AND. Z5(1).EQ.END5) GO TO 130        
      IF (LN .LE. -1) GO TO 130        
      LB = (LN*5)/4+1        
      K  = 0        
      L  = 1        
 60   IF (L .GT. LN) GO TO 120        
      K  = K+1        
      Z5L= Z5(L)        
      IF (Z1 .EQ. I1) GO TO 90        
      IF (Z1 .EQ. R1) GO TO 100        
      IF (Z1 .EQ. B1) GO TO 70        
      IF (Z1 .EQ. F1) GO TO 80        
      IF (Z1 .EQ. D1) GO TO 110        
      WRITE  (NOUT,65) Z5L        
 65   FORMAT (/,' SYSTEM ERROR/TABLEV @65  Z5L=',A5)        
      GO TO 150        
C        
C     BCD        
C        
 70   READ (Z5L,75) Z(LB+K)        
 75   FORMAT (1X,A4)        
C        
C     FILLER        
C        
 80   L = L+1        
      GO TO 60        
C        
C     INTEGER        
C        
 85   FORMAT (3A5)        
 90   WRITE  (Z10,85) Z5(L),Z5(L+1)        
      READ   (Z10,95) Z(LB+K)        
 95   FORMAT (1X,I9)        
      L = L+2        
      GO TO 60        
C        
C     REAL, SINGLE PRECISION        
C        
 100  WRITE  (Z15, 85) Z5(L),Z5(L+1),Z5(L+2)        
      READ   (Z15,105) RZ(LB+K)        
 105  FORMAT (1X,E14.7)        
      L = L+3        
      GO TO 60        
C        
C     REAL, DOUBLE PRECISION        
C        
 110  WRITE (Z15, 85) Z5(L),Z5(L+1),Z5(L+2)        
      READ  (Z15,115) DZ        
 115  FORMAT (1X,D14.7)        
      RZ(LB+K  ) = Z4(1)        
      RZ(LB+K+1) = Z4(2)        
      K = K+1        
      L = L+3        
      GO TO 60        
C        
 120  IF (K .LE. 0) GO TO 40        
      CALL WRITE (OUT,Z(LB+1),K,1)        
      KOUNT = KOUNT+1        
      GO TO 40        
C        
C     ALL DONE.        
C     CLOSE OUTPUT GINO FILE AND WRITE TRAILER        
C        
 130  CALL CLOSE (OUT,1)        
      IF (DEBUG) WRITE (NOUT,135) TRL(2),KOUNT        
 135  FORMAT (/,' DEBUG ECHO - OLD AND NEW COLUMN COUNTS =',2I5)        
      TRL(1) = OUT        
      TRL(2) = KOUNT        
      CALL WRTTRL (TRL)        
      FUF = FU(1)        
      IF (P4 .EQ. 0) FUF = FU(2)        
      WRITE  (NOUT,140) FUF,NAMEX        
 140  FORMAT (/5X,'DATA TRANSFERED SUCCESSFULLY FROM ',A2,'FORMATTED ', 
     1       'TAPE TO GINO OUTPUT FILE ',2A4)        
      GO TO 200        
C        
C     ERROR        
C        
 150  CALL CLOSE (OUT,1)        
      WRITE  (NOUT,160) NAMEX        
 160  FORMAT (//5X,'ERROR IN READING INPUT TAPE IN TABLEV. NO ',2A4,    
     1         /5X,'FILE GENERATED')        
      GO TO 200        
 170  CALL MESAGE (8,0,SUB)        
      GO TO 200        
 180  CALL MESAGE (1,OUT,SUB)        
C        
 200  RETURN 1        
      END        
