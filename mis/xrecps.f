      SUBROUTINE XRECPS (INEW,IOLD)        
C        
C     ******************************************************************
C     * ATTENTION CDC 6600 SET-UPS ** THESE ENTRY POINTS MAY BE        *
C     * SEPARATED EACH ENTRY MAY BE MADE A SUBROUTINE (EXCEPT /CRDFLG/ *
C     * AND /INTEXT/ WHICH USE COMMON CODE)  DUPE THE SPECIFICATION    *
C     * STMTS FOR EACH SUB                                             *
C     ******************************************************************
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER KBMSK1(8),SFT(4),NRECPS(2),CON(38),MK(4),C10C(7),EXTAB(37)
C        
C     ENTRY XFADJ (BF,SD,KK)        
C     * XFADJ ADJUSTS 4 CHARACTER FIELDS, LEFT OR RIGHT, 2 OR 4 FIELDS  
C       AT A TIME - IF FIELDS CONTAIN ONLY INTEGERS 0 THRU 9, SHIFT IS  
C       RIGHT, OTHERWISE SHIFT IS LEFT  / BF= ADDR OF LEFT MOST FIELD / 
C       SD= 0 SINGLE (2 FIELDS), 1 DOUBLE (4 FIELDS).  THIS ROUTINE     
C       DETERMINES ONLY TYPE OF SHIFT NEEDED, SHIFTING IS DONE BY XFADJ1
C       KK IS RETURNED EQUAL TO 0 FOR INTEGER, 1 FOR NON-INTEGER        
C        
      INTEGER BF(1)        
C        
C     ENTRY XBCDBI (BA)        
C     * XBCDBI CONVERTS 2, 4 CHARACTER BCD INTEGER FIELDS (RIGHT        
C       ADJUSTED IN THE LEFT MOST 4 CHAR) INTO A SINGLE FORTRAN BINARY  
C       INTEGER (RIGHT ADJUSTED IN THE WORD IN THE RIGHT FIELD)        
C       BA= ADDR OF LEFT FIELD        
C        
      INTEGER BA(2)        
C        
C     ENTRY XPRETY (BFF)        
C     * ROUTINE PRETTIES UP SORT OUTPUT BY LEFT ADJUSTING ALL FIELDS    
C        
      INTEGER BFF(2)        
C        
C     ENTRY CRDFLG (CARD)        
C     * ROUTINE SETS CARD TYPE FLAGS IN RESTART TABLES        
C       CONVERTS TO EXTERNAL CODE FIRST        
C       IF CARD TYPE IS PARAM, SET FLAG FOR PARAM NAME (FIELD 2)        
C        
      INTEGER CARD(4)        
C        
C     ENTRY EXTINT (EXTWRD)        
C     * ROUTINE CONVERTS FROM EXTERNAL MACHINE DEPENDENT CHARACTER CODES
C       TO AN INTERNAL MACHINE INDEPENDENT INTEGER        
C        
      INTEGER EXTWRD(1)        
C        
C     ENTRY INTEXT (INTWRD)        
C     * ROUTINE CONVERTS FROM INTERNAL MACHINE INDEPENDENT INTEGERS TO  
C       AN EXTERNAL MACHINE DEPENDENT CHARACTER CODE        
C        
      INTEGER INTWRD(2)        
C        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF,COMPLF        
      LOGICAL         DEC        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /MACHIN/ MACH        
      COMMON /SYSTEM/ B,OUTTAP,D1(6),NLPP,D2(2),LCNT,D3(26),        
     1                NBPC,NBPW,NCPW        
      COMMON /XSRTCM/ BIMSK1(6),BIMSK2(5),BIMSK3(4),BIMSK4(4),BIMSK5(2),
     1                BIMSK6,BKMSK1(8),BKMSK2,SHIFTS(4),        
     2                ICON1,ICON2,STAR,PLUS,DOLLAR,STARL,SLASH,SFTM,    
     3                MASK,BLANK,MKA,IS,MBIT4        
      COMMON /TWO   / ITWO(32)        
      COMMON /IFPX0 / LBD,LCC,IBITS(1)        
      COMMON /IFPX1 / NUM,ICARDS(2)        
      EQUIVALENCE     (SFT(1),SHIFTS(1)),(MK(1),BIMSK3(1)),        
     1                (SFT1,SHIFTS(2)),(EXTAB(1),CON(1))        
      DATA ITAPE4/304/,NRECPS/4HXREC,4HPS  /        
      DATA CON/4H    ,4H   0,4H   1,4H   2,4H   3,4H   4,4H   5,4H   6, 
     1  4H   7,4H   8,4H   9,4H   A,4H   B,4H   C,4H   D,4H   E,4H   F, 
     2  4H   G,4H   H,4H   I,4H   J,4H   K,4H   L,4H   M,4H   N,4H   O, 
     3  4H   P,4H   Q,4H   R,4H   S,4H   T,4H   U,4H   V,4H   W,4H   X, 
     4  4H   Y,4H   Z,4H              /        
      DATA C10C/10,100,1000,10000,100000,1000000,10000000/        
      DATA PAR1,PAR2/4HPARA,4HM       /        
      DATA KPRET1,KPRET2/4H.   ,4H0.0 /        
