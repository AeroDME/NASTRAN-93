      SUBROUTINE MASSTQ(NARG)
C     ******************************************************************
C     E C P T    L I S T I N G S
C     **************************
C         MTWIST              MQDMEM                        MTRMEM
C         MSHEAR    MQUAD1    MQUAD2    MTRIA1    MTRBSC    MTRIA2
C **********************************************************************
C ECPT( 1)ELEM. ID  ELEM. ID  ELEM. ID  ELEM. ID  ELEM. ID  ELEM. ID
C ECPT( 2)GR.PT. A  GR.PT. A  GR.PT. A  GR.PT. A  GR.PT. A  GR.PT. A
C ECPT( 3)GR.PT. B  GR.PT. B  GR.PT. B  GR.PT. B  GR.PT. B  GR.PT. B
C ECPT( 4)GR.PT. C  GR.PT. C  GR.PT. C  GR.PT. C  GR.PT. C  GR.PT. C
C ECPT( 5)GR.PT. D  GR.PT. D  GR.PT. D  THETA     THETA     THETA
C ECPT( 6)MAT ID    THETA     THETA     MAT ID 1  MAT ID 1  MAT ID
C ECPT( 7)T         MAT ID 1  MAT ID    T1        I         T
C ECPT( 8)N S MASS  T1        T         MAT ID 2  MAT ID 2  NS MASS
C ECPT( 9)CSID 1    MAT ID 2  N S MASS  I         T2        CSID 1
C ECPT(10)X1        I         CSID 1    MAT ID 3  N S MASS  X1
C ECPT(11)Y1        MAT ID 3  X1        T2        Z1        Y1
C ECPT(12)Z1        T2        Y1        N S MASS  Z2        Z1
C ECPT(13)CSID 2    N S MASS  Z1        Z1        CSID 1    CSID 2
C ECPT(14)X2        Z1        CSID 2    Z2        X1        X2
C ECPT(15)Y2        Z2        X2        CSID 1    Y1        Y2
C ECPT(16)Z2        CSID 1    Y2        X1        Z1        Z2
C ECPT(17)CSID 3    X1        Z2        Y1        CSID 2    CSID 3
C ECPT(18)X3        Y1        CSID 3    Z1        X2        X3
C ECPT(19)Y3        Z1        X3        CSID 2    Y2        Y3
C ECPT(20)Z3        CSID 2    Y3        X2        Z2        Z3
C ECPT(21)CSID 4    X2        Z3        Y2        CSID 3    TEMP
C ECPT(22)X4        Y2        CSID 4    Z2        X3
C ECPT(23)Y4        Z2        X4        CSID 3    Y3
C ECPT(24)Z4        CSID 3    Y4        X3        Z3
C ECPT(25)TEMP      X3        Z4        Y3        TEMP
C ECPT(26)          Y3        TEMP      Z3
C ECPT(27)          Z3                  TEMP
C ECPT(28)          CSID 4
C ECPT(29)          X4
C ECPT(30)          Y4
C ECPT(31)          Z4
C ECPT(32)          TEMP
C **********************************************************************
C
      DOUBLE PRECISION  MASS
      DIMENSION NECPT (7)
      LOGICAL HEAT
      COMMON /SMA2HT/ HEAT
      COMMON /HMTOUT/ CP
      COMMON /MATIN/ MATID,INFLAG,ELTEMP
      COMMON /MATOUT/ RHO
C     COMMON /MATOUT/RHO
      COMMON /SMA2ET/ ECPT(100)
      COMMON /SMA2IO/ DUM4(10),IFMGG,DUMXX(1), IFBGG
      COMMON /SMA2CL/  IOPTB, BGGIND, NPVT
      COMMON /SMA2DP/    MASS(36)      ,V1(3)
     1                  ,V1XV2(3)      ,V2(3)
     2                  ,TERM
     3                  ,T             ,FMU
     4                  ,NPT1          ,NPT3
     5                  ,NPT2          ,NPT4
     6                  ,ISUB1         ,ISUB3
     7                  ,ISUB2         ,NCSID
     8                  ,ICHEK         ,NTYPE
     9                  ,NPIVOT        ,AREA
     T                  ,DUMMY(504)
      EQUIVALENCE ( NECPT(1) , ECPT(1) )
      EQUIVALENCE (IFLAG , ECPT(8) )
      DATA PI23/2.0943952/                                              
C                                                                       
C     THIS ROUTINE COMPUTES A MASS MATRIX OF THE FOLLOWING FORM.
C
C                     TERM 0   0   0   0   0
C                      0  TERM 0   0   0   0
C                      0   0  TERM 0   0   0
C      MASS MATRIX =   0   0   0   0   0   0
C                      0   0   0   0   0   0
C                      0   0   0   0   0   0
C
C                   *******************
C                   NTYPE = 1  -MQDMEM-
C                   NTYPE = 1  -MQUAD2-
C                   NTYPE = 2  -MQUAD1-
C                   NTYPE = 3  -MTRBSC-
C                   NTYPE = 3  -MTRPLT-
C                   NTYPE = 4  -MTRMEM-
C                   NTYPE = 4  -MTRIA2-
C                   NTYPE = 5  -MTRIA1-
C                   NTYPE = 6  -MSHEAR-
C                   NTYPE = 6  -MTWIST-
C                   NTYPE = 7  -MQDPLT-
C                   *******************
C
      NTYPE = NARG
C
C            -MQDMEM-      -MTRPLT-MTRMEM-      -MTWIST-
C            -MQUAD2-MQUAD1-MTRBSC-MTRIA2-MTRIA1-MSHEAR-MQDPLT-
      GO TO(10,20,30,40,50,60,70),NTYPE
