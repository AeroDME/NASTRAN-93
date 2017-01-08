      SUBROUTINE MPY3NU (IZ)        
C        
C     CALCULATES NEXT TIME USED FOR INDIVIDUAL COLUMNS OF B OR FOR ROWS 
C     CORRESPONDING TO NON-ZERO TERMS IN COLUMN OF A.        
C        
      INTEGER         ZPNTRS        
      DIMENSION       IZ(1),NAME(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      COMMON /MPY3CP/ ITRL,ICORE,N,NCB,DUM1(4),ZPNTRS(22),LAEND,        
     1                DUM2(8),J,ID,NTBU        
      EQUIVALENCE     (IPOINT,ZPNTRS(3)),(IACOLS,ZPNTRS(5))        
      DATA    NAME  / 4HMPY3,4HNU   /        
C        
C     CALCULATION BY SEARCH THROUGH ROW OF A IN QUESTION.        
C        
      LP = IPOINT + ID - 1        
      L1 = IZ(LP)        
      IF (L1 .EQ.   0) GO TO 60        
      IF (ID .EQ. NCB) GO TO 20        
      LL = ID + 1        
      DO 10 L = LL,NCB        
      LP = LP + 1        
      IF (IZ(LP) .EQ. 0) GO TO 10        
      L2 = IZ(LP) - 1        
      GO TO 30        
   10 CONTINUE        
   20 L2  = LAEND        
   30 LAC = IACOLS + L1 - 2        
      DO 40 L = L1,L2        
      LAC = LAC + 1        
      IF (J .LT. IZ(LAC)) GO TO 50        
   40 CONTINUE        
      NTBU = 99999999        
      GO TO 80        
   50 NTBU = IZ(LAC)        
      GO TO 80        
C        
C    ERROR MESSAGE.        
C        
   60 WRITE  (NOUT,70) UFM        
   70 FORMAT (A23,' 6557, UNEXPECTED NULL COLUMN OF A(T) ENCOUNTERED.') 
      CALL MESAGE (-37,0,NAME)        
C        
   80 RETURN        
      END        
