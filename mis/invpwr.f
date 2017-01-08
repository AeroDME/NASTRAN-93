      SUBROUTINE INVPWR        
C        
C     GIVEN A REAL SYMETRIC MATRIX, INVPWR WILL SOLVE FOR ALL OF THE    
C     EIGENVALUES AND EIGENVECTORS WITHIN A SPECIFIED RANGE        
C        
C     DEFINITION OF INPUT AND OUTPUT PARAMETERS        
C        
C     FILEK(7) =  MATRIX CONTROL BLOCK FOR THE INPUT STIFFNESS MATRIX K 
C     FILEM(7) =  MATRIX CONTROL BLOCK FOR THE INPUT MASS MATRIX M      
C     FILELM(7)=  MATRIX CONTROL BLOCK FOR THE OUTPUT EIGENVALUES       
C     FILEVC(7)=  MATRIX CONTROL BLOCK FOR THE OUTPUT EIGENVECTORS      
C     SR1FIL-        
C     SR7FIL   =  SCRATCH FILES REQUIRED INTERNALLY        
C     LAMMIN   =  MINIMUM VALUE FOR THE EIGENVALUE        
C     LAMMAX   =  MAXIMUM VALUE FOR THE EIGENVALUE        
C     NOEST    =  NUMBER OF ESTIMATED EIGENVALUES WITHIN THE SPECIFIED  
C                 RANGE        
C     NDPLUS   =  NUMBER OF DESIRED EIGENVALUES IN THE POSITIVE RANGE   
C     NDMNUS   =  NUMBER OF DESIRED EIGENVALUES IN THE NEGATIVE RANGE   
C     EPS      =  CONVERGENCE CRITERIA        
C        
C     FILELM AND FILEVC WILL BE USED AS SR1FIL AND SR2FIL WHILE THE     
C     EIGENVALUES AND EIGENVECTORS WILL BE STORED ON THE ACTUAL SR1FIL  
C     AND SR2FIL. THE ORDERING OF THE EIGENVALUES AND EIGENVECTORS WILL 
C     PUT THEM ON FILELM AND FILEVC IN THE CORRECT SEQUENCE AT THE END  
C     OF THE SUBROUTINE        
C        
C     SR1FIL-FILELM CONTAINS (K-LAMBDA*M)        
C     SR2FIL-FILEVC CONTAINS THE LOWER TRIANGLE L        
C     SR3FIL        CONTAINS THE UPPER TRIANGLE U        
C     SR4FIL        IS USED AS SCRATCH IN DECOMP        
C     SR5FIL        IS USED AS SCRATCH IN DECOMP        
C     SR6FIL        IS USED AS SCRATCH IN DECOMP        
C     SR7FIL        CONTAINS THE VECTORS WHICH ARE USED TO ORTHOGONALIZE
C                   THE CURRENT ITERATE        
C        
      EXTERNAL          NORM11    ,SUB1     ,MTMSU1   ,XTRNY1   ,       
     1                  NORM1     ,SUB      ,MTIMSU   ,XTRNSY        
      INTEGER           SYSBUF    ,COMFLG   ,FILEK    ,NAME(2)  ,       
     1                  SWITCH    ,DMPFIL   ,IZ(12)   ,STURM    ,       
     2                  T1        ,T2       ,TIMED        
      REAL              LAMMIN    ,LAMMAX   ,LMIN     ,Z        ,       
     1                  ZZ(1)        
      DOUBLE PRECISION  LAMBDA    ,LMBDA        
      COMMON   /DCOMPX/ DUMXX(35) ,ISYM        
      COMMON   /INVPWX/ FILEK(7)  ,FILEM(7) ,FILELM(7),FILEVC(7),       
     1                  SR1FIL    ,SR2FIL   ,SR3FIL   ,SR4FIL   ,       
     2                  SR5FIL    ,SR6FIL   ,SR7FIL   ,SR8FIL   ,       
     3                  DMPFIL    ,LAMMIN   ,LAMMAX   ,NOEST    ,       
     4                  NDPLUS    ,NDMNUS   ,EPS      ,NORTHO        
      COMMON   /STURMX/ STURM     ,SHFTPT   ,KEEP(2)        
      COMMON   /INVPXX/ LAMBDA    ,COMFLG   ,ITER     ,TIMED    ,       
     1                  NOPOS     ,RZERO    ,NEG      ,NOCHNG   ,       
     2                  IND       ,LMBDA    ,SWITCH   ,NZERO    ,       
     3                  NONEG     ,IVECT    ,IREG     ,ISTART        
      COMMON   /SYSTEM/ KSYSTM(65)        
      COMMON   /NAMES / RD        ,RDREW    ,WRT      ,WRTREW   ,       
     1                  REW       ,NOREW    ,EOFNRW        
