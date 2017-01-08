      SUBROUTINE RAND5 (NFREQ,NPSDL,NTAU,XYCB,LTAB,IFILE,PSDF,AUTO,     
     1                  NFILE)        
C        
C     THIS ROUTINE COMPUTES RANDOM RESPONSE FOR UNCOUPLED POWER SPECTRAL
C     DENSITY COEFFICIENTS        
C        
      INTEGER IZ(1),SYSBUF,FILE,XYCB,PSDF,AUTO,IFILE(1),NAME(2),        
     1        MCB1(7),MCB2(7),OLDLD        
      REAL    Q(2),DATA(100)        
C        
      COMMON /SYSTEM/ SYSBUF        
CZZ   COMMON /ZZRAND/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
C        
      EQUIVALENCE  (Z(1),IZ(1))        
C        
      DATA    NAME,MCB1,MCB2 /4HRAND,4H5   ,14*0/        
      DATA    IPSDF,IAUTO    /  4001,4002       /        
C *****        
C     DEFINITION OF VARIABLES        
C *****        
C     NFREQ    NUMBER OF FREQUENCIES        
C     NPSDL    NUMBER OF SUBCASES ON PSDL CARDS        
C     NTAU     NUMBER OF TIMES        
C     XYCB     DATA BLOCK CONTAINING XY USER REQUESTS        
C     LTAB     LENGTH OF CORE  USED FOR TABLES BY PRETAB        
C     IFILE    ARRY CONTAINING FILE NAMES FOR SORT 2 INPUT FILES        
C     PSDF     OUTPUT FILE FOR POWER SPECTRAL DENSITY FUNCTIONS        
C     AUTO     OUTPUT FILE FOR AUTOCORRELATION FUNCTIONS        
C     NFILE    LENGTH OF IFILE ARRAY        
C     MCB1     TRAILER FOR PSDF        
C     MCB2     TRAILER FOR AUTO        
C     IPSDF    OFP ID FOR  PSDF        
C     IAUTO    OFP ID FOR  AUTO        
C     LCORE    AVAIABLE CORE FOR ANY LIST        
C     IBUF1    BUFFER POINTERS        
C     IBUF2        
C     IBUF3        
C     ITAU     POINTER TO FIRST TAU -1        
C     ISAA     POINTER TO FIRST S(AA) -1        
C     TAU      TIMES FOR AUTTOCORRELATION        
C     SAA      POWER SPECTRAL DENSITY FACTORS        
C     ICORE    POINTER  TO FIRST REQUEST -1        
C     SYSBUF   LENGTH OF ONE BUFFER        
C     NPOINT   NUMBER OF REQUESTS        
C     NZ       CORE AVAILABLE FOR STORING PSDF-S        
C     IP       POINTER TO FIRST POINT OF CURRENT CORE LOAD        
C     NDONE    NUMBER OF REQUESTS PROCESSED        
C     OLDLD    LOAD ID OF OLD LOAD SET        
C     NDO      NUMBER POSSIBLE TO DO IN CORE        
C     ICS      POINTER TO FIRST PSDF VECTOR        
C     NLOAD    NUMBER OF PSDL CARDS PROCESSED        
C     ICDONE   NUMBER CURRENTLY DONE-- SEVERAL COMP FROM EACH VALUE     
C     LOAD     SUBCASE ID FROM INPUT RECORD        
C     IF       FORMAT FLAG  IF =0  DATA IS REA/IMAG IF.NE.0 MAG/PHASE   
C     LEN      LENGTH OF DATA RECORD        
C     Q        MEAN RESPONSE        
C     R        AUTO CORRALATION FUNCTION AT TIME TAU        
C     IP1      LOCAL POINT POINTER        
C        
C        
C *****        
C     CORE LAYOUT DURING EXECUTION        
C *****        
C     FREQUENCIES   NFREQ OF THEM        
C     RANDPS DATA   NPSDL OF THEM  5 WORDS PER CARD        
C                   LOAD ID   LOAD ID   X    Y=0. TABLE        
C     TAUS          NTAU OF THEM        
C     TABLE DATA    LTAB OF IT        
C     S(AA)         NFREQ OF THEM  THESE ARE  REEVALUATED WHEN LOAD CHAG
C     REQUESTS      NPOINT OF THEM 5 WORDS PER REQUEST        
C                   D.B. ID   COMP O.P. P/P        
C     S(J,A)        NO  DO OF THEM      LENGTH = NFREQ        
C        
C        
C     BUFFERS       3 NEEDED        
C        
C        
C     INITALIZE GENERAL VARIABLES, ASSIGN BUFFERS  ETC        
C        
      MCB1(1) = PSDF        
      MCB2(1) = AUTO        
      LCORE = KORSZ(Z)        
      IBUF1 = LCORE -SYSBUF+1        
      IBUF2 = IBUF1 -SYSBUF        
      IBUF3 = IBUF2 -SYSBUF        
      ITAU  = NFREQ +5*NPSDL        
      ISAA  = NTAU  +LTAB+ITAU        
      ICORE = ISAA  +NFREQ        
      LCORE = LCORE -ICORE-3*SYSBUF        
      ICRQ  =-LCORE        
      IF (LCORE .LE. 0) GO TO 980        
