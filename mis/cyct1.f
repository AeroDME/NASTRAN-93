      SUBROUTINE CYCT1        
C        
C     GENERATE CYCLIC TRANSFORMATION MATRIX, TRANSFORM VECTORS        
C        
C     DMAP CALLING SEQUENCE        
C        
C     CYCT1   VIN/VOUT,GCYC/V,Y,CTYPE/V,Y,CDIR/V,Y,N/V,Y,KMAX/        
C             V,Y,NLOAD/V,N,NOGO $        
C        
      LOGICAL          LBACK, LCOS, LDRL, LDSA, LNMULT, LVIN, LVOUT     
      INTEGER          BUF, CDIR, CTYPE, GCYC, HBACK, HDRL, HDSA, HROT, 
     1                 IZ, MCB(7), PKIN, PKINCR, PKIROW, PKNROW, PKOUT, 
     2                 PRECIS, SCRT, SUBR(2), SYSBUF, VIN, VOUT, OUTPT  
      REAL             RZ(1)        
      DOUBLE PRECISION DC, DC1, DFAC, DFAK, DS, DS1, DZ(1)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /PACKX /  PKIN,PKOUT,PKIROW,PKNROW,PKINCR        
CZZ   COMMON /ZZCYC1/  IZ(1)        
      COMMON /ZZZZZZ/  IZ(1)        
      COMMON /BLANK /  CTYPE(2),CDIR(2),NN,KMAXI,NLOAD,NOGO        
      EQUIVALENCE      (KSYSTM( 1),SYSBUF), (KSYSTM( 2) ,OUTPT),        
     1                 (KSYSTM(55),IPREC ), (IZ(1),RZ(1),DZ(1))        
      DATA    SUBR  /  4HCYCT, 4H1   /,   HBACK  /  4HBACK    /        
      DATA    VIN   /  101  /, VOUT,GCYC /201,202/, SCRT  /301/        
      DATA    HROT  ,  HDRL  , HDSA  /4HROT ,4HDRL ,4HDSA     /        
C        
C        
C     FIND NECESSARY PARAMETERS        
C        
      NOGO   = 1        
      PRECIS = 2        
      IF (IPREC .NE. 2) PRECIS = 1        
      LDRL = CTYPE(1).EQ.HDRL        
      LDSA = CTYPE(1).EQ.HDSA        
      IF (.NOT.((CTYPE(1).EQ.HROT) .OR. LDRL.OR.LDSA)) GO TO 310        
   10 LBACK = CDIR(1).EQ.HBACK        
C        
C     CURRENT DOCUMENTED USAGE DOES NOT USE NEGATIVE VALUES OF KMAXI    
C     OTHER THAN THE DEFAULT OF -1     10/02/73        
C     LOGIC IS INCLUDED IN THE ROUTINE TO USE NEGATIVE KMAXI BUT IS NOT 
C     FULLY CHECKED OUT.  THE FOLLOWING STATEMENT NEGATES ALL THIS LOGIC
C        
      IF (KMAXI .LT. 0) KMAXI = NN/2        
      KMAX = KMAXI        
      KMIN = 0        
      IF (KMAX .GE. 0) GO TO 20        
      KMAX =-KMAX        
      KMIN = KMAX        
   20 IF (2*KMAX.GT.NN .OR. NN.LE.0) GO TO 330        
   30 IF (NLOAD .LE. 0) GO TO 350        
   40 NLOADS = NLOAD        
      IF (LDSA) NLOADS = 2*NLOAD        
      NLOADT = NLOAD        
      IF (LDRL .OR. LDSA) NLOADT = 2*NLOAD        
      NUMROW = NN        
      IF (.NOT.LBACK) GO TO 50        
      NUMROW = 2*(KMAX-KMIN+1)        
      IF (KMIN   .EQ.  0) NUMROW = NUMROW - 1        
      IF (2*KMAX .EQ. NN) NUMROW = NUMROW - 1        
   50 NUMROW = NLOADT*NUMROW        
