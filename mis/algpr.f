      SUBROUTINE ALGPR (IERR)        
C        
      LOGICAL         DEBUG        
      INTEGER         SYSBUF,NAME(2),EDT,EQEXIN,CSTM,UGV,FILE,CORWDS,   
     1                PGEOM,BUF1,BUF2,SCR1,SCR2,RET2,TYPOUT,BGPDT,      
     2                ITRL(7),STREAM(3),APRESS,ATEMP,STRML,ALGDB,       
     3                IDATA(24),KPTSA(10),IFANGS(10),RD,RDREW,WRT,      
     4                WRTREW,CLSREW,NOREW,LEN(3),IFILL(3),ALGDD        
      REAL            RFILL(3),Z(1),TA(9),RDATA(6),XSTA(21,10),        
     1                RSTA(21,10),R(21,10),B1(21),B2(21),RLE(21),       
     2                TC(21),TE(21),CORD(21),DELX(21),DELY(21),ZED(21), 
     3                PHI(2,21),ZR(21),PP(21),QQ(21),CORD2(21),        
     4                FCHORD(21),JZ(21),XB(21,10),YB(21,10),ZB(21,10),  
     5                DISPT(3),DISPR(3),DISPT1(21,10),DISPT2(21,10),    
     6                DISPT3(21,10),BLAFOR(21,10),DISPR1(21,10),        
     7                DISPR2(21,10),DISPR3(21,10)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / APRESS,ATEMP,STRML,PGEOM,IPRTK,IFAIL,SIGN,ZORIGN, 
     1                FXCOOR,FYCOOR,FZCOOR        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,NOREW        
CZZ   COMMON /ZZALGX/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /CONDAS/ PI,TWOPI,RADEG        
      COMMON /UNPAKX/ TYPOUT,IR1,IR2,INCR        
      EQUIVALENCE     (IZ(1),Z(1)),(IDATA(1),RDATA(1)),        
     1                (IFILL(1),RFILL(1))        
      DATA    NAME  / 4HALGP,4HR   /        
      DATA    STREAM/ 3292, 92,292 /        
      DATA    LEN   / 18, 24, 6    /        
      DATA    IBLK  , IZERO,RZERO  / 4H    , 0, 0.0          /        
      DATA    EDT   , EQEXIN,UGV,ALGDD,CSTM,BGPDT, SCR1,SCR2 /        
     1        102   , 103   ,104,105  ,106 ,107  , 301 ,302  /        
C        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      DEBUG =.FALSE.        
      CALL SSWTCH (20,J)        
      IF (J .EQ. 1) DEBUG =.TRUE.        
      BUF1 = KORSZ(IZ) - SYSBUF        
      BUF2 = BUF1 - SYSBUF        
      LEFT = CORWDS(IZ(1),IZ(BUF2-1))        
      M8   =-8        
      IF (LEFT .LE. 0) CALL MESAGE (M8,0,NAME)        
      IR1  = 1        
      INCR = 1        
      TYPOUT = 1        
      IERR = 0        
C        
      IFILL(1) = IBLK        
      IFILL(2) = IZERO        
      RFILL(3) = RZERO        
C        
C     CREATE ALGDB WITH CORRECT LENGTH RECORDS -        
C     BCD(18 WORDS), INTEGER(24 WORDS), REAL(6 WORDS)        
C        
      CALL GOPEN (ALGDD,IZ(BUF1),RDREW)        
      CALL GOPEN (SCR2,IZ(BUF2),WRTREW)        
      ITRL(1) = ALGDD        
      CALL RDTRL (ITRL)        
      ITRL(1) = SCR2        
      CALL WRTTRL (ITRL)        
    1 CALL READ (*7,*2,ALGDD,IDATA,99,1,NWAR)        
    2 CALL ALGPB (IDATA(1),NTYPE)        
      LENGTH = LEN(NTYPE)        
