      SUBROUTINE SWITCH        
C        
C     THE PURPOSE OF THIS MODULE IS TO INTERCHANGE THE NAMES OF THE     
C     TWO INPUT FILES.  THIS IS ACCOMPLISHED BY THE DIRECT UPDATING     
C     OF THE FIAT        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      INTEGER         FILE1,FILE2,MODNAM(2),NAME(2),PSAVE1,PSAVE2,      
     1                ANDF,ORF,RSHIFT,COMPLF,UNIT,UNIT1,UNIT2,UNT       
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /XFIAT / IFIAT(3)        
      COMMON /XFIST / IFIST(2)        
      COMMON /XPFIST/ IPFIST        
      COMMON /BLANK / IPARAM        
      COMMON /SYSTEM/ SYSBUF,NOUT,SKIP(21),ICFIAT        
      DATA    FILE1 / 101/, FILE2 / 102/, MODNAM/ 4HSWIT,4HCH  /        
C        
      IF (IPARAM .GE. 0) RETURN        
      MASK2 = 32767        
      MASK3 = COMPLF(MASK2)        
      MASK  = LSHIFT(1,30) - 1        
      MASK  = LSHIFT(RSHIFT(MASK,16),16)        
      MASK1 = COMPLF(MASK)        
      NUNIQE= IFIAT(1)*ICFIAT + 3        
      MXE   = IFIAT(2)*ICFIAT + 3        
      LASTWD= IFIAT(3)*ICFIAT + 3        
C        
C     LOCATE FILE POINTERS IN THE FIST        
C        
      NWD    = 2*IPFIST   + 2        
      NACENT = 2*IFIST(2) + 2        
      NFILES = NACENT - NWD        
      PSAVE1 = 0        
      PSAVE2 = 0        
      DO 10 I = 1,NFILES,2        
      IF (IFIST(NWD+I).NE.FILE1 .AND. IFIST(NWD+I).NE.FILE2) GO TO 10   
      IF (IFIST(NWD+I)-FILE1) 2,3,2        
    2 IF (IFIST(NWD+I)-FILE2) 10,4,10        
    3 PSAVE1 = IFIST(NWD+I+1) + 1        
      GO TO 10        
    4 PSAVE2 = IFIST(NWD+I+1) + 1        
   10 CONTINUE        
C        
C     CHECK THAT FILES ARE IN FIST        
C        
      IF (PSAVE1 .EQ. 0) CALL MESAGE (-1,FILE1,MODNAM)        
      IF (PSAVE2 .EQ. 0) CALL MESAGE (-1,FILE2,MODNAM)        
C        
C     SWITCH FILE NAMES IN FIAT        
C        
      NAME(1) = IFIAT(PSAVE1+1)        
      NAME(2) = IFIAT(PSAVE1+2)        
      UNIT1   = ANDF(MASK2,IFIAT(PSAVE1))        
      UNIT2   = ANDF(MASK2,IFIAT(PSAVE2))        
      NWD     = ICFIAT*IFIAT(3) - 2        
      LTU1    = ANDF(MASK,IFIAT(PSAVE1))        
      LTU2    = ANDF(MASK,IFIAT(PSAVE2))        
      IFIAT(PSAVE1  ) = ORF(ANDF(IFIAT(PSAVE1),MASK2),LTU2)        
      IFIAT(PSAVE1+1) = IFIAT(PSAVE2+1)        
      IFIAT(PSAVE1+2) = IFIAT(PSAVE2+2)        
      IFIAT(PSAVE2  ) = ORF(ANDF(IFIAT(PSAVE2),MASK2),LTU1)        
      IFIAT(PSAVE2+1) = NAME(1)        
      IFIAT(PSAVE2+2) = NAME(2)        
C        
C     SWITCH STACKED DATA BLOCKS        
C        
      DO 100 I = 4,NWD,ICFIAT        
      IF (PSAVE1.EQ.I .OR. PSAVE2.EQ.I) GO TO 100        
      UNIT = ANDF(MASK2,IFIAT(I))        
      IF (UNIT.NE.UNIT1 .AND. UNIT.NE.UNIT2) GO TO 100        
      IF (UNIT .EQ. UNIT1) UNT = UNIT2        
      IF (UNIT .EQ. UNIT2) UNT = UNIT1        
      IF (I   .GT. NUNIQE) GO TO 50        
C        
C     DATA BLOCK RESIDES IN UNIQUE PART OF FIAT        
C     MOVE ENTRY TO BOTTOM        
C        
      IF (LASTWD+ICFIAT .LE. MXE) GO TO 30        
      WRITE  (NOUT,20) SFM        
   20 FORMAT (A25,' 1021, FIAT OVERFLOW')        
      CALL MESAGE (-37,0,MODNAM)        
   30 IFIAT(LASTWD+1) = ORF(ANDF(IFIAT(I),MASK3),UNT)        
      DO 40 K = 2,ICFIAT        
   40 IFIAT(LASTWD+K) = IFIAT(I+K-1)        
      LASTWD   = LASTWD   + ICFIAT        
      IFIAT(3) = IFIAT(3) + 1        
C        
C     CLEAR OLD ENTRY IN UNIQUE PART        
C        
      IFIAT(I) = ANDF(IFIAT(I),MASK2)        
      J1 = I + 1        
      J2 = I + ICFIAT - 1        
      DO 45 K = J1,J2        
   45 IFIAT(K) = 0        
      GO TO 100        
C        
C     DATA BLOCK RESIDES IN NON-UNIQUE PORTION OF FIAT        
C     SWITCH UNIT NUMBERS        
C        
   50 IFIAT(I) = ORF(ANDF(IFIAT(I),MASK3),UNT)        
  100 CONTINUE        
      RETURN        
      END        