C        
C     DEFINE OPEN CORE POINTERS AND GINO BUFFER        
C                POINTERS                BEGIN    END        
C          TABLE OF COS (2.0*PI*N/NN)     ICOS    NCOS        
C          TABLE OF SIN (2.0*PI*N/NN)     ISIN    NSIN        
C          AREA TO ASSEMBLE COLUMNS       ICOL    NCOL        
C          (NOTE  N = LITTLE N, NN = CAPITAL N)   N = 0,(NN-1)        
C          (ALLOW FOR (NLOADS-1) ZEROS BEFORE FIRST ENTRY IN COL)       
C        
      BUF  = KORSZ(IZ) - SYSBUF + 1        
      ICOS = 1        
      NCOS = ICOS + NN - 1        
      ISIN = NCOS + 1        
      NSIN = ISIN + NN - 1        
      ICOL = NSIN + 1        
      JCOL = ICOL + NLOADS - 1        
      NCOL = JCOL + NUMROW - 1        
      IF (2*NCOL .GE. BUF) CALL MESAGE (-8,0,SUBR)        
C        
C     CHECK DATA BLOCK TRAILERS        
C        
      MCB(1) = GCYC        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) GO TO 370        
   60 MCB(1) = VOUT        
      CALL RDTRL (MCB(1))        
      LVOUT  = MCB(1).GT.0        
      MCB(1) = VIN        
      CALL RDTRL (MCB(1))        
      LVIN = MCB(1).GT.0        
      IF (.NOT.LVIN) MCB(2) = 0        
      LNMULT = MCB(2).NE.NUMROW        
      IF (LVIN .AND. LVOUT .AND. LNMULT) GO TO 390        
      IF (NOGO) 410,410,70        
C        
C     THE PARAMETERS ARE OK        
C     PREPARE TRIGONOMETRIC TABLES,  DC1=COS(2*PI/NN), PI = 4*ATAN(1)   
C     MOVABLE POINTERS  JXXX=N , KXXX= NN-N        
C        
   70 RN   = FLOAT(NN)        
      DFAC = (8.0D0*DATAN(1.0D0))/DBLE(RN)        
      DC1  = DCOS(DFAC)        
      DS1  = DSIN(DFAC)        
      JCOS = ICOS        
      KCOS = NCOS + 1        
      JSIN = ISIN        
      KSIN = NSIN + 1        
      DZ(JCOS) = 1.0D0        
      DZ(JSIN) = 0.0D0        
   80 IF (KCOS-JCOS-2) 120,90,100        
   90 DC   =-1.0D0        
      DS   = 0.0D0        
      GO TO 110        
  100 DC   = DC1*DZ(JCOS) - DS1*DZ(JSIN)        
      DS   = DS1*DZ(JCOS) + DC1*DZ(JSIN)        
  110 JCOS = JCOS + 1        
      JSIN = JSIN + 1        
      KCOS = KCOS - 1        
      KSIN = KSIN - 1        
      DZ(JCOS) = DC        
      DZ(JSIN) = DS        
      DZ(KCOS) = DC        
      DZ(KSIN) =-DS        
      GO TO 80        
C        
C     ZERO THE AREA FOR FORMING THE COLUMN        
C        
  120 DO 130 J = ICOL,NCOL        
      DZ(J) = 0.0D0        
  130 CONTINUE        
C        
C     OPEN GCYC MATRIX,  GET READY TO USE PACK        
C        
      CALL GOPEN (GCYC,IZ(BUF),1)        
      CALL MAKMCB (MCB,GCYC,NUMROW,2,PRECIS)        
      PKIN   = 2        
      PKOUT  = PRECIS        
      PKIROW = 1        
      PKNROW = NUMROW        
      PKINCR = 1        
      IF (LBACK) GO TO 240        
C        
C     START LOOPING ON COLUMNS OF MATRIX OF TYPE FORE.        
C     FORM A COLUMN AND PACK IT OUT        
C          K = KMIN,KMAX  ALTERNATE COSINE AND SINE COLUMNS        
C        
      DFAC = 2.0D0/DBLE(RN)        
      IF (LDRL) DFAC = 0.5D0*DFAC        
      K    = KMIN        
  140 DFAK = DFAC        
      IF (K.EQ.0 .OR. 2*K.EQ.NN) DFAK = 0.5D0*DFAK        
      LCOS  = .TRUE.        
      KTRIG = ICOS        
      NTRIG = NCOS        
      GO TO 160        
  150 LCOS  = .FALSE.        
      KTRIG = ISIN        
      NTRIG = NSIN        
  160 DO 170 KCOL = JCOL,NCOL,NLOADT        
      DZ(KCOL) = DFAK*DZ(KTRIG)        
      KTRIG = KTRIG + K        
      IF (KTRIG .GT. NTRIG) KTRIG = KTRIG - NN        
  170 CONTINUE        
