      SUBROUTINE FNXTV (V1,V2,V3,V4,V5,ZB,IFN)        
C        
C     FNXTV OBTAINS THE REDUCED TRIDIAGONAL MATRIX B WHERE FRBK        
C     PERFORMS THE OPERATIONAL INVERSE.   (SINGLE PREC VERSION)        
C        
C           T   -        
C      B = V  * A  * V        
C        
C     V1  = SPACE FOR THE PREVIOUS CURRENT TRIAL VECTOR. INITALLY NULL  
C     V2  = SPACE FOR THE CURRENT TRIAL VECTOR. INITIALLY A PSEUDO-     
C           RANDOM START VECTOR        
C     V3,V4,V5 = WORKING SPACES FOR THREE VECTORS        
C     IFN = NO. OF TRIAL VECOTRS EXTRACTED. INITIALLY ZERO.        
C     SEE FEER FOR DEFINITIONS OF OTHER PARAMETERS. ALSO PROGRAMMER'S   
C           MANUAL PP. 4.48-19G THRU I        
C        
C     NUMERIC ACCURACY IS VERY IMPORTANT IN THIS SUBROUTINE. SEVERAL    
C     KEY AREAS ARE REINFORCED BY DOUBLE PRECISION CALCULATIONS        
C        
C     IN THIS SINGLE PRECISION VERSION, WE AVOID MATHEMATIC OPERATION   
C     IN A DO LOOP, INVOLVING MIXED MODE COMPUTATION AND THE RESULT     
C     STORED IN S.P. WORD. SOME MACHINES, SUCH AS VAX, ARE VERY SLOW IN 
C     THIS SITUATION. MIXED MODE COMPUTATION AND RESULT IN D.P. IS OK.  
C        
      INTEGER            SYSBUF    ,CNDFLG   ,SR5FLE   ,NAME(5)  ,      
     1                   VDOT        
      DOUBLE PRECISION   LMBDA     ,LAMBDA        
      DOUBLE PRECISION   DBI       ,SDMAX    ,D        ,DB       ,      
     1                   DSQ       ,SD       ,AII      ,DTMP     ,      
     2                   DEPX      ,DEPX2    ,OPDEPX   ,OMDEPX   ,      
     3                   ZERO        
      DIMENSION          V1(1)     ,V2(1)    ,V3(1)    ,V4(1)    ,      
     1                   V5(1)     ,ZB(1)    ,B(2)        
      CHARACTER          UFM*23    ,UWM*25        
      COMMON   /XMSSG /  UFM       ,UWM        
      COMMON   /FEERCX/  IFKAA(7)  ,IFMAA(7) ,IFLELM(7),IFLVEC(7),      
     1                   SR1FLE    ,SR2FLE   ,SR3FLE   ,SR4FLE   ,      
     2                   SR5FLE    ,SR6FLE   ,SR7FLE   ,SR8FLE   ,      
     3                   DMPFLE    ,NORD     ,XLMBDA   ,NEIG     ,      
     4                   MORD      ,IBK      ,CRITF    ,NORTHO   ,      
     5                   IFLRVA    ,IFLRVC        
      COMMON   /FEERXX/  LAMBDA    ,CNDFLG   ,ITER     ,TIMED    ,      
     1                   L16       ,IOPTF    ,EPX      ,ERRC     ,      
     2                   IND       ,LMBDA    ,IFSET    ,NZERO    ,      
     3                   NONUL     ,IDIAG    ,MRANK    ,ISTART        
      COMMON   /SYSTEM/  KSYSTM(65)        
      COMMON   /OPINV /  MCBLT(7)  ,MCBSMA(7),MCBVEC(7),MCBRM(7)        
      COMMON   /UNPAKX/  IPRC      ,II       ,NN       ,INCR        
      COMMON   /PACKX /  ITP1      ,ITP2     ,IIP      ,NNP      ,      
     1                   INCRP        
      COMMON   /NAMES /  RD        ,RDREW    ,WRT      ,WRTREW   ,      
     1                   REW       ,NOREW    ,EOFNRW        
      EQUIVALENCE        (KSYSTM(1),SYSBUF)  ,(KSYSTM(2),IO)        
      DATA      NAME  /  4HFNXT    ,4HV      ,2*4HBEGN ,4HEND    /      
      DATA      VDOT  ,  ZERO /     4HV.     ,0.0D+0             /      