C        
C     OPEN OUTPUT FILES        
C        
      CALL GOPEN (PSDF,Z(IBUF2),1)        
      CALL GOPEN (AUTO,Z(IBUF3),1)        
C        
C     BEGIN LOOP ON EACH FILE        
C        
      DO 1000 I = 1,NFILE        
C        
C     BUILD POINT LIST FOR FILE(I)        
C        
      CALL RAND6 (XYCB,Z(IBUF1),NPOINT,IZ(ICORE+1),IFILE(I),LCORE)      
      IF (NPOINT .EQ. 0) GO TO 1000        
      NZ   = LCORE -5*NPOINT        
      ICRQ =-NZ        
      IF (NZ .LE. 0) GO TO 980        
C        
C     OPEN INPUT FILE        
C        
      FILE  = IFILE(I)        
      CALL OPEN (*1000,FILE,Z(IBUF1),0)        
      IP    = ICORE +1        
      NDONE = 0        
      OLDLD = 0        
      ICS   = ICORE +5*NPOINT +1        
      LLIST = 5*NPOINT        
      IPS   = IP        
      LLISTS= LLIST        
   13 NDO   = MIN0(NPOINT-NDONE,NZ/NFREQ)        
      ICRQ  = MAX0(NPOINT-NDONE,NFREQ)        
      IF (NDO .EQ. 0) GO TO 980        
      NLOAD = 0        
C        
C     ZERO CORE        
C        
      JJ = ICS + NDO*NFREQ-1        
      DO 16 K = ICS,JJ        
      Z(K) = 0.0        
   16 CONTINUE        
      ICDONE = 0        
C        
C     GET READY TO OBTAIN FIRST VALUE        
C        
   15 CALL RAND2 (IFILE(I),IZ(IP),LOAD,IF,LEN,LLIST)        
C        
C     CHECK FOR NEW LOAD        
C        
      IF (LOAD .EQ. 0) IF (NLOAD-NPSDL) 111,100,111        
      IF (LOAD .EQ. OLDLD) GO TO 50        
C        
C     NEW LOAD --EVALUATE S(AA) FUNCTIONS FOR THIS LOAD        
C        
      J  = NFREQ +1        
      JJ = ITAU        
      DO 10 K = J,JJ,5        
      IF (IZ(K) .EQ. LOAD) GO TO 20        
   10 CONTINUE        
C        
C     LOAD NOT NEEDED --REJECT        
C        
      GO TO 15        
C        
C     GOOD LOAD --EVALUATE        
C        
   20 OLDLD = LOAD        
      NLOAD = NLOAD +1        
      DO 30 J = 1,NFREQ        
      JJ = ISAA +J        
C        
C                TAB      X    F(X)        
      CALL TAB (IZ(K+4),Z(J),Z(JJ))        
      IF (IZ(K+4) .EQ. 0) Z(JJ) = 1.0        
      Z(JJ) = Z(JJ)*Z(K+2)        
   30 CONTINUE        
C        
C     BRING IN DATA        
C        
   50 IF (LEN .GT. 100) GO TO 970        
      DO 60 J = 1,NFREQ        
C        
C     ACCESS DATA FROM FILE INTO DATA ARRAY        
C        
      CALL RAND2A (DATA(1))        
      IP1 = IP        
      II  = ICDONE        
      LL  = ISAA +J        
C        
C     COMPUTE  MAGNITUDE         OF CURRENT COMPONENT        
C        
   52 IF ((LEN-2)/2 .GE. IZ(IP1+2)) GO TO 53        
C        
C     REQUEST OUT OF RANGE        
C        
      CALL MESAGE (52,IZ(IP1),IZ(IP1+1))        
      IZ(IP1+2) = (LEN-2)/2        
   53 JJ = IZ(IP1+2) +2        
      IF (IF .NE. 0) GO TO 51        
