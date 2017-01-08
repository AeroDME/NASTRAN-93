      SUBROUTINE STRM62 (TI)        
C        
C        
C     PHASE II OF STRESS DATA RECOVERY FOR TRIANGULAR MEMBRANE ELEMENT  
C     TRIM6        
C        
C     PHASE I OUTPUT IS THE FOLLOWING        
C        
C     PH1OUT(1)               ELEMENT ID        
C     PH1OUT(2, THRU 7)       6 S1L5        
C     PH1OUT(8 THRU 10)       THICKNESSES AT CORNER GRID POINT        
C     PH1OUT(11)              REFERENCE TEMPERATURE        
C     PH1OUT(12)-(227)        S SUB I MATRICES FOR 4 POINTS        
C     PH1OUT(228)-(230)       THERMAL VECTOR - G TIMES ALPHA        
C        
C        
      INTEGER         TLOADS        
      DIMENSION       TI(6),NS1L(6),NPH1OU(990),STR(18),SI(36),        
     1                STOUT(99),STRESS(3)        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SDR2X4/ DUMMY(35),IVEC,IVECN,LDTEMP,DEFORM,DUM8(8),TLOADS 
      COMMON /SDR2X7/ PH1OUT(250)        
      COMMON /SDR2X8/ TEMP,DELTA,NPOINT,IJ1,IJ2,NPT1,VEC(5),TEM        
      EQUIVALENCE     (NS1L(1),PH1OUT(2)),(NPH1OU(1),PH1OUT(1)),        
     1                (SI(1),PH1OUT(11)),(LDTEMP,FTEMP)        
C        
      DO 155 II=1,4        
C        
C     ZERO OUT LOCAL STRESSES        
C        
      SIG X  1 =0.0        
      SIG Y  1 =0.0        
      SIG XY 1 =0.0        
      SIG X  2 =0.0        
      SIG Y  2 =0.0        
      SIG XY 2 =0.0        
      IF (NS1L(1).EQ.0) GO TO 90        
C        
C     ZERO STRESS VECTOR STORAGE        
C        
      DO 42 I=1,3        
      STRESS(I)=0.0        
   42 CONTINUE        
C        
C                        I=6        
C     STRESS VECTOR =(SUMMATION (5 )(U ) ) - (S )(TEMP      - TEMP   )  
C                        I=1      I   I        T      POINT       REF   
C        
      DO 60 I=1,6        
C        
C     POINTER TO I-TH SIL IN PH1OUT        
C        
      NPOINT = IVEC + NPH1OU(I+1) - 1        
C        
C     POINTER TO  3X3 S SUB I MATRIX        
C        
      NPT1=12+(I-1)*9+(II-1)*54        
C        
      CALL GMMATS (PH1OUT(NPT1),3,3,0,Z(NPOINT),3,1,0,VEC(1))        
      DO 50 J=1,3        
      STRESS(J)=STRESS(J)+VEC(J)        
      STR(J)=STRESS(J)        
   50 CONTINUE        
   60 CONTINUE        
      IF (LDTEMP.EQ.(-1)) GO TO 80        
      II12=II*2-1        
      IF (II.NE.4) TEM=TI(II12)-PH1OUT(11)        
      IF( II.EQ.4) TEM=(TI(1)+TI(2)+TI(3)+TI(4)+TI(5)+TI(6))/6.0-       
     1    PH1OUT(11)        
      DO 70 I=1,3        
      STRESS(I)=STRESS(I)-PH1OUT(227+I)*TEM        
      STR(I)=STRESS(I)        
   70 CONTINUE        
   80 CONTINUE        
   90 IF (NPH1OU(2).EQ.0) GO TO 120        
C        
C     COMPUTE PRINCIPAL STRESSES        
C        
C        
C     8 LOCATIONS FOR STRESS AT A POINT AS FOLLOWS        
C        
C      1. ELEMENT ID        
C      2. SIGMA X1        
C      3. SIGMA Y1        
C      4. SIGMA XY1        
C      5. ANGLE OF ZERO SHEAR        
C      6. SIGMA PRINCIPAL STRESS 1        
C      7. SIGMA PRINCIPAL STRESS 2        
C      8. TAU MAX        
C        
C     FOR EACH POINT, THESE VALUES ARE STORED IN STOUT(1-8,9-16,        
C     17-24,25-32) ALSO IN LOCATIONS STR(1-7) EXCEPT THE ELEMENT ID     
C     FINALLY, THESE VALUES ARE STORED IN PH1OUT(101-108,109-115,       
C     116-122,123-129)        
C        
      TEMP = STRESS(1)-STRESS(2)        
      TEMP1= SQRT ((TEMP/2.0E0)**2 + STRESS(3)**2)        
      STR(7)= TEMP1        
      DELTA= (STRESS(1)+STRESS(2))/2.0        
      STR(5)=DELTA+TEMP1        
      STR(6)=DELTA-TEMP1        
      DELTA= 2.0E0 * STRESS(3)        
      IF (ABS(DELTA).LT.1.0E-15.AND.ABS(TEMP).LT.1.0E-15) GO TO 100     
      STR(4)=ATAN2(DELTA,TEMP)*28.6478898E0        
      GO TO 110        
  100 STR(4)=0.0        
  110 CONTINUE        
      GO TO 140        
  120 DO 130 I=1,9        
      STR(I)=0.0E0        
  130 CONTINUE        
  140 CONTINUE        
      IJK=(II-1)*8        
      STOUT(IJK+1)=PH1OUT(1)        
      DO 149 I=2,8        
  149 STOUT(IJK+I)=STR(I-1)        
  155 CONTINUE        
      DO 156 I=1,8        
  156 PH1OUT(100+I)=STOUT(I)        
      DO 159 J=1,3        
      DO 159 I=1,7        
      J1=108+(J-1)*7+I        
      J2=J*8+I+1        
      PH1OUT(J1)=STOUT(J2)        
  159 CONTINUE        
      RETURN        
      END        
