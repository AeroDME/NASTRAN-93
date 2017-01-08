      SUBROUTINE GP4        
C        
C     GP4  PERFORMS THE FOLLOWING FUNCTIONS--        
C       1. READS CASECC AND MAKES ANALYSIS OF SUBCASE LOGIC        
C       2. PROCESSES RIGID ELEMENTS AND ALL OTHER CONSTRAINT DATA (MPC, 
C          SPC, OMIT, SUPORT, ASET, ETC.)        
C       3. BUILDS THE USET FOR THE CURRENT SUBCASE        
C       4. CALLS GP4SP TO EXAMINE GRID POINT SINGULARITIES        
C       5. BUILDS THE RGT MATRIX AND YS VECTOR FOR CURRENT SUBCASE      
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT ,RSHIFT ,ANDF   ,ORF    ,COMPLF        
      DIMENSION       BUF(20),MPC(2) ,OMIT(2),SUPORT(2)      ,SPC(2) ,  
     1                MPCADD(2)      ,SPC1(2),SPCADD(2)      ,MASK(6),  
     2                NAME(2),MCB(7) ,MCBUST(7)      ,MCBYS(7)       ,  
     3                OMITX1(2)      ,ASET(2),ASET1(2)       ,MAK(4) ,  
     4                SPCD(2),CTYPE(18)        
      REAL            RZ(1)  ,BUFR(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /MACHIN/ MACH   ,IHALF  ,JHALF        
      COMMON /BITPOS/ UM     ,UO     ,UR     ,USG    ,USB    ,UL     ,  
     1                UA     ,UF     ,US     ,UN     ,UG        
      COMMON /BLANK / LUSET  ,MPCF1  ,MPCF2  ,SINGLE ,OMIT1  ,REACT  ,  
     1                NSKIP  ,REPEAT ,NOSETS ,NOL    ,NOA    ,IDSUB  ,  
     2                IAUTSP        
      COMMON /GP4FIL/ GEOMP  ,BGPDT  ,CSTM   ,RGT    ,SCR1        
      COMMON /GP4PRM/ BUF    ,BUF1   ,BUF2   ,BUF3   ,BUF4   ,KNKL1  ,  
     1                MASK16 ,NOGO   ,GPOINT ,KN        
      COMMON /GP4SPX/ MSKUM  ,MSKUO  ,MSKUR  ,MSKUS  ,MSKUL  ,MSKSNG ,  
     1                SPCSET ,MPCSET ,NAUTO  ,IOGPST        
      COMMON /NAMES / RD     ,RDREW  ,WRT    ,WRTREW ,CLSREW        
      COMMON /PACKX / ITA1   ,ITB1   ,II1    ,JJ1    ,INCR1        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /TWO   / TWO(32)        
      COMMON /UNPAKX/ ITB    ,II     ,JJ     ,INCR        
      COMMON /ZBLPKX/ X(4)   ,IX        
CZZ   COMMON /ZZGP4X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM( 1),SYSBUF), (KSYSTM( 2),OUTTAP ),        
     1                (KSYSTM(27),IAXIC ), (KSYSTM(38),IAXIF  ),        
     2                (Z(1)      ,RZ(1) ), (BUF(1)    ,BUFR(1)),        
     3                (UGSET     ,USGSET), (IB6       ,BUF(6) )        
      DATA    OMIT  / 5001,   50/,        
     1        SUPORT/ 5601,   56/,        
     2        SPC   / 5501,   55/,        
     3        SPC1  / 5481,   58/,        
     4        SPCADD/ 5491,   59/,        
     5        OMITX1/ 4951,   63/,        
     6        ASET  / 5561,   76/,        
     7        ASET1 / 5571,   77/,        
     8        SPCD  / 5110,   51/,        
     9        MPC   / 4901,   49/,        
     O        MPCADD/ 4891,   60/        
      DATA    NAME  / 4HGP4  ,4H    /        
      DATA    MSET  / 4H M   /,   SG/4H SG   /, R/ 4H R  /        
      DATA    YS    , USET   /202    ,203    /        
      DATA    SCR2           /302            /        
      DATA    MPCAX1, MPCAX2 /101    ,102    /        
      DATA    CASECC, EQEXIN ,GPDT   /101    ,103  ,104  /        
      DATA    CTYPE / 4HMPC , 4H    ,        
     1                4HOMIT, 4H    ,        
     2                4HOMIT, 4H1   ,        
     3                4HSUPO, 4HRT  ,        
     4                4HSPC1, 4H    ,        
     5                4HSPC , 4H    ,        
     6                4HSPCD, 4H    ,        
     7                4HASET, 4H    ,        
     8                4HASET, 4H1   /        
      DATA    IZ2,IZ3,IZ5,IZ16,IZ138/ 2, 3, 5, 16, 138   /        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      GEOMP  = 102        
      BGPDT  = 105        
      CSTM   = 106        
      RGT    = 201        
      SCR1   = 301        
      NAUTO  = 0        
      IOGPST = -1        
      BUF1   = KORSZ(Z) - SYSBUF - 2        
      BUF2   = BUF1 - SYSBUF        
      BUF3   = BUF2 - SYSBUF        
      BUF4   = BUF3 - SYSBUF        
      ICRQ   = LUSET- BUF4        
      INSUFF = 10        
      IF (LUSET .GE. BUF4) GO TO 2430        
C     MASK16 = 65535        
C     MASK15 = 32767        
      MASK16 = JHALF        
      MASK15 = JHALF/2        
      N23    = 2        
      MSKUM  = TWO(UM )        
      MSKUO  = TWO(UO )        
      MSKUR  = TWO(UR )        
      MSKUSG = TWO(USG)        
      MSKUSB = TWO(USB)        
      MSKUL  = TWO(UL )        
      MSKUA  = TWO(UA )        
      MSKUF  = TWO(UF )        
      MSKUS  = TWO(US )        
      MSKUN  = TWO(UN )        
      MSKUG  = TWO(UG )        
      MSKUNG = ORF(MSKUN,MSKUG)        
      MSKFNG = ORF(MSKUF,MSKUNG)        
      MSKSNG = ORF(MSKUS,MSKUNG)        
      MASK(1)= ORF(MSKUM,MSKUG)        
      MASK(2)= ORF(MSKUO,MSKFNG)        
      MASK(3)= ORF(MSKUR,ORF(MSKUA,MSKFNG))        
      MASK(4)= ORF(MSKUSG,MSKSNG)        
      MASK(5)= ORF(MSKUSB,MSKSNG)        
      MASK(6)= ORF(MSKUL,ORF(MSKUA,MSKFNG))        
      MAK(1) = ORF(MSKUM,MSKUL)        
      MAK(2) = ORF(MSKUS,MSKUL)        
      MAK(3) = ORF(MSKUO,MSKUL)        
      MAK(4) = ORF(MSKUR,MSKUL)        
      CALL MAKMCB (MCBYS,YS,0,2,1)        
      CALL MAKMCB (MCBUST,USET,LUSET,0,0)        
      MULTI  = -1        
      USGSET = -1        
      SINGLE = -1        
      OMIT1  = -1        
      NOSETS = -1        
      ASETX  = -1        
      REACT  = -1        
      NOYS   =  0        
      NOGEOM =  0        
      NOL    = -1        
      NOA    = +1        
      NOGO   =  0        
      NOGOOF =  0        
      DUP    =  0        
      IFLAG  =  0        
      FLAG   =  0        
      MSKCK  = COMPLF(LSHIFT(COMPLF(0),20))        
      RIGID  =  0        
      SPCOLD = -1        
      MPCOLD = -1        
      L21    =  0        
      L22    =  0        
      MCB(1) = GEOMP        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LT. 0) GO TO 20        
C        
C     BIT ASSIGNMENTS FOR RIGID ELEMENTS -        
C     CRIGD1 - 53       CRROD    - 65       CRBE1 - 68        
C     CRIGD2 - 54       CRBAR    - 66       CRBE2 - 69        
C     CRIGD3 - 83       CRTRPLT  - 67       CRBE3 - 70        
C     CRIGDR - 82       CRSPLINE - 71        
C        
      IF (ANDF(MCB(5),TWO(21)) .EQ. TWO(21)) RIGID = 1        
      IF (ANDF(MCB(5),TWO(22)) .EQ. TWO(22)) RIGID = 1        
      IF (ANDF(MCB(7),TWO(19)) .EQ. TWO(19)) RIGID = 1        
      IF (ANDF(MCB(7),TWO(18)) .EQ. TWO(18)) RIGID = 1        
      I = MCB(6)        
      DO 10 J = 17,23        
      IF (ANDF(I,TWO(J)) .EQ. TWO(J)) RIGID = 1        
   10 CONTINUE        
      CALL MAKMCB (MCB,RGT,0,2,1)        
