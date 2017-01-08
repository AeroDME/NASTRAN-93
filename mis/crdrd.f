      SUBROUTINE CRDRD (*,*,MU,INDCOM,N23)        
C        
C     WRITE THE RIGID ROD ELEMENT ON THE RG FILE        
C        
C     EXTERNAL        ORF    ,LSHIFT        
C     INTEGER         ORF    ,LSHIFT        
      INTEGER         GEOMP  ,BGPDT  ,CSTM   ,RGT    ,SCR1   ,        
     1                BUF(20),MASK16 ,GPOINT ,Z      ,MCODE(2)        
      REAL            INDTFM(9),DEPTFM(9),RODCOS(3),IDRCOS(3),        
     1                DDRCOS(3),DZ(1),XD     ,YD     ,ZD     ,        
     2                RLNGTH ,CDEP   ,RZ(1)        
      COMMON /MACHIN/ MAC    ,IHALF  ,JHALF        
CZZ   COMMON /ZZGP4X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /GP4FIL/ GEOMP  ,BGPDT  ,CSTM   ,RGT    ,SCR1        
      COMMON /GP4PRM/ BUF    ,BUF1   ,BUF2   ,BUF3   ,BUF4   ,        
     1                KNKL1  ,MASK16 ,NOGO   ,GPOINT ,KN        
      EQUIVALENCE     (Z(1)  ,DZ(1)  ,RZ(1))        
C        
C     INDTFM = INDEPENDENT GRID POINT TRANSFORMATION MATRIX        
C     DEPTFM = DEPENDENT GRID POINT TRANSFORMATION MATRIX        
C     RODCOS = BASIC COSINES OF ROD ELEMENT        
C     IDRCOS = DIRECTION COSINES OF INDEPENDENT GRID POINT        
C     DDRCOS = DIRECTION COSINES OF DEPENDENT GRID POINT        
C        
      MASK15 = JHALF/2        
C        
C     OBTAIN TRANSFORMATION MATRIX        
C        
      IF (Z(KNKL1+3) .EQ. 0) GO TO 50        
      DO 10 I = 1,4        
      BUF(I) = Z(KNKL1+2+I)        
   10 CONTINUE        
      CALL TRANSS (BUF,INDTFM)        
   50 IF (Z(KNKL1+10) .EQ. 0) GO TO 70        
      DO 60 I = 1,4        
      BUF(I) = Z(KNKL1+9+I)        
   60 CONTINUE        
      CALL TRANSS (BUF,DEPTFM)        
C        
C     COMPUTE THE LENGTH OF THE RIGID ROD ELEMENT        
C        
   70 XD = RZ(KNKL1+11) - RZ(KNKL1+4)        
      YD = RZ(KNKL1+12) - RZ(KNKL1+5)        
      ZD = RZ(KNKL1+13) - RZ(KNKL1+6)        
C        
C     CHECK TO SEE IF LENGTH OF ROD IS ZERO        
C        
      IF (XD.EQ.0.0 .AND. YD.EQ.0.0 .AND. ZD.EQ.0.0) RETURN 1        
      RLNGTH = SQRT(XD*XD + YD*YD + ZD*ZD)        
C        
C     COMPUTE THE BASIC DIRECTION COSINES OF THE RIGID ROD ELEMENT      
C        
      RODCOS(1) = XD/RLNGTH        
      RODCOS(2) = YD/RLNGTH        
      RODCOS(3) = ZD/RLNGTH        
C        
C     OBTAIN THE DIRECTION COSINES ASSOCIATED WITH        
C     THE INDEPENDENT GRID POINT        
C        
      IF (Z(KNKL1+3) .NE. 0) GO TO 100        
      DO 80 I = 1,3        
      IDRCOS(I) = RODCOS(I)        
   80 CONTINUE        
      GO TO 200        
  100 CALL GMMATS (RODCOS,1,3,0, INDTFM,3,3,0, IDRCOS)        
C        
C     OBTAIN THE DIRECTION COSINES ASSOCIATED WITH        
C     THE DEPENDENT GRID POINT        
C        
  200 IF (Z(KNKL1+10) .NE. 0) GO TO 300        
      DO 250 I = 1,3        
      DDRCOS(I) = RODCOS(I)        
  250 CONTINUE        
      GO TO 400        
  300 CALL GMMATS (RODCOS,1,3,0, DEPTFM,3,3,0, DDRCOS)        
C        
C     DETERMINE THE DEPENDENT SIL AND THE CORRESPONDING COEFFICIENT     
C        
  400 DO 500 I = 1,3        
      IF (INDCOM .NE. I) GO TO 500        
      IDEP = Z(KNKL1+6+I)        
      CDEP = RODCOS(I)        
      GO TO 600        
  500 CONTINUE        
C        
C     CHECK TO SEE IF RIGID ROD IS PROPERLY DEFINED        
C        
  600 IF (ABS(CDEP) .LT. 0.0) RETURN 2        
      MCODE(2) = IDEP        
      IF (IDEP .GT. MASK15) N23 = 3        
      DO 700 I = 1,3        
C     MCODE = ORF(LSHIFT(Z(KNKL1+I-1),IHALF),IDEP)        
      MCODE(1) = Z(KNKL1+I-1)        
      IF (MCODE(1) .GT. MASK15) N23 = 3        
      COEFF = -IDRCOS(I)/CDEP        
      CALL WRITE (RGT,MCODE,2,0)        
      CALL WRITE (RGT,COEFF,1,0)        
C     MCODE = ORF(LSHIFT(Z(KNKL1+6+I),IHALF),IDEP)        
      MCODE(1) = Z(KNKL1+6+I)        
      IF (MCODE(1) .GT. MASK15) N23 = 3        
      COEFF = DDRCOS(I)/CDEP        
      CALL WRITE (RGT,MCODE,2,0)        
      CALL WRITE (RGT,COEFF,1,0)        
  700 CONTINUE        
      Z(MU) = IDEP        
      MU = MU - 1        
      RETURN        
      END        