C        
      DATA KBMSK1 / 4H0000, 4H000$, 4H00$$, 4H0$$$,        
     1              4H$$$ , 4H$$  , 4H$   , 4H            /        
      DATA ISTR   , ISTRL , IPLS  , IDOLLR, ISLSH , IZERO /        
     1     4H   * , 4H*   , 4H+   , 4H$   , 4H/   , 4H0   /        
C        
C        
C     THE ARRAYS IN /XSRTCM/ WILL BE SET BY INITO AS FOLLOWS        
C        
C                           VAX        
C                    CDC    IBM   UNIVAC        
C        SHIFTS(1) =  0      0      0        
C        SHIFTS(2) =  6      8      9        
C        SHIFTS(3) = 12     16     18        
C        SHIFTS(4) = 18     24     27        
C        SFTM      = 36      0      0        
C        
C                      ----------- BYTE --------------        
C                      1ST   2ND   3RD   4TH   5TH,...        
C        BIMSK1(1) = / 777 / 777 / 777 / 000 / 00..        CDC USES /77/
C        BIMSK1(2) = / 777 / 777 / 000 / 000 / 00..        INSTEAD OF   
C        BIMSK1(3) = / 777 / 000 / 000 / 000 / 00..        /777/ IN A   
C        BIMSK1(4) = / 000 / 000 / 000 / 777 / 00..        BYTE        
C        BIMSK1(5) = / 000 / 000 / 777 / 777 / 00..        
C        BIMSK1(6) = / 000 / 777 / 777 / 777 / 00..        
C        
C        BIMSK2(1) = / 777 / 777 / 777 / 777 / 77.. (FOR CDC ONLY)      
C                  = / 377 / 777 / 777 / 777 / 00.. (FOR IBM,VAX,UNIVAC)
C        BIMSK2(2) = / 777 / 777 / 777 / 000 / 77..        
C        BIMSK2(3) = / 777 / 777 / 000 / 000 / 77..        
C        BIMSK2(4) = / 777 / 000 / 000 / 000 / 77..        
C        BIMSK2(5) = / 000 / 000 / 000 / 000 / 77..        
C        
C        BIMSK3(1) = / 777 / 000 / 000 / 000 / 00..        
C        BIMSK3(2) = / 000 / 777 / 000 / 000 / 00..        
C        BIMSK3(3) = / 000 / 000 / 777 / 000 / 00..        
C        BIMSK3(4) = / 000 / 000 / 000 / 777 / 00..        
C        
C        BIMSK4(1) = / 000 / 777 / 777 / 777 / 77..        
C        BIMSK4(2) = / 777 / 000 / 777 / 777 / 77..        
C        BIMSK4(3) = / 777 / 777 / 000 / 777 / 77..        
C        BIMSK4(4) = / 777 / 777 / 777 / 000 / 77..        
C        
C        BIMSK5(1) = / 377 / 777 / 777 / 777 / 00..        
C        BIMSK5(2) = / 377 / 777 / 777 / 000 / 00..        
C        BIMSK6    = / 000 / 000 / 000 / 000 / 77..        
C        
C        IS        = / 400 / 000 / 000 / 000 / 77..        
C        MKA       = / 000 / 000 / 000 / 777 / 77..        
C        MASK      = 4TH OR 10TH BYTE IS /777/, ZERO FILLED        
C        BLANK     = 4TH OR 10TH BYTE IS BLANK, ZERO FILLED        
C        
C     ARRAY BKMSK1 IS SAME AS KBMSK1 EXCEPT THAT THE DOLLARS ARE        
C     REPLACED BY BINARY ZEROS        
C     SIMILARY, THE BLANKS IN ISTR,ISTRL,IPLS,IDOLLR,ISLSH, AND ARRAY   
C     CON ARE ALSO REPLACED BY BINARY ZEROS.        
C     ICON1 AND ICON2 ARE LEFT ADJUSTED CON(1) AND CON(2), ZERO FILLED. 
C        
C     THIS ROUTINE POSITIONS ITAPE4 TO THE PROPER CONTINUATION RECORD   
C        
      DEC  = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      IF (INEW .NE. 1) GO TO 10        
      CALL REWIND (ITAPE4)        
      IOLD = 2        
      RETURN        