C        
C     REMOVE NUMERIC ZEROS FROM BCD STRING        
C        
      IF (NTYPE .NE. 1) GO TO 4        
    3 IF (IDATA(NWAR) .NE. 0) GO TO 4        
      NWAR = NWAR - 1        
      IF (NWAR .GT.      0) GO TO 3        
    4 IF (NWAR .GE. LENGTH) GO TO 6        
      NWAR1 = NWAR + 1        
      DO 5 I = NWAR1,LENGTH        
    5 IDATA(I) = IFILL(NTYPE)        
    6 CALL WRITE (SCR2,IDATA,LENGTH,1)        
      GO TO 1        
    7 CALL CLOSE (ALGDD,CLSREW)        
      CALL CLOSE (SCR2,CLSREW)        
      ALGDB = SCR2        
C        
C     IF UGV IS NOT IN FIST (PURGED) THEN THERE WILL BE NO DATA        
C     MODIFICATION        
C        
      ITRL(1) = UGV        
      CALL RDTRL (ITRL)        
      IF (ITRL(1) .LT. 0) GO TO 997        
C        
C     READ EQEXIN INTO CORE        
C        
      FILE = EQEXIN        
      CALL GOPEN (EQEXIN,IZ(BUF1),RDREW)        
      CALL READ (*901,*10,EQEXIN,IZ(1),LEFT,1,NEQEX)        
      CALL MESAGE (M8,0,NAME)        
   10 CALL FREAD (EQEXIN,IZ(NEQEX+1),NEQEX,1)        
      CALL CLOSE (EQEXIN,CLSREW)        
      KN = NEQEX/2        
      IF (DEBUG) CALL BUG1 ('EQEX    ',10,IZ(1),NEQEX)        
      IF (DEBUG) CALL BUG1 ('EQEX    ',10,IZ(NEQEX+1),NEQEX)        
C        
C     READ CSTM INTO CORE (CSTM MAY BE PURGED)        
C        
      FILE  = CSTM        
      ICSTM = 2*NEQEX + 1        
      NCSTM = 0        
      CALL OPEN (*30,CSTM,Z(BUF1),RDREW)        
      CALL FWDREC (*901,CSTM)        
      CALL READ (*901,*20,CSTM,IZ(ICSTM),BUF1-ICSTM,1,NCSTM)        
      CALL MESAGE (M8,0,NAME)        
   20 CALL CLOSE (CSTM,CLSREW)        
      IF (DEBUG) CALL BUG1 ('CSTM    ',20,IZ(ICSTM),NCSTM)        
C        
C     SET-UP FOR CALLS TO TRANSS        
C        
      CALL PRETRS (IZ(ICSTM),NCSTM)        
C        
C     UNPACK UGV DISPLACEMENT VECTOR (SUBCASE 2) INTO CORE        
C        
   30 IVEC = ICSTM + NCSTM        
      FILE = UGV        
      ITRL(1) = FILE        
      CALL RDTRL (ITRL)        
C        
C     CHECK FOR VALID UGV VECTOR        
C     THIS ROUTINE WILL ONLY PROCESS A REAL S.P. RECT. VECTOR        
C     OF SIZE G X 2        
C     (EXPANDED TO INCLUDE REAL D.P. RECT. VECTOR, G X 2,        
C     BY G.CHAN/UNISYS)        
C        
      NVECTS = ITRL(2)        
      KFORM  = ITRL(4)        
      KTYPE  = ITRL(5)        
C     IF (NVECTS.NE.2 .OR. KFORM.NE.2 .OR. KTYPE.NE.1) GO TO 902        
      IF (NVECTS.NE.2 .OR. KFORM.NE.2) GO TO 902        
      IVECN = IVEC + KTYPE*ITRL(3) - 1        
      IF (IVECN .GE. BUF1) CALL MESAGE (M8,0,NAME)        
C        
C     OPEN UGV AND SKIP FIRST COLUMN (SUBCASE 1)        
C        
      CALL GOPEN (UGV,IZ(BUF1),RDREW)        
      CALL FWDREC (*901,UGV)        
      IR2 = ITRL(3)        
      CALL UNPACK (*40,UGV,IZ(IVEC))        
      GO TO 60        
