      SUBROUTINE DETM4        
      DOUBLE PRECISION P,DETX,PS1,DET1,PSAVE(1),DET(1),PS(1)        
      INTEGER PREC,U1,U2,SCR1,SCR2,SCR3,SCR4,SCR5,SCR6,SCR7        
      DIMENSION IPDET(1)        
      COMMON /DETMX/P(4),DETX(4),PS1(4),DET1(4),N2EV,IPSAV,IPS,IDET,    
     1  IPDETA,PREC, U1,U2,IC,NSMOVE,L2,IS,ND, IADD,SML1,IPDETX(4),     
     2  IPDET1(4), IFAIL,K,FACT1        
      COMMON  /REGEAN/ IM(7),IK(7),IEV(7),SCR1,SCR2,SCR3,SCR4,SCR5,LCORE
     1 , RMAX,RMIN,MZ,NEV,EPSI,RMINR,NE,NIT,NEVM,SCR6,SCR7        
     2  ,NFOUND,LAMA        
CZZ   COMMON /ZZDETX/PSAVE        
      COMMON /ZZZZZZ/PSAVE        
      EQUIVALENCE  (PSAVE(1),PS(1),DET(1),IPDET(1))        
C        
C     RMAX = APPROXIMATE MAGNITUDE OF LARGEST EIGENVALUE OF INTEREST    
C        
C     RMIN = LOWEST  NON-ZERO  EIGENVALUE        
C        
C     MZ = NUMBER OF ZERO EIGENVALUES        
C        
C     NEV = NUMBER OF NON-ZERO EIGENVALUES IN RANGE OF INTEREST        
C        
C     EPSI = CONVERGENCE CRITERION        
C        
C     RMINR = LOWEST EIGENVALUE OF INTEREST        
C        
C     NE   =  NUMBER OF PERMISSIBLE CHANGES OF EPSI        
C        
C     NIT = INTERATIONS TO AN EIGENVALUE        
C        
C     NEVM = MAXIMUM NUMBER OF EIGENVALUES DESIRED        
C        
C     IS  = STARTING SET COUNTER        
C        
C     IC  = COUNTER FOR CHANGE OF CONVERGENCE CRITERIA        
C        
C     NFOUND  = THE NUMBER OF EIGENVALUES FOUND TO DATA        
C        
C     NSMOVE = THE NUMBER OF TIMES THE STATTING POINTS HAVE BEEN MOVED  
C        
C      IM = MASS MATRIX CONTROL BLOCK        
C        
C      IK = K MATRIX CONTROL BLOCK        
C        
C        A = M +P*K        
C        
C     IEV = EIGENVECTOR CONTROL BLOCK        
C        
      NN = IPSAV+NFOUND        
      PSAVE(NN) = P(3)        
      EPS1 = FACT1*DSQRT(DABS(P(3)))        
      DO 40 N=1,3        
      NN = N  + IADD -2        
      NNP = NN+IPS        
      IF(DABS(PS(NNP)-P(3)) .GE. 400.*EPS1) GO TO 40        
   10 PS(NNP) = PS(NNP) +2.E3*EPS1        
      NSMOVE = NSMOVE+1        
      IF(NFOUND .EQ. 1) GO TO 30        
      NFND = NFOUND-1        
      DO 20 I=1,NFND        
      NNZ = IPSAV+I        
      IF(DABS(PS(NNP)-PSAVE(NNZ)) .GT. 400.*EPS1) GO TO 20        
      GO TO 10        
   20 CONTINUE        
   30 NND = NN+IDET        
      NNI = NN+IPDETA        
      CALL EADD(-PS(NNP),PREC)        
      CALL DETDET(DET(NND),IPDET(NNI),PS(NNP),SML1,0.0D0,1)        
   40 CONTINUE        
      N2EV2 = IADD + ND        
      DO 50 I=1,N2EV2        
      NND = I+IDET        
      NNP = I+IPS        
      NNI = I+IPDETA        
      DET(NND) = DET(NND)/(PS(NNP)-P(3))        
      CALL DETM6(DET(NND),IPDET(NNI))        
   50 CONTINUE        
      DO 60 I=1,3        
   60 DET1(I) = DET1(I)/(PS1(I)-P(3))        
      RETURN        
      END        