C        
   10 IDIF = INEW - IOLD        
      IF (IDIF) 50,20,30        
   20 IOLD = INEW + 1        
      RETURN        
C        
   30 DO 40 I = 1,IDIF        
      CALL FWDREC (*65,ITAPE4)        
   40 CONTINUE        
      GO TO 20        
   50 IDIF = IABS(IDIF)        
      DO 60 I = 1,IDIF        
      CALL BCKREC (ITAPE4)        
   60 CONTINUE        
      GO TO 20        
   65 WRITE  (OUTTAP,66) SFM        
   66 FORMAT (A25,' 217, ILLEGAL EOF ON ITAPE4.')        
      CALL MESAGE (-37,0,NRECPS)        
      RETURN        
C        
C     INITIALIZES BCD CONSTANTS FOR USE WITHIN SORT        
C        
      ENTRY INITCO        
C     ============        
C        
C     INITIALIZE (CREATE) BINARY CHARACTER MASKS        
C        
      DEC       = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      SHIFTS(1) = 0        
      SHIFTS(2) = NBPC        
      SHIFTS(3) = NBPC*2        
      SHIFTS(4) = NBPC*3        
      MBITS     = COMPLF(0)        
      SFTM      = (NCPW-4)*NBPC        
      MBIT4     = LSHIFT(MBITS,SFTM)        
      BIMSK1(1) = LSHIFT(MBIT4,NBPC)        
      BIMSK1(2) = LSHIFT(BIMSK1(1),NBPC)        
      BIMSK1(3) = LSHIFT(BIMSK1(2),NBPC)        
      BIMSK1(4) = RSHIFT(BIMSK1(3),NBPC*3)        
      BIMSK1(5) = RSHIFT(BIMSK1(2),NBPC*2)        
      BIMSK1(6) = RSHIFT(BIMSK1(1),NBPC)        
      BIMSK2(1) = MBITS        
      BIMSK2(2) = COMPLF(BIMSK1(4))        
      BIMSK2(3) = COMPLF(BIMSK1(5))        
      BIMSK2(4) = COMPLF(BIMSK1(6))        
      BIMSK2(5) = RSHIFT(MBITS,NBPC*4)        
      BIMSK3(4) = BIMSK1(4)        
      BIMSK3(3) = LSHIFT(BIMSK3(4),NBPC)        
      BIMSK3(2) = LSHIFT(BIMSK3(3),NBPC)        
      BIMSK3(1) = BIMSK1(3)        
      BIMSK4(1) = COMPLF(BIMSK3(1))        
      BIMSK4(2) = COMPLF(BIMSK3(2))        
      BIMSK4(3) = COMPLF(BIMSK3(3))        
      BIMSK4(4) = COMPLF(BIMSK3(4))        
      BIMSK5(1) = RSHIFT(BIMSK2(1),1)        
      BIMSK5(2) = RSHIFT(LSHIFT(BIMSK2(2),1),1)        
      BIMSK6    = BIMSK2(5)        
      IF (MACH.EQ.2 .OR. DEC) BIMSK2(1) = BIMSK5(1)        
C        
C     NEXT CARD FOR UNIVAC ASCII VERSION ONLY (NOT FORTRAN 5)        
C        
      IF (MACH .EQ. 3) BIMSK2(1) = BIMSK5(1)        
      MASK  = RSHIFT(BIMSK3(4),SFTM)        
      BLANK = RSHIFT(KBMSK1(8),(3*NBPC+SFTM))        
      IS    = COMPLF(BIMSK5(1))        
      MKA   = ORF(BIMSK3(4),BIMSK6)        
C        
C     INITIALIZE THE BCD BLANK DATA        
C        
      IF (DEC) GO TO 92        
