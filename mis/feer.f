      SUBROUTINE FEER        
C        
C     DRIVER FOR THE FEER (FAST EIGENVALUE EXTRACTION ROUTINE) METHOD.  
C     THIS ROUTINE WAS CALLED FCNTL BEFORE        
C        
C     GIVEN A REAL SYMETRIC MATRIX, FEER WILL SOLVE FOR THE EIGENVALUES 
C     AND EIGENVECTORS AROUND THE CENTER OF INTEREST        
C        
C     DEFINITION OF INPUT AND OUTPUT PARAMETERS        
C        
C     IFKAA(7) = 101, MATRIX GINO BLOCK FOR THE INPUT STIFFNESS MATRIX K
C     IFMAA(7) = 102, MATRIX GINO BLOCK FOR THE INPUT MASS MATRIX M     
C     IFLELM(7)= 201, MATRIX GINO BLOCK FOR THE OUTPUT EIGENVALUES      
C     IFLVEC(7)= 202, MATRIX GINO BLOCK FOR THE OUTPUT EIGENVECTORS     
C            ? = 203        
C     DMPFLE   = 204, EIGENVALUE SUMMARY FILE        
C     SR1FLE-SR8FLE = 301-308, SCRATCH FILES REQUIRED INTERNALLY        
C     XLMBDA   =  INPUT, CENTER OF RANGE OF INTEREST.        
C                 (USER SPECIFIED SHIFT)        
C     NEIG     =  NUMBER OF DESIRED EIGENVALUES AROUND THE CENTER       
C                 OF INTEREST. (EIGENVALUES SPECIFIED BY USER)        
C     NORD     =  PROBLEM SIZE (SET INTERNALLY USING THE DIMENSION OF   
C                 THE STIFFNESS MATRIX)        
C     MORD     =  ORDER OF THE REDUCED PROBLEM (SET INTERNALLY)        
C     NORTHO   =  NO. OF ORTHOGONAL VECTORS IN PRESENT SET (INCLUDE     
C                 PREVISOUSLY COMPUTED VECTORS)        
C     EPXM     =  ZERO MASS CRITERIA TO DETERMINE RANK        
C     EPX      =  ORTHOGONALITY CONVERGENCE CRITERIA        
C     IBK      =  BUCKLING OPTION INDICATOR (SET INTERNALLY)        
C     CRITF    =  THE USER SPECIFIED (OR DEFAULT) DESIRED THEORETICAL   
C                 ACCURACY OF THE EIGENVALUES EXPRESSED AS A PERCENTAGE 
C     LAMBDA   =  VALUE OF THE SHIFT ACTUALLY USED (D.P.)        
C     CNDFLG   =  TERMINATION INDICATOR        
C     ITER     =  NO. OF STARTING POINTS USED        
C     IOPTF    =  SPECIFIED SHIFT OPTION INDICATOR, SET INTERNALLY      
C     NOCHNG   =  THEORETICAL ERROR PARAMETER        
C     IFSET    =  INTERNALLY COMPUTED SHIFT INDICTOR        
C     NONUL    =  NO. OF VETOR ITERATIONS        
C     MRANK    =  MATRIX RANK OF THE PROBLEM        
C     IND,LMBDA,IDAIG = NOT ACTIVEATED        
C        
C     EIGENVALUES AND EIGENVECTORS WILL BE STORED ON THE ACTUAL SR1FLE  
C     AND SR2FLE. THE SELECTION OF ACCURATE EIGENVALUES AND VECTORS WILL
C     PUT THEM ON IFLELM AND IFLVEC IN THE CORRECT SEQUENCE AT THE END  
C     OF PROCESSING        
C        
C     IFLELM        CONTAINS (K+LAMBDA*M) OR KAA        
C     IFLVEC        CONTAINS THE LOWER TRIANGLE L OR C        
C     SR4FLE        IS USED AS SCRATCH IN SDCOMP        
C     SR5FLE        IS USED AS SCRATCH IN SDCOMP        
C     SR6FLE        IS USED AS SCRATCH IN SDCOMP        
C     SR7FLE        CONTAINS THE VECTORS WHICH ARE USED TO ORTHOGONALIZE
C     SR8FLE        CONTAINS THE CONTITIONED MAA MATRIX        
C     IFLRVA = 301        
C     IFLRVC = 302        
C     MCBLT         LOWER TRAINGULAR MATRIX L CONTROL BLOCK        
C     MCBSMA        CONTITIONED MASTRIX M CONTROL BLOCK        
C     MCBVEC        ORTHOGONAL VECTOR FILE CONTROL BLOCK        
C     MCBRM         TRIAL VECTOR V OR C(INVERSE-TRANSPOSE)*V CONTROL    
C                   BLOCK        
C        
      INTEGER          SYSBUF    ,CNDFLG   ,SR8FLE   ,NAME(3)  ,        
     1                 DMPFLE    ,IZ(12)   ,TIMED    ,STURM    ,        
     2                 T1        ,T2       ,T3       ,TIMET    ,        
     3                 MCB(7)    ,ICR(2)   ,JCR(2)        
      DOUBLE PRECISION LAMBDA    ,LMBDA    ,DZ(1)    ,DRSN     ,        
     1                 DRSM      ,EPXM     ,SCALE    ,DSM        
      DIMENSION        TMT(4)    ,TML(4)        
      CHARACTER        UFM*23    ,UWM*25   ,UIM*29        
      COMMON  /XMSSG / UFM       ,UWM      ,UIM        
      COMMON  /BLANK / IPROB(2)  ,NUMMOD   ,ICASE        
      COMMON  /FEERCX/ IFKAA(7)  ,IFMAA(7) ,IFLELM(7),IFLVEC(7),        
     1                 SR1FLE    ,SR2FLE   ,SR3FLE   ,SR4FLE   ,        
     2                 SR5FLE    ,SR6FLE   ,SR7FLE   ,SR8FLE   ,        
     3                 DMPFLE    ,NORD     ,XLMBDA   ,NEIG     ,        
     4                 MORD      ,IBK      ,CRITF    ,NORTHO   ,        
     5                 IFLRVA    ,IFLRVC        
      COMMON  /FEERXX/ LAMBDA    ,CNDFLG   ,ITER     ,TIMED    ,        
     1                 L16       ,IOPTF    ,EPX      ,NOCHNG   ,        
     2                 IND       ,LMBDA    ,IFSET    ,NZERO    ,        
     3                 NONUL     ,IDIAG    ,MRANK    ,ISTART   ,        
     4                 NZ3        
      COMMON  /REIGKR/ OPTION(2)        
