      SUBROUTINE GENPAR        
C        
C     GENERATES PARTITIONING VECTORS FOR DDAM SO THAT ONLY THE FIRST    
C     LMODES MODES WILL BE USED, NOT NECESSARILY ALL THE ONES FOUND ON  
C     THE PREVIOUS EIGENVALUE RUN. LMODES MUST BE GREATER THAN ZERO.    
C     IF LMODES IS GREATER THAN THE NUMBER FOUND(OBTAINED FROM PF), IT  
C     IS REDUCED TO THE NUMBER PREVIOUSLY FOUND        
C        
C     GENPART  PF/RPLAMB,CPLAMB,RPPF,CPMP/C,Y,LMODES/V,N,NMODES $       
C     SAVE NMODES $        
C        
      INTEGER         PF,CPLAMB,RPLAMB,RPPF,CPMP,BUF1,SYSBUF,OTPE       
      DIMENSION       IZ(1),MCB(7),NAM(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / LMODES,NMODES        
      COMMON /PACKX / IN,IOUT,II,NN,INCR        
      COMMON /SYSTEM/ SYSBUF,OTPE        
CZZ   COMMON /ZZGENP/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (Z(1),IZ(1))        
      DATA    PF,RPLAMB,CPLAMB,RPPF,CPMP / 101,201,202,203,204 /        
      DATA    NAM   / 4HGENP,4HART /        
C        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE - SYSBUF + 1        
      LCORE = BUF1 - 1        
      IF (LCORE .LT. 5) GO TO 1008        
C        
      IN   = 1        
      IOUT = 1        
      II   = 1        
      INCR = 1        
C        
      IF (LMODES .LE. 0) GO TO 500        
      MCB(1) = PF        
      CALL RDTRL (MCB)        
      NMODES = MCB(3)        
      NDIR   = MCB(2)        
      IF (LMODES .GT. NMODES) LMODES=NMODES        
C        
C     GENERATE ROW PARTITIONING VECTOR FOR LAMB MATRIX TO PICK OFF THE  
C     2ND COLUMN, WHICH IS THE COLUMN OF RADIAN FREQUENCIES. THEN       
C     TRUNCATE THE COLUMN TO LMODES SIZE        
C        
      IF (LCORE .LT. NMODES) GO TO 1008        
      CALL GOPEN (CPLAMB,Z(BUF1),1)        
      NN = 0        
      Z(   1) = 0.        
      Z(NN+2) = 1.        
      Z(NN+3) = 0.        
      Z(NN+4) = 0.        
      Z(NN+5) = 0.        
      NN = 5        
      MCB(1) = CPLAMB        
      MCB(2) = 0        
      MCB(3) = 5        
      MCB(4) = 2        
      MCB(5) = 1        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL PACK (Z,CPLAMB,MCB)        
      CALL CLOSE (CPLAMB,1)        
      CALL WRTTRL (MCB)        
C        
      CALL GOPEN (RPLAMB,Z(BUF1),1)        
      DO 10 I = 1,LMODES        
   10 Z(I) = 1.        
      IF (LMODES .EQ. NMODES) GO TO 30        
      L1 = LMODES + 1        
      DO 20 I = L1,NMODES        
   20 Z(I) = 0.        
   30 NN = NMODES        
      MCB(1) = RPLAMB        
      MCB(2) = 0        
      MCB(3) = NMODES        
      MCB(4) = 2        
      MCB(5) = 1        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL PACK (Z,RPLAMB,MCB)        
      CALL CLOSE (RPLAMB,1)        
      CALL WRTTRL (MCB)        
C        
C     ROW PARTITION FOR PF        
C        
      CALL GOPEN (RPPF,Z(BUF1),1)        
      MCB(1) = RPPF        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL PACK (Z,RPPF,MCB)        
      CALL CLOSE (RPPF,1)        
      CALL WRTTRL (MCB)        
C        
C     COLUMN PARTITION FOR MP-SAME AS ROW PARTITION FOR PREVIOUS FILES  
C        
      CALL GOPEN (CPMP,Z(BUF1),1)        
      MCB(1) = CPMP        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL PACK (Z,CPMP,MCB)        
      CALL CLOSE (CPMP,1)        
      CALL WRTTRL (MCB)        
C        
      RETURN        
  500 WRITE  (OTPE,501) UFM        
  501 FORMAT (A23,', LMODES PARAMETER MUST POSITIVE')        
      CALL MESAGE (-61,0,0)        
C        
 1008 CALL MESAGE (-8,0,NAM)        
      RETURN        
      END        