C        
C     IBM, CDC, UNIVAC        
C        
      BKMSK1(1) = KBMSK1(1)        
      BKMSK1(2) = ANDF(KBMSK1(2),BIMSK2(2))        
      BKMSK1(3) = ANDF(KBMSK1(3),BIMSK2(3))        
      BKMSK1(4) = ANDF(KBMSK1(4),BIMSK2(4))        
      BKMSK1(5) = ANDF(KBMSK1(5),ORF(BIMSK1(4),BIMSK6))        
      BKMSK1(6) = ANDF(KBMSK1(6),ORF(BIMSK1(5),BIMSK6))        
      BKMSK1(7) = ANDF(KBMSK1(7),ORF(BIMSK1(6),BIMSK6))        
      BKMSK1(8) = KBMSK1(8)        
      BKMSK2    = ANDF(BKMSK1(1),BIMSK6)        
      STAR      = ANDF(ISTR  ,ORF(BIMSK1(4),BIMSK6))        
      PLUS      = ANDF(IPLS  ,BIMSK2(4))        
      DOLLAR    = ANDF(IDOLLR,BIMSK2(4))        
      STARL     = ANDF(ISTRL ,BIMSK2(4))        
      SLASH     = ANDF(ISLSH ,BIMSK2(4))        
      DO 90 I = 1,38        
   90 CON(I) = ANDF(CON(I),BIMSK3(4))        
      ICON1  = LSHIFT(CON(1),SFT(4)-1)        
      ICON2  = LSHIFT(CON(2),SFT(4)-1)        
      RETURN        
C        
C     VAX        
C        
   92 BKMSK2    = 0        
      BKMSK1(1) = KBMSK1(1)        
      BKMSK1(2) = KHRFN3(BKMSK2,KBMSK1(2),-1,1)        
      BKMSK1(3) = KHRFN3(BKMSK2,KBMSK1(3),-2,1)        
      BKMSK1(4) = KHRFN3(BKMSK2,KBMSK1(4),-3,1)        
      BKMSK1(5) = KHRFN3(BKMSK2,KBMSK1(5),-3,0)        
      BKMSK1(6) = KHRFN3(BKMSK2,KBMSK1(6),-2,0)        
      BKMSK1(7) = KHRFN3(BKMSK2,KBMSK1(7),-1,0)        
      BKMSK1(8) = KBMSK1(8)        
      STAR      = KHRFN1(BKMSK2,4,ISTR  ,4)        
      PLUS      = KHRFN1(BKMSK2,1,IPLS  ,1)        
      DOLLAR    = KHRFN1(BKMSK2,1,IDOLLR,1)        
      STARL     = KHRFN1(BKMSK2,1,ISTRL ,1)        
      SLASH     = KHRFN1(BKMSK2,1,ISLSH ,1)        
      DO 95 I = 1,38        
   95 CON(I) = KHRFN1(BKMSK2,4,CON(I),4)        
      ICON1  = RSHIFT(KHRFN1(BKMSK2,1,CON(1),4),1)        
      ICON2  = RSHIFT(KHRFN1(BKMSK2,1,CON(2),4),1)        
      RETURN        
C        
C        
      ENTRY XFADJ (BF,SD,KK)        
C     ======================        
C        
C     DATA SFT /0,6,12,18/        
C     DATA MK  /O770000000000,O007700000000,O000077000000,O000000770000/
C        
      DEC = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      II  = 2        
      IF (SD .EQ. 1) II = 4        
      DO 400 I = 1,II        
      BFI = BF(I)        
      DO 300 J = 1,4        
      JI  = 5 - J        
      IF (.NOT.DEC) TEST = RSHIFT(ANDF(BFI,MK(J)),SFT(JI))        
      IF (     DEC) TEST = KHRFN1(BKMSK2,4,BFI,J)        
      DO 100 K = 1,11        
      IF (TEST .EQ. CON(K)) GO TO 200        
  100 CONTINUE        
C        
C     CHARACTER NON-INTEGER        
C        
      CALL XFADJ1 (BF,LSHIFT,SD)        
      KK = 1        
      RETURN        
C        
  200 IF (K .EQ. 1) GO TO 300        
C        
C     CHARACTER INTEGER        
C        
      CALL XFADJ1 (BF,RSHIFT,SD)        
      KK = 0        
      RETURN        
C        
  300 CONTINUE        
  400 CONTINUE        