C        
C     SR5FLE CONTAINS THE REDUCED TRIDIAGONAL ELEMENTS        
C        
C     SR6FLE CONTAINS THE G VECTORS        
C     SR7FLE CONTAINS THE ORTHOGONAL  VECTORS        
C     SR8FLE CONTAINS THE CONDITIONED MAA MATRIX        
C        
      IF (MCBLT(7) .LT. 0) NAME(2) = VDOT        
      NAME(3) = NAME(4)        
      CALL CONMSG (NAME,3,0)        
      ITER  = ITER + 1        
      IPRC  = 1        
      INCR  = 1        
      INCRP = INCR        
      ITP1  = IPRC        
      ITP2  = IPRC        
      IFG   = MCBRM(1)        
      IFV   = MCBVEC(1)        
      DEPX  = EPX        
      DEPX2 = DEPX**2        
      OPDEPX= 1.0D0 + DEPX        
      OMDEPX= 1.0D0 - DEPX        
      D     = ZERO        
      NORD1 = NORD - 1        
C        
C     NORMALIZE START VECTOR        
C        
      DSQ = ZERO        
      IF (IOPTF .EQ. 1) GO TO 20        
      CALL FRMLT (MCBSMA(1),V2(1),V3(1),V5(1))        
      DO 10 I = 1,NORD        
   10 DSQ = DSQ + DBLE(V2(I)*V3(I))        
      GO TO 40        
   20 DO 30 I = 1,NORD        
   30 DSQ = DSQ + DBLE(V2(I)*V2(I))        
   40 DSQ = 1.0D+0/DSQRT(DSQ)        
      TMP = SNGL(DSQ)        
      DO 50 I = 1,NORD        
   50 V2(I) = V2(I)*TMP        
      IF (NORTHO .EQ. 0) GO TO 200        
C        
C     ORTHOGONALIZE WITH PREVIOUS VECTORS        
C        
      DO 60 I = 1,NORD        
   60 V3(I) = V2(I)        
   70 DO 170 IX = 1,14        
      NONUL = NONUL + 1        
      CALL GOPEN (IFV,ZB(1),RDREW)        
      IF (IOPTF .EQ. 0) CALL FRMLT (MCBSMA(1),V2(1),V3(1),V5(1))        
      SDMAX = ZERO        
      DO 110 IY = 1,NORTHO        
      II = 1        
      NN = NORD        
      SD = ZERO        
      CALL UNPACK (*90,IFV,V5(1))        
      DO 80 I = 1,NORD        
      SD = SD + DBLE(V3(I)*V5(I))        
   80 CONTINUE        
   90 IF (DABS(SD) .GT. SDMAX) SDMAX = DABS(SD)        
      TMP = SNGL(SD)        
      DO 100 I = 1,NORD        
  100 V2(I) = V2(I) - TMP*V5(I)        
  110 CONTINUE        
      CALL CLOSE (IFV,EOFNRW)        
      DSQ = ZERO        
      IF (IOPTF .EQ. 1) GO TO 130        
      CALL FRMLT (MCBSMA(1),V2(1),V3(1),V5(1))        
      DO 120 I = 1,NORD1        
  120 DSQ = DSQ + DBLE(V2(I)*V3(I))        
      GO TO 150        
  130 DO 140 I = 1,NORD1        
  140 DSQ = DSQ + DBLE(V2(I)*V2(I))        
