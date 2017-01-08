      SUBROUTINE CMRD2E (ITER)        
C        
C     THIS SUBROUTINE CALCULATES THE H TRANSFORMATION MATRIX FOR THE    
C     CMRED2 MODULE.        
C        
C     INPUT  DATA        
C     GINO - HIM     - MODAL TRANSFORMATION MATRIX        
C     SOF  - GIMS    - G TRANSFORMATION MATRIX FOR BOUNDARY POINTS OF   
C                      ORIGINAL SUBSTRUCTURE        
C        
C     OUTPUT  DATA        
C     GINO  - HGH    - HORG PARTITION MATRIX        
C     SOF   - HORG   - H TRANSFORMATION MATRIX FOR ORIGINAL SUBSTRUCTURE
C        
C     PARAMETERS        
C     INPUT - GBUF   - GINO BUFFERS        
C             INFILE - INPUT FILE NUMBERS        
C             OTFILE - OUTPUT FILE NUMBERS        
C             ISCR   - SCRATCH FILE NUMBERS        
C             KORLEN - LENGTH OF OPEN CORE        
C             KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C             OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C     OTHERS- HIM    - HIM PARTITION MATRIX FILE NUMBER (RIGHT SIDE)    
C             HGH    - HORG MATRIX FILE NUMBER (RIGHT SIDE)        
C             GIB    - GIMS INPUT FILE NUMBER (RIGHT SIDE)        
C             HIMBAR - HIM PARTITION MATRIX FILE NUMBER (LEFT SIDE)     
C             HGHBAR - HGH PARTITION MATRIX FILE NUMBER (LEFT SIDE)     
C             GIBBAR - GIB PARTITION MATRIX FILE NUMBER (LEFT SIDE)     
C             UPRT   - USET PARTITIONING VECTOR FILE NUMBER        
C        
      INTEGER          DRY,GBUF1,GBUF2,Z,TYPINP,TYPEOP,TYPEU,HIM,HGH,   
     1                 GIB,HIMBAR,HGHBAR,GIBBAR,UPRT,HIMRL,HGHRL,GIBRL, 
     2                 DBLKOR,GIBTYP,HIMTYP,SGLKOR,DICORE        
      DOUBLE PRECISION DZ        
      DIMENSION        MODNAM(2),ITRLR1(7),ITRLR2(7),RZ(1),ITMLST(4),   
     1                 DZ(1),ITRLR3(7)        
      CHARACTER        UFM*23        
      COMMON /XMSSG /  UFM        
      COMMON /BLANK /  IDUM1,DRY,IDUM7,GBUF1,GBUF2,IDUM2(4),INFILE(11), 
     1                 OTFILE(6),ISCR(11),KORLEN,KORBGN,OLDNAM(2)       
CZZ   COMMON /ZZCMRD/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /PACKX /  TYPINP,TYPEOP,IROWP,NROWP,INCRP        
      COMMON /UNPAKX/  TYPEU,IROWU,NROWU,INCRU        
      COMMON /SYSTEM/  IDUM3,IPRNTR        
      EQUIVALENCE      (HIM,ISCR(10)),(GIB,ISCR(6)),(UPRT,ISCR(7)),     
     1                 (GIBBAR,ISCR(11)),(HGHBAR,ISCR(9)),(HGH,ISCR(9)),
     2                 (HIMBAR,ISCR(8)),(RZ(1),Z(1)),(DZ(1),Z(1))       
      DATA    MODNAM/  4HCMRD,4H2E  /        
      DATA    ITMLST/  4HHORG,4HHLFT,4HGIMS,4HUPRT/        