C
   10 NCSID = 10
      MATID = NECPT(7)
      T     = ECPT(8)
      FMU   = ECPT(9)
      GO TO 80
C
   20 NCSID = 16
      MATID = NECPT(7)
      T     = ECPT(8)
      FMU   = ECPT(13)
      GO TO 80
C
   30 NCSID =  13
      MATID = NECPT( 6)
      T     =  0.0E0
      FMU   =  ECPT(10)
      GO TO 80
C
   40 NCSID = 9
      MATID = NECPT(6)
      T     = ECPT(7)
      FMU   = ECPT(8)
      GO TO 80
C
   50 NCSID = 15
      MATID = NECPT( 6)
      T     =  ECPT( 7)
      FMU   =  ECPT(12)
      GO TO 80
   60 NCSID = 9
      MATID = NECPT(6)
      T     =  ECPT(7)
      FMU   =  ECPT(8)
      GO TO 80
   70 NCSID = 14
      MATID = NECPT(7)
      T     = 0.0E0
      FMU   = ECPT(11)
C
C  30 COMPUTE PIVOT TRIANGLE AREA
C
C     FIRST SET UP THE POINTERS TO THE CSID OF THE 3 POINTS FROM THE
C     BASE CSID
C
   80 NPT1 = 0
      NPT2 = 4
      NPT3 = 8
      IF(NTYPE.GE.3  .AND.  NTYPE.LE.5) GO TO 140
      ICHEK = 1
C     SELECT 3 POINTS FOR THE PIVOT TRIANGLE OF A QUADRILATERAL
C     FIND PIVOT NUMBER FIRST
      DO 90 I=1,4
      IF( NPVT .NE. NECPT(I + 1) ) GO TO 90
      NPIVOT = I
      GO TO 100
   90 CONTINUE
C
C     ERROR IF FALL THRU ABOVE LOOP
C
      CALL MESAGE(-30,34,ECPT(1))
      RETURN
C
C
  100 IF(NPIVOT - 2) 110,140,120
  110 NPT3 = 12
      GO TO 140
  120 IF(NPIVOT .EQ. 3) GO TO 130
      NPT2 = 12
      GO TO 140
  130 NPT1 = 12
C
C     ABOVE LOGIC SETS THE 3 POINTS FOR THE PIVOT TRIANGLE OF A QUAD.
C
  140 DO 150 I=1,3
      ISUB1 = NCSID + NPT1 + I
      ISUB2 = NCSID + NPT2 + I
      ISUB3 = NCSID + NPT3 + I
      V1(I) = ECPT(ISUB3) - ECPT(ISUB1)
  150 V2(I) = ECPT(ISUB3) - ECPT(ISUB2)
C
C     COMPUTE AREA OF QUAD OR TRI USING V1 AND V2
      AREA = 0.0E0
C
  160 V1XV2(1) = V1(2) * V2(3)  -  V1(3) * V2(2)
      V1XV2(2) = V1(3) * V2(1)  -  V1(1) * V2(3)
      V1XV2(3) = V1(1) * V2(2)  -  V1(2) * V2(1)
C
      AREA = AREA + SQRT(V1XV2(1)**2 + V1XV2(2)**2 + V1XV2(3)**2)/2.0E0
C
      IF( NTYPE .GT. 2  .AND.  NTYPE .LT. 6 ) GO TO 190
      IF( ICHEK  ) 170,190,170
C
C     COMPUTE AREA OF WHOLE QUAD, FIRST SET UP V1 + V2 THEN TRA TO 600.
C
  170 IF ( NARG .NE. 1 .OR. IFLAG .NE. 1 ) GO TO 175
      ISUB1 = NCSID + NPT1 + 1
      ISUB2 = NCSID + NPT2 + 1
      ISUB3 = NCSID + NPT3 + 1
      T = PI23 * ( ECPT(ISUB1) + ECPT(ISUB2) + ECPT(ISUB3) )
  175 NPT1 = NCSID
      NPT2 = NCSID + 4
      NPT3 = NCSID + 8
      NPT4 = NCSID +12
      DO 180 I=1,3
      NPT1 = NPT1 + 1
      NPT2 = NPT2 + 1
      NPT3 = NPT3 + 1
      NPT4 = NPT4 + 1
      V1(I) = ECPT(NPT1) - ECPT(NPT3)
  180 V2(I) = ECPT(NPT2) - ECPT(NPT4)
      ICHEK = 0
C
      GO TO 160
C     ******************************************************************
C     FINAL COMPUTATION OF TERM AND SHIP OUT OF MATRIX.
C
  190 DO 200 I=1,36
  200 MASS(I) = 0.0D0
      IF( T ) 210,220,210
C     RHO NOT NEEDED IF T = 0
C
  210 INFLAG = 4
      IF( HEAT ) GO TO 230
      CALL MAT( ECPT(1) )
C
C
  220 TERM = ( FMU + RHO * T ) * AREA / 3.0E0
      IF( NTYPE .LT. 3   .OR.   NTYPE .GT. 5 ) TERM = TERM/2.0E0
      MASS( 1) = TERM
      MASS( 8) = TERM
      MASS(15) = TERM
C
      CALL SMA2B( MASS(1), NPVT, -1, IFMGG, 0.0D0 )
C
      RETURN
C*****
C  HEAT FORMULATION.
C*****
  230 CALL HMAT( ECPT )
      MASS(1) = (CP*T)*AREA/3.0
      IF( NTYPE.LT.3  .OR.  NTYPE.GT.5 ) MASS(1) = MASS(1) / 2.0D0
      CALL SMA2B( MASS(1), NPVT, NPVT, IFBGG, 0.0D0 )
      RETURN
      END