CZZ   COMMON  /ZZFER3/ Z(1)        
      COMMON  /ZZZZZZ/ Z(1)        
      COMMON  /NTIME / LNTIME    ,TCONS(15)        
      COMMON  /OPINV / MCBLT(7)  ,MCBSMA(7),MCBVEC(7),MCBRM(7)        
      COMMON  /SYSTEM/ KSYSTM(65)        
      COMMON  /PACKX / ITP1      ,ITP2     ,IIP      ,NNP      ,        
     1                 INCRP        
      COMMON  /UNPAKX/ IPRC      ,II       ,NN       ,INCR        
      COMMON  /NAMES / RD        ,RDREW    ,WRT      ,WRTREW   ,        
     1                 REW       ,NOREW    ,EOFNRW        
      COMMON  /STURMX/ STURM     ,SHFTPT   ,KEEP(2)        
      EQUIVALENCE      (IZ(1),Z(1),DZ(1))  ,(KSYSTM( 1),SYSBUF),        
     1                 (KSYSTM(2),    IO)  ,(KSYSTM(55),IPREC ),        
     2                 (TCONS(8) ,TMT(1))  ,(TCONS(12) ,TML(4)),        
     3                 (KSYSTM(40), NBPW)        
      DATA     NAME  / 4HFEER,2*2H   /     ,IBEGN/ 4HBEGN   /        
      DATA     IEND  / 4HEND         /     ,MODE / 4HMODE   /        
      DATA     I1,I2 , I3,I4,I0      /  1H1,1H2,1H3,1H4,1H  /        
      DATA     ICR   / 4HPASS,4HFAIL /, JCR/4HFREQ,4HBUCK   /        
C        
C     SET PRECISION DIGITS TO 12, ALL MACHINES (NEW 1/92)        
C        
      IT  = 12        
      EPX = 10.**(2-IT)        
      DSM = 10.0D0**(-2*IT/3)        
      NAME(3)  = IBEGN        
      CALL CONMSG (NAME,3,0)        
      CALL FEERDD        