C        
C     NULL COLUMN        
C        
   40 DO 50 I = IVEC,IVECN        
   50 Z(I) = 0.0        
   60 CALL CLOSE (UGV,CLSREW)        
      IF (DEBUG) CALL BUG1 ('UGV     ',60,IZ(IVEC),IR2)        
C        
C     LOCATE STREAML1 CARDS ON EDT AND STORE IN CORE        
C        
      FILE   = EDT        
      ICHORD = IVECN + 1        
      CALL PRELOC (*903,IZ(BUF1),EDT)        
      CALL LOCATE (*904,IZ(BUF1),STREAM,IDX)        
      CALL READ (*901,*70,EDT,IZ(ICHORD),BUF1-ICHORD,1,NCHORD)        
      CALL MESAGE (M8,0,NAME)        
   70 CALL CLOSE (EDT,CLSREW)        
      IF (DEBUG) CALL BUG1 ('CHOR    ',70,IZ(ICHORD),NCHORD)        
      LCHORD = ICHORD + NCHORD -1        
C        
C     READ THE BGPDT INTO CORE        
C        
      IBGPDT = LCHORD + 1        
      FILE   = BGPDT        
      CALL GOPEN (BGPDT,IZ(BUF1),RDREW)        
      CALL READ (*901,*80,BGPDT,IZ(IBGPDT),BUF1-IBGPDT,1,NBGPDT)        
      CALL MESAGE (M8,0,NAME)        
   80 CALL CLOSE (BGPDT,CLSREW)        
      IF (DEBUG) CALL BUG1 ('BGPD    ',80,IZ(IBGPDT),NBGPDT)        
C        
C     FOR EACH STREAML1 CARD -        
C     (1) FIND BLADE NODES        
C     (2) FIND EQUIVALENT INTERNAL NUMBERS OF THESE NODES        
C     (3) LOCATE CORRESPONDING COMPONENTS OF DISPLACEMENT AND        
C         CONVERT THEN TO BASIC VIA CSTM        
C     (4) LOCATE BASIC GRID POINT DATA FOR BLADE NODES        
C        
      IC  = ICHORD + 1        
      ICC = ICHORD        
      JCHORD = 1        
      NNODES = 0        
  100 ISTATN = 0        
  110 ID = IZ(IC)        
      IF (ID .NE. -1) GO TO 120        
      ICC = IC + 1        
      IC  = IC + 2        
      NNODES = NNODES + ISTATN        
      JCHORD = JCHORD + 1        
      IF (IC .GE. LCHORD) GO TO 150        
      GO TO 100        
  120 ISTATN = ISTATN + 1        
      GO TO 1005        
C        
C     STORE BASIC GRID POINT COORDINATES FROM BGPDT        
C        
  130 XB(JCHORD,ISTATN) = Z(ICID+1)        
      YB(JCHORD,ISTATN) = Z(ICID+2)        
      ZB(JCHORD,ISTATN) = Z(ICID+3)        
      DISPT1(JCHORD,ISTATN) = DISPT(1)        
      DISPT2(JCHORD,ISTATN) = DISPT(2)        
      DISPT3(JCHORD,ISTATN) = DISPT(3)        
      DISPR1(JCHORD,ISTATN) = DISPR(1)        
      DISPR2(JCHORD,ISTATN) = DISPR(2)        
      DISPR3(JCHORD,ISTATN) = DISPR(3)        
      IF (DEBUG) CALL BUG1 ('NODE    ',ID,Z(ICID+1),3)        
      IF (DEBUG) CALL BUG1 ('NODE    ',ID,DISPT,3)        
      IF (DEBUG) CALL BUG1 ('NODE    ',ID,DISPR,3)        
      IC = IC + 1        
      GO TO 110        
  150 CONTINUE        
      JCHORD = JCHORD - 1        
      IF (JCHORD .GT. 21) GO TO 906        
