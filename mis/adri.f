      SUBROUTINE ADRI (FL,NFREQ,NCORE,QHHL,SCR2,SCR1,SCR3,SCR4,NROW,    
     1                 NCOL,NOGO)        
C        
      INTEGER         QHHL,SCR1,SCR2,SCR3,SCR4,TRL(7),OUT        
      DIMENSION       FL(1),MCB(7),NAME(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / BOV,RM        
      COMMON /CONDAS/ PI,TWOPI        
      COMMON /SYSTEM/ ISYS,OUT,DUM(52),IPREC        
      COMMON /UNPAKX/ IOUT,INN,NNN,INCR1        
      COMMON /PACKX / ITI,ITO,II,NN,INCR        
      COMMON /TYPE  / P(2),IWC(4)        
      DATA    NHFRDI, NAME /4HFRDI,4HADRI,4H    /        
C        
      IBUF1 = NCORE - ISYS        
      IBUF2 = IBUF1 - ISYS        
      NROW  = 0        
      INCR  = 1        
      INCR1 = 1        
      II    = 1        
      INN   = 1        
      MCB(1)= QHHL        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 250        
      NROW  = MCB(3)        
      CALL OPEN (*250,QHHL,FL(IBUF2),0)        
      CALL GOPEN (SCR1,FL(IBUF1),1)        
      CALL READ (*220,*220,QHHL,FL(1),-2,0,FLAG)        
      CALL READ (*220,*220,QHHL,NCOL,1,0,FLAG)        
      CALL READ (*220,*220,QHHL,N,1,0,FLAG)        
      N    = N + N        
      NI   = (MCB(2)/NCOL)*2        
      NI   = MIN0(NI,N)        
      NNN  = NROW        
      NN   = NCOL*NROW        
      ITI  = 3        
      ITO  = ITI        
      IOUT = ITI        
      NWC  = IWC(ITI)        
      CALL MAKMCB (TRL,SCR1,NN,MCB(4),ITO)        
C        
C     MAKE   DEPENDENT FREQ LIST        
C        
      IPD  = 1        
      NL   = 2*NFREQ        
      N    = NFREQ + 1        
      IPI  = IPD + NL        
      DO 10 I = 1,NFREQ        
      FL(NL  ) = FL(N-I)*TWOPI*BOV        
      FL(NL-1) = 0.0        
      NL   = NL -2        
   10 CONTINUE        
C        
C     MAKE INDEPENDENT FREQ LIST        
C        
      CALL READ (*220,*220,QHHL,FL(IPI),NI,1,FLAG)        
C        
C     FIND M"S CLOSEST TO RM        
C        
      ICP = IPI + NI        
      RMI = 1.E20        
      RMS = 0.0        
      DO 30 I = 1,NI,2        
      RMX = ABS(FL(IPI+I-1) - RM)        
      RMI = AMIN1(RMI,RMX)        
      IF (RMX .GT. RMI) GO TO 30        
      RMS = FL(IPI+I-1)        
   30 CONTINUE        
      RMI = RMS        
C        
C     DO ALL K"S ASSOCIATED WITH RMI        
C        
      K = 0        
      DO 150 I = 1,NI,2        
      IF (FL(IPI+I-1) .EQ. RMI) GO TO 120        
C        
C     SKIP MATRIX        
C        
      CALL SKPREC (QHHL,NCOL)        
      GO TO 150        
C        
C     MAKE MATRIX INTO COLUMN        
C        
  120 FL(IPI+K+1) = FL(IPI+I)        
      K  = K + 2        
      JI = ICP        
      N  = NROW*NWC        
      DO 130 J = 1,NCOL        
      CALL UNPACK (*131,QHHL,FL(JI))        
      GO TO 135        
  131 CALL ZEROC (FL(JI),N)        
  135 JI = JI + N        
  130 CONTINUE        
C        
C     DIVIDE IMAG PART OF QHHL BY FREQUENCY        
C        
      JJ = ICP + 1        
      KK = JI  - 1        
      DO 132 J = JJ,KK,2        
      FL(J) = FL(J)/FL(IPI+I)        
  132 CONTINUE        
      CALL PACK (FL(ICP),SCR1,TRL)        
  150 CONTINUE        
      CALL CLOSE (QHHL,1)        
      CALL CLOSE (SCR1,1)        
      CALL WRTTRL (TRL)        
      CALL BUG (NHFRDI,150,K ,1)        
      CALL BUG (NHFRDI,150,NFREQ,1)        
      CALL BUG (NHFRDI,150,FL(1),ICP)        
C        
C     SETUP TO CALL MINTRP        
C        
      NI   = K/2        
      NOGO = 0        
      NC   = NCORE - ICP        
      CALL DMPFIL (-SCR1,FL(ICP),NC)        
      IM   = 0        
      IK   = 1        
      CALL MINTRP (NI,FL(IPI),NFREQ,FL(IPD),-1,IM,IK,0.0,SCR1,SCR2,     
     1             SCR3,SCR4,FL(ICP),NC,NOGO,IPREC)        
      IF (NOGO .EQ. 1) GO TO 200        
      CALL DMPFIL (-SCR2,FL(ICP),NC)        
      RETURN        
C        
  200 WRITE  (OUT,210) UFM        
  210 FORMAT (A23,' 2271, INTERPOLATION MATRIX IS SINGULAR')        
CIBMR 6/93  GO TO 240                                                 !* 9999 
      GO TO 240
  220 CALL MESAGE (3,QHHL,NAME)        
  240 NOGO = 1        
  250 CALL CLOSE (QHHL,1)        
      RETURN        
      END        