C        
C     SUBCASE LOGIC -- NSKIP IS 0 (SET BY PARAM MODULE) IF FIRST        
C     SUBCASE. OTHERWISE NSKIP IS THE NO. OF RECORDS TO SKIP ON CASE    
C     CONTROL DATA BLOCK TO REACH THE LAST SUBCASE. GP4 SETS THE        
C     FOLLOWING PARAMETERS -        
C     (1) MPCF1 = +1 (DO NOT PURGE OR EQUIV MCE DATA BLOCKS) = -1 (PURGE
C                 AND EQUIV TO TAKE).        
C     (2) MPCF2 = +1 (EXECUTE MCE1 AND MCE2) = -1 (DO NOT EXECUTE)      
C     (3) REPEAT= +1 (MORE SUBCASES AFTER THIS ONE) = -1 (LAST SUBCASE).
C     (4) NSKIP = NO. OF RECORDS TO SKIP ON CASE CONTROL TO REACH THE   
C                 CURRENT SUBCASE (FOR MODULES IN REMAINDER OF LOOP).   
C        
   20 REPEAT= -1        
      MPCF1 = -1        
      MPCF2 = -1        
      NSKP1 =  1        
      FILE  = CASECC        
      CALL GOPEN (CASECC,Z(BUF1),0)        
      IF (NSKIP .GT. 1) CALL SKPREC (CASECC,NSKIP-1)        
      CALL FREAD (CASECC,Z,36,1)        
      IF (NSKIP .GT. 0) GO TO 30        
C        
C     FIRST SUBCASE - INITIALIZE.        
C        
      MPCSET = Z(IZ2)        
      SPCSET = Z(IZ3)        
      NSKIP  = 1        
      GO TO 50        
C        
C     SUBSEQUENT SUBCASE - POSITION CASE CONTROL AND INITIALIZE.        
C        
   30 MPCOLD = Z(IZ2)        
      SPCOLD = Z(IZ3)        
   40 NSKIP  = NSKIP + 1        
      CALL FREAD (CASECC,Z,36,1)        
      IF (Z(IZ16) .NE. 0) GO TO 40        
      IF (Z(IZ2).EQ.MPCOLD .AND. Z(IZ3).EQ.SPCOLD) GO TO 40        
      MPCSET = Z(IZ2)        
      SPCSET = Z(IZ3)        
C        
C     LOOK AHEAD TO END OF CURRENT SUBCASE AND SET PARAMETERS.        
C        
   50 CALL READ (*60,*2420,CASECC,Z,138,1,FLAG)        
C        
C     CHECK FOR SYMMETRY        
C        
      IF (Z(IZ16) .NE. 0) GO TO 50        
C        
C     CHECK FOR BUCKLING OR DIFFERENTIAL STIFFNESS        
C        
      IF (Z(IZ5).NE.0 .OR. Z(IZ138).NE.0) GO TO 60        
      IF (Z(IZ2).EQ.MPCSET .AND. Z(IZ3).EQ.SPCSET) GO TO 110        
      REPEAT = 1        
C        
C     CHECK TO SEE IF MPC SET IS SELECTED OR IF RIGID ELEMENTS EXIST    
C        
   60 IF (MPCSET.EQ.0 .AND. RIGID.EQ.0) GO TO 70        
      MPCF1 = 1        
      MPCF2 = 1        
      IF (NSKIP  .EQ.      1) GO TO 70        
      IF (MPCSET .EQ. MPCOLD) MPCF2 = -1        
   70 CALL CLOSE (CASECC,CLSREW)        
      ASSIGN 120 TO RET        
C        
C     READ EQEXIN INTO CORE        
C        
   80 FILE = EQEXIN        
      CALL GOPEN (EQEXIN,Z(BUF1),0)        
      CALL READ  (*2410,*90,EQEXIN,Z,BUF4,1,KN)        
      INSUFF = 80        
      ICRQ   = BUF4        
      GO TO 2430        
   90 CALL READ  (*2410,*2420,EQEXIN,Z(KN+1),KN,1,FLAG)        
      CALL CLOSE (EQEXIN, CLSREW)        
      KM  = 2*KN        
      KN2 = KN/2        
C        
C     FORM ARRAY OF SORTED SIL VALUES STARTING AT Z(KM+1)        
C        
      DO 100 I = 1, KN2        
      J = 2*(I-1) + 2 + KN        
      Z(KM+I) = Z(J)/10        
  100 CONTINUE        
      CALL SORT (0,0,1,1,Z(KM+1),KN2)        
      Z(KM+KN2+1) = LUSET + 1        
      KNKL1 = KM + KN2 + 2        
C        
C     SET DIAG-S 21 AND 22 FOR DEGREE-OF-FREEDOM PRINTER LATER.        
C        
      CALL SSWTCH (21,L21)        
      CALL SSWTCH (22,L22)        
      GO TO RET, (120,1930,1660)        
C        
  110 NSKP1 = NSKP1 + 1        
      GO TO 50        
C        
C     OPEN INPUT DATA FILE        
C        
  120 FILE = GEOMP        
      CALL PRELOC (*130,Z(BUF1),GEOMP)        
      NOGEOM = 1        
C        
C     CHECK TO SEE IF MPC SET IS SELECTED OR IF RIGID ELEMENTS EXIST    
C        
      IF (MPCSET.EQ.0 .AND. RIGID.EQ.0) GO TO 130        
C        
C     OPEN RGT FILE        
C        
      FILE = RGT        
      CALL GOPEN (RGT,Z(BUF3),1)        
C        
C     IF RIGID ELEMENTS EXIST, GENERATE THEIR COEFFICIENTS        
C        
      NOGOO = NOGO        
      NOGO  = 0        
      IF (RIGID .EQ. 1) CALL CRIGGP (N23)        
      IF (NOGO  .NE. 0) GO TO 2540        
      NOGO = NOGOO        
C        
C     OPEN SCRATCH DATA FILE        
C        
  130 FILE = SCR1        
      CALL OPEN (*2400,SCR1,Z(BUF2),WRTREW)        
C        
C     CHECK TO SEE IF GEOMP FILE EXISTS        
C        
      IF (NOGEOM .EQ. 0) GO TO 790        
C        
C     CHECK TO SEE IF MPC SET IS SELECTED OR IF RIGID ELEMENTS EXIST    
C        
      IF (MPCSET.EQ.0 .AND. RIGID.EQ.0) GO TO 610        
      IF (MPCSET .NE. 0) GO TO 140        
C        
C     NO MPC SET IS SELECTED        
C        
      MULTI = 0        
      IMPC  = KNKL1        
      I = IMPC        
      J = BUF3 - 1        
      GO TO 370        
C        
C     IF MPC SET IS SELECTED, DETERMINE IF SET IS ON MPCADD CARD.       
C     IF NOT, SIMULATE AN MPCADD SET LIST WITH ONE SET = MPCSET.        
C        
  140 IMPCAD = KNKL1        
      NMPCAD = KNKL1        
      IMPC   = IMPCAD + 2        
      I      = IMPCAD        
      Z(I)   = MPCSET        
      Z(I+1) = 0        
      FILE   = GEOMP        
      CALL LOCATE (*200,Z(BUF1),MPCADD,FLAG)        
  150 CALL READ (*2410,*200,GEOMP,ID,1,0,FLAG)        
      IF (ID .EQ. MPCSET) GO TO 170        
  160 CALL FREAD (GEOMP,BUF,1,0)        
      IF (BUF(1) .NE. -1) GO TO 160        
      GO TO 150        
  170 CALL READ (*2410,*190,GEOMP,BUF,1,0,FLAG)        
      IF (BUF(1) .EQ. -1) GO TO 180        
      Z(I  ) = BUF(1)        
      Z(I+1) = 0        
      I  = I + 2        
      GO TO 170        
  180 CALL FWDREC (*2410,GEOMP)        
  190 IMPC   = I        
      NMPCAD = I - 2        
C        
C     READ MPC CARDS. FOR EACH EQUATION WHOSE SET ID MATCHES A SET ID   
C     IN THE MPCADD SET LIST, CONVERT THE GRID POINT AND COMPONENT NO.  
C     (OR SCALAR NO.) TO A SIL VALUE. COMPUTE THE ROW AND COLUMN NO.    
C     FOR THE POINT AND SAVE THIS ALONG WITH ITS VALUE.        
C        
  200 CALL LOCATE (*320,Z(BUF1),MPC,FLAG)        
      J = BUF3 - 1        
      I = IMPC        
      MULTI = 0        
      ASSIGN 260  TO RET        
      ASSIGN 2460 TO RET1        
      ASSIGN 250  TO RET2        
      ASSIGN 270  TO RET3        
  210 CALL READ (*2410,*320,GEOMP,ID,1,0,FLAG)        
      DO 220 K = IMPCAD,NMPCAD,2        
      IF (Z(K) .EQ. ID) GO TO 240        
  220 CONTINUE        
  230 CALL FREAD (GEOMP,BUF,3,0)        
      IF (BUF(1) .NE. -1) GO TO 230        
      GO TO 210        
  240 MULTI = MULTI + 1        
      Z(K+1)= 1        
      IFL   = 0        
  250 CALL FREAD (GEOMP,BUF,3,0)        
      IF (BUF(1) .EQ. -1) GO TO 310        
      GPOINT = BUF(1)        
      GO TO 2100        
  260 INDEX = 1        
      ICOMP = BUF(2)        
      GO TO 2300        
  270 IF (ICOMP .NE. 0) GPOINT = GPOINT + ICOMP - 1        
      IF (IFL .EQ. 0) SILD = GPOINT        
      IF (N23 .EQ. 3) GO TO 300        
      IF (GPOINT .GT. MASK15) GO TO 290        
      Z(I  ) = ORF(LSHIFT(GPOINT,IHALF),SILD)        
      Z(I+1) = BUF(3)        
  280 I = I + N23        
      INSUFF = 236        
      IF (I .GE. J) GO TO 2430        
      IFL = 1        
      GO TO 250        