C        
C     INITIALIZE FEERCX        
C     DEFINITION OF INTERNAL PARAMETERS        
C        
      IBK   = 0        
      IF (IPROB(1) .NE. MODE) IBK = 1        
      IOPTF = IBK        
      TIMED = 0        
      TIMET = 0        
      CALL SSWTCH (16,L16)        
      IF (L16 .EQ. 1) WRITE (IO,10)        
   10 FORMAT (//,' *** DIAG16 - ALL TERMS USED ARE DESCRIBED IN ',      
     1       'PROGRAMMER MANUAL  P. 4.48-19I THRU K',/)        
      LAMBDA = -XLMBDA        
      IF (IBK    .EQ.   0) GO TO 40        
      IF (XLMBDA .EQ. 0.0) GO TO 30        
      CALL PAGE2 (3)        
      WRITE  (IO,20) UWM        
   20 FORMAT (A25,' 2388', /5X,'USER SPECIFIED RANGE NOT USED FOR FEER',
     1       ' BUCKLING. THE ROOTS OF LOWEST MAGNITUDE ARE OBTAINED')   
   30 LAMBDA = 0.0D+0        
   40 IFSET  = 0        
      IF (XLMBDA.EQ.0. .AND. IBK.EQ.0) IFSET = 1        
      IF (IFSET .EQ. 1) IOPTF = 1        
      CNDFLG = 0        
      NODCMP = 0        
      CALL RDTRL (IFKAA(1))        
      CALL RDTRL (IFMAA(1))        
      IFK   = IFKAA(1)        
      IFM   = IFMAA(1)        
      IPRC  = IFKAA(5)        
      NORD  = IFKAA(2)        
      INCR  = 1        
      INCRP = INCR        
      ITP1  = IPRC        
      ITP2  = IPRC        
      NZ    = KORSZ(Z)        
      IBUF1 = NZ    - SYSBUF        
      IBUF2 = IBUF1 - SYSBUF        
      NTOT  = IPRC*(5*NORD+1) + 4*SYSBUF - NZ        
      IF (NTOT .GT. 0) CALL MESAGE (-8,NTOT,NAME)        
      CALL KLOCK (ISTART)        
      MRANK = 0        
      CALL GOPEN  (IFM,Z(IBUF1),RDREW)        
      CALL MAKMCB (MCB,SR8FLE,NORD,6,IPRC)        
      CALL GOPEN  (SR8FLE,Z(IBUF2),WRTREW)        
      MCB(2) = 0        
      MCB(6) = 0        
      IF (IPRC .EQ. 2) GO TO 90        
      DO 80 J = 1,NORD        
      II = 0        
      CALL UNPACK (*60,IFM,Z(1))        
      NT = NN - II + 1        
      EPXM = 0.0D+0        
      IF (II.LE.J .AND. NN.GE.J) EPXM = Z(J-II+1)*DSM        
      NTZ = 0        
      DO 50 JJ = 1,NT        
      IF (ABS(Z(JJ)) .GT. EPXM) GO TO 50        
      Z(JJ) = 0.        
      NTZ   = NTZ + 1        
   50 CONTINUE        
      IF (NTZ .LT. NT) MRANK = MRANK + 1        
      GO TO 70        
   60 II  = 1        
      NN  = 1        
      NT  = 1        
      Z(1)= 0.        
   70 IIP = II        
      NNP = NN        
      CALL PACK (Z(1),SR8FLE,MCB(1))        
   80 CONTINUE        
      GO TO 140        
   90 DO 130 J = 1,NORD        
      II = 0        
      CALL UNPACK (*110,IFM,DZ(1))        
      NT = NN - II + 1        
      EPXM = 0.0D+0        
      IF (II.LE.J .AND. NN.GE.J) EPXM = DZ(J-II+1)*DSM        
      NTZ = 0        
      DO 100 JJ = 1,NT        
      IF (DABS(DZ(JJ)) .GT. EPXM) GO TO 100        
      DZ(JJ) = 0.0D+0        
      NTZ = NTZ + 1        
  100 CONTINUE        
      IF (NTZ .LT. NT) MRANK = MRANK + 1        
      GO TO 120        
  110 II = 1        
      NN = 1        
      NT = 1        
      DZ(1) = 0.0D+0        
  120 IIP = II        
      NNP = NN        
      CALL PACK (DZ(1),SR8FLE,MCB(1))        
  130 CONTINUE        
  140 CALL WRTTRL (MCB)        
      MORD = 2*(NEIG-NORTHO) + 10        
      MRK  = MRANK - NORTHO        
      NZERO= NORTHO        
      IF (MORD .GT.   MRK) MORD = MRK        
      IF (NEIG .LE. MRANK) GO TO 160        
      CALL PAGE2 (3)        
      WRITE  (IO,150) UWM        
  150 FORMAT (A25,' 2385', /5X,'DESIRED NUMBER OF EIGENVALUES EXCEED ', 
     1       'THE EXISTING NUMBER, ALL EIGENSOLUTIONS WILL BE SOUGHT.') 
  160 CALL CLOSE (SR8FLE,NOREW)        
      CALL CLOSE (IFM,REW)        
      DO 170 I = 1,7        
      MCBSMA(I) = MCB(I)        
  170 IFMAA(I)  = MCBSMA(I)        
      IFM = IFMAA(1)        
      IF (IBK .EQ. 0) GO TO 180        