C        
C     ALL FIELDS BLANK        
C        
      KK = 0        
      RETURN        
C        
C        
      ENTRY XBCDBI (BA)        
C     =================        
C        
C     DATA SFT1/6/,SFTM/12/,MASK/O77/,BLANK/O60/        
C        
C     IF MACHINE IS VAX-11/780, ORDER OF CHARACTERS IN A WORD IS REVERSE
C     OF THAT ON OTHER MACHINES.  THE CHARACTER ORDER MUST THEREFORE BE 
C     REVERSED BEFORE DECODING TO AN INTEGER VALUE.        
C        
      DEC = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      IF (.NOT.DEC) GO TO 430        
      DO 420 IBA = 1,2        
      ITEMP = 0        
      DO 410 IVAX = 1,4        
      JTEMP = RSHIFT(BA(IBA),8*(IVAX-1))        
      JTEMP = ANDF(MASK,JTEMP)        
      JTEMP = LSHIFT(JTEMP,8*(4-IVAX))        
      ITEMP = ORF(ITEMP,JTEMP)        
  410 CONTINUE        
      BA(IBA) = ITEMP        
  420 CONTINUE        
C        
  430 CONTINUE        
      BA(1) = RSHIFT(BA(1),SFTM)        
      BA(2) = RSHIFT(BA(2),SFTM)        
      IVAR  = ANDF(BA(2),MASK)        
      IF (IVAR .NE. BLANK) GO TO 490        
      BA(2) = 0        
      RETURN        
C        
  490 IF (MACH .EQ. 4) IVAR = IVAR - 27        
      IVAR  = ANDF(IVAR,15)        
      DO 500 I = 1,3        
      BA(2) = RSHIFT(BA(2),SFT1)        
      ICHAR = ANDF(BA(2),MASK)        
      IF (MACH .EQ. 4) ICHAR = ICHAR - 27        
  500 IVAR  = IVAR + C10C(I)*ANDF(15,ICHAR)        
      ICHAR = ANDF(BA(1),MASK)        
      IF (MACH .EQ. 4) ICHAR = ICHAR - 27        
      IVAR  = IVAR + C10C(4)*ANDF(15,ICHAR)        
      DO 510 I = 5,7        
      BA(1) = RSHIFT(BA(1),SFT1)        
      ICHAR = ANDF(BA(1),MASK)        
      IF (MACH .EQ. 4) ICHAR = ICHAR - 27        
  510 IVAR  = IVAR + C10C(I)*ANDF(15,ICHAR)        
      BA(2) = IVAR        
      RETURN        
C        
C        
      ENTRY XPRETY (BFF)        
C     ==================        
C        
C     DATA  MKA/O000000777777/, STAR/4H000*/        
C        
      DEC = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      IF (.NOT.DEC) ITST = ANDF(MKA,BFF(2))        
      IF (     DEC) ITST = KHRFN1(BKMSK2,4,BFF(2),4)        
      IF (ITST .EQ. STAR) GO TO 610        
      DO 600 I = 3,17,2        
      IF (BFF(I).EQ.BKMSK1(8) .AND. BFF(I+1).EQ.BKMSK1(8)) GO TO 600    
      CALL XFADJ1 (BFF(I),LSHIFT,0)        
      IF (BFF(I) .EQ. KPRET1) BFF(I) = KPRET2        
      IF (BFF(I) .NE. BKMSK1(8)) GO TO 600        
      IF (.NOT.DEC) BFF(I) = ORF(RSHIFT(BFF(I),SFT(2)),BKMSK1(4))       
      IF (     DEC) BFF(I) = KHRFN3(IZERO,BFF(I),1,0)        
  600 CONTINUE        
      RETURN        
C        
  610 DO 620 I = 3,15,4        
      IF (BFF(I).EQ.BKMSK1(8) .AND. BFF(I+1).EQ.BKMSK1(8) .AND.        
     1    BFF(I+2).EQ.BKMSK1(8) .AND. BFF(I+3).EQ.BKMSK1(8)) GO TO 620  
      CALL XFADJ1 (BFF(I),LSHIFT,1)        
      IF (BFF(I) .EQ. KPRET1) BFF(I) = KPRET2        
      IF (BFF(I) .NE. BKMSK1(8)) GO TO 620        
      IF (.NOT.DEC) BFF(I) = ORF(RSHIFT(BFF(I),SFT(2)),BKMSK1(4))       
      IF (     DEC) BFF(I) = KHRFN3(IZERO,BFF(I),1,0)        
  620 CONTINUE        
      RETURN        
