      SUBROUTINE MRED1D        
C        
C     THIS SUBROUTINE GENERATES THE EEDX DATA BLOCK USING THE EED DATA  
C     BLOCK FORMAT FROM THE EIGR OR EIGC AND EIGP BULK DATA FOR THE     
C     MRED1 MODULE.        
C        
C     INPUT  DATA        
C     GINO - DYNAMICS - EIGC DATA        
C                       EIGP DATA        
C                       EIGR DATA        
C        
C     OUTPUT DATA        
C     GINO - EEDX     - EIGC DATA        
C                       EIGP DATA        
C                       EIGR DATA        
C        
C     PARAMETERS        
C     INPUT  - DNAMIC - DYNAMICS DATA BLOCK INPUT FILE NUMBER        
C              GBUF1  - GINO BUFFER        
C              EEDX   - EEDX DATA BLOCK OUTPUT FILE NUMBER        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              IEIG   - EIGENVALUE EXTRACTION SET IDENTIFICATION NUMBER 
C     OUTPUT - DRY    - MODULE OPERATION FLAG        
C     OTHERS - EIGTYP - EIG CARD TYPE PROCESSING FLAG        
C                     = 1, PROCESS EIGC DATA        
C                     = 2, PROCESS EIGP DATA        
C                     = 3, PROCESS EIGR DATA        
C              EIGCP  - EIGC AND EIGP DATA ERROR FLAG        
C                     = 0, NO EIGC, EIGP DATA - NO ERROR        
C                     = 1, EIGC DATA ONLY - NO ERROR        
C                     = 2, EIGP DATA ONLY - ERROR        
C                     = 3, EIGC AND EIGP DATA - NO ERROR        
C              EIGTRL - EEDX TRAILER        
C              EIGCPR - DUMMY EIG(C,P,R) ARRAY        
C              EIG    - ARRAY OF EIG(C,P,R) CARD TYPES AND HEADER       
C                       INFORMATION        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              NWDS2R - NUMBER OF EIG(C,P,R) WORDS TO READ ON DYNAMIC   
C                       DATA FILE        
C        
      EXTERNAL        ORF        
      LOGICAL         USRMOD        
      INTEGER         ORF,OLDNAM,DRY,TYPE,GBUF1,GBUF2,Z,DNAMIC,        
     1                EIG(3,3),EIGCPR(3),EEDX,EIGTRL(7),EIGTYP,EIGCP    
      DIMENSION       MODNAM(2),LETR(3)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / OLDNAM(2),DRY,IDUM1(3),TYPE(2),IDUM5,GBUF1,GBUF2, 
     1                IDUM2(3),KORLEN,IDUM7(4),IEIG,IDUM3(6),KORBGN,    
     2                IDUM6(12),USRMOD        
CZZ   COMMON /ZZMRD1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /TWO   / ITWO(32)        
      COMMON /SYSTEM/ IDUM4,IPRNTR        
      DATA    DNAMIC, EIG,EEDX/103,207,2,0,257,4,0,307,3,0,202/        
      DATA    MODNAM, LETR /4HMRED,4H1D  ,1HC,1HP,1HR/        
      DATA    KOMPLX, KREAL/4HCOMP,4HREAL/        
C        
C     OPEN DYNAMICS, EEDX DATA BLOCKS        
C        
      IF (DRY .EQ. -2) RETURN        
      IF (USRMOD) GO TO 175        
      CALL PRELOC (*180,Z(GBUF1),DNAMIC)        
      CALL GOPEN (EEDX,Z(GBUF2),1)        
C        
C     SET PROCESSING FLAGS        
C        
      EIGTYP = 0        
      EIGCP  = 0        
      EIGTRL(1) = EEDX        
      DO 10 I = 2,7        
   10 EIGTRL(I) = 0        
C        
C     INCREMENT EIG PROCESSING FLAG        
C     EIGTYP .EQ. 1, PROCESS EIGC DATA        
C     EIGTYP .EQ. 2, PROCESS EIGP DATA        
C     EIGTYP .EQ. 3, PROCESS EIGR DATA        
C        
   20 EIGTYP = EIGTYP + 1        
      IF (EIGTYP .EQ. 4) GO TO 170        
C        
C     SELECT EIG MODE        
C        
      IF (TYPE(1).EQ.KREAL  .AND. EIGTYP.LT.3) GO TO 20        
      IF (TYPE(1).EQ.KOMPLX .AND. EIGTYP.EQ.3) GO TO 20        
      DO 30 I = 1,3        
   30 EIGCPR(I) = EIG(I,EIGTYP)        
