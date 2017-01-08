      SUBROUTINE MRED2E        
C        
C     THIS SUBROUTINE CALCULATES THE MODAL TRANSFORMATION MATRIX FOR THE
C     MRED2 MODULE.        
C        
C     INPUT DATA        
C     GINO   - LAMAMR - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED 
C              PHISS  - EIGENVECTOR MATRIX FOR SUBSTRUCTURE BEING REDUCE
C     SOF    - GIMS   - G TRANSFORMATION MATRIX FOR ORIGINAL SUBSTRUCTUR
C        
C     OUTPUT DATA        
C     GINO   - HIM    - HIM MATRIX PARTITION        
C        
C     PARAMETERS        
C     INPUT  - GBUF   - GINO BUFFERS        
C              INFILE - INPUT FILE NUMBERS        
C              OTFILE - OUTPUT FILE NUMBERS        
C              ISCR   - SCRATCH FILE NUMBERS        
C              KORLEN - LENGTH OF OPEN CORE        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C              NMAX   - MAXIMUM NUMBER OF FREQUENCIES TO BE USED        
C     OUTPUT - MODUSE - BEGINNING ADDRESS OF MODE USE DESCRIPTION ARRAY 
C              MODLEN - LENGTH OF MODE USE ARRAY        
C              NFOUND - NUMBER OF MODAL POINTS FOUND        
C     OTHERS - HIMPRT - HIM PARTITION VECTOR        
C              PPRTN  - PHISS MATRIX PARTITION VECTOR        
C              PHIAM  - PHIAM MATRIX PARTITION        
C              PHIBM  - PHIBM MATRIX PARTITION        
C              PHIIM  - PHIIM MATRIX PARTITION        
C              IPARTN - BEGINNING ADDRESS OF PHISS PARTITION VECTOR     
C              LAMAMR - LAMAMR INPUT FILE NUMBER        
C              PHISS  - PHISS INPUT FILE NUMBER        
C              PPRTN  - PARTITION VECTOR FILE NUMBER        
C              HIMPRT - HIM PARTITION VECTOR FILE NUMBER        
C              GIB    - GIB INPUT FILE NUMBER        
C              PHIAM  - PHIAM PARTITION MATRIX FILE NUMBER        
C              PHIBM  - PHIBM PARTITION MATRIX FILE NUMBER        
C              PHIIM  - PHIIM PARTITION MATRIX FILE NUMBER        
C              HIM    - HIM INPUT FILE NUMBER        
C              HIMSCR - HIM SCRATCH INPUT FILE NUMBER        
C        
      LOGICAL          FREBDY        
      INTEGER          DRY,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,SBUF3,OTFILE,  
     1                 OLDNAM,Z,TYPIN,TYPEP,FUSET,UN,UB,UI        
      INTEGER          T,SIGNAB,SIGNC,PREC,SCR,RULE,TYPEU,PHISS        
      INTEGER          PPRTN,GIB,PHIAM,PHIBM,PHIIM,HIM,HIMSCR,HIMPRT,   
     1                 USETMR,HIMTYP,FBMODS,DBLKOR,SGLKOR,DICORE        
      DOUBLE PRECISION DZ,DHIMSM,DHIMAG        
      DIMENSION        MODNAM(2),RZ(1),ITRLR(7),DZ(1)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /BLANK /  IDUM1,DRY,IDUM6,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,   
     1                 SBUF3,INFILE(12),OTFILE(6),ISCR(10),KORLEN,      
     2                 KORBGN,OLDNAM(2),IDUM4(2),FREBDY,RANGE(2),NMAX,  
     3                 IDUM5(5),MODUSE,NFOUND,MODLEN,IDUM2,LSTZWD       
