      SUBROUTINE DTRANP        
C        
C     DRIVER OF MATRIX TRANSPOSE MODULE        
C        
C     TRNSP    IA/IAT/C,N,IXX  $        
C        
C     THE DIAGONALS OF THE LOWER OR UPPER TRIANGULAR MATRICES ARE       
C     REPLACED BY UNITY (1.0) IF IXX IS ONE. (DEFAULT IS ZERO)        
C        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / IXX        
      COMMON /SYSTEM/ IBUF,NOUT        
CZZ   COMMON /ZZDTRA/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /TRNSPX/ IA(7),IAT(7),LCORE,NSCR,ISCR(8)        
      DATA    IN1   , IN2  /101, 201 /        
C        
      IA(1) = IN1        
      CALL RDTRL (IA(1))        
      IF (IA(1) .GT. 0) GO TO 20        
      WRITE  (NOUT,10) UWM        
   10 FORMAT (A25,' FROM TRNSP, MISSING INPUT DATA BLOCK FOR MATRIX ',  
     1       'TRANSPOSE')        
      GO TO 60        
   20 IAT(1) = IN2        
      IAT(2) = IA(3)        
      IAT(3) = IA(2)        
      IAT(4) = IA(4)        
      IAT(5) = IA(5)        
      IAT(6) = 0        
      IAT(7) = 0        
      LCORE  = KORSZ(CORE)        
      NSCR = 8        
      DO 30 I = 1,NSCR        
   30 ISCR(I) = 300 + I        
      IF (IXX .EQ. 1) IXX = -123457890        
      CALL TRNSP (CORE(1))        
      CALL WRTTRL (IAT(1))        
C        
   60 RETURN        
      END        