C        
C     MODIFY AERODYNAMIC INPUT  (OPEN ALGDB DATA BLOCK)        
C        
      FILE = ALGDB        
      CALL GOPEN (ALGDB,IZ(BUF1),RDREW)        
      CALL FWDREC (*907,ALGDB)        
      CALL READ (*901,*908,ALGDB,IDATA,2,1,NWAR)        
      NAERO = IDATA(2)        
      CALL SKPREC (ALGDB,1)        
      CALL FREAD (ALGDB,IDATA,17,1)        
      NLINES = IDATA(1)        
      NSTNS  = IDATA(2)        
      NSPEC  = IDATA(4)        
      IPUNCH = IDATA(8)        
      ISECN  = IDATA(9)        
      IFCORD = IDATA(10)        
      ISPLIT = IDATA(13)        
      IRLE   = IDATA(15)        
      IRTE   = IDATA(16)        
      NSIGN  = IDATA(17)        
      CALL SKPREC (ALGDB,1)        
      DO 204 ISK = 1,NSTNS        
      CALL FREAD (ALGDB,IDATA,2,1)        
      KPTSA(ISK) = IDATA(1)        
      IFANGS(ISK)= IDATA(2)        
      CALL SKPREC (ALGDB,IDATA(1))        
      DO 202 INL = 1,NLINES        
      CALL FREAD (ALGDB,RDATA,2,1)        
  202 BLAFOR(INL,ISK) = RDATA(2)        
  204 CONTINUE        
      DO 210 ISK = 1,NSPEC        
      CALL FREAD (ALGDB,RDATA,6,1)        
      ZR(ISK)  = RDATA(1)        
      JZ(ISK)  = RDATA(1) + 0.4        
      B1(ISK)  = RDATA(2)        
      B2(ISK)  = RDATA(3)        
      PP(ISK)  = RDATA(4)        
      QQ(ISK)  = RDATA(5)        
      RLE(ISK) = RDATA(6)        
      CALL FREAD (ALGDB,RDATA,6,1)        
      TC(ISK)  = RDATA(1)        
      TE(ISK)  = RDATA(2)        
      ZED(ISK) = RDATA(3)        
      CORD(ISK)= RDATA(4)        
      DELX(ISK)= RDATA(5)        
      DELY(ISK)= RDATA(6)        
      IF (ISECN.EQ.1 .OR. ISECN.EQ.3) CALL SKPREC (ALGDB,1)        
  210 CONTINUE        
      CALL CLOSE (ALGDB,CLSREW)        
C        
C     NUMBER OF BLADE STATIONS        
C        
      NBLSTN = IRTE - IRLE + 1        
      IF (NLINES .NE. JCHORD) GO TO 909        
      IF (NNODES .NE. NLINES*NBLSTN) GO TO 909        
C        
C     COMPUTE FCORD AND PHI        
C        
      DO 305 K = 1,NSPEC        
      J    = JZ(K)        
      TEMP = (XB(J,NBLSTN)-XB(J,1))**2 + (ZB(J,NBLSTN)-ZB(J,1))**2      
      IF (IFCORD .EQ. 1) TEMP = TEMP   + (YB(J,NBLSTN)-YB(J,1))**2      
      FCHORD(K) = CORD(K)/SQRT(TEMP)        
      PHI(1,K)  = ATAN((ZB(J,2)-ZB(J,1))/(XB(J,2)-XB(J,1)))        
      PHI(2,K)  = ATAN((ZB(J,NBLSTN)-ZB(J,NBLSTN-1))/        
     1                 (XB(J,NBLSTN)-XB(J,NBLSTN-1)))        
  305 CONTINUE        
C     COMPUTE NEW COORDINATES        
C     GENERATE XSTA, RSTA AND R , SET KPTS = NLINES        
      DO 310 I = 1,NLINES        
      DO 310 J = 1,NBLSTN        
      XB(I,J) = XB(I,J) + SIGN*DISPT1(I,J)*FXCOOR        
      YB(I,J) = YB(I,J) + SIGN*DISPT2(I,J)*FYCOOR        
      ZB(I,J) = ZB(I,J) + SIGN*DISPT3(I,J)*FZCOOR        
      XSTA(I,J) = XB(I,J)        
      RSTA(I,J) = ZB(I,J) + ZORIGN        
      R(I,J)  = RSTA(I,J)        
  310 CONTINUE        