CZZ   COMMON /ZZMRD2/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /PACKX /  TYPIN,TYPEP,IROWP,NROWP,INCRP        
      COMMON /PATX  /  LCORE,NSUB(3),FUSET        
      COMMON /MPYADX/  ITRLRA(7),ITRLRB(7),ITRLRC(7),ITRLRD(7),NZ,T,    
     1                 SIGNAB,SIGNC,PREC,SCR        
      COMMON /BITPOS/  IDUM3(9),UN,IDUM7(10),UB,UI        
      COMMON /PARMEG/  IA(7),IA11(7),IA21(7),IA12(7),IA22(7),LCR,RULE   
      COMMON /UNPAKX/  TYPEU,IROWU,NROWU,INCRU        
      COMMON /SYSTEM/  IDUM8,IPRNTR        
      EQUIVALENCE      (LAMAMR,INFILE(2)),(PHISS,INFILE(3)),        
     1                 (USETMR,INFILE(5))        
      EQUIVALENCE      (GIB,ISCR(8)),(PPRTN,ISCR(5)),        
     1                 (HIM,ISCR(8)),        
     2                 (HIMPRT,ISCR(9)),(PHIBM,ISCR(9))        
      EQUIVALENCE      (RZ(1),Z(1)),(DZ(1),Z(1))        
      DATA    MODNAM/  4HMRED,4H2E  /        
      DATA    EPSLON,  ISCR4,FBMODS /1.0E-03,304,6/        
      DATA    ITEM  /  4HGIMS       /        
C        
C     READ LAMAMR FILE        
C        
      IF (DRY .EQ. -2) GO TO 300        
      KORE  = KORBGN        
      IFILE = LAMAMR        
      CALL GOPEN (LAMAMR,Z(GBUF1),0)        
      CALL FWDREC (*170,LAMAMR)        
      ITER = 0        
    2 CALL READ (*160,*4,LAMAMR,Z(KORBGN),7,0,NWDS)        
C        
C     REJECT MODES WITH NO ASSOCIATED VECTORS        
C        
      IF (RZ(KORBGN+5) .LE. 0.0) GO TO 2        
      KORBGN = KORBGN + 7        
      IF (KORBGN .GE. KORLEN) GO TO 180        
      ITER = ITER + 1        
      GO TO 2        
    4 CALL CLOSE (LAMAMR,1)        
C        
C     ZERO OUT PARTITIONING VECTOR AND SET UP MODE USE DESCRIPTION      
C     RECORD        
C        
      MODEXT  = KORBGN        
      ITRLR(1)= PHISS        
      CALL RDTRL (ITRLR)        
      ITPHIS  = ITRLR(2)        
      NROWS   = ITRLR(3)        
      IF ((3*ITPHIS)+MODEXT .GE. KORLEN) GO TO 180        
      LAMLEN  = 7*ITPHIS        
      NNMAX   = MIN0(NMAX,ITPHIS)        
      MODUSE  = MODEXT + ITPHIS        
      IPARTN  = MODEXT + 2*ITPHIS        
      MODLEN  = ITPHIS        
      DO 10 I = 1,ITPHIS        
      Z(MODEXT+I-1) = 0        
      Z(MODUSE+I-1) = 3        
   10 RZ(IPARTN+I-1) = 0.0        
C        
C     SELECT DESIRED MODES        
C        
      KORBGN = MODEXT + 3*ITPHIS        
      IF (KORBGN .GE. KORLEN) GO TO 180        
      NFOUND = 0        
      DO 20 I = 1,ITPHIS        
      J = 4 + 7*(I-1)        
      IF (RZ(KORE+J).LE.RANGE(1) .OR. RZ(KORE+J).GE.RANGE(2)) GO TO 20  
C        
C     REMOVE MODES WITH NEGATIVE EIGENVALUES        
C        
      IF (RZ(KORE+J-2) .LT. 0.0) GO TO 20        
      Z(MODEXT+NFOUND) = I        
      NFOUND = NFOUND + 1        
      Z(MODUSE +I-1) = 1        
      RZ(IPARTN+I-1) = 1.0        
   20 CONTINUE        