C        
C        
      ENTRY CRDFLG (CARD)        
C     ===================        
C        
      DEC    = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      INWRDI = CARD(1)        
      KARD2  = CARD(2)        
      KBRN   = -1        
      ASSIGN 640 TO IRET        
      GO TO 770        
  640 IF (.NOT.DEC) KARD2 = ORF(ANDF(BIMSK1(1),KARD2),BKMSK1(5))        
      IF (     DEC) KARD2 = KHRFN1(KARD2,4,BKMSK1(8),4)        
      IF (KARD1.NE.PAR1 .OR. KARD2.NE.PAR2) GO TO 645        
      KARD1 = CARD(3)        
      KARD2 = CARD(4)        
  645 LMT   = NUM* 2        
      DO 650 I = 1,LMT,2        
      IF (KARD1.EQ.ICARDS(I) .AND. KARD2.EQ.ICARDS(I+1)) GO TO 660      
  650 CONTINUE        
      RETURN        
C        
  660 J = I/2        
      ICYCL = (J/31) + 1        
      IPOS  = MOD(J,31) + 2        
      IBITS(ICYCL) = ORF(IBITS(ICYCL),ITWO(IPOS))        
      RETURN        
C        
C        
      ENTRY EXTINT (EXTWRD)        
C     =====================        
C        
      DEC = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      DO 750 I = 1,2        
      EXWRDI = EXTWRD(I)        
      DO 730 J = 1,4        
      JI = 5 - J        
      SFTJI = SFT(JI)        
      IF (.NOT.DEC) TEST = RSHIFT(ANDF(EXWRDI,MK(J)),SFTJI)        
      IF (     DEC) TEST = KHRFN1(BKMSK2,4,EXWRDI,J)        
      DO 710 K = 1,37        
      IF (TEST .EQ. EXTAB(K)) GO TO 720        
  710 CONTINUE        
      K = 1        
      GO TO 740        
  720 IF (.NOT.DEC)        
     1   EXWRDI = ORF(ANDF(EXWRDI,BIMSK4(J)),LSHIFT(K,SFTJI+SFTM))      
      IF (DEC) EXWRDI = KHRFN1(EXWRDI,J,K,-1)        
      IF (K .EQ. 1) GO TO 740        
  730 CONTINUE        
  740 EXTWRD(I) = EXWRDI        
      IF (K .EQ. 1) RETURN        
  750 CONTINUE        
      RETURN        
C        
C        
      ENTRY INTEXT (INTWRD)        
C     =====================        
C        
      DEC    = MACH.EQ.5 .OR. MACH.EQ.6 .OR. MACH.EQ.21        
      ASSIGN 800 TO IRET        
      INWRDI = INTWRD(1)        
      KBRN   = 0        
  770 DO 780 J = 1,4        
      JI     = 5 - J        
      SFTJI  = SFT(JI)        
      IF (.NOT.DEC) TEST = RSHIFT(ANDF(INWRDI,MK(J)),SFTJI+SFTM)        
      IF (     DEC) TEST = KHRFN1(BKMSK2,-1,INWRDI,J)        
      IF (TEST .GT. 37) GO TO 781        
      IF (.NOT.DEC)        
     1   INWRDI = ORF(ANDF(INWRDI,BIMSK4(J)),LSHIFT(EXTAB(TEST),SFTJI)) 
      IF (DEC) INWRDI = KHRFN1(INWRDI,J,EXTAB(TEST),4)        
      IF (TEST .EQ. 1) GO TO 781        
  780 CONTINUE        
  781 IF (KBRN) 782,784,786        
  782 KARD1  = INWRDI        
      INWRDI = CARD(2)        
      KBRN   = +2        
      GO TO 810        
  784 INTWRD(1) = INWRDI        
      INWRDI = INTWRD(2)        
      KBRN = +1        
      GO TO 810        
  786 IF (KBRN .EQ. 1) GO TO 788        
      KARD2 = INWRDI        
      GO TO 790        
  788 INTWRD(2) = INWRDI        
  790 GO TO IRET, (800,640)        
  800 RETURN        
C        
  810 IF (TEST.EQ.1 .OR. TEST.GT.37) GO TO 790        
      GO TO 770        
C        
      END        