C        
C     PACK OUT NLOADT COLUMNS  (FOR EITHER FORE OR BACK)        
C      IF  ROT OR DSA   WE ARE READY        
C      IF     DRL       PRODUCE INTERMEDIATE TERMS FIRST (EXPAND)       
C        
  180 NXCOL = 1        
      IF (.NOT.LDRL) GO TO 220        
      DO 190 KCOL = JCOL,NCOL,NLOADT        
      KCOL2 = KCOL + NLOADS        
      DZ(KCOL2) = DZ(KCOL)        
  190 CONTINUE        
      GO TO 220        
  200 NXCOL = 2        
      DO 210 KCOL = JCOL,NCOL,NLOADT        
      KCOL2 = KCOL + NLOADS        
      DZ(KCOL2) = -DZ(KCOL)        
  210 CONTINUE        
  220 KCOL = JCOL        
  230 CALL PACK (DZ(KCOL),GCYC,MCB)        
      KCOL = KCOL - 1        
      IF (KCOL .GE. ICOL) GO TO 230        
      IF (LDRL .AND. NXCOL.EQ.1) GO TO 200        
      IF (LBACK) GO TO 280        
C        
C     BOTTOM OF LOOP FOR TYPE FORE        
C        
      IF (K.NE.0 .AND. 2*K.NE.NN .AND. LCOS) GO TO 150        
      K = K + 1        
      IF (K-KMAX) 140,140,290        
C        
C     START LOOPING ON COLUMNS OF MATRIX OF TYPE BACK        
C         N = 1,NN        
C        
  240 N = 1        
  250 K = 0        
      KCOS = ICOS        
      KCOL = JCOL        
  260 IF (K .LT. KMIN) GO TO 270        
      DZ(KCOL) = DZ(KCOS)        
      KCOL = KCOL + NLOADT        
      IF (K.EQ.0 .OR. 2*K.EQ.NN) GO TO 270        
      DZ(KCOL) = DZ(KCOS+NN)        
      KCOL = KCOL + NLOADT        
  270 KCOS = KCOS + N - 1        
      IF (KCOS .GT. NCOS) KCOS = KCOS - NN        
      K = K + 1        
      IF (K-KMAX) 260,260,180        
C        
C     BOTTOM OF LOOP FOR TYPE BACK        
C        
  280 N = N + 1        
      IF (N-NN) 250,250,290        
C        
C     THE GCYC MATRIX IS NOW COMPLETE        
C        
  290 CALL CLOSE  (GCYC,1)        
      CALL WRTTRL (MCB(1))        
C        
C     IF WE HAVE TO FORM VOUT, USE SSG2B.  (VOUT = VIN*GCYC)        
C        
      IF (LNMULT) GO TO 300        
      CALL SSG2B (VIN,GCYC,0,VOUT,0,PRECIS,1,SCRT)        
  300 CONTINUE        
      RETURN        
C        
C     FATAL MESSAGES        
C        
  310 NOGO = -1        
      WRITE  (OUTPT,320) UFM,CTYPE(1)        
  320 FORMAT (A23,' 4063, ILLEGAL VALUE (',A4,') FOR PARAMETER CTYPE.') 
      GO TO 10        
  330 NOGO = -1        
      WRITE  (OUTPT,340) UFM,NN,KMAXI        
  340 FORMAT (A23,' 4064, ILLEGAL VALUES (',I8,1H,,I8,        
     1        ') FOR PARAMETERS (NSEGS,KMAX).')        
      GO TO 30        
  350 NOGO = -1        
      WRITE  (OUTPT,360) UFM,NLOAD        
  360 FORMAT (A23,' 4065, ILLEGAL VALUE (',I8,') FOR PARAMETER NLOAD.') 
      GO TO 40        
  370 NOGO = -1        
      WRITE  (OUTPT,380) UFM        
  380 FORMAT (A23,' 4066, SECOND OUTPUT DATA BLOCK MUST NOT BE PURGED.')
      GO TO 60        
  390 NOGO = -1        
      WRITE  (OUTPT,400) UFM,MCB(2),NUMROW        
  400 FORMAT (A23,' 4067, VIN HAS',I9,' COLS, GCYC HAS',I9,6H ROWS.)    
  410 CALL MESAGE (-61,0,SUBR)        
      RETURN        
      END        
