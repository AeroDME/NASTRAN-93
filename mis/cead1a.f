      SUBROUTINE CEAD1A (LAMI,PHIDI,PHIDLI,LAMD,PHID,PHIDL,NFOUND,NVECT,
     * CAPP)        
C        
C     ROUTINE SORTS LAMI, PHIDI AND PHIDLI (INV. POWER), BASED ON LAMI, 
C     AND CREATES LAMD, PHID AND PHIDL        
C        
      DOUBLE PRECISION ZD(1),D1,D2        
      INTEGER PHIDI,PHID,SYSBUF,IZ(1),IH(7),FILE        
      INTEGER NAME(2)        
      INTEGER CAPP,DET,HES        
      INTEGER FILEK,FILEM,FILEB        
      INTEGER PHIDLI,PHIDL        
C        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /OUTPUT/HEAD(1)        
CZZ   COMMON /ZZCEA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /CINVPX/ FILEK(7),FILEM(7),FILEB(7)        
      COMMON /CONDAS/    PI       ,TWOPI    ,RADEG    ,DEGRA    ,       
     1                   S4PISQ        
      COMMON /PACKX/ IT1,IT2,II,JJ,INCUR        
C        
      EQUIVALENCE ( KSYSTM( 1) , SYSBUF )        
      EQUIVALENCE (IZ(1),Z(1)),(Z(1),ZD(1))        
C        
      DATA NAME/4HCEAD,4H1A  /        
      DATA IH / 7*0 /        
      DATA DET,HES / 4HDET ,4HHESS /        
C        
C     INITIALIZE POINTER ARRAY        
C        
      DO 10 I=1,NFOUND        
      IZ(I)= I        
   10 CONTINUE        
C        
C     BRING IN  EIGENVALUES        
C        
      ILAMA =(NFOUND+1)/2  +1        
      IBUF = KORSZ(IZ)-SYSBUF+1        
      FILE = LAMI        
      CALL OPEN(*170,LAMI,IZ(IBUF),0)        
      K =ILAMA        
      DO 20 I=1,NFOUND        
      CALL READ(*190,*200,LAMI,ZD(K),4,1,IFLAG)        
      K= K +2        
   20 CONTINUE        
      CALL CLOSE(LAMI,1)        
      IF(NFOUND .EQ.1) GO TO 70        
C        
C        
C     SORT ON SIGN IMAGINARY THEN ON MAG IMAG        
C        
      JJ = NFOUND-1        
      DO 60 I=1,JJ        
      II = I+1        
      M  = ILAMA+ 2*I -2        
      DO 50 J=II,NFOUND        
      L =  ILAMA +2*J-2        
C        
C     SIGN IMAG        
C        
      D1 = DSIGN(1.0D0,ZD(L+1))        
      D2 = DSIGN(1.0D0,ZD(M+1))        
      IF(D1 .EQ. D2) GO TO 40        
      IF( D1 .EQ. 1.0D0)GO TO 50        
C        
C     SWITCH        
C        
   30 D1 = ZD(L)        
      ZD(L) =ZD(M)        
      ZD(M)=D1        
      D1 =ZD(L+1)        
      ZD(L+1)=ZD(M+1)        
      ZD(M+1)=D1        
      IT1 = IZ(J)        
      IZ(J)= IZ(I)        
      IZ(I)= IT1        
      GO TO 50        
C        
C     TEST MAGNITIDE IMAG        
C        
   40 IF(DABS(ZD(L+1)) -DABS(ZD(M+1))) 30,50,50        
   50 CONTINUE        
   60 CONTINUE        
C        
C     PUT OUT LAMA-S IN ORDER GIVEN BY LIST        
C        
   70 CALL GOPEN(LAMD,IZ(IBUF),1)        
      IH(2) =1006        
      IH(1) = 90        
      CALL WRITE(LAMD,  IH, 4,0)        
      IH(6) = 6        
      CALL WRITE(LAMD,  IH, 6,0)        
      CALL WRITE(LAMD,  IZ,40,0)        
      CALL WRITE(LAMD,HEAD,96,1)        
      L = 5*NFOUND +2        
      DO 90 I=1,NFOUND        
      IZ(L)=I        
      IZ(L+1)=IZ(I)        
      K = 2*I-2+ILAMA        
      Z(L+2) =ZD(K)        
      Z(L+3) = ZD(K+1)        
      Z(L+4) = 0.0        
      Z(L+5) = 0.0        
      IF(ABS(Z(L+3)) .LE. 1.0E-3*ABS(Z(L+2))) GO TO 80        
      Z(L+4) = ABS(Z(L+3))/TWOPI        
      Z(L+5) = -2.0*Z(L+2)/ABS(Z(L+3))        
   80 CALL WRITE(LAMD,IZ(L),6,0)        
   90 CONTINUE        
      CALL CLOSE(LAMD,1)        
      IH(1) =LAMD        
      CALL WRTTRL(IH)        