C        
C     SET UP ROW PARTITION        
C        
      IF (DRY .EQ. -2) RETURN        
      ITEM = ITMLST(4)        
      CALL MTRXI (UPRT,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 210        
      CALL SOFTRL (OLDNAM,ITEM,ITRLR1)        
      IF (KORBGN+ITRLR1(3) .GE. KORLEN) GO TO 270        
      TYPEU = ITRLR1(5)        
      IROWU = 1        
      NROWU = ITRLR1(3)        
      INCRU = 1        
      CALL GOPEN (UPRT,Z(GBUF1),0)        
      CALL UNPACK (*5,UPRT,RZ(KORBGN))        
      GO TO 15        
    5 DO 10 I = 1, NROWU        
   10 RZ(KORBGN+I-1) = 0.0        
   15 CALL CLOSE (UPRT,1)        
      LUPRT  = NROWU        
      KORE   = KORBGN        
      KORBGN = KORBGN + LUPRT        
C        
C     GET GIB MATRIX        
C        
      IF (ITER .EQ. 2) GO TO 20        
      ITEM = ITMLST(3)        
      CALL SOFTRL (OLDNAM,ITEM,ITRLR1)        
      IF (ITEST .NE. 1) GO TO 210        
      CALL MTRXI (GIB,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 210        
      ITRLR1(1) = GIB        
      GIBRL = GIB        
      GO TO 30        
   20 ITRLR1(1) = GIBBAR        
      CALL RDTRL (ITRLR1)        
      GIBRL = GIBBAR        
C        
C     SET UP HGH TRAILER        
C        
   30 HGHRL = HGH        
      IF (ITER .EQ. 2) HGHRL = HGHBAR        
      NROWS1 = ITRLR1(3)        
      KOLS1  = ITRLR1(2)        
      GIBTYP = ITRLR1(5)        
      HIMRL  = HIM        
      IF (ITER .EQ. 2) HIMRL = HIMBAR        
      ITRLR2(1) = HIMRL        
      CALL RDTRL (ITRLR2)        
      NROWS2 = ITRLR2(3)        
      KOLS2  = ITRLR2(2)        
      HIMTYP = ITRLR2(5)        
      IFORM  = 2        
      IF (ITRLR1(2)+ITRLR1(3) .EQ. ITRLR2(2)+ITRLR2(3)) IFORM = 1       
      IPRC   = 1        
      ITYP   = 0        
      IF (ITRLR1(5).EQ.2 .OR. ITRLR1(5).EQ.4) IPRC = 2        
      IF (ITRLR2(5).EQ.2 .OR. ITRLR2(5).EQ.4) IPRC = 2        
      IF (ITRLR1(5) .GE. 3) ITYP = 2        
      IF (ITRLR2(5) .GE. 3) ITYP = 2        
      ITYPE = IPRC + ITYP        
      CALL MAKMCB (ITRLR3,HGHRL,LUPRT,IFORM,ITYPE)        
C        
C     SET UP PACK/UNPACK PARAMETERS        
C        
      TYPEOP = ITRLR3(5)        
      IROWP  = 1        
      NROWP  = ITRLR1(2) + ITRLR1(3)        
      INCRP  = 1        
      INCRU  = 1        
      DBLKOR = KORBGN/2 + 1        
      SGLKOR = 2*DBLKOR - 1        
C        
C     FORM HGH MATRIX        
C        
C                  **         **        
C                  *     .     *        
C        **   **   *  I  .  0  *        
C        *     *   *     .     *        
C        * HGH * = *...........*        
C        *     *   *     .     *        
C        **   **   * GIB . HIM *        
C                  *     .     *        
C                  **         **        
C        
      CALL GOPEN (HGHRL,Z(GBUF1),1)        
C        
C     PROCESS GIB MATRIX        
C        
      TYPEU  = ITRLR1(5)        
      NROWU  = ITRLR1(3)        
      TYPINP = ITRLR1(5)        
      NROWS  = ITRLR1(3)        
      IF (ITRLR1(5) .GT. 2) NROWS = 2*ITRLR1(3)        
      IF (ITRLR1(5).EQ.1 .OR. ITRLR1(5).EQ.3)        
     1    DICORE = (SGLKOR+NROWS)/2 + 1        
      IF (ITRLR1(5).EQ.2 .OR. ITRLR1(5).EQ.4) DICORE = DBLKOR + NROWS   
      ICORE  = 2*DICORE - 1        
      IF (DICORE+NROWS .GE. KORLEN) GO TO 270        
      CALL GOPEN (GIBRL,Z(GBUF2),0)        
      DO 90 I = 1,KOLS1        
      K  = 0        
      KK = 0        
      CALL UNPACK (*40,GIBRL,DZ(DBLKOR))        
      GO TO 50        
C        
C     NULL GIB COLUMN        
C        
   40 GO TO (42,46,42,46), GIBTYP        
   42 DO 44 J = 1,NROWS        
   44 RZ(SGLKOR+J-1) = 0.0        
      GO TO 50        
   46 DO 48 J = 1,NROWS        
   48 DZ(DBLKOR+J-1) = 0.0D0        
C        
C     MOVE GIB DATA        
C        
   50 DO 80 J = 1,LUPRT        
      IF (RZ(KORE+J-1) .EQ. 1.0) GO TO 70        
      KK = KK + 1        
      L  = 1 + 2*(KK-1)        
      LL = 1 + 2*( J-1)        
      GO TO (62,64,66,68), GIBTYP        
   62 RZ(ICORE+J-1) = RZ(SGLKOR+KK-1)        
      GO TO 80        
   64 DZ(DICORE+J-1) = DZ(DBLKOR+KK-1)        
      GO TO 80        
   66 RZ(ICORE+LL-1) = RZ(SGLKOR+L-1)        
      RZ(ICORE+LL  ) = RZ(SGLKOR+L)        
      GO TO 80        
   68 DZ(DICORE+LL-1) = DZ(DBLKOR+L-1)        
      DZ(DICORE+LL  ) = DZ(DBLKOR+L)        
      GO TO 80        
C        
C     MOVE IDENTITY MATRIX DATA        
C        
   70 K = K + 1        
      L = 1 + 2*(J-1)        
      GO TO (72,74,76,78), GIBTYP        
   72 RZ(ICORE+J-1) = 0.0        
      IF (K .EQ. I) RZ(ICORE+J-1) = 1.0        
      GO TO 80        
   74 DZ(DICORE+J-1) = 0.0D0        
      IF (K .EQ. I) DZ(DICORE+J-1) = 1.0D0        
      GO TO 80        
   76 RZ(ICORE+L-1) = 0.0        
      IF (K .EQ. I) RZ(ICORE+L-1) = 1.0        
      RZ(ICORE+L) = 0.0        
      GO TO 80        
   78 DZ(DICORE+L-1) = 0.0D0        
      IF (K .EQ. I) DZ(DICORE+L-1) = 1.0D0        
      DZ(DICORE+L) = 0.0D0        
   80 CONTINUE        
   90 CALL PACK (DZ(DICORE),HGHRL,ITRLR3)        
      CALL CLOSE (GIBRL,1)        
C        
C     PROCESS HIM MATRIX        
C        
      TYPEU  = ITRLR2(5)        
      NROWU  = ITRLR2(3)        
      TYPINP = ITRLR2(5)        
      NROWS  = ITRLR2(3)        
      IF (ITRLR2(5) .GT. 2) NROWS = 2*ITRLR2(3)        
      IF (ITRLR2(5).EQ.2 .OR. ITRLR2(5).EQ.4)        
     1    DICORE = (SGLKOR+NROWS)/2 + 1        
      IF (ITRLR2(5).EQ.1 .OR. ITRLR2(5).EQ.3) DICORE = DBLKOR + NROWS   
      ICORE = 2*DICORE - 1        
      IF (DICORE+NROWS .GE. KORLEN) GO TO 270        
      CALL GOPEN (HIMRL,Z(GBUF2),0)        
      DO 150 I = 1,KOLS2        
      KK = 0        
      CALL UNPACK (*100,HIMRL,DZ(DBLKOR))        
      GO TO 110        
C        
C     NULL HIM COLUMN        
C        
  100 GO TO (102,106,102,106), HIMTYP        
  102 DO 104 J = 1,NROWS        
  104 RZ(SGLKOR+J-1) = 0.0        
      GO TO 110        
  106 DO 108 J = 1,NROWS        
  108 DZ(DBLKOR+J-1) = 0.0D0        
C        
C     MOVE HIM MATRIX DATA        
C        
  110 DO 140 J = 1,LUPRT        
      IF (RZ(KORE+J-1) .EQ. 1.0) GO TO 130        
      KK = KK + 1        
      L  = 1 + 2*(KK-1)        
      LL = 1 + 2*( J-1)        
      GO TO (122,124,126,128), HIMTYP        
  122 RZ(ICORE+J-1) = RZ(SGLKOR+KK-1)        
      GO TO 140        
  124 DZ(DICORE+J-1) = DZ(DBLKOR+KK-1)        
      GO TO 140        
  126 RZ(ICORE+LL-1) = RZ(SGLKOR+L-1)        
      RZ(ICORE+LL  ) = RZ(SGLKOR+L)        
      GO TO 140        
  128 DZ(DICORE+LL-1) = DZ(DBLKOR+L-1)        
      DZ(DICORE+LL  ) = DZ(DBLKOR+L)        
      GO TO 140        
C        
C     MOVE ZERO MATRIX DATA        
C        
  130 L = 1 + 2*(J-1)        
      GO TO (132,134,136,138), HIMTYP        
  132 RZ(ICORE+J-1) = 0.0        
      GO TO 140        
  134 DZ(DICORE+J-1) = 0.0D0        
      GO TO 140        
  136 RZ(ICORE+L-1) = 0.0        
      RZ(ICORE+L  ) = 0.0        
      GO TO 140        
  138 DZ(DICORE+L-1) = 0.0D0        
      DZ(DICORE+L  ) = 0.0D0        
  140 CONTINUE        
  150 CALL PACK (DZ(DICORE),HGHRL,ITRLR3)        
      CALL CLOSE (HIMRL,1)        
      CALL CLOSE (HGHRL,1)        
      CALL WRTTRL (ITRLR3)        
      KORBGN = KORE        
C        
C     SAVE HGH ON SOF AS H(ORG,LFT) MATRIX        
C        
      ITEM = ITMLST(ITER)        
      CALL MTRXO (HGHRL,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 210        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  210 GO TO (220,220,220,230,240,260), ITEST        
  220 WRITE (IPRNTR,900) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
  230 IMSG = -2        
      GO TO 250        
  240 IMSG = -3        
  250 CALL SMSG(IMSG,ITEM,OLDNAM)        
      RETURN        
C        
  260 WRITE (IPRNTR,901) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  270 IMSG = -8        
      IFILE = 0        
      CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
  900 FORMAT (A23,' 6211, MODULE ',2A4,' - ITEM ',A4,        
     1       ' OF SUBSTRUCTURE ',2A4,' HAS ALREADY BEEN WRITTEN.')      
  901 FORMAT (A23,' 6632, MODULE ',2A4,' - NASTRAN MATRIX FILE FOR I/O',
     1       ' OF SOF ITEM ',A4,', SUBSTRUCTURE ',2A4,', IS PURGED.')   
C        
      END        
