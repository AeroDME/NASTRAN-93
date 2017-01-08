      SUBROUTINE TIGER (IG,LIST,INV,II3,NORIG,KG,JG)        
C        
C     THIS ROUTINE MAKES ADDITIONS TO THE CONNECTION TABLE IG TO REFLECT
C     THE PRESENCE OF MPC'S AND STORES THE DEPENDENT POINTS IN LIST.    
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     NEQ =NUMBER OF MPC EQUATIONS.        
C     NEQR=NUMBER OF MPC EQUATIONS COMING FROM RIGID ELEMENTS        
C        
      INTEGER          SCR1,     BUNPK,    RDREW,    RD,       REW      
      DIMENSION        IG(1),    LIST(1),  NORIG(1), KG(1),    SUB(2),  
     1                 JG(1),    INV(II3,1)        
      COMMON /BANDA /  IBUF1,    NOMPC,    NODEP        
      COMMON /BANDB /  DUM6B(6), KDIM        
      COMMON /BANDD /  DUM(7),   NEQ,      NEQR        
      COMMON /BANDS /  NN,       MM,       DUM2S(2), MAXGRD,   MAXDEG,  
     1                 DUM3S(3), NEDGE        
      COMMON /GEOMX /  GDUM(3),  SCR1        
      COMMON /SYSTEM/  IBUF,     NOUT        
      COMMON /NAMES /  RD,       RDREW,    NDUM(2),  REW        
CZZ   COMMON /ZZBAND/  IZ(1)        
      COMMON /ZZZZZZ/  IZ(1)        
      DATA             SUB /     4HTIGE, 4HR   /        
C        
      IF (NEQ+NEQR .EQ. 0) GO TO 170        
      KDIM4=KDIM*4        
      CALL OPEN (*200,SCR1,IZ(IBUF1),RDREW)        
C        
C     GENERATE NEW CONNECTIONS.        
C     TWO PASSES.   FIRST PASS FOR MPC CARDS, AND SECOND FOR RIGID ELEM.
C        
      DO 60 JJ=1,2        
      IF (JJ .EQ. 1) NQ=NEQ        
      IF (JJ .EQ. 2) NQ=NEQR        
      IF (NQ .EQ. 0) GO TO 60        
C        
C     READ MPC EQUATIONS AND RIGID ELEMENT GRIDS        
C     AND CONVERT ORIGINAL GRID NOS. TO INTERNAL LABELS.        
C        
      DO 50 II=1,NQ        
      CALL READ (*210,*210,SCR1,NTERM,1,0,M)        
      KK=1        
      J2=2        
      IF (JJ .EQ. 1) GO TO 10        
      K=MOD(NTERM,1000)        
      NTERM=NTERM/1000        
      KK=NTERM-K        
      J2=NTERM        
   10 IF (NTERM.GT.KDIM4) GO TO 70        
      CALL READ (*210,*210,SCR1,KG,NTERM,1,M)        
      CALL SCAT (KG,NTERM,INV,II3,NORIG)        
C        
      DO 40 K=1,KK        
      IGRID=KG(K)        
      IF (NODEP.EQ.+1) LIST(IGRID)=IGRID        
C        
C     IGRID=DEPENDENT GRID POINT IN AN MPC EQUATION.        
C        
      CALL BUNPAK(IG,IGRID,MAXDEG,JG)        
      DO 30 I=1,MAXDEG        
C     L=BUNPK(IG,IGRID,I)        
      L=JG(I)        
      IF (L.LE.0) GO TO 40        
C        
C     L= A GRID POINT THAT IGRID IS CONNECTED TO BEFORE THE MPC IS APPLI
C        
      IF (NTERM.LT.2) GO TO 30        
      DO 20 J=J2,NTERM        
      CALL SETIG (L,KG(J),IG,NORIG)        
   20 CONTINUE        
   30 CONTINUE        
   40 CONTINUE        
   50 CONTINUE        
   60 CONTINUE        
      GO TO 90        
C        
   70 WRITE (NOUT,80)        
   80 FORMAT (72H0*** MPC CARDS NOT PROCESSED IN BANDIT DUE TO INSUFFICI
     1ENT SCRATCH SPACE,//)        
      NEQ =0        
      NEQR=0        
   90 CALL CLOSE (SCR1,REW)        
C        
C     QUIT HERE IF MPC DEPENDENT POINTS ARE NOT TO BE DELETED FROM THE  
C     CONNECTION TABLE IG.        
C        
      IF (NODEP.NE.+1) GO TO 170        
C        
C     COMPRESS OUT ZEROS FORM LIST        
C        
      N=0        
      DO 110 I=1,NN        
      IF (LIST(I).EQ.0) GO TO 110        
      N=N+1        
      LIST(N)=LIST(I)        
  110 CONTINUE        
C        
C     DELETES ALL REFERENCE IN THE CONNECTION TABLE IG TO THOSE POINTS  
C     IN LIST        
C        
      IF (N.LE.0) GO TO 170        
      MM1=MM-1        
      DO 160 II=1,N        
      I=LIST(II)        
      CALL BUNPAK (IG,I,MM,JG)        
      DO 150 J=1,MM        
C     L=BUNPK(IG,I,J)        
      L=JG(J)        
      IF (L.EQ.0) GO TO 160        
      NEDGE=NEDGE-1        
      K=0        
  120 K=K+1        
      M=BUNPK(IG,L,K)        
      IF (M.NE. I) GO TO 120        
      IF (K.GE.MM) GO TO 140        
      DO 130 NP=K,MM1        
      IS=BUNPK(IG,L,NP+1)        
  130 CALL BPACK (IG,L,NP,IS)        
  140 CALL BPACK (IG,L,MM1+1,0)        
      CALL BPACK (IG,I,J,0)        
  150 CONTINUE        
  160 CONTINUE        
  170 RETURN        
C        
C     SCR1 FILE ERROR        
C        
  200 K=-1        
      GO TO 220        
  210 K=-2        
  220 CALL MESAGE (K,SCR1,SUB)        
      RETURN        
      END        
