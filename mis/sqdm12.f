      SUBROUTINE SQDM12        
C        
C      PHASE TWO STRESS DATA RECOVERY QUADRILATERAL MEMBRANE        
C        
C      ELEMENT ID        
C      4 SILS        
C      T SUB 0        
C      S SUB T 3X1        
C      4 S ARRAYS EACH 3X3        
C        
C        
C     STRES(1) - PH1OUT(1)        
C     STRES(2) - SIGMA X        
C     STRES(3) - SIGMA Y        
C     STRES(4) - SIGMA XY        
C     STRES(5) - PHI 1 ANGLE OF PRINCIPAL DIRECTION OF STRESS        
C     STRES(6) - SIGMA 1        
C     STRES(7) - SIGMA 2        
C     STRES(8) - TAU MAXIMUM SHEAR STRESS        
C        
      DIMENSION NSIL(4),S(36),ST(3),FRLAST(2),PH1OUT(45)        
      INTEGER EJECT,ISHED(7),ISTYP(2)        
C        
      COMMON   /SYSTEM/  IBFSZ    ,NOUT     ,IDM(9)   ,LINE        
CZZ   COMMON   /ZZSDR2/ Z(1)        
      COMMON   /ZZZZZZ/ Z(1)        
      COMMON   /SDR2X4/ DUMMY(35),IVEC,IVECN,LDTEMP,DEFORM        
      COMMON   /SDR2X7/ EST(100),STRES(100),FORVEC(25)        
      COMMON   /SDR2X8/ STRESS(3),VEC(3),TEM,TEMP,NPOINT,DELTA,NSIZE,   
     1      CSTRS(4),CVC(3)        
      COMMON /SDR2X9/ NCHK,ISUB,ILD,FRTMEI(2),TWOTOP,FNCHK        
C        
      EQUIVALENCE (PH1OUT(1),EST(1)) , (NSIL(1),PH1OUT(2)) ,        
     1 (TSUB0,PH1OUT(6)) , (ST(1),PH1OUT(7)) , (S(1),PH1OUT(10))        
     2, (FTEMP,LDTEMP) , (ISHED(1),LSUB) , (ISHED(2),LLD)        
     3, (ISHED(6),FRLAST(1))        
      DATA ISTYP / 4HQDME, 2HM1 /        
      DATA LSUB,LLD,FRLAST / 2*-1, -1.0E30, -1.0E30 /        
C        
C      ZERO OUT THE STRESS VECTOR        
C        
      STRESS(1)=0.        
      STRESS(2)=0.        
      STRESS(3)=0.        
      CSTRS(2) = 0.0E0        
      CSTRS(3) = 0.0E0        
      CSTRS(4) = 0.0E0        
C        
C                           I=4                      -        
C         STRESS VECTOR =(SUMMATION (S )(U )) - (S )(T - T)        
C                           I=1       I   I       T       0        
      DO 3 I=1,4        
      NPOINT=IVEC+NSIL(I)-1        
      CALL SMMATS (S(9*I-8),3,3,0, Z(NPOINT),3,1,0, VEC(1),CVC(1))      
      DO 2 J=1,3        
      IF (NCHK.LE.0)GO TO 1        
      CSTRS(J+1) = CSTRS(J+1) + CVC(J)        
    1 STRESS(J) = STRESS(J) + VEC(J)        
    2 CONTINUE        
    3 CONTINUE        
      STRES(1) = PH1OUT(1)        
      STRES(2) = STRESS(1)        
      STRES(3) = STRESS(2)        
      STRES(4) = STRESS(3)        
      CSTRS(1) = STRES(1)        
C        
C      ADD IN TEMPERATURE EFFECTS        
C        
      IF(LDTEMP.EQ.(-1)) GO TO 200        
      TEM = FTEMP-TSUB0        
      DO 4 I=2,4        
      STRES(I)=STRES(I)-ST(I-1)*TEM        
    4 CONTINUE        
C        
C      STRESS VECTOR COMPLETE AND CONTAINS SIGMA X ,  SIGMA Y ,  SIGMA X
C        
C      PRINCIPAL STRESSES AND ANGLE OF ACTION PHI        
C        
  200 TEMP=STRES(2)-STRES(3)        
C        
C     COMPUTE TAU        
C        
      STRES(8)=SQRT((TEMP/2.0E0)**2+STRES(4)**2)        
      DELTA=(STRES(2)+STRES(3))/2.0E0        
C        
C     COMPUTE SIGMA 1 AND SIGMA 2        
C        
      STRES(6)=DELTA+STRES(8)        
      STRES(7)=DELTA-STRES(8)        
      DELTA=2.0E0*STRES(4)        
      IF (ABS(DELTA).LT.1.0E-15.AND.ABS(TEMP).LT.1.0E-15) GO TO 5       
      IF(ABS(TEMP) .LT. 1.0E-15) GO TO 6        
C        
C     COMPUTE PHI 1 DEPENDING ON WHETHER OR NOT SIGMA XY AND/OR        
C               (SIGMA 1 - SIGMA 2) ARE ZERO        
C        
      STRES(5)=ATAN2(DELTA,TEMP)*28.6478898E00        
      GO TO 7        
    5 STRES(5)=0.0E0        
      GO TO 7        
    6 STRES(5)=45.        
    7 IF (NCHK.LE.0) GO TO 150        
C        
C  . STRESS PRECISION CHECK...        
C        
      K = 0        
      CALL SDRCHK (STRES(2),CSTRS(2),3,K)        
      IF (K.EQ.0) GO TO 150        
C        
C  . LIMITS EXCEEDED...        
      J = 0        
      IF (LSUB.EQ.ISUB .AND. FRLAST(1).EQ.FRTMEI(1) .AND.        
     1    LLD  .EQ.ILD  .AND. FRLAST(2).EQ.FRTMEI(2)) GO TO 120        
C        
      LSUB = ISUB        
      FRLAST(1) = FRTMEI(1)        
      FRLAST(2) = FRTMEI(2)        
      LLD = ILD        
      J = 1        
      CALL PAGE1        
  100 CALL SD2RHD (ISHED,J)        
      WRITE(NOUT,110)        
      LINE = LINE + 1        
  110 FORMAT (7X,4HTYPE,5X,3HEID,5X,2HSX,5X,2HSY,4X,3HSXY)        
      GO TO 130        
  120 IF (EJECT (2) .NE. 0) GO TO 100        
C        
  130 WRITE(NOUT,140) ISTYP,CSTRS        
  140 FORMAT (1H0,5X,A4,A2,I7,4F7.1)        
C        
  150 CONTINUE        
      RETURN        
      END        