C        
C     SET UP TO DECOMPOSE KAA        
C        
      IFLELM(1) = IFKAA(1)        
      GO TO 210        
  180 IF (IFSET .EQ. 0) GO TO 200        
C        
C     CALCULATE INITIAL SHIFT        
C        
      CALL GOPEN (IFK,Z(IBUF1),RDREW)        
      CALL GOPEN (IFM,Z(IBUF2),RDREW)        
      CALL FRMAX (IFK,IFM,NORD,IPRC,DRSN,DRSM)        
      CALL CLOSE (IFK,REW)        
      CALL CLOSE (IFM,REW)        
      SCALE  = DBLE(FLOAT(NORD))*10.0D0**(-IT)*DRSM        
      LAMBDA = 10.0D0**(-IT/3)*DRSN        
      IF (LAMBDA .LT. SCALE) LAMBDA = SCALE        
C        
C     CALL IN ADD LINK TO FORM  (K+LAMBDA*M)        
C        
  200 NAME(2) = I1        
      CALL CONMSG (NAME,3,0)        
      CALL FEER1        
      NAME(3) = IEND        
      CALL CONMSG (NAME,3,0)        
C        
C     CALL IN SDCOMP TO DECOMPOSE THIS MATRIX        
C        
  210 NODCMP  = NODCMP + 1        
      SHFTPT  = DABS(LAMBDA)        
      NAME(2) = I2        
      NAME(3) = IBEGN        
      CALL CONMSG (NAME,3,0)        
      CALL FEER2 (ISING)        
      NAME(3) = IEND        
      CALL CONMSG (NAME,3,0)        
      IK = IBK   + 1        
      IJ = ISING + 1        
      IF (ISING.NE.1 .AND. L16.EQ.0) GO TO 230        
      CALL PAGE2 (4)        
      WRITE  (IO,220) JCR(IK),NORD,MRANK,MORD,NORTHO,NEIG,NZERO,XLMBDA, 
     1                LAMBDA,ICR(IJ)        
  220 FORMAT ('0*** DIAG 16 OUTPUT FOR FEER ANALYSIS, OPTION =',A4, /5X,
     1       'ORDER =',I5,',  MAX RANK =',I5,',  REDUCED ORDER =',I5,   
     2       ',  ORTH VCT =',I5,',  NEIG =',I4,',  NZERO =',I4, /5X,    
     3       'USER SHIFT =',1P,E16.8,',  INTERNAL SHIFT =',D16.8,       
     4       ',  SINGULARITY CHECK ',A4)        
  230 IF (ISING .EQ. 0) GO TO 300        
C        
C     SINGULAR MATRIX. ADJUST LAMBDA        
C        
      IF (IBK .EQ. 1) GO TO 500        
      CNDFLG = CNDFLG + 1        
      IF (NODCMP .EQ. 3) GO TO 520        
      LAMBDA = 100.0D0*LAMBDA        
      GO TO 200        
C        
C     DETERMINE THE TIME REQUIRED TO COMPLETE FEER PROCESS        
C        
  300 CALL TMTOGO (T1)        
      XM  = MORD        
      XMP = NORTHO        
      XN  = NORD        
      XI  = IFSET        
      IFL = MCBLT(1)        
      CALL GOPEN (IFL,Z(IBUF1),RDREW)        
      NTMS = 0        
      DO 310 I = 1,NORD        
      II = 0        
      CALL UNPACK (*310,IFL,Z(1))        
      NTMS = NTMS + NN - II + 1        
  310 CONTINUE        
      CALL CLOSE (IFL,REW)        
      XT = NTMS        
      SP = (XT*(1.-XI)*(XM+XMP)+2.*XM) + XN*(2.+XI)*.5*(3.*XM**2+2.*XMP)
     1   + (16.+11.*XI*.5)*XN*XM + 14.*XM**2        
C        
C     OBTAIN TRIDIAGONAL REDUCTION        
C        
      NAME(2) = I3        
      NAME(3) = IBEGN        
      CALL CONMSG (NAME,3,0)        
      CALL FEER3        
      NAME(3) = IEND        
      CALL CONMSG (NAME,3,0)        
      IF (CNDFLG .NE. 3) GO TO 330        
      CALL PAGE2 (3)        
      WRITE  (IO,320) UWM        
  320 FORMAT (A25,' 2389', /5X,'PROBLEM SIZE REDUCED - NO MORE TRIAL ', 
     1       'VECTORS CAN BE OBTAINED.')        
  330 IF (MORD .EQ. 0) GO TO 350        
      CALL TMTOGO (T2)        
      TIMET = T3 - T1        
