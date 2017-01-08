      SUBROUTINE WRTMSG (FILEX)        
C        
C  $MIXED_FORMATS        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      INTEGER         FILE,FILEX,TITLE,TTLSAV(32,6),COUNT,FOR(100),     
     1                RET,EJECT,REW,BLANK,FORMAX,MASK1(5),MASK2(5),     
     2                POS,ANDF,ORF,RSHIFT,COMPLF,SYSX        
      REAL            LST(50)        
      COMMON /OUTPUT/ TITLE(32,6)        
      COMMON /SYSTEM/ SYSX(41)        
      COMMON /MACHIN/ MACH        
      EQUIVALENCE     (SYSX( 2),MO   ), (SYSX( 9),MAXLIN),        
     1                (SYSX(12),COUNT), (SYSX(39),NBPC  ),        
     2                (SYSX(40),NBPW ), (SYSX(41),NCPW  )        
      DATA    LSTMAX, REW,FORMAX,BLANK/ 50,1,100,4H     /        
C        
      N2CPW    = NCPW/2        
      N2CPW1   = N2CPW - 1        
      NBPC2    = 2*NBPC        
      MASK1(1) = RSHIFT(COMPLF(0),NBPC2)        
      MASK2(1) = COMPLF(MASK1(1))        
      DO 10 I  = 2,N2CPW        
      MASK1(I) = ORF(MASK2(1),RSHIFT(MASK1(I-1),NBPC2))        
      MASK2(I) = COMPLF(MASK1(I))        
   10 CONTINUE        
      FILE = FILEX        
C        
      DO 20 J = 1,6        
      DO 20 I = 1,32        
      TTLSAV(I,J) = TITLE(I,J)        
   20 CONTINUE        
C        
   30 COUNT = MAXLIN        
   40 CALL READ (*500,*30,FILE,N,1,0,NF)        
      IF (N) 100,130,110        
C        
C     A TITLE OR SUBTITLE FOLLOWS.        
C        
  100 N = -N        
      IF (N .LE. 6) CALL FREAD (FILE,TITLE(1,N),32,0)        
      IF (N .GT. 6) CALL FREAD (FILE,0,-32,0)        
      GO TO 30        
C        
C     A MESSAGE FOLLOWS...N = NUMBER OF LIST ITEMS.        
C        
  110 IF (N .LE. LSTMAX) GO TO 120        
      CALL FREAD (FILE,0,-N,0)        
      GO TO 130        
  120 IF (N .NE. 0) CALL FREAD (FILE,LST,N,0)        
C        
C     READ THE CORRESPONDING FORMAT...NF = SIZE OF THE FORMAT.        
C        
  130 CALL FREAD (FILE,NF,1,0)        
      IF (NF) 140,150,160        
  140 COUNT = COUNT - NF        
      GO TO 130        
  150 COUNT = MAXLIN        
      GO TO 130        
  160 IF (NF .LE. FORMAX) GO TO 170        
      CALL FREAD (FILE,0,-NF,0)        
      GO TO 30        
  170 CALL FREAD (FILE,FOR,NF,0)        
C        
C     CONDENSE FOR ARRAY TO ACQUIRE CONTIGUOUS HOLLERITH STRINGS.       
C        
      IF (NCPW .EQ. 4) GO TO 300        
      DO 290 I = 2,NF        
      K1 = 1        
      POS= 2*I - 1        
      J  = (POS+N2CPW1)/N2CPW        
      K2 = POS - N2CPW*(J-1)        
      ASSIGN 200 TO RET        
      GO TO 240        
  200 CONTINUE        
      K1 = 2        
      IF (K2+1 .LE. N2CPW) GO TO 210        
      K2 = 1        
      J  = J + 1        
      GO TO 220        
  210 K2 = K2 + 1        
  220 CONTINUE        
      ASSIGN 230 TO RET        
      GO TO 240        
  230 CONTINUE        
      GO TO 290        
  240 IF (K2-K1) 250,260,270        
  250 FOR(J) = ORF(ANDF(FOR(J),MASK1(K2)),        
     1         LSHIFT(ANDF(FOR(I),MASK2(K1)),(NBPC2*(K1-K2))))        
      GO TO 280        
  260 FOR(J) = ORF(ANDF(FOR(J),MASK1(K2)),ANDF(FOR(I),MASK2(K1)))       
      GO TO 280        
  270 FOR(J) = ORF(ANDF(FOR(J),MASK1(K2)),        
     1         RSHIFT(ANDF(FOR(I),MASK2(K1)),(NBPC2*(K2-K1))))        
      GO TO 280        
  280 CONTINUE        
      GO TO RET, (200,230)        
  290 CONTINUE        
  300 CONTINUE        
C        
C     PRINT THE LINE        
C        
      IF (EJECT(1) .EQ. 0) GO TO 450        
      DO 440 J = 4,6        
      DO 410 I = 1,32        
      IF (TITLE(I,J) .NE. BLANK) GO TO 420        
  410 CONTINUE        
      COUNT = COUNT - 1        
      GO TO 440        
  420 WRITE  (MO,430) (TITLE(I,J),I=1,32)        
  430 FORMAT (2X,32A4)        
  440 CONTINUE        
      WRITE  (MO,430)        
      COUNT = COUNT + 1        
C        
  450 IF (N .EQ. 0) GO TO 470        
C     IF (MACH .EQ. 3) GO TO 460        
      WRITE (MO,FOR,ERR=40) (LST(J),J=1,N)        
      GO TO 40        
C 460 CALL WRTFMT (LST,N,FOR)        
C     GO TO 40        
  470 WRITE (MO,FOR)        
      GO TO 40        
C        
C     END OF MESSAGE FILE        
C        
  500 CALL CLOSE (FILE,REW)        
      DO 510 J = 1,6        
      DO 510 I = 1,32        
      TITLE(I,J) = TTLSAV(I,J)        
  510 CONTINUE        
      RETURN        
      END        