C        
C     BRING IN PHIDI IN ORDER NEEDED AND OUTPUT        
C        
      IBUF1 = IBUF -SYSBUF        
      CALL GOPEN(PHID,IZ(IBUF1),1)        
      IT1 = 4        
      IT2 = 3        
      INCUR =1        
      II =1        
      IH(1)=PHID        
      IH(2)= 0        
      IH(4) =2        
      IH(5) =3        
      IH(6) = 0        
      K = 1        
  101 IF(IZ(K) .LE. NVECT) GO TO 111        
      K = K+1        
      GO TO 101        
  111 FILE = PHIDI        
      IPOS =1        
      CALL OPEN(*170,PHIDI,IZ(IBUF),0)        
      DO 160 I=1,NVECT        
      IF (NVECT .EQ. 1) GO TO 130        
  100 L= IZ(I)-IPOS        
      IF(L) 150,130,110        
  110 CALL SKPREC(PHIDI,L)        
C        
C     BRING IN EIGENVECTORS        
C        
  130 CALL READ(*190,*140,PHIDI,ZD(ILAMA),IBUF1-1,0,M)        
      GO TO 210        
  140 JJ= M/4        
      IPOS = IZ(K) +1        
      CALL PACK(ZD(ILAMA),PHID,IH)        
      GO TO 159        
C        
C     PAST VECTOR NEEDED        
C        
  150 CALL REWIND(PHIDI)        
      IPOS =1        
      GO TO 100        
  159 K = K+1        
  160 CONTINUE        
      CALL CLOSE(PHID,1)        
      CALL CLOSE(PHIDI,1)        
      IH(3) =JJ        
      CALL WRTTRL(IH)        
C        
C     OUTPUT PHIDL IF NOT PURGED AND IF AT LEAST ONE INPUT MATRIX IS    
C     UNSYMMETRIC        
C        
      IH(1) = PHIDL        
      CALL RDTRL (IH)        
      IF (IH(1) .LT. 0) RETURN        
      IF (CAPP .NE. DET .AND. CAPP .NE. HES) GO TO 301        
      FILEK(1) = 101        
      CALL RDTRL (FILEK)        
      FILEM(1) = 103        
      CALL RDTRL (FILEM)        
      FILEB(1) = 102        
      CALL RDTRL (FILEB)        
  301 IF (FILEK(1) .GT. 0 .AND. FILEK(4) .NE. 6) GO TO 302        
      IF (FILEM(1) .GT. 0 .AND. FILEM(4) .NE. 6) GO TO 302        
      IF (FILEB(1) .GT. 0 .AND. FILEB(4) .NE. 6) GO TO 302        
      RETURN        
  302 CALL GOPEN (PHIDL,IZ(IBUF1),1)        
      CALL MAKMCB (IH,PHIDL,0,2,3)        
      IF (CAPP .NE. DET .AND. CAPP .NE. HES) GO TO 305        
      CALL CLVEC (LAMD,NVECT,PHIDL,IH,IBUF,IBUF1)        
      GO TO 395        
  305 K = 1        
  310 IF (IZ(K) .LE. NVECT) GO TO 320        
      K = K + 1        
      GO TO 310        
  320 FILE = PHIDLI        
      IPOS = 1        
      CALL OPEN(*170,PHIDLI,IZ(IBUF),0)        
      DO 390 I=1,NVECT        
      IF (NVECT .EQ. 1) GO TO 350        
  330 L = IZ(I) - IPOS        
      IF (L) 370,350,340        
  340 CALL SKPREC (PHIDLI,L)        
C        
C     BRING IN LEFT EIGENVECTORS        
C        
  350 CALL READ(*190,*360,PHIDLI,ZD(ILAMA),IBUF1-1,0,M)        
      GO TO 210        
  360 JJ = M/4        
      IPOS = IZ(K) + 1        
      CALL PACK (ZD(ILAMA),PHIDL,IH)        
      GO TO 380        
C        
C     PAST VECTOR NEEDED        
C        
  370 CALL REWIND (PHIDLI)        
      IPOS = 1        
      GO TO 330        
  380 K = K + 1        
  390 CONTINUE        
      CALL CLOSE (PHIDLI,1)        
  395 CALL CLOSE (PHIDL,1)        
      IH(3) = JJ        
      CALL WRTTRL (IH)        
      RETURN        
C        
C     ERROR MESAGES        
C        
  170 IP1 =-1        
  180 CALL MESAGE(IP1,FILE,NAME)        
  190 IP1 =-2        
      GO TO 180        
  200 IP1 = -3        
      GO TO 180        
  210 IP1 = -8        
      GO TO 180        
      END        