C        
C     COMPUTE CORD2        
C        
      DO 315 K = 1,NSPEC        
      J    = JZ(K)        
      TEMP = (XB(J,NBLSTN)-XB(J,1))**2 + (ZB(J,NBLSTN)-ZB(J,1))**2      
      IF (IFCORD .EQ. 1) TEMP = TEMP   + (YB(J,NBLSTN)-YB(J,1))**2      
      CORD2(K) = FCHORD(K)*SQRT(TEMP)        
  315 CONTINUE        
C        
C     MODIFY B1, B2, RLE, TC, TE, CORD, DELX AND DELY        
C        
      I1 = (NBLSTN+1)/2        
      I2 = I1        
      IF (I1*2 .NE. NBLSTN+1) I2 = I2 + 1        
      DO 318 K = 1,NSPEC        
      J  = JZ(K)        
      B1(K) = B1(K) - NSIGN*SIGN*RADEG*(DISPR3(J,1)*COS(PHI(1,K)) -     
     1                                  DISPR1(J,1)*SIN(PHI(1,K)))      
      B2(K) = B2(K) - NSIGN*SIGN*RADEG*(DISPR3(J,NBLSTN)*COS(PHI(2,K)) -
     1                                  DISPR1(J,NBLSTN)*SIN(PHI(2,K))) 
      TEMP   = CORD(K)/CORD2(K)        
      RLE(K) = RLE(K) *TEMP        
      TC(K)  = TC(K)  *TEMP        
      TE(K)  = TE(K)  *TEMP        
      CORD(K) = CORD2(K)        
      DELX(K) = DELX(K) + 0.5*SIGN*FXCOOR*(DISPT1(J,I1)+DISPT1(J,I2))   
      DELY(K) = DELY(K) + 0.5*SIGN*FYCOOR*(DISPT2(J,I1)+DISPT2(J,I2))   
  318 CONTINUE        
C        
C     GENERATE NEW ALGDB DATA BLOCK        
C        
      CALL GOPEN (ALGDB,IZ(BUF1),RDREW)        
      CALL GOPEN (SCR1,IZ(BUF2),WRTREW)        
      ITRL(1) = ALGDB        
      CALL RDTRL (ITRL)        
C        
C     MODIFY THE NUMBER OF CARDS IN ALGDB        
C        
      NCDSX = 0        
      DO 320 KPT = IRLE,IRTE        
  320 NCDSX = NCDSX + NLINES - KPTSA(KPT)        
      ITRL(2) = ITRL(2) + NCDSX        
      ITRL(1) = SCR1        
      CALL WRTTRL (ITRL)        
      ASSIGN 322 TO RET2        
      NREC = 5        
      GO TO 1300        
C        
C     COPY DATA FOR STATIONS 1 THRU (IRLE-1)        
C        
  322 IF (IRLE .EQ. 1) GO TO 335        
      NLES = IRLE - 1        
      NREC = NLES + NLES*NLINES        
      DO 324 IKP = 1,NLES        
  324 NREC = NREC + KPTSA(IKP)        
      ASSIGN 326 TO RET2        
      GO TO 1300        
C        
C     SKIP OVER EXISTING RECORDS FOR STATIONS IRLE THRU IRTE        
C        
  326 NREC = NBLSTN + NBLSTN*NLINES        
      DO 328 IKP = IRLE,IRTE        
  328 NREC = NREC + KPTSA(IKP)        
      CALL SKPREC (ALGDB,NREC)        