CZZ   COMMON   /ZZINVP/ Z(1)        
      COMMON   /ZZZZZZ/ Z(1)        
CZZ   COMMON   /ZZINV3/ ZZ        
      EQUIVALENCE       (ZZ(1),Z(1))        
      EQUIVALENCE       (IZ(1),Z(1)), (KSYSTM(1),SYSBUF),        
     1                  (KSYSTM(55),IPREC)        
      DATA      NAME  / 4HINVP,4HWR  /        
C        
C     DEFINITION OF INTERNAL PARAMETERS        
C        
C     NSHIFT =  NUMBER OF SHIFT POINTS        
C     ISHIFT =  CURRENT SHIFT REGION        
C     NOVECT =  NUMBER OF EIGENVECTORS FOUND IN A GIVEN REGION        
C     NOSKIP =  NUMBER OF VECTORS TO SKIP TO REACH THE LAST SHIFT REGION
C     NEG    =  1 = FIND NEGATIVE ROOTS        
C               0 = FIND ONLY POSITIVE ROOTS        
C              -1 = WE ARE NOW SEARCHING FOR THE NEGATIVE ROOTS        
C     LAMBDA =  THE CURRENT SHIFT POINT        
C     RZEROP =  THE CURRENT EIGENVALUE MUST BE .LT. LAMBDA + RZEROP     
C     RZEROM =  THE CURRENT EIGENVALUE MUST BE .GT. LAMBDA - RZEROM     
C     LMBDA  =  THE ORIGINAL VALUE OF LAMBDA IN A GIVEN REGION        
C     COMFLG =  0 = INITIAL ENTRY WITH NEW LAMBDA        
C               1 = NEW SHIFT POINT WITHIN THE SEARCH REGION        
C               2 = NEW SHIFT DUE TO CLOSENESS TO AN EIGENVALUE        
C               3 = NUMBER OF DESIRED POSITIVE ROOTS FOUND        
C               4 = NUMBER FOUND EXCEEDS 3*NOEST        
C     ISING  =  SINGULARITY FLAG  0 = NO SINGULARITY        
C                                 1 = SINGULAR MATRIX - CHANGE LAMBDA   
C                                     AND TRY ONE MORE TIME        
C     ITER   =  TOTAL NUMBER OF ITERATIONS        
C     NOCHNG =  NUMBER OF SHIFTS WITHIN ONE REGION        
C     TIMED  =  TIME REQUIRED TO FORM AND DECOMPOSE (K-LAMBDA*M)        
C     NFIRST =  NUMBER OF VECTORS IN THE FIRST POSITIVE SEARCH REGION   
C        
      ISYM   = 1        
      NSHIFT = (NOEST+5)/6        
      NCOL   = FILEK(2)        
      NCOL2  = 2*NCOL        
      ISHIFT = 1        
      NZ     = KORSZ(ZZ(1))        
      ICRQ   = NCOL*(1+7*IPREC) + 4*SYSBUF - NZ        
      IF (ICRQ .GT. 0) GO TO 220        
      NZ     = KORSZ(Z(1))        
      IBUF1  = NZ - SYSBUF        
      ICRQ   = NCOL2 - IBUF1        
      IF (IBUF1 .LE. NCOL2) GO TO 220        
      NOPOS  = NORTHO        
      NONEG  = 0        
      NEG    = 0        
      IND    = 0        
      ITER   = 0        
      NODCMP = 0        
      NOSTRT = 0        
      NOMOVS = 0        
      IF (NORTHO .GT. 0) GO TO 20        
      CALL GOPEN (SR1FIL,Z(IBUF1),WRTREW)        
      CALL CLOSE (SR1FIL,NOREW)        
      CALL GOPEN (SR2FIL,Z(IBUF1),WRTREW)        
      CALL CLOSE (SR2FIL,NOREW)        
   20 LMIN   = LAMMIN        
      IF (LAMMIN .GE. 0.0) GO TO 30        
      LMIN   = 0.        
      NEG    = 1        
      IF (LAMMAX .GT. 0.0) GO TO 30        
      LMIN   = LAMMAX        
      NEG    =-1        
      DELLAM = LAMMIN - LAMMAX        
      GO TO 40        
