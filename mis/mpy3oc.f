      SUBROUTINE MPY3OC (Z,IZ,DZ)        
C        
C     OUT-OF-CORE PRODUCT.        
C        
      LOGICAL          FIRST1,FIRST2,FIRST3,E        
      INTEGER          FILEA,FILEE,FILEC,CODE,PREC,SCR1,SCR2,SCR3,FILE, 
     1                 BUF1,BUF2,BUF3,BUF4,SYSBUF,ZPNTRS,EOL,EOR,PRECM, 
     2                 TYPIN,TYPOUT,ROW1,ROWM,UTYP,UROW1,UROWN,UINCR,   
     3                 BUF5,SIGNAB,SIGNC        
      DOUBLE PRECISION DZ(1),DA        
      DIMENSION        Z(1),IZ(1),NAME(2),NAMS(2)        
C        
C     MPYAD COMMON        
      COMMON /MPYADX/  MFILEA(7),MFILEB(7),MFILEE(7),MFILEC(7),MCORE,   
     1                 MT,SIGNAB,SIGNC,MPREC,MSCR        
C        
C     FILES        
      COMMON /MPY3TL/  FILEA(7),FILEB(7),FILEE(7),FILEC(7),SCR1,SCR2,   
     1                 SCR,LKORE,CODE,PREC,LCORE,SCR3(7),BUF1,BUF2,     
     2                 BUF3,BUF4,E        
C        
C     SUBROUTINE CALL PARAMETERS        
      COMMON /MPY3CP/  DUM1(2),N,NCB,M,NK,D,MAXA,ZPNTRS(22),LAEND,      
     1                 FIRST1,FIRST2,K,K2,KCOUNT,IFLAG,KA,LTBC,J,LTAC   
C        
C     PACK        
      COMMON /PACKX /  TYPIN,TYPOUT,ROW1,ROWM,INCR        
C        
C     UNPACK        
      COMMON /UNPAKX/  UTYP,UROW1,UROWN,UINCR        
C        
C     TERMWISE MATRIX READ        
      COMMON /ZNTPKX/  A(2),DUM(2),IROW,EOL,EOR        
C        
C     SYSTEM PARAMETERS        
      COMMON /SYSTEM/  SYSBUF,NOUT        
      EQUIVALENCE      (ISAVP,ZPNTRS(1)),  (NSAVP,ZPNTRS(2)),        
     1                 (INTBU,ZPNTRS(3)),  (NNTBU,ZPNTRS(4)),        
     2                 (ILAST,ZPNTRS(5)),  (NLAST,ZPNTRS(6)),        
     3                 (INTBU2,ZPNTRS(7)), (NNTBU2,ZPNTRS(8)),        
     4                 (IC,ZPNTRS(9)),     (NC,ZPNTRS(10)),        
     5                 (IBCOLS,ZPNTRS(11)),(NBCOLS,ZPNTRS(12)),        
     6                 (IBCID,ZPNTRS(13)), (NBCID,ZPNTRS(14)),        
     7                 (IBNTU,ZPNTRS(15)), (NBNTU,ZPNTRS(16)),        
     8                 (IKTBP,ZPNTRS(17)), (NKTBP,ZPNTRS(18)),        
     9                 (IANTU,ZPNTRS(19)), (NANTU,ZPNTRS(20)),        
     O                 (IAKJ,ZPNTRS(21)),  (NAKJ,ZPNTRS(22)),        
     1                 (A(1),DA)        
      DATA    NAME  /  4HMPY3,4HOC   /        
      DATA    NAMS  /  4HSCR3,4H     /        
C        
C     RECALCULATION OF NUMBER OF COLUMNS OF B ABLE TO BE PUT IN CORE.   
C        
      BUF5  = BUF4 - SYSBUF        
      LCORE = BUF5 - 1        
      NK = (LCORE - 4*N - PREC*M - (2 + PREC)*MAXA)/(2 + PREC*N)        
      IF (NK .LT. 1) GO TO 5008        
C        
C    INITIALIZATION.        
C        
      FIRST1 = .TRUE.        
      FIRST2 = .TRUE.        
      FIRST3 = .FALSE.        
      PRECM  = PREC*M        
C        
C     OPEN CORE POINTERS        
C        
      ISAVP  = 1        
      NSAVP  = NCB        
      INTBU  = NSAVP + 1        
      NNTBU  = NSAVP + NCB        
      ILAST  = NNTBU + 1        
      NLAST  = NNTBU + NCB        
      INTBU2 = NLAST + 1        
      NNTBU2 = NLAST + NCB        
      IC     = NNTBU2 + 1        
      NC     = NNTBU2 + PREC*M        
      IBCOLS = NC + 1        
      NBCOLS = NC + PREC*N*NK        
      IBCID  = NBCOLS + 1        
      NBCID  = NBCOLS + NK        
      IBNTU  = NBCID + 1        
      NBNTU  = NBCID + NK        
      IKTBP  = NBNTU + 1        
      NKTBP  = NBNTU + MAXA        
      IANTU  = NKTBP + 1        
      NANTU  = NKTBP + MAXA        
      IAKJ   = NANTU + 1        
      NAKJ   = NANTU + PREC*MAXA        
      KF     = NSAVP        
      KL     = NNTBU        
      KN2    = NLAST        
      KBC    = NBCOLS        
      KBN    = NBCID        
      KT     = NBNTU        
      KAN    = NKTBP        