C        
C 150 IF (DSQ .LT. DEPX2) GO TO 500        
C        
C     COMMENTS FORM G.CHAN/UNISYS ABOUT DSQ AND DEPX2 ABOVE,   1/92     
C        
C     DEPX2 IS SQUARE OF EPX. ORIGINALLY SINCE DAY 1, EPX (FOR VAX AND  
C     IBM) IS 10.**-14 AND THEREFORE DEPX2 = 10.**-28. (10.**-24 FOR    
C     THE 60/64 BIT MACHINES, USING S.P. COMPUTATION)        
C     (EPX WAS CHAGNED TO 10.**-10, ALL MACHINE, S.P. AND D.P., 1/92)   
C        
C     NOTICE THAT DSQ IS THE DIFFERENCE OF TWO CLOSE NUMERIC NUMBERS.   
C     THE FINAL VAULES OF DSQ AND THE PRODUCT OF V2*V2 OR V2*V3 APPROACH
C     ONE ANOTHER, AND DEFFER ONLY IN SIGN. THEREFORE, THE NUMBER OF    
C     DIGITS (MANTISSA) AS WELL AS THE EXPONENT ARE IMPORTANT HERE.     
C     (PREVIOUSLY, DO LOOPS 120 AND 140 GO FROM 1 THRU NORD)        
C        
C     MOST OF THE 32 BIT MACHINES HOLD 15 DIGIT IN D.P. WORD, AND SAME  
C     FOR THE 64 BIT MACHINES USING S.P. WORD. THEREFORE, CHECKING DSQ  
C     DOWN TO 10.**-28 (OR 10.**-24) IS BEYOND THE HARDWARE LIMITS.     
C     THIS MAY EXPLAIN SOME TIMES THE RIGID BODY MODES (FREQUENCY = 0.0)
C     GO TO NEGATIVE; IN SOME INSTANCES REACHING -1.E+5 RANGE        
C        
C     NEXT 7 LINES TRY TO SOLVE THE ABOVE DILEMMA.        
C        
  150 D = DBLE(V3(NORD))        
      IF (IOPTF .EQ. 1) D = DBLE(V2(NORD))        
      D = DBLE(V2(NORD))*D        
      DTMP = DSQ        
      DSQ  = DSQ + D        
      IF (DSQ .LT. DEPX2) GO TO 500        
      DTMP = DABS(D/DTMP)        
      IF (DTMP.GT.OMDEPX .AND. DTMP.LT.OPDEPX) GO TO 500        
      D = ZERO        
C        
      DSQ = DSQRT(DSQ)        
      IF (L16 .NE. 0) WRITE (IO,620) IX,SDMAX,DSQ        
      DSQ = 1.0D+0/DSQ        
      TMP = SNGL(DSQ)        
      DO 160 I = 1,NORD        
      V2(I) = V2(I)*TMP        
  160 V3(I) = V2(I)        
      IF (SDMAX .LT. DEPX) GO TO 200        
  170 CONTINUE        
      GO TO 500        
C        
  200 IF (IFN .NE. 0) GO TO 300        
C        
C     SWEEP START VECTOR FOR ZERO ROOTS        
C        
      DSQ = ZERO        
      IF (IOPTF .EQ. 1) GO TO 220        
      CALL FRSW (V2(1),V4(1),V3(1),V5(1))        
      CALL FRMLT (MCBSMA(1),V3(1),V4(1),V5(1))        
      DO 210 I = 1,NORD        
  210 DSQ = DSQ + DBLE(V3(I)*V4(I))        
      GO TO 240        
  220 CALL FRBK (V2(1),V4(1),V3(1),V5(1))        
      DO 230 I = 1,NORD        
  230 DSQ = DSQ + DBLE(V3(I)*V3(I))        
  240 DSQ = 1.0D+0/DSQRT(DSQ)        
      TMP = SNGL(DSQ)        
      DO 250 I = 1,NORD        
  250 V2(I) = V3(I)*TMP        
      GO TO 320        
C        
C     CALCULATE OFF DIAGONAL TERM OF B        
C        
  300 D = ZERO        
      DO 310 I = 1,NORD        
  310 D = D + DBLE(V2(I)*V4(I))        