C        
C     PACK OUT PARTITIONING VECTOR        
C        
      TYPIN = 1        
      TYPEP = 1        
      IROWP = 1        
      NROWP = ITRLR(2)        
      INCRP = 1        
      IFORM = 2        
      CALL MAKMCB (ITRLR,PPRTN,NROWP,IFORM,TYPIN)        
      CALL GOPEN (PPRTN,Z(GBUF1),1)        
      CALL PACK (RZ(IPARTN),PPRTN,ITRLR)        
      CALL CLOSE (PPRTN,1)        
      CALL WRTTRL (ITRLR)        
C        
C     PARTITION PHISS MATRIX        
C        
C        **     **   **         **        
C        *       *   *   .       *        
C        * PHISS * = * 0 . PHIAM *        
C        *       *   *   .       *        
C        **     **   **         **        
C        
      NSUB(1) = ITPHIS - NFOUND        
      NSUB(2) = NFOUND        
      NSUB(3) = 0        
      LCORE   = KORLEN - KORBGN        
      ICORE   = LCORE        
C        
C     TEST FOR ALL MODES        
C        
      IF (NSUB(1) .EQ. 0) GO TO 32        
      PHIAM = ISCR(8)        
      CALL GMPRTN (PHISS,0,0,PHIAM,0,PPRTN,0,NSUB(1),NSUB(2),Z(KORBGN), 
     1             ICORE)        
C        
C     PARTITION PHIAM MATRIX        
C        
C                    **     **        
C                    *       *        
C        **     **   * PHIBM *        
C        *       *   *       *        
C        * PHIAM * = *.......*        
C        *       *   *       *        
C        **     **   * PHIIM *        
C                    *       *        
C                    **     **        
C        
      GO TO 34        
   32 PHIAM = PHISS        
   34 CONTINUE        
C        
C     CALCULATE THE VECTOR MAGNITUDE        
C        
      IF (KORBGN+NROWS .GE. KORLEN) GO TO 180        
      CALL GOPEN (PHIAM,Z(GBUF1),0)        
      TYPEU = 1        
      IROWU = 1        
      NROWU = NROWS        
      INCRU = 1        
      DO 40 I = 1,NFOUND        
      L     = IPARTN + I - 1        
      RZ(L) = 0.0        
      CALL UNPACK (*40,PHIAM,RZ(KORBGN))        
      DO 38 J = 1,NROWS        
      K     = KORBGN + J - 1        
      RZ(L) = RZ(L) + RZ(K)**2        
   38 CONTINUE        
   40 CONTINUE        
      CALL CLOSE (PHIAM,1)        
      FUSET = USETMR        
      CALL CALCV (PPRTN,UN,UI,UB,Z(KORBGN))        
C        
C     TEST FOR NULL B SET        
C        
      ITRLR(1) = PPRTN        
      CALL RDTRL (ITRLR)        
      IF (ITRLR(6) .GT. 0) GO TO 44        
      PHIIM   = PHIAM        
      IA11(1) = PHIAM        
      CALL RDTRL (IA11)        
      DO 42 I = 1,7        
   42 IA21(I) = 0        
      GO TO 55        
   44 CONTINUE        
      PHIIM = ISCR(7)        
      CALL GMPRTN (PHIAM,PHIIM,PHIBM,0,0,0,PPRTN,NSUB(1),NSUB(2),       
     1             Z(KORBGN),ICORE)        
      JHIM = 0        