C        
C     CREATE NEW DATA RECORDS FOR STATIONS IRLE THRU IRTE        
C        
      KSTA = 0        
      DO 334 JSTA = IRLE,IRTE        
      KSTA = KSTA + 1        
      IDATA(1) = NLINES        
      IDATA(2) = IFANGS(JSTA)        
      CALL WRITE (SCR1,IDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',329,IDATA,2)        
      DO 330 I = 1,NLINES        
      RDATA(1) = XSTA(I,KSTA)        
      RDATA(2) = RSTA(I,KSTA)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',330,RDATA,2)        
  330 CALL WRITE(SCR1,RDATA,2,1)        
      DO 332 I = 1,NLINES        
      RDATA(1) = R(I,KSTA)        
      RDATA(2) = BLAFOR(I,KSTA)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',332,RDATA,2)        
  332 CALL WRITE (SCR1,RDATA,2,1)        
  334 CONTINUE        
  335 CONTINUE        
C        
C     COPY DATA FOR STATIONS (IRTE+1) THRU NSTNS        
C        
      IF (IRTE .EQ. NSTNS) GO TO 338        
      IRTE1 = IRTE  + 1        
      IRTE2 = NSTNS - IRTE        
      NREC  = IRTE2 + IRTE2*NLINES        
      DO 336 IKP = IRTE1,NSTNS        
  336 NREC  = NREC  + KPTSA(IKP)        
      ASSIGN 338 TO RET2        
      GO TO 1300        
  338 CONTINUE        
C        
C     MODIFY THE NEXT NSPEC RECORDS        
C        
      DO 340 I = 1,NSPEC        
      CALL SKPREC(ALGDB,2)        
      RDATA(1) = ZR(I)        
      RDATA(2) = B1(I)        
      RDATA(3) = B2(I)        
      RDATA(4) = PP(I)        
      RDATA(5) = QQ(I)        
      RDATA(6) = RLE(I)        
      CALL WRITE (SCR1,RDATA,6,1)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',338,RDATA,6)        
      RDATA(1) = TC(I)        
      RDATA(2) = TE(I)        
      RDATA(3) = ZED(I)        
      RDATA(4) = CORD(I)        
      RDATA(5) = DELX(I)        
      RDATA(6) = DELY(I)        
      CALL WRITE (SCR1,RDATA,6,1)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',339,RDATA,6)        
      IF (ISECN.NE.1 .AND. ISECN.NE.3) GO TO 340        
      CALL FREAD (ALGDB,RDATA,2,1)        
      CALL WRITE (SCR1,RDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',340,RDATA,2)        
  340 CONTINUE        
C        
C     COPY REST OF ANALYTIC DATA        
C        
      IF (ISPLIT .LT. 1) GO TO 344        
      NREC = NSPEC        
      DO 342 I = 1,NSTNS        
      IF (IFANGS(I) .EQ. 2) NREC = NREC + NLINES        
  342 CONTINUE        
      ASSIGN 344 TO RET2        
      GO TO 1300        
  344 CONTINUE        
      IF (NAERO.NE.1 .AND. IPUNCH.NE.1) GO TO 352        
      NREC  = 1        
      ASSIGN 346 TO RET2        
      GO TO 1300        
  346 NRAD  = IDATA(1)        
      NDPTS = IDATA(2)        
      NDATR = IDATA(3)        
      ASSIGN 347 TO RET2        
      NREC  = 2        
      GO TO 1300        
  347 NB = NBLSTN - 1        
      I  = 1        
  348 NREC = 1        
      ASSIGN 349 TO RET2        
      GO TO  1300        
  349 NREC = IDATA(1)        
      ASSIGN 350 TO RET2        
      GO TO  1300        
  350 I = I + 1        
      IF (I .LE. NB) GO TO 348        
      NREC = NRAD*(NDPTS+1) + NDATR        
      ASSIGN 352 TO RET2        
      GO TO  1300        
C        
C     PROCESS AERODYNAMIC INPUT        
C        
  352 IF (NAERO .EQ. 0) GO TO 366        
      ASSIGN 354 TO RET2        
      NREC  = 3        
      GO TO 1300        
  354 NSTNS = IDATA(1)        
      NCASE = IDATA(6)        
      NMANY = IDATA(16)        
      NLE   = IDATA(19)        
      NTE   = IDATA(20)        
      NSIGN = IDATA(21)        
      IF (NSTNS .EQ. 0) NSTNS = 11        
      IF (NCASE .EQ. 0) NCASE = 1        
      NREC  = NCASE + 3        
      IF (NMANY .GT. 0) NREC = NCASE + 4        
      ASSIGN 356 TO RET2        
      GO TO  1300        
  356 CONTINUE        
C        
C     COPY DATA FOR STATIONS 1 THRU (NLE-1)        
C        
      IF (NLE .EQ. 1) GO TO 361        
      NLE1 = NLE - 1        
      I    = 1        
  357 NREC = 1        
      ASSIGN 358 TO RET2        
      GO TO  1300        
  358 NREC = IDATA(1)        
      ASSIGN 360 TO RET2        
      GO TO  1300        
  360 I = I + 1        
      IF (I .LE. NLE1) GO TO 357        
  361 JSTA = 0        
C        
C     MODIFY DATA FOR STATIONS NLE THRU NTE        
C        
      DO 364 I = NLE,NTE        
      JSTA = JSTA + 1        
      CALL FREAD (ALGDB,NSPEC,1,1)        
      CALL SKPREC (ALGDB,NSPEC)        
      CALL WRITE (SCR1,NLINES,1,1)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',361,NLINS,1)        
      DO 362 NL = 1,NLINES        
      RDATA(1) = XSTA(NL,JSTA)        
      RDATA(2) = RSTA(NL,JSTA)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',362,RDATA,2)        
  362 CALL WRITE (SCR1,RDATA,2,1)        
  364 CONTINUE        
C        
C     COPY REST OF DATA        
C        
      ASSIGN 366 TO RET2        
      NREC = 65000        
      GO TO  1300        
C        
C     CLOSE ALGDB AND SCR1        
C        
  366 CALL CLOSE (ALGDB,CLSREW)        
      CALL CLOSE (SCR1,CLSREW)        
C        
C     PUNCH NEW ALGDB TABLE INTO DTI CARDS IF PGEOM=3.        
C        
      IF (PGEOM .EQ. 3) CALL ALGAP (ALGDD,SCR1)        
      GO TO 999        
C        
C        
C     INTERNAL BINARY SEARCH ROUTINE        
C        
C     SEARCH EQEXIN FOR INTERNAL NUMBER AND SIL NUMBER OF EXTERNAL NODE 
C        
 1005 KLO = 1        
      KHI = KN        
 1010 K   = (KLO + KHI + 1) / 2        
 1020 IF (ID - IZ(2*K-1)) 1030,1090,1040        
 1030 KHI = K        
      GO TO 1050        
 1040 KLO = K        
 1050 IF (KHI - KLO - 1)  905,1060,1010        
 1060 IF (K .EQ. KLO) GO TO 1070        
      K   = KLO        
      GO TO 1080        
 1070 K   = KHI        
 1080 KLO = KHI        
      GO TO 1020        
 1090 INTN = IZ(2*K)        
      ISIL = IZ(2*K+NEQEX)/10        
      KODE = IZ(2*K+NEQEX) - 10*ISIL        
      IF (DEBUG) CALL BUG1('ISTL    ',1090,ISIL,1)        
      IF (DEBUG) CALL BUG1('KODE    ',1090,KODE,1)        
C        
C     LOCATE COORDINATE SYSTEM ID FOR THIS NODE IN THE BGPDT        
C        
      ICID = 4*(INTN-1) + IBGPDT        
C        
C     SET-UP COORDINATE SYSTEM TRANSFORMATION FOR DISPLACEMENTS.        
C        
      IF (IZ(ICID) .GT. 0) CALL TRANSS (IZ(ICID),TA)        
C        
C     COMPUTE POINTER INTO UGV        
C     JVEC = IVEC + KTYPE *(ISIL-1)        
C        
      JVEC = IVEC + TYPOUT*(ISIL-1)        
C        
C     PICK-UP DISPLACEMENTS        
C        
      IF (KODE .EQ. 1) GO TO 1092        
C        
C     SCALAR POINT        
C        
      DISPT(1) = Z(JVEC)        
      DISPT(2) = 0.0        
      DISPT(3) = 0.0        
      DISPR(1) = 0.0        
      DISPR(2) = 0.0        
      DISPR(3) = 0.0        
      GO TO 1100        
C        
C     GRID POINT        
C        
 1092 IF (IZ(ICID) .GT. 0) GO TO 1094        
C        
C     DISPLACEMENTS ALREADY IN BASIC SYSTEM        
C        
      DISPT(1) = Z(JVEC  )        
      DISPT(2) = Z(JVEC+1)        
      DISPT(3) = Z(JVEC+2)        
      DISPR(1) = Z(JVEC+3)        
      DISPR(2) = Z(JVEC+4)        
      DISPR(3) = Z(JVEC+5)        
      GO TO 1100        
C        
C     DISPLACEMENTS MUST BE TRANSFORMED TO BASIC        
C        
 1094 CALL GMMATS (TA,3,3,0,Z(JVEC  ),3,1,0,DISPT)        
      CALL GMMATS (TA,3,3,0,Z(JVEC+3),3,1,0,DISPR)        
 1100 CONTINUE        
      GO TO 130        
 1300 DO 1304 ICOPY = 1,NREC        
      CALL READ (*1306,*1302,ALGDB,IDATA,99,1,NWAR)        
 1302 CALL WRITE (SCR1,IDATA,NWAR,1)        
      IF (DEBUG) CALL BUG1 ('ALGPR   ',1302,IDATA,NWAR)        
 1304 CONTINUE        
      IF (NREC .LT. 65000) GO TO 1306        
      WRITE  (NOUT,1305)        
 1305 FORMAT (/,' *** NO. OF RECORDS EXCEEDS HARDWARE LIMIT/ALGPR')     
      CALL MESAGE (-37,0,0)        
 1306 GO TO RET2, (322,326,338,344,346,347,349,350,352,354,356,358,     
     1             360,366)        
C        
  901 CALL MESAGE (-2,FILE,NAME)        
      GO TO 998        
  902 WRITE (NOUT,2001) UFM        
      GO TO 998        
  903 WRITE (NOUT,2002) UFM        
      GO TO 998        
  904 WRITE (NOUT,2003) UFM        
      GO TO 998        
  905 WRITE (NOUT,2004) UFM,IZ(ICC),ID        
      GO TO 998        
  906 WRITE (NOUT,2005) UWM        
      GO TO 999        
  907 WRITE (NOUT,2006) UFM        
      GO TO 998        
  908 CALL MESAGE (-3,FILE,NAME)        
      GO TO 998        
  909 WRITE (NOUT,2007) UFM        
      GO TO 998        
  997 IERR = 1        
      GO TO 999        
  998 IERR = -1        
  999 RETURN        
C        
 2001 FORMAT (A23,' - ALG MODULE - UGV DATA BLOCK IS NOT A REAL S.P. ', 
     1       'RECTANGULAR MATRIX OF ORDER G BY 2.')        
 2002 FORMAT (A23,' - ALG MODULE - EDT DATA BLOCK MAY NOT BE PURGED.')  
 2003 FORMAT (A23,' - ALG MODULE - STREAML1 BULK DATA CARD MISSING ',   
     1       'FROM BULK DATA DECK.')        
 2004 FORMAT (A23,' - ALG MODULE - STREAML1 BULK DATA CARD (SLN NO. =', 
     1       I3,') REFERENCES UNDEFINED NODE NO.',I8)        
 2005 FORMAT (A25,' - ALG MODULE - MORE THAN 21 STREAML1 CARDS READ. ', 
     1       'FIRST 21 WILL BE USED.')        
 2006 FORMAT (A23,' - ALG MODULE - ALGDB DATA BLOCK (FILE 105) DOES ',  
     1       'NOT HAVE ENOUGH RECORDS.')        
 2007 FORMAT (A23,' - ALG MODULE - INPUT IN ALGDB DATA BLOCK (FILE 105',
     1       ') INCONSISTENT WITH DATA ON STREAML1 BULK DATA CARDS.',   
     2       /39X,'CHECK THE NUMBER OF COMPUTING STATIONS AND THE ',    
     3       'NUMBER OF STREAMSURFACES ON THE BLADE.')        
      END        