C        
C     EVALUATE THE VALUE OF LAMBDA IN THE CENTER OF THE CURRENT SEARCH  
C     REGION        
C        
   30 DELLAM = LAMMAX - LMIN        
   40 LAMBDA = LMIN + (ISHIFT - 0.5)*DELLAM/NSHIFT        
      RZERO  = ABS(0.55*DELLAM/NSHIFT)        
      NOSTRT = NOSTRT + 1        
   50 COMFLG = 0        
      LMBDA  = LAMBDA        
C        
C     INITIATE CLOCK TIME        
C        
      CALL KLOCK (ISTART)        
      NOCHNG = 0        
      SWITCH = 0        
      IVECT  = 0        
      IREG   = 0        
      IND    = IND + 1        
      IF (IABS(IND) .EQ. 13) IND = 1        
      ISING  = 0        
      GO TO 90        
   70 ISING  = 0        
      SWITCH = 1        
   90 IF (NOCHNG .GE. 4) GO TO 160        
      NOCHNG = NOCHNG + 1        
      CALL KLOCK (T1)        
C        
C     CALL IN ADD LINK TO FORM  (K-LAMBDA*M)        
C        
      CALL INVP1        
C        
C     CALL IN DECOMP TO DECOMPOSE THIS MATRIX        
C        
      NODCMP = NODCMP + 1        
      SHFTPT = LAMBDA        
      CALL INVP2 (*100)        
      CALL KLOCK (T2)        
      GO TO 110        
C        
C     SINGULAR MATRIX. INCREMENT LAMBDA AND TRY ONCE MORE        
C        
  100 IF (ISING .EQ. 1) GO TO 150        
      ISING  = 1        
      LAMBDA = LAMBDA + .02*RZERO        
      GO TO 90        
C        
C     DETERMINE THE TIME REQUIRED TO FORM AND DECOMPOSE (K-LAMBDA*M)    
C        
  110 TIMED  = T2 - T1        
C        
C     CALL IN THE MAIN LINK TO ITERATE FOR EIGENVALUES        
C        
      IF (IPREC  .EQ. 1) CALL INVP3 (NORM11,SUB1,MTMSU1,XTRNY1)        
      IF (IPREC  .EQ. 2) CALL INVP3 (NORM1 ,SUB ,MTIMSU,XTRNSY)        
      IF (COMFLG .EQ. 2) GO TO 200        
      IF (COMFLG .EQ. 1) GO TO 70        
      IF (COMFLG .EQ. 3) GO TO 130        
      IF (COMFLG .EQ. 0) GO TO 120        
      GO TO 170        
  120 ISHIFT = ISHIFT + 1        
      IF (ISHIFT .GT. NSHIFT) GO TO 130        
      GO TO 40        
  130 IF (NEG) 180,180,140        
C        
C     INITIALIZE PARAMETERS TO SOLVE FOR NEGATIVE EIGENVALUES        
C        
  140 X      = NSHIFT*(-LAMMIN/LAMMAX)        
      IX     = X        
      Y      = IX        
      IF (X .NE. Y) IX = IX + 1        
      NSHIFT = IX        
      NEG    =-1        
      DELLAM = LAMMIN        
      ISHIFT = 1        
      GO TO 40        
  150 ITERM  = 1        
      GO TO 190        
  160 ITERM  = 2        
      GO TO 190        
  170 ITERM  = COMFLG        
      GO TO 190        
  180 ITERM  = 3        
C        
C     RE-ORDER EIGENVALUES AND EIGENVECTORS        
C        
  190 CALL GOPEN (DMPFIL,Z(IBUF1),WRTREW)        
      IZ( 1) = 2        
      IZ( 2) = NORTHO        
      IZ( 3) = NOSTRT        
      IZ( 4) = NOMOVS        
      IZ( 5) = NODCMP        
      IZ( 6) = ITER        
      IZ( 7) = 0        
      IZ( 8) = ITERM        
      IZ( 9) = 0        
      IZ(10) = 0        
      IZ(11) = 0        
      IZ(12) = 0        
      CALL WRITE (DMPFIL,IZ,12,1)        
      CALL CLOSE (DMPFIL,REW)        
      RETURN        
  200 NOMOVS = NOMOVS + 1        
      GO TO 50        
  220 NO     =-8        
      IFILE  = ICRQ        
      CALL MESAGE (NO,IFILE,NAME)        
      RETURN        
      END        