C        
C     GPOINT IS TOO BIG TO BE PACKED INTO HALF A WORD.  ABANDON COL.    
C     AND ROW PACKING LOGIC, AND DO IT OVER AGAIN WITHOUT PACKING.      
C        
  290 N23 = 3        
      CALL REWIND (GEOMP)        
      CALL FWDREC (*2410,GEOMP)        
      GO TO 200        
  300 Z(I  ) = GPOINT        
      Z(I+1) = SILD        
      Z(I+2) = BUF(3)        
      GO TO 280        
C        
C     SAVE A LIST OF DEPENDENT SIL VALUES        
C        
  310 Z(J)= SILD        
      J   = J - 1        
      GO TO 210        
C        
C     DETERMINE IF ALL MPC SETS IN MPCADD SET LIST HAVE BEEN INPUT      
C        
  320 IF (NOGO .NE. 0) GO TO 2540        
      NOGOO = NOGO        
      NOGO  = 0        
      IGOTCH= 0        
      DO 350 K = IMPCAD,NMPCAD,2        
      IF (Z(K+1) .NE. 0) GO TO 340        
      NOGO  = -1        
      IF (Z(K).EQ.200000000 .AND. IAXIF.NE.0) GO TO 350        
      IF (IAXIC .EQ. 0) GO TO 330        
      IF (Z(K).EQ.MPCAX1 .OR. Z(K).EQ.MPCAX2) GO TO 350        
      IF (Z(K) .EQ. 200000000) GO TO 350        
  330 NOGO  = +1        
      BUF(1)= Z(K)        
      BUF(2)= 0        
      CALL MESAGE (30,47,BUF)        
      GO TO 350        
  340 IGOTCH= 1        
  350 CONTINUE        
      IF (NOGO .EQ. 0) GO TO 370        
      IF (NOGO.EQ.-1 .AND. IGOTCH.EQ.1) GO TO 360        
      MPCSET=  0        
      MULTI = -1        
      MPCF1 = -1        
      MPCF2 = -1        
      IF (NOGO.EQ.-1 .AND. NOGOO.EQ.0) NOGO = 0        
      GO TO 600        
  360 CONTINUE        
      IF (NOGO.EQ.-1 .AND. NOGOO.EQ.0) NOGO = 0        
C        
C     CHECK TO SEE IF RIGID ELEMENTS EXIST        
C        
  370 IF (RIGID .EQ. 0) GO TO 470        
C        
C     EXPAND THE DEPENDENT SET BY APPENDING RIGID ELEMENT        
C     DATA TO MPC DATA        
C        
      CALL GOPEN  (RGT,Z(BUF3),0)        
      CALL SKPREC (RGT,1)        
      I1   = BUF3 - I        
      CALL READ (*2410,*380,RGT,Z(I),I1,1,NRIGID)        
      INSUFF = 3020        
      GO TO 2430        
  380 J = J - NRIGID        
      MULTI = MULTI + NRIGID        
      CALL SKPREC (RGT,-2)        
      CALL READ (*2410,*410,RGT,Z(I),I1,1,FLAG)        
      INSUFF = 3030        
      I2 = I1        
  390 CALL BCKREC (RGT)        
      CALL READ (*2410,*400,RGT,Z(I),-I2,0,FLAG)        
      CALL READ (*2410,*400,RGT,Z(I), I1,0,FLAG)        
      I2 = I2 + I1        
      GO TO 390        
  400 FLAG = I2 + FLAG        
      GO TO 440        
C        
C     RE-CODE COLUMN-ROW PACKED WORD IF NECESSARY FOR DATA JUST BROUGHT 
C     IN FROM RIGID ELEMENTS        
C     THEN READ THE LAST RECORD FROM RGT        
C        
  410 IF (N23 .EQ. 3) GO TO 430        
      I1 = I - 1        
      I2 = I1        
      I3 = I1 + FLAG        
  420 Z(I2+1) = ORF(LSHIFT(Z(I1+1),IHALF),Z(I1+2))        
      Z(I2+2) = Z(I1+3)        
      I1 = I1 + 3        
      I2 = I2 + 2        
      IF (I1 .LT. I3) GO TO 420        
      FLAG = I2 - I + 1        
C        
  430 INSUFF = 3050        
  440 I3 = I + FLAG        
      IF (I3 .LT. J)  GO TO 460        
      WRITE  (OUTTAP,450) I,I3,J,FLAG,BUF3,NRIGID,N23        
  450 FORMAT ('  GP4/3060 I,I3,J,FLAG,BUF3,NRIGID,N23 =',7I7)        
      ICRQ = I - J        
      GO TO 2430        
  460 I  = I3        
      CALL READ  (*2410,*2420,RGT,Z(J+1),NRIGID,1,FLAG)        
      CALL CLOSE (RGT,CLSREW)        
      CALL GOPEN (RGT,Z(BUF3),1)        
C        
C     SORT THE LIST OF DEPENDENT SIL VALUES        
C     THUS FORMING THE UM SUBSET        
C        
  470 II = J + 1        
      M  = BUF3 - II        
      NNX= BUF3 - 1        
      IF (M .EQ. 1) GO TO 510        
      CALL SORT (0,0,1,1,Z(II),M)        