C        
C     LOCATE EIG(C,P,R) DATA CARD        
C        
      CALL LOCATE (*20,Z(GBUF1),EIGCPR,ITEST)        
C        
C     SET UP EEDX DATA RECORD        
C        
      DO 40 I = 1,3        
   40 Z(KORBGN+I-1) = EIGCPR(I)        
C        
C     FIND CORRECT EIG(C,P,R) DATA CARD        
C        
      GO TO (50,60,70), EIGTYP        
   50 NWDS2R = 10        
      GO TO 80        
   60 NWDS2R = 4        
      GO TO 80        
   70 NWDS2R = 18        
   80 CALL READ (*190,*200,DNAMIC,Z(KORBGN+3),NWDS2R,0,NOWDSR)        
      IF (Z(KORBGN+3) .EQ. IEIG) GO TO 100        
      GO TO (90,80,80), EIGTYP        
C        
C     READ REST OF EIGC DATA        
C        
   90 CALL READ (*190,*200,DNAMIC,Z(KORBGN+3),7,0,NOWDSR)        
      IF (Z(KORBGN+3) .EQ. -1) GO TO 80        
      GO TO 90        
C        
C     SELECT EIG PROCESSING MODE        
C        
  100 GO TO (110,140,150), EIGTYP        
C        
C     WRITE EIGC DATA ONTO EEDX DATA BLOCK        
C        
  110 CALL WRITE (EEDX,Z(KORBGN),13,0)        
      EIGTRL(2) = ORF(EIGTRL(2),16384)        
      EIGCP = EIGCP + 1        
  120 CALL READ (*190,*200,DNAMIC,Z(KORBGN),7,0,NOWDSR)        
      IF (Z(KORBGN) .EQ. -1) GO TO 130        
      CALL WRITE (EEDX,Z(KORBGN),7,0)        
      GO TO 120        
  130 CALL WRITE (EEDX,Z(KORBGN),7,1)        
      GO TO 20        
C        
C     WRITE EIGP DATA ONTO EEDX DATA BLOCK        
C        
  140 CALL WRITE (EEDX,Z(KORBGN),7,1)        
      EIGCP = EIGCP + 2        
      EIGTRL(2) = ORF(EIGTRL(2),4096)        
      GO TO 20        
C        
C     WRITE EIGR DATA ONTO EEDX DATA BLOCK        
C        
  150 CALL WRITE (EEDX,Z(KORBGN),21,1)        
      EIGTRL(2) = ORF(EIGTRL(2),8192)        
      GO TO 20        
C        
C     CLOSE DYNAMICS, EEDX DATA BLOCKS        
C        
  170 CALL CLOSE (DNAMIC,1)        
      CALL CLOSE (EEDX,1)        
C        
C     TEST FOR EIG CARD ERRORS        
C        
      IF (EIGTRL(2) .EQ. 0) GO TO 230        
      IF (EIGCP .EQ. 2) GO TO 240        
C        
C     WRITE EEDX DATA BLOCK TRAILER        
C        
      CALL WRTTRL (EIGTRL)        
  175 CONTINUE        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  180 IMSG = -1        
      GO TO 220        
  190 IMSG = -2        
      IF (EIGTYP .EQ. 2) GO TO 20        
      GO TO 210        
  200 IMSG = -3        
      IF (EIGTYP .EQ. 2) GO TO 20        
  210 WRITE (IPRNTR,900) UFM,LETR(EIGTYP),IEIG,OLDNAM        
  220 CALL SOFCLS        
      CALL MESAGE (IMSG,DNAMIC,MODNAM)        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  230 WRITE (IPRNTR,901) UFM,IEIG,OLDNAM        
      GO TO 250        
  240 WRITE (IPRNTR,902) UFM,IEIG,OLDNAM        
  250 DRY = -2        
      RETURN        
C        
  900 FORMAT (A23,' 6627, NO EIG',A1,' DATA CARD ',        
     1       'SPECIFIED FOR SET ID',I9,', SUBSTRUCTURE ',2A4,1H.)       
  901 FORMAT (A23,' 6628, NO EIGC OR EIGR CARD SPECIFIED FOR SET ID',I9,
     1       ', SUBSTRUCTURE ',2A4,1H.)        
  902 FORMAT (A23,' 6629, NO EIGC DATA CARD SPECIFHIED WITH EIGP DATA ',
     1       'CARD SET ID',I9,', SUBSTRUCTURE ',2A4,1H.)        
C        
      END        