C        
C     COMMENTS FROM G.CHAN/UNISYS   1/92        
C     WHAT HAPPENS IF D IS NEGATIVE HERE? NEXT LINE WILL BE ALWAYS TRUE.
C        
      IF (D .LT. DEPX*DABS(AII)) GO TO 500        
  320 CALL GOPEN (IFG,ZB(1),WRT)        
      IIP = 1        
      NNP = NORD        
      IF (IOPTF .EQ. 1) GO TO 330        
      CALL FRSW (V2(1),V4(1),V3(1),V5(1))        
      CALL FRMLT (MCBSMA(1),V3(1),V4(1),V5(1))        
      CALL PACK (V2(1),IFG,MCBRM(1))        
      GO TO 350        
  330 CALL FRBK (V2(1),V4(1),V3(1),V5(1))        
      CALL PACK (V4(1),IFG,MCBRM(1))        
      DO 340 I = 1,NORD        
  340 V4(I) = V3(I)        
  350 CALL CLOSE (IFG,NOREW)        
C        
C     CALCULATE DIAGONAL TERM OF B        
C        
      AII = ZERO        
      DO 400 I = 1,NORD        
  400 AII = AII + DBLE(V2(I)*V4(I))        
      TMP = SNGL(AII)        
      IF (D .EQ. ZERO) GO TO 420        
      XD  = SNGL(D)        
      DO 410 I = 1,NORD        
  410 V3(I) = V3(I) - TMP*V2(I) - XD*V1(I)        
      GO TO 440        
  420 DO 430 I = 1,NORD        
  430 V3(I) = V3(I) - TMP*V2(I)        
  440 DB = ZERO        
      IF (IOPTF .EQ. 1) GO TO 460        
      CALL FRMLT (MCBSMA(1),V3(1),V4(1),V5(1))        
      DO 450 I = 1,NORD        
  450 DB = DB + DBLE(V3(I)*V4(I))        
      GO TO 480        
  460 DO 470 I = 1,NORD        
  470 DB = DB + DBLE(V3(I)*V3(I))        
  480 DB = DSQRT(DB)        
      ERRC = SNGL(DB)        
      B(1) = SNGL(AII)        
      B(2) = SNGL(D)        
      CALL WRITE (SR5FLE,B(1),2,1)        
      CALL GOPEN (IFV,ZB(1),WRT)        
      IIP  = 1        
      NNP  = NORD        
      CALL PACK (V2(1),IFV,MCBVEC(1))        
      CALL CLOSE (IFV,NOREW)        
      NORTHO= NORTHO + 1        
      IFN   = NORTHO - NZERO        
      IF (L16 .NE. 0) WRITE (IO,610) IFN,MORD,AII,DB,D        
      IF (IFN .GE. MORD) GO TO 630        
C        
C     IF NULL VECTOR GENERATED, RETURN TO OBTAIN A NEW SEED VECTOR      
C        
      IF (DB .LT. DEPX*DABS(AII)) GO TO 630        
C        
C     A GOOD VECTOR IN V2. MOVE IT INTO 'PREVIOUS' VECTOR SPACE V1,     
C     NORMALIZE V3 AND V2. LOOP BACK FOR MORE VECTORS.        
C        
      DBI = 1.0D+0/DB        
      TMP = SNGL(DBI)        
      DO 490 I = 1,NORD        
      V1(I) = V2(I)        
      V3(I) = V3(I)*TMP        
  490 V2(I) = V3(I)        
      GO TO 70        
C        
  500 MORD = IFN        
      WRITE (IO,600) UWM,MORD        
      GO TO 630        
C        
  600 FORMAT (A25,' 2387, PROBLEM SIZE REDUCED TO',I5,' DUE TO -', /5X, 
     1        'ORTHOGONALITY DRIFT OR NULL TRIAL VECTOR', /5X,        
     2        'ALL EXISTING MODES MAY HAVE BEEN OBTAINED.  USE DIAG 16',
     3        ' TO DETERMINE ERROR BOUNDS',/)        
  610 FORMAT (5X,'TRIDIAGONAL ELEMENTS ROW (IFN)',I5, /5X,'MORD =',I5,  
     1        ', AII,DB,D = ',1P,3D16.8)        
  620 FORMAT (11X,'ORTH ITER (IX)',I5,',  MAX PROJ (SDMAX)',1P,D16.8,   
     1        ',  NORMAL FACT (DSQ)',1P,D16.8)        
C        
  630 NAME(3) = NAME(5)        
      CALL CONMSG (NAME,3,0)        
      RETURN        
      END        