C        
C     PACK PARAMETERS        
C        
      TYPIN = PREC        
      TYPOUT= PREC        
      ROW1  = 1        
      INCR  = 1        
C        
C     UNPACK PARAMETERS        
C        
      UTYP  = PREC        
      UROW1 = 1        
      UINCR = 1        
C        
C     MATRIX TRAILERS        
C        
      CALL MAKMCB (SCR3,SCR3(1),N,2,PREC)        
      IF (M .EQ. N) SCR3(4) = 1        
C        
C     PUT B ONTO SCRATCH FILE IN UNPACKED FORM.        
C        
      CALL MPY3A (Z,Z,Z)        
C        
C     OPEN FILES AND CHECK EXISTENCE OF MATRIX E.        
C        
      IF (CODE.EQ.0 .OR. .NOT.E) GO TO 15        
      FILE = FILEE(1)        
      CALL OPEN (*5001,FILEE,Z(BUF5),2)        
      CALL FWDREC (*5002,FILEE)        
   15 FILE = FILEA(1)        
      CALL OPEN (*5001,FILEA,Z(BUF1),0)        
      CALL FWDREC (*5002,FILEA)        
      FILE = SCR1        
      CALL OPEN (*5001,SCR1,Z(BUF2),0)        
      FILE = SCR2        
      CALL OPEN (*5001,SCR2,Z(BUF3),1)        
      IF (CODE .EQ. 0) GO TO 20        
      FILE = FILEC(1)        
      CALL GOPEN (FILEC,Z(BUF4),1)        
      ROWM = FILEC(3)        
      GO TO 30        
   20 FILE = SCR3(1)        
      CALL OPEN (*5001,SCR3,Z(BUF4),1)        
      CALL WRITE (SCR3,NAMS,2,1)        
      ROWM = SCR3(3)        
C        
C     PROCESS SCR2 AND SET FIRST-TIME-USED AND LAST-TIME-USED FOR EACH  
C     ROW OF A.        
C        
   30 DO 40 K = 1,NCB        
      IZ(KF+K) = 0        
   40 IZ(KL+K) = 0        
      DO 90 J = 1,M        
      K = 0        
      CALL INTPK (*80,FILEA,0,PREC,0)        
   50 CALL ZNTPKI        
      K = K + 1        
      IZ(KT+K) = IROW        
      IF (IZ(KF+IROW) .GT. 0) GO TO 60        
      IZ(KF+IROW) = J        
   60 IZ(KL+IROW) = J        
      IF (EOL .EQ. 1) GO TO 70        
      GO TO 50        
   70 CALL WRITE (SCR2,IZ(IKTBP),K,0)        
   80 CALL WRITE (SCR2,0,0,1)        
   90 CONTINUE        
      CALL CLOSE (FILEA,1)        
      CALL OPEN (*5001,FILEA,Z(BUF1),2)        
      CALL FWDREC (*5002,FILEA)        
      CALL CLOSE (SCR2,1)        
      CALL OPEN (*5001,SCR2,Z(BUF3),0)        
C        
C     PROCESS COLUMNS OF A ONE AT A TIME.        
C        
      DO 360 J = 1,M        
C        
C     INITIALIZE SUM - ACCUMULATION MATRIX TO 0.        
C        
      DO 100 I = IC,NC        
  100 Z(I) = 0.        
      IF (CODE.EQ.0 .OR. .NOT.E) GO TO 105        
      UROWN = N        
      CALL UNPACK (*105,FILEE,Z(IC))        
C        
C     PROCESS A AND PERFORM FIRST PART OF PRODUCT BA(J).        
C        
  105 CALL MPY3B (Z,Z,Z)        
C        
C     TEST IF PROCESSING IS COMPLETE        
C        
      IF (IFLAG .EQ. 0) GO TO 340        
C        
C     PROCESS REMAINING TERMS OF COLUMN J OF A.        
C        
C     TEST IF BCOLS IS FULL        
C        
  110 IF (K2 .LT. NK) GO TO 330        
