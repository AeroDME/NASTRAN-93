      SUBROUTINE CURV        
C        
C     MAIN DRIVING ROUTINE OF MODULE -CURV-.        
C        
C     DMAP CALLING SEQUENCE.        
C        
C     CURV   OES1,MPT,CSTM,EST,SIL,GPL/OES1M,OES1G/P1/P2 $        
C        
      LOGICAL         FOES1G, EOFOS1, STRAIN        
      INTEGER         SUBR(6), FILE, MCB(7)        
      CHARACTER       UFM*23, UWM*25, UIM*29, SFM*25        
      COMMON /XMSSG / UFM, UWM, UIM, SFM        
      COMMON /BLANK / IP1, IP2        
      COMMON /SYSTEM/ ISYSBF, IOUTPT        
      COMMON /CURVTB/ INDEXS(108)        
CZZ   COMMON /ZZCURV/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
C        
C     COMMON /ZZCURV/ MUST BE AT THE LONGEST OF OVERLAYS WITH CURV1,    
C     CURV2, AND CURV3.        
C        
      EQUIVALENCE     (INDEXS( 16),LMCSID), (INDEXS( 52),LCORE),        
     1                (INDEXS( 79),LOC), (INDEXS( 80),FILE),        
     2                (INDEXS( 81),IMSG), (INDEXS(100),EOFOS1),        
     3                (INDEXS(103),FOES1G), (INDEXS(104),STRAIN),       
     4                (INDEXS(105),LOGERR)        
      DATA     SUBR / 4HCURV,4H1   ,4HCURV,4H2   ,4HCURV,4H3     /      
C        
C        
C     CHECK TO SEE IF COMPUTATIONS NEED TO BE DONE        
C        
      IF (IP1 .LT. 0) RETURN        
C        
C     CHECK TO SEE IF THE INPUT FILE EXISTS        
C        
      MCB(1) = 101        
      CALL RDTRL (MCB(1))        
      IF (MCB(1) .LE. 0) RETURN        
C        
C     PERFORM INITIALIZATION AND CREATE ESTX ON SCRATCH FILE 1.        
C        
      DO 10 I = 1,107        
      INDEXS(I) = 777777777        
   10 CONTINUE        
      IMSG = 0        
      JSUB = 1        
      CALL CURV1        
      IF (IMSG  .EQ. -8) GO TO 10001        
      IF (IMSG  .LT.  0) GO TO 9000        
      IF (LMCSID .LE. 0) GO TO 8000        
C        
C     CREATE OES1M FOR NEXT SUBCASE IF NOT AT EOF IN OES1.        
C        
  100 IF (EOFOS1) GO TO 4000        
      JSUB = 2        
      CALL CURV2        
      IF (IMSG .EQ. -8) GO TO 10001        
      IF (IMSG .LT.  0) GO TO 9000        
C        
C     IF OES1G IS TO BE FORMED CALL CURV3 OVERLAY.  PROCESS CURRENT     
C     SUBCASE        
C        
      IF (.NOT.FOES1G) GO TO 100        
      JSUB = 3        
      CALL CURV3        
      IF (IMSG .EQ. -8) GO TO 10001        
      IF (IMSG .LT.  0) GO TO 9000        
      GO TO 100        
C        
C     EOF HIT IN OES1.  ALL THROUGH.        
C        
 4000 CONTINUE        
      RETURN        
C        
C     NO NON-ZERO MATERIAL COORDINATE SYSTEM IDS ENCOUNTERED        
C        
 8000 CALL PAGE2 (3)        
      WRITE (IOUTPT,8100) UWM        
      IF (.NOT.STRAIN) WRITE (IOUTPT,8200)        
      IF (     STRAIN) WRITE (IOUTPT,8300)        
 8100 FORMAT (A25,' 3173, NO NON-ZERO MATERIAL COORDINATE SYSTEM IDS ', 
     1        'ENCOUNTERED IN MODULE CURV.')        
 8200 FORMAT (39H STRESSES IN MATERIAL COORDINATE SYSTEM,        
     1        14H NOT COMPUTED.)        
 8300 FORMAT (49H STRAINS/CURVATURES IN MATERIAL COORDINATE SYSTEM,     
     1        14H NOT COMPUTED.)        
      GO TO 4000        
C        
C     ERROR CONDITION IN CURV1, CURV2, OR CURV3.        
C        
 9000 IF (IMSG .NE. -37) GO TO 9999        
      WRITE  (IOUTPT,9100) SFM,JSUB,IMSG,LOC,JSUB,FILE        
 9100 FORMAT (A25,' 3174, SUBROUTINE CURV',I1,        
     1        ' HAS RETURNED WITH ERROR CONDITION ',I4, /5X,        
     2        'LOCATION CODE = ',I4,' IN SUBROUTINE CURV',I1, /5X,      
     3        'FILE NUMBER   = ',I4)        
      WRITE  (IOUTPT,9998) INDEXS        
 9998 FORMAT (/5X,29H CONSTANTS IN COMMON /CURVTB/ , /,(3X,4I15))       
C        
C     INSURE ALL FILES CLOSED        
C        
 9999 CONTINUE        
      DO 10000 I = 1,9        
      DO 10000 J = 100,300,100        
      CALL CLOSE (I+J,1)        
10000 CONTINUE        
10001 WRITE (IOUTPT,9100) SFM,JSUB,IMSG,LOC,JSUB,FILE        
      JSUB = 2*JSUB - 1        
      IF (IMSG .EQ. -8) FILE = LCORE        
      CALL MESAGE (IMSG,FILE,SUBR(JSUB))        
      GO TO 4000        
      END        