C        
C     CHECK FOR DEPENDENT COMPONENT ERRORS IN MPC/RIGID ELEMENT DATA    
C        
      JJ   = NNX - 1        
      NOLD = 0        
      JXX  = 0        
      DO 490 J = II,JJ        
      IF (Z(J) .EQ. NOLD) GO TO 490        
      IF (Z(J).NE.Z(J+1)) GO TO 490        
      NOLD = Z(J)        
      NOGO = 1        
      JXX  = JXX + 1        
      IF (JXX .GT. 50) GO TO 490        
      CALL PAGE2 (2)        
      WRITE  (OUTTAP,480) UFM,Z(J)        
  480 FORMAT (A23,' 2423, DEPENDENT COMPONENT SPECIFIED MORE THAN ONCE',
     1       ' ON MPC CARDS AND/OR IN RIGID ELEMENTS.  SIL =',I9)       
  490 CONTINUE        
      IF (JXX .GT. 50) WRITE (OUTTAP,500)        
  500 FORMAT (//12X,12H... AND MORE,/)        
  510 IF (NOGO .NE. 0) GO TO 2540        
      CALL WRITE (SCR1,Z(II),M,1)        
C        
C     SORT THE LIST OF CODED COL AND ROW NOS (OR UNCODED NOS)        
C     THEN BLDPK EACH COL THUS FORMING THE RG MATRIX        
C        
      N   = I - IMPC        
      NMPC= I - N23        
      J   = IMPC        
      IF (N23 .EQ. 3) CALL SORT2K (0,0,3,1,Z(J),N)        
      IF (N23 .EQ. 2) CALL SORT   (0,0,2,1,Z(J),N)        
C        
C     CHECK FOR INDEPENDENT COMPONENT ERRORS IN MPC DATA        
C        
      KJ   = J + N - 2*N23        
      NOLD = 0        
      NOGO = 0        
      DO 540 KK = J,KJ,N23        
      IF (Z(KK) .EQ.      NOLD) GO TO 540        
      IF (Z(KK) .NE. Z(KK+N23)) GO TO 540        
      IF (N23.EQ.3 .AND. Z(KK+1).NE.Z(KK+N23+1)) GO TO 540        
      NOLD = Z(KK)        
      NOGO = 1        
      JJ   = NOLD        
      IF (N23 .EQ. 2) JJ = RSHIFT(NOLD,IHALF)        
      CALL PAGE2 (-2)        
      WRITE  (OUTTAP,530) UFM,JJ        
  530 FORMAT (A23,' 3180, INDEPENDENT COMPONENT SPECIFIED MORE THAN ',  
     1       'ONCE IN AN MPC RELATIONSHIP.   SIL =',I6)        
  540 CONTINUE        
      IF (NOGO .NE. 0) GO TO 2540        
      NCOL= 1        
      M   = BUF3 - I        
      N231= N23  - 1        
  550 CALL BLDPK (1,1,RGT,0,0)        
  560 IF (J .GT. NMPC) GO TO 590        
      JJ = Z(J)        
      IF (N23 .EQ. 2) JJ = RSHIFT(Z(J),IHALF)        
      IF (JJ .GT. NCOL) GO TO 590        
      IX = Z(J+1)        
      IF (N23 .EQ. 2) IX = ANDF(Z(J),MASK16)        
      X(1) = Z(J+N231)        
      DO 570 NN1 = II,NNX        
      IF (IX .EQ. Z(NN1)) GO TO 580        
  570 CONTINUE        
      GO TO 2540        
  580 IX = NN1 - II + 1        
      CALL ZBLPKI        
      J  = J + N23        
      GO TO 560        
  590 CALL BLDPKN (RGT,0,MCB)        
      NCOL = NCOL + 1        
      IF (NCOL .LE. LUSET) GO TO 550        
      MCB(3) = MULTI        
      CALL WRTTRL (MCB)        
  600 CALL CLOSE (RGT,CLSREW)        
C        
C     READ OMIT CARDS (IF PRESENT).        
C        
  610 I = KNKL1        
      CALL LOCATE (*650,Z(BUF1),OMIT,FLAG)        
      ASSIGN 630  TO RET        
      ASSIGN 2470 TO RET1        
      ASSIGN 620  TO RET2        
      ASSIGN 640  TO RET3        
      OMIT1 = 1        
  620 CALL READ (*2410,*650,GEOMP,BUF,2,0,FLAG)        
      GPOINT= BUF(1)        
      GO TO 2100        
  630 INDEX = 3        
      ICOMP = BUF(2)        
      GO TO 2300        
  640 IF (ICOMP .NE. 0) GPOINT = GPOINT + ICOMP - 1        
      Z(I)= GPOINT        
      I   = I + 1        
      IF (I .LE. BUF3) GO TO 620        
      ICRQ = I - BUF3        
      INSUFF = 345        
      GO TO 2430        
C        
C     READ OMIT1 CARDS (IF PRESENT).        
C        
  650 IF (NOGO .NE. 0) GO TO 2540        
      CALL LOCATE (*720,Z(BUF1),OMITX1,FLAG)        
      OMIT1 = 1        
      ASSIGN 680  TO RET        
      ASSIGN 2470 TO RET1        
      ASSIGN 670  TO RET2        
      ASSIGN 690  TO RET3        
  660 CALL READ (*2410,*720,GEOMP,BUF,1,0,FLAG)        
      IF (BUF(1) .NE. 0) CALL SCALEX (1,BUF(1),BUF(8))        
  670 CALL READ (*2410,*720,GEOMP,BUF(2),1,0,FLAG)        
      IF (BUF(2) .EQ. -1)  GO TO 660        
      GPOINT = BUF(2)        
      GO TO 2100        
  680 INDEX = 5        
      ICOMP = BUF(1)        
      GO TO 2300        
  690 IF (ICOMP .NE. 0) GO TO 700        
      Z(I) = GPOINT        
      I    = I + 1        
      GO TO 670        
  700 GPOINT = GPOINT - 1        
      DO 710 IJK = 1,6        
      IF (BUF(IJK+7) .EQ. 0) GO TO 670        
      Z(I) = GPOINT+BUF(IJK+7)        
      I    = I + 1        
  710 CONTINUE        
      GO TO 670        
  720 IF (OMIT1 .NE. 1) GO TO 730        
      IF (NOGO  .NE. 0) GO TO 2540        
C        
C     SORT OMIT AND OMIT1 DATA AND WRITE IT ON SCR1.        
C        
      N = I - KNKL1        
      I = KNKL1        
      CALL SORT (0,0,1,1,Z(I),N)        
      CALL WRITE (SCR1,Z(I),N,1)        
C        
C     READ SUPORT CARDS (IF PRESENT)        
C        
  730 CALL LOCATE (*780,Z(BUF1),SUPORT,FLAG)        
      REACT = 1        
      I = KNKL1        
      ASSIGN 750  TO RET        
      ASSIGN 2480 TO RET1        
      ASSIGN 740  TO RET2        
      ASSIGN 760  TO RET3        
  740 CALL READ (*2410,*770,GEOMP,BUF,2,0,FLAG)        
      GPOINT = BUF(1)        
      GO TO 2100        
  750 INDEX = 7        
      ICOMP = BUF(2)        
      GO TO 2300        
  760 IF (ICOMP .NE. 0) GPOINT = GPOINT + ICOMP - 1        
      Z(I) = GPOINT        
      I    = I + 1        
      IF (I .LT. BUF3) GO TO 740        
      ICRQ   = I - BUF3        
      INSUFF = 445        
      GO TO 2430        
  770 IF (NOGO .NE. 0) GO TO 2540        
      N = I - KNKL1        
      I = KNKL1        
      CALL SORT (0,0,1,1,Z(I),N)        
      CALL WRITE (SCR1,Z(I),N,1)        
C        
C     READ THE GPDT AND EXTRACT CONSTRAINED POINTS (IF ANY)        
C        
  780 CALL CLOSE (GEOMP,CLSREW)        
  790 FILE = GPDT        
      ASSIGN 810 TO RET        
      CALL GOPEN (GPDT,Z(BUF1),0)        
  800 CALL READ (*2400,*820,GPDT,BUF,7,0,FLAG)        
      IF (BUF(7) .EQ. 0) GO TO 800        
      J = BUF(1) + KM        
      BUF(1) = Z(J)        
      CALL SCALEX (BUF,BUF(7),BUF(8))        
      GO TO 2200        
  810 CALL WRITE (SCR1,BUF(8),N,0)        
      UGSET = 1        
      GO TO 800        
  820 IF (UGSET .GT. 0) CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (GPDT,CLSREW)        
      FILE = GEOMP        
      IF (NOGEOM .EQ. 0) GO TO 830        
      CALL PRELOC (*2400,Z(BUF1),GEOMP)        
      GO TO 840        
  830 IF (MPCSET .NE. 0) CALL MESAGE (30,47,MPCSET)        
      IF (SPCSET .NE. 0) CALL MESAGE (30,53,SPCSET)        
      IF (MPCSET.NE.0 .OR. SPCSET.NE.0) NOGO = +1        
      GO TO 1280        
C        
C     IF SPC SET IS SELECTED, READ SPCADD CARDS (IF PRESENT).        
C     DETERMINE IF SET ID IS ON SPCADD CARD.        
C     IF NOT, SIMULATE AN SPCADD SET LIST WITH ONE SET = SPCSET.        
C        
  840 IF (SPCSET .EQ. 0) GO TO 1150        
      ISPCAD = KNKL1        
      NSPCAD = KNKL1        
      ISPC   = ISPCAD + 2        
      I      = ISPCAD        
      Z(I  ) = SPCSET        
      Z(I+1) = 0        
      CALL LOCATE (*900,Z(BUF1),SPCADD,FLAG)        
  850 CALL READ (*2410,*900,GEOMP,ID,1,0,FLAG)        
      IF (ID .EQ. SPCSET) GO TO 870        
  860 CALL FREAD (GEOMP,ID,1,0)        
      IF (ID .NE. -1) GO TO 860        
      GO TO 850        
  870 CALL READ (*2410,*890,GEOMP,BUF,1,0,FLAG)        
      IF (BUF(1) .EQ. -1) GO TO 880        
      Z(I  ) = BUF(1)        
      Z(I+1) = 0        
      I      = I + 2        
      GO TO 870        
  880 CALL FWDREC (*2410,GEOMP)        
  890 ISPC   = I        
      NSPCAD = I - 2        
C        
C     READ SPC1 AND SPC CARDS.        
C     FOR EACH SET ID WHICH IS IN THE SPCADD SET LIST,        
C     CONVERT THE GRID POINT NO. AND COMPONENT VALUE (OR SCALAR NO.)    
C     TO AN SIL VALUE. SAVE A LIST IN CORE OF SIL VALUES AND        
C     ENFORCED DISPLACEMENT (ON SPC1 CARDS, ENF. DISPL. = 0.)        
C        
  900 I = ISPC        
      GO TO 1010        
C        
C     SPC1 PROCESSING EXECUTES AFTER SPC PROCESSING        
C        
  910 IF (NOGO .NE. 0) GO TO 2540        
      CALL LOCATE (*1130,Z(BUF1),SPC1,FLAG)        
      ASSIGN 970  TO RET        
      ASSIGN 2490 TO RET1        
      ASSIGN 960  TO RET2        
      ASSIGN 980  TO RET3        
  920 CALL READ (*2410,*1130,GEOMP,ID,1,0,FLAG)        
      DO 930 K = ISPCAD,NSPCAD,2        
      IF (Z(K) .EQ. ID) GO TO 950        
  930 CONTINUE        
  940 CALL FREAD (GEOMP,BUF,1,0)        
      IF (BUF(1) .NE. -1) GO TO 940        
      GO TO 920        
  950 Z(K+1) = 1        
      CALL FREAD (GEOMP,BUF,1,0)        
      SINGLE = 1        
      IF (BUF(1) .NE. 0) CALL SCALEX (1,BUF(1),BUF(8))        
  960 CALL READ (*2410,*920,GEOMP,BUF(2),1,0,FLAG)        
      IF (BUF(2) .LT. 0) GO TO 920        
      GPOINT = BUF(2)        
      GO TO 2100        
  970 INDEX = 9        
      ICOMP = BUF(1)        
      GO TO 2300        
  980 IF (ICOMP .NE. 0) GO TO 990        
      Z(I  ) = GPOINT        
      Z(I+1) = 0        
      I      = I + 2        
      GO TO 960        
  990 GPOINT = GPOINT - 1        
      DO 1000 IJK = 1,6        
      IF (BUF(IJK+7) .EQ. 0) GO TO 960        
      Z(I  ) = GPOINT+BUF(IJK+7)        
      Z(I+1) = 0        
      I      = I + 2        
 1000 CONTINUE        
      GO TO 960        
C        
C     PROCESSING OF SPC CARDS EXECUTES FIRST.        
C        
 1010 CALL LOCATE (*910,Z(BUF1),SPC,FLAG)        
      ASSIGN 1050  TO RET        
      ASSIGN 2530 TO RET1        
      ASSIGN 1020  TO RET2        
      ASSIGN 1060  TO RET3        
 1020 CALL READ (*2410,*1090,GEOMP,BUF,4,0,FLAG)        
      DO 1030 K = ISPCAD,NSPCAD,2        
      IF (Z(K) .EQ. BUF(1)) GO TO 1040        
 1030 CONTINUE        
      GO TO 1020        
 1040 SINGLE = 1        
      Z(K+1) = 1        
      GPOINT = BUF(2)        
      GO TO 2100        
 1050 INDEX = 11        
      ICOMP = BUF(3)        
      GO TO 2300        
 1060 IF (ICOMP .NE. 0) GO TO 1070        
      Z(I  ) = GPOINT        
      Z(I+1) = BUF(4)        
      I      = I+2        
      GO TO 1020        
 1070 CALL SCALEX (GPOINT,BUF(3),BUF(8))        
      DO 1080 IJK = 1,6        
      IF (BUF(IJK+7) .EQ. 0) GO TO 1020        
      Z(I  ) = BUF(IJK+7)        
      Z(I+1) = BUF(4)        
      I      = I + 2        
 1080 CONTINUE        
      GO TO 1020        
 1090 IF (NOGO .NE. 0) GO TO 2540        
      N = I - ISPC        
      IF (N .LE. 2) GO TO 910        
C        
C     CHECK FOR DUPLICATELY DEFINED ENFORCED DISPLACEMENTS ON SPC CARDS 
C        
      CALL SORT (0,0,2,1,Z(ISPC),N)        
      N    = N - 2        
      NOLD = 0        
      DO 1110 K = 1,N,2        
      IF (Z(ISPC+K-1) .EQ. NOLD) GO TO 1110        
      IF (Z(ISPC+K-1) .NE. Z(ISPC+K+1)) GO TO 1110        
      IF (Z(ISPC+K).EQ.0 .AND. Z(ISPC+K+2).EQ.0) GO TO 1110        
      NOLD = Z(ISPC+K-1)        
      NOGO = 1        
      CALL PAGE2 (3)        
      WRITE  (OUTTAP,1100) UFM,NOLD        
 1100 FORMAT (A23,' 3147, ENFORCED DISPLACEMENT ON SPC CARDS SPECIFIED',
     1     ' MORE THAN ONCE', /5X,'FOR THE SAME COMPONENT.  SIL VALUE ='
     2,    I10)        
 1110 CONTINUE        
      IF (NOGO .NE. 0) GO TO 2540        
      GO TO 910        
C        
C     FLUID PROBLEM AND NO SPC-S AT ALL.        
C        
 1120 SPCSET = 0        
      GO TO 840        
 1130 NSPC = I - 2        
      ICRQ = NSPC - BUF3        
      INSUFF = 740        
      IF (ICRQ .GT. 0) GO TO 2430        
C        
C     DETERMINE IF ALL SPC SETS IN SPCADD SET LIST HAVE BEEN DEFINED    
C        
      IF (NOGO .NE. 0) GO TO 2540        
      DO 1140 K = ISPCAD,NSPCAD,2        
      IF (Z(K+1) .NE. 0) GO TO 1140        
      IF (IAXIF.NE.0 .AND. Z(K).EQ.200000000) GO TO 1120        
      NOGO   = 1        
      BUF(1) = Z(K)        
      BUF(2) = 0        
      CALL MESAGE (30,53,BUF)        
 1140 CONTINUE        
      IF (NOGO .NE. 0) GO TO 2540        
C        
C     SORT THE SPC LIST AND WRITE IT ON SCR1        
C        
      N = NSPC - ISPC + 2        
      CALL SORT  (0,0,2,1,Z(ISPC),N)        
      CALL WRITE (SCR1,Z(ISPC),N,1)        
C        
C     READ ASET CARDS (IF PRESENT)        
C        
 1150 I = KNKL1        
      CALL LOCATE (*1190,Z(BUF1),ASET,FLAG)        
      ASSIGN 1170 TO RET        
      ASSIGN 2470 TO RET1        
      ASSIGN 1160 TO RET2        
      ASSIGN 1180 TO RET3        
      ASETX = 1        
 1160 CALL READ (*2410,*1190,GEOMP,BUF,2,0,FLAG)        
      GPOINT = BUF(1)        
      GO TO 2100        
 1170 INDEX = 15        
      ICOMP = BUF(2)        
      GO TO 2300        
 1180 IF (ICOMP .NE. 0) GPOINT = GPOINT + ICOMP - 1        
      Z(I) = GPOINT        
      I    = I + 1        
      IF (I .LE. BUF3) GO TO 1160        
      ICRQ = I - BUF3        
      INSUFF = 1445        
      GO TO 2430        
C        
C     READ ASET1 CARDS (IF PRESENT)        
C        
 1190 IF (NOGO .NE. 0) GO TO 2540        
      CALL LOCATE (*1260,Z(BUF1),ASET1,FLAG)        
      ASETX = 1        
      ASSIGN 1220 TO RET        
      ASSIGN 2470 TO RET1        
      ASSIGN 1210 TO RET2        
      ASSIGN 1230 TO RET3        
 1200 CALL READ (*2410,*1260,GEOMP,BUF,1,0,FLAG)        
      IF (BUF(1) .NE. 0) CALL SCALEX (1,BUF(1),BUF(8))        
 1210 CALL READ (*2410,*1260,GEOMP,BUF(2),1,0,FLAG)        
      IF (BUF(2) .EQ. -1) GO TO 1200        
      GPOINT = BUF(2)        
      GO TO 2100        
 1220 INDEX = 17        
      ICOMP = BUF(1)        
      GO TO 2300        
 1230 IF (ICOMP .NE. 0) GO TO 1240        
      Z(I) = GPOINT        
      I    = I + 1        
      GO TO 1210        
 1240 GPOINT = GPOINT - 1        
      DO 1250 IJK = 1,6        
      IF (BUF(IJK+7) .EQ. 0) GO TO 1210        
      Z(I) = GPOINT + BUF(IJK+7)        
      I    = I + 1        
 1250 CONTINUE        
      GO TO  1210        
 1260 IF (ASETX .NE. 1) GO TO 1270        
      IF (NOGO  .NE. 0) GO TO 2540        
C        
C     SORT ASET AND ASET1 DATA AND WRITE IT ON SCR1        
C        
      N = I - KNKL1        
      I = KNKL1        
      CALL SORT  (0,0,1,1,Z(I),N)        
      CALL WRITE (SCR1,Z(I),N,1)        
 1270 CALL CLOSE (GEOMP,CLSREW)        
 1280 CALL CLOSE (SCR1,CLSREW)        
C        
C     FORM THE BASIC USET BY READING EACH OF THE SUBSETS AND        
C     TURNING ON THE APPROPRIATE BIT IN THE APPROPRIATE WORD        
C        
      FILE = SCR1        
      CALL OPEN (*2400,SCR1,Z(BUF2),RDREW)        
      DO 1290 K = 1,LUSET        
 1290 Z(K)   = 0        
      BUF(1) = MULTI        
      BUF(2) = OMIT1        
      BUF(3) = REACT        
      BUF(4) = USGSET        
      BUF(5) = SINGLE        
      BUF(6) = ASETX        
      ICOUNT = 0        
      DO 1360 K = 1,6        
      IF (BUF(K) .LT. 0) GO TO 1360        
      IF (K .LT. 5) ICOUNT = ICOUNT + 1        
      GO TO (1300,1310,1300,1300,1300,1310), K        
 1300 MCBUST(5) = ORF(MCBUST(5),MASK(K))        
      NOSETS = 1        
      IF (K .EQ. 5) GO TO 1350        
 1310 CALL READ (*2410,*1360,SCR1,J,1,0,FLAG)        
      IF (K .EQ. 2) GO TO 1340        
      IF (K .EQ. 6) GO TO 1330        
      IF (ANDF(Z(J),MASK(K)) .NE. MASK(K)) GO TO 1340        
      DUP = 1        
      IF (IFLAG .NE. 0) GO TO 1320        
      FILE = USET        
      CALL OPEN (*2400,USET,Z(BUF1),WRTREW)        
      IFLAG  = 1        
      FILE   = SCR1        
 1320 BUF(1) = J        
      BUF(2) = K        
      CALL WRITE (USET,BUF(1),2,0)        
      GO TO 1340        
 1330 IF (ANDF(Z(J),MSKUA) .NE. 0) GO TO 1310        
 1340 Z(J) = ORF(Z(J),MASK(K))        
      GO TO 1310        
 1350 CALL READ (*2410,*1360,SCR1,BUF(7),2,0,FLAG)        
      J    = BUF(7)        
      Z(J) = ORF(Z(J),MASK(K))        
      GO TO 1350        
 1360 CONTINUE        
      IF (DUP .EQ. 0) GO TO 1370        
      CALL WRITE (USET,0,0,1)        
      CALL CLOSE (USET,CLSREW)        
 1370 CALL CLOSE (SCR1,CLSREW)        
C        
C     THE FOLLOWING CONVENTION WILL BE USED WITH REGARD TO DEGREES OF   
C     FREEDOM NOT SPECIFICALLY INCLUDED OR OMITTED-        
C       1. IF ASET OR ASET1 CARDS ARE PRESENT, UNSPECIFIED DEGREES OF   
C          FREEDOM WILL BE OMITTED.        
C       2. IF ASET OR ASET1 CARDS ARE NOT PRESENT AND OMIT OR OMIT1     
C          CARDS ARE PRESENT, UNSPECIFIED DEGREES OF FREEDOM WILL BE    
C          INCLUDED IN THE ANALYSIS SET.        
C       3. IF NO ASET, ASET1, OMIT, OR OMIT 1 CARDS ARE PRESENT ALL     
C          UNSPECIFIED DEGREES OF FREEDOM WILL BE INCLUDED IN THE       
C          ANALYSIS SET.        
C       4. IF BOTH ASET OR ASET1 CARDS AND OMIT OR OMIT1 CARDS ARE      
C          SUPPLIED, UNSPECIFIED DEGREES OF FREEDOM WILL BE OMITTED.    
C        
      MSKRST = MASK(2)        
      IF (ASETX .GT. 0) GO TO 1380        
      MSKRST = MASK(6)        
      IMSK   = 0        
 1380 DO 1390 K = 1, LUSET        
      IF (ANDF(MSKCK,Z(K)) .NE. 0) GO TO 1390        
      IMSK = MSKRST        
      Z(K) = ORF(Z(K),MSKRST)        
 1390 CONTINUE        
      IF (IMSK .EQ. MASK(6)) ASETX = 1        
      IF (IMSK .EQ. MASK(2)) OMIT1 = 1        
C        
C     CALL SUBROUTINE GP4SP TO EXAMINE GRID POINT SINGULARITIES        
C        
      CALL GP4SP (BUF2,BUF3,BUF4)        
C        
C     TURN ON CERTAIN FLAGS IF THERE ARE OMIT OR ASET        
C     DEGREES OF FREEDOM        
C        
      OMIT1 = -1        
      DO 1400 K = 1,LUSET        
      IF (ANDF(Z(K),MSKUO) .EQ. 0) GO TO 1400        
      MCBUST(5) = ORF(MCBUST(5),MASK(2))        
      NOSETS = 1        
      OMIT1  = 1        
      GO TO 1410        
 1400 CONTINUE        
 1410 DO 1420 K = 1,LUSET        
      IF (ANDF(Z(K),MSKUA) .EQ. 0) GO TO 1420        
      MCBUST(5) = ORF(MCBUST(5),MASK(6))        
      NOL = 1        
      GO TO 1430        
 1420 CONTINUE        
C        
 1430 CALL OPEN (*2400,SCR1,Z(BUF2),RDREW)        
      CALL SKPREC (SCR1,ICOUNT)        
C        
C     OPEN YS FILE. WRITE SPCSET IN YS HEADER.        
C     IF NO USB SET (FROM SPC AND SPC1 CARDS), WRITE NULL COLUMN        
C     FOR YS VECTOR. IF USB SET IS PRESENT, BUILD THE YS VECTOR.        
C        
      FILE = SCR1        
      CALL OPEN (*1440,YS,Z(BUF3),WRTREW)        
      NOYS = 1        
      CALL FNAME (YS,BUF)        
      BUF(3) = SPCSET        
      CALL WRITE (YS,BUF,3,1)        
 1440 IX = 0        
      II = 1        
      IF (SINGLE .GT. 0) GO TO 1450        
      IF (NAUTO.GT.0 .OR. USGSET.GT.0) SINGLE = 1        
      IF (NOYS .NE. 0) CALL BLDPK (1,1,YS,0,0)        
      GO TO 1490        
 1450 IF (NOYS .NE. 0) CALL BLDPK (1,1,YS,0,0)        
 1460 CALL READ (*2410,*1490,SCR1,BUF,2,0,FLAG)        
      J = BUF(1)        
      IF (BUF(2) .EQ. 0) GO TO 1460        
      DO 1470 K = II,J        
      IF (ANDF(Z(K),MSKUS) .NE. 0) IX = IX + 1        
 1470 CONTINUE        
      II   = J + 1        
      X(1) = BUF(2)        
      IF (NOYS   .NE. 0) GO TO 1480        
      IF (NOGOOF .NE. 0) GO TO 1460        
      NOGO   = 1        
      NOGOOF = 1        
      CALL MESAGE (30,132,BUF)        
      GO TO 1460        
 1480 CALL ZBLPKI        
      GO TO 1460        
 1490 IF (NOYS .NE. 0) CALL BLDPKN (YS,0,MCBYS)        
      IF (II .GT. LUSET) GO TO 1510        
      DO 1500 K = II,LUSET        
      IF (ANDF(Z(K),MSKUS) .NE. 0) IX = IX + 1        
 1500 CONTINUE        
 1510 MCBYS(3) = IX        
      IF (NOYS .EQ. 0) GO TO 1520        
      CALL WRTTRL (MCBYS)        
      CALL CLOSE (YS,CLSREW)        
 1520 CALL CLOSE (SCR1,CLSREW)        
C        
      IF (L21+L22.GT.0 .OR. IDSUB.GT.0) CALL GP4PRT (BUF1)        
      IF (NAUTO .EQ. 0) GO TO 1540        
C        
C     CHANGE AUTO SPC FLAGS TO BOUNDARY SPC FLAGS        
C        
      J = 0        
      DO 1530 K = 1,LUSET        
      IF (ANDF(Z(K),MSKUS) .EQ. 0) GO TO 1530        
      IF (ANDF(Z(K),MSKUSG).NE.0 .OR.  ANDF(Z(K),MSKUSB).NE.0)        
     1    GO TO 1530        
      Z(K) = MASK(5)        
      J = 1        
 1530 CONTINUE        
      IF (J .EQ. 1) MCBUST(5) = ORF(MCBUST(5),MASK(5))        
C        
 1540 FILE = USET        
      IF (DUP .EQ. 0) GO TO 1570        
      CALL OPEN (*2400,USET,Z(BUF1),RDREW)        
      FILE = SCR1        
      CALL OPEN (*2400,SCR1,Z(BUF2),WRTREW)        
      FILE = USET        
 1550 CALL READ  (*1560,*1560,USET,BUF(1),2,0,FLAG)        
      CALL WRITE (SCR1,BUF(1),2,0)        
      GO TO 1550        
 1560 CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (USET,CLSREW)        
 1570 CALL OPEN  (*2400,USET,Z(BUF1),WRTREW)        
      CALL FNAME (USET,BUF)        
      BUF(3) = SPCSET        
      BUF(4) = MPCSET        
      CALL WRITE (USET,BUF,4,1)        
      CALL WRITE (USET,Z(1),LUSET,1)        
      IF (NOL .EQ. 1) MCBUST(5)= ORF(MCBUST(5),MASK(6))        
C        
C     SEPARATE TRAILER WORD 4 INTO TWO PARTS        
C        
      MCBUST(4) = RSHIFT(MCBUST(5),IHALF)        
      MCBUST(5) = ANDF(MCBUST(5),COMPLF(LSHIFT(MCBUST(4),IHALF)))       
      CALL WRTTRL (MCBUST)        
      CALL CLOSE (USET,CLSREW)        
C        
C     PROCESS USET FOR CONSISTENCY OF DISPLACEMENT SET DEFINITIONS.     
C     EACH POINT IN USET MAY BELONG TO AT MOST ONE DEPENDENT SUBSET.    
C        
      FLAG    = 0        
      MASK(1) = MSKUM        
      MASK(2) = MSKUS        
      MASK(3) = MSKUO        
      MASK(4) = MSKUR        
      MSKUMS  = ORF(MSKUM,MSKUS)        
      MSKUOR  = ORF(MSKUO,MSKUR)        
      BUF( 1) = ORF(MSKUS,MSKUOR)        
      BUF( 2) = ORF(MSKUM,MSKUOR)        
      BUF( 3) = ORF(MSKUR,MSKUMS)        
      BUF(4)  = ORF(MSKUO,MSKUMS)        
      MSKALL  = ORF(MSKUMS,MSKUOR)        
      MSKAL   = ORF(MSKALL,MSKUL)        
      DO 1620 I = 1,LUSET        
      IUSET = Z(I)        
      IDEPN = ANDF(MSKAL,IUSET)        
      DO 1580 IK = 1,4        
      IF (ANDF(MAK(IK),IDEPN) .EQ. MAK(IK)) GO TO 1600        
 1580 CONTINUE        
      IDEPN = ANDF(IUSET,MSKALL)        
      IF (IDEPN .EQ. 0) GO TO 1620        
      DO 1590 J = 1,4        
      MSK1 = MASK(J)        
      MSK2 = BUF( J)        
      IF (ANDF(IDEPN,MSK1) .EQ. 0) GO TO 1590        
      IF (ANDF(IDEPN,MSK2) .NE. 0) GO TO 1600        
 1590 CONTINUE        
      GO TO 1620        
 1600 IF (FLAG.NE.0 .OR. IFLAG.NE.0) GO TO 1610        
      FILE = SCR1        
      CALL OPEN (*2400,SCR1,Z(BUF1),WRTREW)        
 1610 BUF(5) = I        
      BUF(6) = IDEPN        
      FLAG   = 1        
      CALL WRITE (SCR1,BUF(5),2,0)        
 1620 CONTINUE        
 1630 IF (MPCF1.GT.0 .OR. SINGLE.GT.0 .OR. OMIT1.GT.0 .OR.        
     1    REACT.GT.0) NOSETS = 1        
      IF (MPCF1.EQ.-1 .AND. SINGLE.EQ.-1 .AND. OMIT1.EQ.-1) NOA = -1    
      IF (ANDF(MSKUA,MCBUST(5)).NE.0 .OR. OMIT1.LT.0) GO TO 1650        
      CALL PAGE2 (2)        
      WRITE  (OUTTAP,1640) UFM        
 1640 FORMAT (A23,' 2403, INVALID TO HAVE AN O-SET WITH A NULL A-SET.') 
      NOGO = 1        
 1650 CONTINUE        
      IF (NOGO .NE. 0) GO TO 2540        
      IF (IFLAG.NE.0 .OR. FLAG.NE.0) GO TO 1920        
C        
C     RECOMPUTE YS MATRIX TO ACCOUNT FOR SPCD CARDS        
C        
C        
      IF (NOYS.EQ.0 .OR . NOGEOM.EQ.0) GO TO 1910        
C     BRING EQEXIN,SIL,AND USET BACK INTO CORE        
C        
      ASSIGN 1660 TO RET        
      GO TO 80        
 1660 CALL GOPEN (USET,Z(BUF1),0)        
      FILE = USET        
      CALL READ (*2410,*1670,USET,Z(KNKL1),BUF4-KNKL1,1,LUSET)        
      ICRQ = BUF4        
      INSUFF = 9711        
      GO TO 2430        
 1670 CALL CLOSE (USET,1)        
C        
C     CONVERT USET POINTERS INTO SILA VALUES        
C        
      M  = KNKL1        
      N  = KNKL1 + LUSET - 1        
      IX = 0        
      DO 1690 I = M,N        
      IF (ANDF(Z(I),MSKUS) .NE. 0) GO TO 1680        
      Z(I) = 0        
      GO TO 1690        
 1680 IX  = IX + 1        
      Z(I)= IX        
 1690 CONTINUE        
C        
C     POSITION CASECC        
C        
      FILE  = CASECC        
      ILOAD = N + 1        
      ICRQ  = N + 2*NSKP1 + 1 - BUF4        
      INSUFF = 977        
      IF (ICRQ .GT. 0) GO TO 2430        
      CALL GOPEN  (CASECC,Z(BUF1),0)        
      CALL SKPREC (CASECC,NSKIP-1)        
      DO 1710 I = 1,NSKP1        
 1700 CALL FREAD (CASECC,BUF,16,1)        
      IF (BUF(16) .NE. 0) GO TO 1700        
      K      = ILOAD + 2*(I-1)        
      Z(K  ) = BUF(4)        
      Z(K+1) = 0        
 1710 CONTINUE        
      CALL CLOSE (CASECC,CLSREW)        
C        
C     CONVERT SPCD CARD TO SILA + VALUE AND WRITE ON SCR2        
C        
      CALL GOPEN (SCR2,Z(BUF2),1)        
      FILE = GEOMP        
      CALL PRELOC (*2400,Z(BUF1),GEOMP)        
      CALL LOCATE (*1830,Z(BUF1),SPCD,FLAG)        
      NN    = 2*NSKP1 + ILOAD - 2        
      IOLD  = 0        
      IRECN = 0        
 1720 CALL READ (*2410,*1820,GEOMP,BUF,4,0,FLAG)        
      DO 1730 I = ILOAD,NN,2        
      IF (BUF(1) .EQ. Z(I)) GO TO 1740        
 1730 CONTINUE        
C        
C     GO ON TO NEXT SET        
C        
      GO TO 1720        
C        
 1740 IF (BUF(1) .EQ. IOLD) GO TO 1760        
      IF (IOLD .NE. 0) CALL WRITE (SCR2,0,0,1)        
      IOLD  = BUF(1)        
      IRECN = IRECN + 1        
      DO 1750 I = ILOAD,NN,2        
      IF (IOLD .EQ. Z(I)) Z(I+1) = IRECN        
 1750 CONTINUE        
 1760 GPOINT = BUF(2)        
      ASSIGN 1770  TO RET        
      ASSIGN 2530 TO RET1        
      ASSIGN 1720  TO RET2        
      ASSIGN 1780 TO RET3        
      GO TO 2100        
C        
C     FOUND SIL        
C        
 1770 INDEX = 13        
      ICOMP = BUF(3)        
      GO TO 2300        
 1780 IF (ICOMP .NE. 0) GO TO 1790        
      M = KNKL1 + GPOINT - 1        
      IF (Z(M) .EQ. 0) GO TO 1810        
      MCB(1) = Z(M)        
      MCB(2) = BUF(4)        
      CALL WRITE (SCR2,MCB,2,0)        
      GO TO 1720        
C        
C     BREAK UP COMPONENTS        
C        
 1790 CALL SCALEX (GPOINT,BUF(3),BUF(8))        
      DO 1800 I = 1,6        
      IF (BUF(I+7) .EQ. 0) GO TO 1720        
      M = KNKL1 + BUF(I+7) - 1        
      IF (Z(M) .EQ. 0) GO TO 1810        
      MCB(1) = Z(M)        
      MCB(2) = BUF(4)        
      CALL WRITE (SCR2,MCB,2,0)        
 1800 CONTINUE        
      GO TO 1720        
 1810 N      = 108        
      BUF(1) = BUF(2)        
      BUF(2) = BUF(I+7) - GPOINT        
      GO TO 2520        
C        
C     END OF SPCD-S        
C        
 1820 IF (NOGO .NE. 0) GO TO 2540        
      CALL WRITE (SCR2,0,0,1)        
 1830 CALL CLOSE (GEOMP,1)        
      CALL CLOSE (SCR2,1)        
      IF (SINGLE .LT. 0) GO TO 1910        
C        
C     BRING IN OLD YS        
C        
      N = 2*NSKP1        
      DO 1840 I = 1,N        
      K = ILOAD + I - 1        
 1840 Z(I) = Z(K)        
      IOYS = N        
      INYS = IOYS + IX        
      ICRQ = INYS + IX - BUF4        
      INSUFF = 988        
      IF (ICRQ .GT. 0) GO TO 2430        
      MCB(1) = YS        
      CALL RDTRL (MCB)        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      CALL GOPEN (YS,Z(BUF1),0)        
      ITB  = MCB(5)        
      ITA1 = ITB        
      ITB1 = ITB        
      INCR = 1        
      INCR1= 1        
      II   = 1        
      II1  = 1        
      JJ   = MCB(3)        
      JJ1  = JJ        
      DO 1850 I = 1,IX        
      RZ(IOYS+I) = 0.0        
 1850 CONTINUE        
      CALL UNPACK (*1860,YS,RZ(IOYS+1))        
 1860 CALL CLOSE (YS,CLSREW)        
      CALL GOPEN (YS,Z(BUF1),1)        
      CALL GOPEN (SCR2,Z(BUF2),0)        
      FILE = SCR2        
      DO 1900 I = 1,N,2        
C        
C     COPY OLD YS TO NEW YS        
C        
      DO 1870 K = 1,IX        
      RZ(INYS+K) = RZ(IOYS+K)        
 1870 CONTINUE        
      IF (Z(I+1) .EQ. 0) GO TO 1890        
C        
C     POSITION SCR2        
C        
      CALL SKPREC (SCR2,Z(I+1)-1)        
 1880 CALL READ (*2410,*1890,SCR2,BUF,2,0,FLAG)        
      K = BUF(1) + INYS        
      RZ(K) = BUFR(2)        
      GO TO 1880        
C        
C     PUT OUT COLUMN        
C        
 1890 CALL PACK (RZ(INYS+1),YS,MCB)        
      CALL REWIND (SCR2)        
      CALL FWDREC (*2410,SCR2)        
 1900 CONTINUE        
      CALL CLOSE  (YS,1)        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (SCR2,1)        
 1910 IF (NOGO .NE. 0) GO TO 2540        
      IF (FLAG .NE. 0) GO TO 1920        
      IF (IOGPST .EQ. 1) CALL MESAGE (17,IAUTSP,0)        
      RETURN        
C        
C     INCONSISTENT DISPLACEMENT SET DEFINITIONS--        
C     READ EQEXIN AND SIL INTO CORE. FOR EACH INCONSISTANT DEFINITION,  
C     LOOK UP EXTERNAL NUMBER AND QUEUE MESSAGE.        
C        
 1920 CALL WRITE (SCR1,0,0,1)        
      CALL CLOSE (SCR1,CLSREW)        
      ASSIGN 1930 TO RET        
      GO TO 80        
 1930 CALL OPEN (*2400,SCR1,Z(BUF1),RDREW)        
      ISIL = KM + 1        
      NEQX = KN - 1        
      Z(KNKL1) = LUSET + 1        
 1940 CALL READ (*2080,*2080,SCR1,BUF(5),2,0,IFLG)        
      DO 1950 I = ISIL,KNKL1        
      IF (Z(I+1) .GT. BUF(5)) GO TO 1960        
 1950 CONTINUE        
 1960 INTRNL = I - KM        
      KOMP = BUF(5) - Z(I) + 1        
      IF (Z(I+1)-Z(I) .EQ. 1) KOMP = 0        
      DO 1970 J = 1,NEQX,2        
      IF (Z(J+1) .EQ. INTRNL) GO TO 1980        
 1970 CONTINUE        
 1980 IF (DUP .EQ. 0) GO TO 2070        
      IF (IFLAG.EQ.0) GO TO 2070        
      CALL PAGE2 (2)        
      GO TO (1990,1940,2010,2030), IB6        
 1990 IF (KOMP .EQ. 0) GO TO 2000        
      NOGO = 1        
      WRITE (OUTTAP,2050) UFM,Z(J),KOMP,MSET        
      GO TO 1940        
 2000 WRITE (OUTTAP,2060) UFM,Z(J),MSET        
      NOGO = 1        
      GO TO 1940        
 2010 IF (KOMP .EQ. 0) GO TO 2020        
      WRITE (OUTTAP,2050) UFM,Z(J),KOMP,R        
      NOGO = 1        
      GO TO 1940        
 2020 WRITE (OUTTAP,2060) UFM,Z(J),R        
      NOGO = 1        
      GO TO 1940        
 2030 IF (KOMP .EQ. 0) GO TO 2040        
      WRITE (OUTTAP,2050) UFM,Z(J),KOMP,SG        
      NOGO = 1        
      GO TO 1940        
 2040 WRITE (OUTTAP,2060) UFM,Z(J),SG        
      NOGO = 1        
      GO TO 1940        
 2050 FORMAT (A23,' 2152, GRID POINT',I9,' COMPONENT',I3,        
     1       ' DUPLICATELY DEFINED IN THE ',A4,5H SET.)        
 2060 FORMAT (A23,' 2153, SCALAR POINT',I9,' DUPLICATELY DEFINED IN ',  
     1       'THE ',A4,5H SET.)        
 2070 BUF(7) = Z(J)        
      BUF(8) = KOMP        
      IF (ANDF(BUF(6),MSKUM) .NE. 0) BUF(8)= BUF(8) + 10        
      IF (ANDF(BUF(6),MSKUS) .NE. 0) BUF(8)= BUF(8) + 100        
      IF (ANDF(BUF(6),MSKUO) .NE. 0) BUF(8)= BUF(8) + 1000        
      IF (ANDF(BUF(6),MSKUR) .NE. 0) BUF(8)= BUF(8) + 10000        
      IF (ANDF(BUF(6),MSKUL) .NE. 0) BUF(8)= BUF(8) + 100000        
      CALL MESAGE (30,101,BUF(7))        
      GO TO 1940        
 2080 IF (DUP   .EQ. 0) GO TO 2090        
      IF (IFLAG .EQ. 0) GO TO 2090        
      IFLAG = 0        
      IF (FLAG .NE. 0) GO TO 1940        
      CALL CLOSE (SCR1,CLSREW)        
      GO TO 1630        
 2090 CALL CLOSE (SCR1,CLSREW)        
      GO TO 2540        
C        
C        
C     INTERNAL SUBROUTINE TO PERFORM BINARY SEARCH IN EQEXIN        
C     AND CONVERT THE EXTERNAL NUMBER TO A SIL VALUE AND A        
C     CORRESPONDING TYPE CODE        
C        
 2100 KLO = 0        
      KHI = KN2        
      LASTK = 0        
 2110 K = (KLO+KHI+1)/2        
      IF (LASTK .EQ. K) GO TO 2150        
      LASTK = K        
      IF (GPOINT-Z(2*K-1)) 2120,2140,2130        
 2120 KHI = K        
      GO TO 2110        
 2130 KLO = K        
      GO TO 2110        
 2140 K = 2*K + KN        
      IPOINT = GPOINT        
      GPOINT = Z(K)/10        
      ICODE  = Z(K) - 10*GPOINT        
      GO TO RET, (260,630,680,750,970,1050,1770,1170,1220)        
 2150 GO TO RET1, (2460,2470,2480,2490,2530)        
C        
C        
C     INTERNAL SUBROUTINE TO SORT THE SCALAR COMPONENTS        
C        
 2200 DO 2210 II = 1,6        
      IF (BUF(II+7) .EQ. 0) GO TO 2220        
 2210 CONTINUE        
      II = 7        
 2220 N  = II - 1        
      IF (N .EQ. 0) GO TO RET, (810)        
      DO 2240 II = 1,N        
      IJK = LUSET + 1        
      DO 2230 JJ = II,N        
      IF (BUF(JJ+7) .GE. IJK) GO TO 2230        
      IJK = BUF(JJ+7)        
      JJX = JJ        
 2230 CONTINUE        
      BUF(JJX+7) = BUF(II+7)        
 2240 BUF(II +7) = IJK        
      GO TO RET, (810)        
C        
C     CHECK TO SEE IF GRID AND SCALAR POINTS HAVE BEEN PROPERLY USED    
C     ON CONSTRAINT CARDS        
C        
 2300 IF (ICODE .EQ. 2) GO TO 2320        
C        
C     GRID POINTS ARE CHECKED HERE        
C        
      IF (ICOMP .GT. 0) GO TO 2350        
      NOGO = 1        
      CALL PAGE2 (2)        
      WRITE  (OUTTAP,2310) UFM,IPOINT,CTYPE(INDEX),CTYPE(INDEX+1)       
 2310 FORMAT (A23,' 3145, COMPONENT 0 (OR BLANK) SPECIFIED FOR GRID ',  
     1       'POINT',I9,4H ON ,2A4,6HCARDS.)        
      GO TO 2340        
C        
C     SCALAR POINTS ARE CHECKED HERE        
C        
 2320 IF (ICOMP .LE. 1) GO TO 2350        
      NOGO = 1        
      CALL PAGE2 (2)        
      WRITE  (OUTTAP,2330) UFM,IPOINT,CTYPE(INDEX),CTYPE(INDEX+1)       
 2330 FORMAT (A23,' 3146, ILLEGAL COMPONENT SPECIFIED FOR SCALAR POINT',
     1        I9,4H ON ,2A4,6HCARDS.)        
 2340 GO TO RET2, (250,620,670,740,960,1020,1720,1160,1210)        
 2350 GO TO RET3, (270,640,690,760,980,1060,1780,1180,1230)        
C        
C        
C     FATAL ERROR MESSAGES        
C        
 2400 J = -1        
      GO TO 2450        
 2410 J = -2        
      GO TO 2450        
 2420 J = -3        
      GO TO 2450        
 2430 J = -8        
      WRITE  (OUTTAP,2440) INSUFF        
 2440 FORMAT (/33X,'GP4 INSUFFICIENT CORE AT ',I5)        
      FILE = ICRQ        
 2450 CALL MESAGE (J,FILE,NAME)        
 2460 BUF(1) = GPOINT        
      BUF(2) = MPCSET        
      N = 48        
      GPOINT = 1        
      GO TO 2520        
 2470 BUF(1) = GPOINT        
      GPOINT = 1        
      N = 49        
      GO TO 2510        
 2480 BUF(1) = GPOINT        
      GPOINT = 1        
      N = 50        
      GO TO 2510        
 2490 N = 51        
 2500 BUF(1) = GPOINT        
      BUF(2) = SPCSET        
      GPOINT = 1        
      GO TO 2520        
 2510 BUF(2) = 0        
 2520 NOGO   = 1        
      CALL MESAGE (30,N,BUF)        
      GO TO RET2, (250,620,670,740,960,1020,1720,1160,1210)        
 2530 N = 52        
      GO TO 2500        
 2540 IF (L21+L22.GT.0 .OR. IDSUB.GT.0) CALL GP4PRT (-BUF4)        
      J = -37        
      GO TO 2450        
      END        