C        
C     OBTAIN EIGENVALUES AND EIGENVECTORS        
C        
      NAME(2) = I4        
      NAME(3) = IBEGN        
      CALL CONMSG (NAME,3,0)        
      CALL FEER4 (IT)        
      NAME(3) = IEND        
      CALL CONMSG (NAME,3,0)        
      CALL TMTOGO (T3)        
      IF (L16 .NE. 0) WRITE (IO,340) T1,T2,T3,SP        
  340 FORMAT (' FEER COMPLETE,  T1,T2,T3 =',3I9,',  SP = ',1P,E16.8)    
      IF (CNDFLG .NE. 4) GO TO 370        
  350 WRITE  (IO,360) UFM        
  360 FORMAT (A23,' 2391, PROGRAM LOGIC ERROR IN FEER')        
      GO TO 540        
  370 IF (MORD+NZERO .GE. NEIG) GO TO 390        
      NPR = NEIG - MORD - NZERO        
      CALL PAGE2 (3)        
      WRITE  (IO,380) UWM,NPR,NEIG        
  380 FORMAT (A25,' 2390', /4X,I5,' FEWER ACCURATE EIGENSOLUTIONS THAN',
     1       ' THE',I5,' REQUESTED HAVE BEEN FOUND.')        
      CNDFLG = 1        
      GO TO 420        
  390 IF (MORD+NZERO .EQ. NEIG) GO TO 420        
      NPR = MORD + NZERO - NEIG        
      CALL PAGE2 (3)        
      WRITE  (IO,400) UIM,NPR,NEIG        
  400 FORMAT (A29,' 2392', /4X,I5,' MORE ACCURATE EIGENSOLUTIONS THAN ',
     1       'THE',I5,' REQUESTED HAVE BEEN FOUND.')        
      IF (L16 .EQ. 0) WRITE (IO,410)        
  410 FORMAT (5X,'USE DIAG 16 TO DETERMINE ERROR BOUNDS')        
  420 CALL GOPEN (DMPFLE,Z(IBUF1),WRTREW)        
C        
C    SET IZ(1) TO 2 (FOR INVPWR) THEN IZ(7) TO 1 (POINTS TO FEER METHOD)
C        
      IZ(1) = 2        
      IZ(2) = MORD + NZERO        
      IZ(3) = ITER        
      IZ(4) = 0        
      IZ(5) = NODCMP        
      IZ(6) = NONUL        
      IZ(7) = 1        
      IZ(8) = CNDFLG        
      IZ(9) = 0        
      IZ(10)= 0        
      IZ(11)= 0        
      IZ(12)= 0        
      CALL WRITE (DMPFLE,IZ,12,1)        
      CALL CLOSE (DMPFLE,REW)        
      CRITF = XN*10.0**(-IT)        
      NAME(2) = I0        
      CALL CONMSG (NAME,3,0)        
      RETURN        
C        
  500 WRITE  (IO,510) UFM        
  510 FORMAT (A23,' 2436, SINGULAR MATRIX IN FEER BUCKLING SOLUTION.')  
      GO TO 540        
  520 WRITE  (IO,530) UFM        
  530 FORMAT (A23,' 2386', /5X,'STIFFNESS MATRIX SINGULARITY CANNOT BE',
     1       ' REMOVED BY SHIFTING.')        
  540 CALL MESAGE (-37,0,NAME)        
      RETURN        
      END        
C        
C     THIS ROUTINE WAS RENUMBERED BY G.CHAN  12/1992        
C        
C                    TABLE OF OLD vs. NEW STATEMENT NUMBERS        
C        
C     OLD NO.    NEW NO.      OLD NO.    NEW NO.      OLD NO.    NEW NO.
C    --------------------    --------------------    -------------------
C          2         10          250        150          330        360 
C        290         20           63        160          120        370 
C          3         30           65        170          310        380 
C          4         40           70        180          130        390 
C          5         50           80        200          320        400 
C         10         60           90        210          325        410 
C         12         70          280        220          190        420 
C         20         80          100        230          220        500 
C         30         90          110        300          350        510 
C         35        100          112        310          240        520 
C         40        110          300        320          260        530 
C         45        120          113        330          245        540 
C         50        130          340        340        
C         60        140        