C        
C     REAL + IMAGINARY        
C        
      K  = JJ + LEN/2 -1        
      DATA(JJ) = SQRT(DATA(JJ)*DATA(JJ) + DATA(K)*DATA(K))        
C        
C     COMPUTE POWER SPECTRAL DENSITY FUNCTION        
C        
   51 K = ICS + II*NFREQ-1 +J        
      Z(K) = Z(K) + DATA(JJ)*Z(LL)*DATA(JJ)        
      IF (II .EQ. NDO-1) GO TO 60        
C        
C     IS NEXT REQUEST FROM SAME POINT        
C        
      IF (IZ(IP1).NE.IZ(IP1+5) .OR. IZ(IP1+1).NE.IZ(IP1+6)) GO TO 60    
      II = II +1        
      IP1= IP1+ 5        
      GO TO 52        
   60 CONTINUE        
      LLIST  = LLIST - 5*(II-ICDONE+1)        
      ICDONE = II +1        
      IP = IP1 +5        
C     HAVE I DONE ALL REQUEST(IN CURRENT CORE)        
C        
      IF (ICDONE .NE. NDO) GO TO 15        
C        
C     HAVE I ADDED IN ALL LOADS        
C        
      IP = IPS        
      IF (NLOAD .EQ. NPSDL) GO TO 100        
C        
C     START AGAIN ON NEXT LOAD        
C        
      LLIST  = LLISTS        
      ICDONE =  0        
      GO TO 15        
C        
C     ALL LOADS FOR CURRENT BUNCH DONE        
C        
  100 JJ = IP        
      J  = NDO* 5 +JJ-1        
      L  = ICS - NFREQ        
      DO 110 K = JJ,J,5        
      L = L+ NFREQ        
C        
C     COMPUTE MEAN RESPONSE   Q        
C        
      CALL RAND3 (Z(1),Z(L),Q,NFREQ)        
      IF (IZ(K+3) .EQ. 2) GO TO 105        
C        
C     PSDF REQUESTED        
C        
C     PUT OUT ID RECORD        
C        
      MCB1(7) = MCB1(7) +1        
      CALL RAND1 (PSDF,IPSDF,IZ(K),IZ(K+1),IZ(K+4),Q)        
C        
C     PUT OUT DATA RECORD        
C        
      DO 101 LL = 1,NFREQ        
      KK = L +LL -1        
      CALL WRITE (PSDF,Z(LL),1,0)        
      CALL WRITE (PSDF,Z(KK),1,0)        
  101 CONTINUE        
      CALL WRITE (PSDF,0,0,1)        
  105 IF (IZ(K+3) .EQ. 1) GO TO 110        
C        
C     AUTOCORRELATION REQUESTED        
C        
      IF (NTAU .EQ. 0) GO TO 110        
      CALL RAND1 (AUTO,IAUTO,IZ(K),IZ(K+1),IZ(K+4),Q)        
      MCB2(7) = MCB2(7)+1        
C        
C     PUT OUT DATA RECORD        
C        
      DO 106 LL = 1,NTAU        
      KK = ITAU + LL        
      CALL WRITE (AUTO,Z(KK),1,0)        
C        
C     COMPUTE AUTO        
C        
      CALL RAND4 (Z(1),Z(L),Z(KK),R,NFREQ)        
      CALL WRITE (AUTO,R,1,0)        
  106 CONTINUE        
      CALL WRITE (AUTO,0,0,1)        
  110 CONTINUE        
      CALL REWIND (IFILE(I))        
      NDONE = NDONE +NDO        
      IF (NDONE .NE. NPOINT) GO TO 200        
  111 CALL CLOSE (IFILE(I),1)        
      GO TO 1000        
C        
C     SPILL ON POINT LISTS --GO AGAIN        
C        
  200 OLDLD = 0        
      IP  = IP + 5*NDO        
      IPS = IP        
      LLISTS = LLISTS-5*NDO        
      GO TO 13        
 1000 CONTINUE        
C        
C     ALL STUFF DONE --GET OUT        
C        
      CALL CLOSE (PSDF,1)        
      CALL CLOSE (AUTO,1)        
      CALL WRTTRL (MCB1)        
      CALL WRTTRL (MCB2)        
      RETURN        
C        
C     FILE + MISC ERRORS        
C        
  901 CALL MESAGE (IP1,FILE,NAME)        
      RETURN        
  970 IP1 = -7        
      GO TO 901        
  980 IP1 = -8        
      FILE= ICRQ        
      GO TO 901        
      END        