C        
C     CALCULATE NEW NEXT TIME USED VALUES        
C        
      IF (FIRST3) GO TO 130        
      FIRST2 = .FALSE.        
      FIRST3 = .TRUE.        
      DO 120 JJ = 1,J        
  120 CALL FWDREC (*5002,SCR2)        
  130 FILE = SCR2        
      KC = 0        
      KN = KF        
      DO 170 KA = 1,NCB        
      KN = KN + 1        
      IF (J .GE. IZ(KN)) GO TO 140        
      KC = KC + 1        
      IF (J+1 .LT. IZ(KN   )) GO TO 135        
      IF (J+1 .LT. IZ(KL+KA)) GO TO 160        
      IZ(KN2+KA) = 99999999        
      GO TO 136        
  135 IZ(KN2+KA) = IZ(KN)        
  136 KC = KC + 1        
      GO TO 170        
  140 IF (J .LT. IZ(KL+KA)) GO TO 150        
      IZ(KN) = 99999999        
      IZ(KN2+KA) = IZ(KN)        
      KC = KC + 2        
      GO TO 170        
  150 IZ(KN    ) = 0        
  160 IZ(KN2+KA) = 0        
  170 CONTINUE        
      IF (KC .EQ. 2*NCB) GO TO 240        
      JJ = J + 1        
  180 CALL READ (*5002,*210,SCR2,KA,1,0,KK)        
      IF (IZ(KN2+KA) .GT. 0) GO TO 180        
      IF (JJ .EQ. J+1) GO TO 190        
      IZ(KN2+KA) = JJ        
      KC = KC + 1        
  190 IF (IZ(KF+KA) .GT. 0) GO TO 200        
      IZ(KF+KA) = JJ        
      KC = KC + 1        
  200 IF (KC .EQ. 2*NCB) GO TO 220        
      GO TO 180        
  210 JJ = JJ + 1        
      GO TO 180        
  220 MM = M - 1        
      IF (J .EQ. MM) GO TO 290        
C        
C     POSITION SCRATCH FILE FOR NEXT PASS THROUGH        
C        
      JJ  = JJ - J        
      J2  = J  + 2        
      JJ1 = JJ - 1        
      IF (J2 .LT. JJ1) GO TO 250        
      IF (JJ1 .GT.  0) GO TO 270        
  230 CALL FWDREC (*5002,SCR2)        
      GO TO 290        
  240 IF (J .EQ. M) GO TO 290        
      GO TO 230        
  250 CALL REWIND (SCR2)        
      J1 = J + 1        
      DO 260 JFWD = 1,J1        
  260 CALL FWDREC (*5002,SCR2)        
      GO TO 290        
  270 DO 280 JBCK = 1,JJ1        
  280 CALL BCKREC (SCR2)        
C        
C     ASSIGN NEXT TIME USED TO COLUMNS OF B IN CORE        
C        
  290 DO 300 KK = 1,NK        
      I = IZ(KBC+KK)        
  300 IZ(KBN+KK) = IZ(KF+I)        
C        
C     ASSIGN NEXT TIME USED TO NON-ZERO TERMS IN COLUMN OF A        
C        
      DO 320 KK = 1,K        
      IF (IZ(KT+KK) .EQ. 0) GO TO 310        
      I = IZ(KT+KK)        
      IZ(KAN+KK) = IZ(KF+I)        
      GO TO 320        
  310 IZ(KAN+KK) = 0        
  320 CONTINUE        
C        
C     PERFORM MULTIPLICATION AND SUMMATION FOR NEXT TERM OF COLUMN OF A 
C        
  330 CALL MPY3C (Z,Z,Z)        
C        
C     TEST IF PROCESSING OF BA(J) IS COMPLETE        
C        
      IF (KCOUNT .EQ. K) GO TO 340        
      IF (FIRST2) GO TO 110        
      IZ(KBN+LTBC) = IZ(KN2+LTAC)        
      GO TO 330        
C        
C     PACK COLUMN OF C OR BA.        
C        
  340 IF (CODE .EQ. 0) GO TO 350        
      CALL PACK (Z(IC),FILEC,FILEC)        
      GO TO 360        
  350 CALL PACK (Z(IC),SCR3,SCR3)        
  360 CONTINUE        
C        
C     CLOSE FILES.        
C        
      CALL CLOSE (FILEA,2)        
      CALL CLOSE (SCR1,1)        
      CALL CLOSE (SCR2,1)        
      IF (.NOT.E) GO TO 369        
      CALL CLOSE (FILEE,2)        
  369 IF (CODE .EQ. 0) GO TO 370        
      CALL CLOSE (FILEC,1)        
      GO TO 9999        
  370 CALL CLOSE (SCR3,1)        
      CALL WRTTRL (SCR3)        
C        
C     CALL MPYAD TO FINISH PRODUCT        
C        
      DO 380 I = 1,7        
      MFILEA(I) = FILEA(I)        
      MFILEB(I) = SCR3(I)        
      MFILEE(I) = FILEE(I)        
  380 MFILEC(I) = FILEC(I)        
      MT     = 1        
      SIGNAB = 1        
      SIGNC  = 1        
      MPREC  = PREC        
      MSCR   = SCR1        
      CALL MPYAD (Z,Z,Z)        
      GO TO 9999        
C        
C     ERROR MESSAGES.        
C        
 5001 NERR = -1        
      GO TO 6000        
 5002 NERR = -2        
      GO TO 6000        
 5008 NERR = -8        
      FILE = 0        
 6000 CALL MESAGE (NERR,FILE,NAME)        
C        
 9999 RETURN        
      END        