C        
C     COMPUTE MODAL TRANSFORMATION MATRIX        
C        
C        **   **   **     **   **   ** **     **        
C        *     *   *       *   *     * *       *        
C        * HIM * = * PHIIM * - * GIB * * PHIBM *        
C        *     *   *       *   *     * *       *        
C        **   **   **     **   **   ** **     **        
C        
      CALL MTRXI (GIB,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 200        
      CALL SOFTRL (OLDNAM,ITEM,ITRLR)        
      ITEST = ITRLR(1)        
      IF (ITEST .NE. 1) GO TO 200        
      DO 50 I = 1, 7        
      ITRLRA(I) = ITRLR(I)        
      ITRLRB(I) = IA21(I)        
   50 ITRLRC(I) = IA11(I)        
      ITRLRA(1) = GIB        
      HIMSCR = ISCR(4)        
      IFORM  = 2        
      IPRC   = 1        
      ITYP   = 0        
      IF (ITRLRA(5).EQ.2 .OR. ITRLRA(5).EQ.4) IPRC = 2        
      IF (ITRLRB(5).EQ.2 .OR. ITRLRB(5).EQ.4) IPRC = 2        
      IF (ITRLRC(5).EQ.2 .OR. ITRLRC(5).EQ.4) IPRC = 2        
      IF (ITRLRA(5) .GE. 3) ITYP = 2        
      IF (ITRLRB(5) .GE. 3) ITYP = 2        
      IF (ITRLRC(5) .GE. 3) ITYP = 2        
      ITYPE  = IPRC + ITYP        
      CALL MAKMCB (ITRLRD,HIMSCR,ITRLR(3),IFORM,ITYPE)        
      CALL SOFCLS        
      T      = 0        
      SIGNAB = -1        
      SIGNC  = 1        
      PREC   = 0        
      SCR    = ISCR(6)        
      DBLKOR = KORBGN/2 + 1        
      NZ     = LSTZWD - ((2*DBLKOR)-1)        
      CALL MPYAD (DZ(DBLKOR),DZ(DBLKOR),DZ(DBLKOR))        
      CALL WRTTRL (ITRLRD)        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
      I      = ITRLRD(2)        
      II     = ITRLRD(3)        
      IFORM  = ITRLRD(4)        
      HIMTYP = ITRLRD(5)        
      GO TO 60        
C        
C     PHIBM IS NULL, HIM = PHIIM        
C        
   55 HIMSCR = PHIIM        
      I      = IA11(2)        
      II     = IA11(3)        
      IFORM  = IA11(4)        
      HIMTYP = IA11(5)        
      JHIM   = 1        
C        
C     TEST SELECTED MODES        
C        
   60 NCORE  = I        
      IF (KORBGN+NCORE .GE. KORLEN) GO TO 180        
      TYPIN  = HIMTYP        
      TYPEP  = HIMTYP        
      IROWP  = 1        
      NROWP  = II        
      INCRP  = 1        
      IROWU  = 1        
      CALL GOPEN (HIMSCR,Z(GBUF1),0)        
      CALL MAKMCB (ITRLR,HIM,II,IFORM,HIMTYP)        
      CALL GOPEN (HIM,Z(GBUF3),1)        
      NFOUND = 0        
      ITER   = I        
      DBLKOR = KORBGN/2 + 1        
      SGLKOR = 2*DBLKOR - 1        
      IF (HIMTYP .EQ. 1) DICORE = (SGLKOR+II)/2 + 1        
      IF (HIMTYP .EQ. 2) DICORE = DBLKOR + II        
      ICORE  = 2*DICORE - 1        
C        
C     UNPACK HIM COLUMN        
C        
      DO 140 I = 1,ITER        
C        
C     LIMIT VECTORS TO NMAX        
C        
      IF (NFOUND .LT. NNMAX) GO TO 65        
      J      = Z(MODEXT+I-1) + MODUSE - 1        
      Z(J)   = 3        
      GO TO 140        
   65 TYPEU  = HIMTYP        
      INCRU  = 1        
      NROWU  = II        
      IHIM   = NROWU        
      CALL UNPACK (*90,HIMSCR,DZ(DBLKOR))        
C        
C     SAVE LARGEST HIM COLUMN VALUE AND CALCULATE MAGNITUDE OF HIM,     
C     COLUMN        
C        
      IF (HIMTYP .EQ. 2) GO TO 74        
      ITYPE  = 0        
      HIMSUM = 0.0        
      HIMMAG = 0.0        
      DO 72 J = 1,IHIM        
      IF (ABS(RZ(SGLKOR+J-1)) .GE. ABS(HIMMAG)) HIMMAG = RZ(SGLKOR+J-1) 
   72 HIMSUM = HIMSUM + (RZ(SGLKOR+J-1)**2)        
      GO TO 78        
   74 ITYPE  = 2        
      DHIMSM = 0.0D0        
      DHIMAG = 0.0D0        
      DO 76 J = 1,IHIM        
      IF (DABS(DZ(DBLKOR+J-1)) .GE. DABS(DHIMAG))        
     1    DHIMAG = DZ(DBLKOR+J-1)        
   76 DHIMSM = DHIMSM + DZ(DBLKOR+J-1)**2        
      HIMSUM = DHIMSM        
   78 IF (JHIM .EQ. 1) GO TO 95        
      PHIMSM = RZ(IPARTN+I-1)        
      IF (PHIMSM .LE. 0.0) GO TO 90        
      PMSM   = PHIMSM*EPSLON*EPSLON        
      IF (HIMSUM .GE. PMSM) GO TO 95        
C        
C     REJECT MODE        
C        
   90 J = Z(MODEXT+I-1)        
      Z(MODUSE+J-1) = 2        
      GO TO 140        
C        
C     USE MODE        
C        
   95 NFOUND = NFOUND + 1        
C        
C     SCALE HIM COLUMN        
C        
      IF (HIMTYP .EQ. 2) GO TO 104        
      DO 102 J = 1,IHIM        
  102 RZ(SGLKOR+J-1) = RZ(SGLKOR+J-1)/HIMMAG        
      GO TO 130        
  104 DO 106 J = 1,IHIM        
  106 DZ(DBLKOR+J-1) = DZ(DBLKOR+J-1)/DHIMAG        
C        
C     PACK HIM COLUMN        
C        
  130 NROWP = NROWU        
      CALL PACK(DZ (DBLKOR),HIM,ITRLR)        
  140 CONTINUE        
      CALL CLOSE (HIM,1)        
      IF (JHIM .EQ. 0) CALL CLOSE (PHIIM,1)        
      CALL CLOSE (HIMSCR,1)        
      CALL WRTTRL (ITRLR)        
      KORBGN = KORE        
      IF (JHIM .EQ. 1) HIMSCR = ISCR4        
C        
C     TEST NUMBER OF MODAL POINTS        
C        
      MODAL = ITRLR(2)        
      IF (FREBDY) MODAL = MODAL + FBMODS        
      IF (MODAL .LE. ITRLR(3)) GO TO 300        
      WRITE  (IPRNTR,145) UFM,OLDNAM,MODAL,ITRLR(3)        
  145 FORMAT (A23,' 6633, FOR SUBSTRUCTURE ',2A4,' THE TOTAL NUMBER OF',
     1        ' MODAL COORDINATES (',I8,1H), /30X,        
     2        'IS LARGER THAN THE NUMBER OF INTERNAL DOF (',I8,2H).)    
      DRY = -2        
      GO TO 300        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  160 IMSG = -2        
      GO TO 190        
  170 IMSG = -3        
      GO TO 190        
  180 IMSG = -8        
      IFILE = 0        
  190 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      GO TO 300        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  200 GO TO (210,210,220,230,240,260), ITEST        
  210 IMSG = -11        
      GO TO 270        
  220 IMSG = -1        
      GO TO 250        
  230 IMSG = -2        
      GO TO 250        
  240 IMSG = -3        
  250 CALL SMSG (IMSG,ITEM,OLDNAM)        
      GO TO 300        
  260 IMSG = -10        
  270 CALL SMSG1 (IMSG,ITEM,OLDNAM,MODNAM)        
      DRY = -2        
  300 RETURN        
      END        
