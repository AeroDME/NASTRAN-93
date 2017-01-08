      SUBROUTINE OPTPR1        
C        
C     THIS ROUTINE IS THE DRIVER FOR PROPERTY OPTIMIZATION, PHASE 1.    
C        
C        
C     OPTPR1  MPT,EPT,ECT,DIT,EST/OPTP1/V,N,PRINT/V,N,TSTART/        
C                                       V,N,COUNT $        
C        
C     WHERE PRINT  = OUTPUT, INTEGER = 1        
C           TSTART = OUTPUT, INTEGER = TIME AT EXIT OF OPTPR1.        
C           COUNT  = OUTPUT, INTEGER =-1 NOT PROPERTY OPTIMIZATION.     
C                                    = 1 IS  PROPERTY OPTIMIZATION.     
C     CRITERIA FOR OPTIMIZATION        
C        
C        1. OUTPUT FILE NOT PURGED.        
C        2. BULK DATA CARD -POPT IS PRESENT.        
C           AFTER THESE TESTS ALL ERRORS ARE FATAL.        
C        
C        
C      SUBROUTINES USED        
C        
C      OPTP1A - READS ELEMENT DATA INTO CORE (NWDSE PER ELEMENT).       
C      OPTP1B - READS PROPERTY IDS INTO CORE AND SETS ELEMENT DATA      
C               POINTER (V1) TO ITS LOCATION. (NWDSP PER PROPERTY).     
C      OPTP1C - READS DESIGN PROPERTIES INTO CORE.        
C      OPTP1D - READS PLIMIT DATA INTO CORE AND SETS PROPERTY DATA      
C               POINTER (PLIM) TO ITS LOCATION. (NWDSK PER LIMIT)       
C        
C        
C     LOGICAL         DEBUG        
      INTEGER         DATTYP(21),DATDTY(90),DTYP(90),SYSBUF,B2,B1P1,    
     1                NAME(2),CREW,FILE,YCOR,PCOR1,ECOR1,PRCOR1,FNAM(2),
     2                PRINT,COUNT,POPH(2),HPOP(2),PLMH(2),NONE(2),      
     3                EPT,ECT,DIT,EST,OPTP1,OUTTAP,Y(1),SCRTH1,ZCOR,    
     4                PCOR2,TSTART        
      REAL            X(7)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG / UFM,UWM,UIM,SFM        
      COMMON /BLANK / PRINT,TSTART,COUNT,SKP(2),YCOR,B1P1,NPOW,        
     1                NELW,NWDSE,NPRW,NWDSP,NKLW,MPT,EPT,ECT,DIT,EST,   
     2                OPTP1,SCRTH1,NELTYP,ITYPE(21)        
      COMMON /OPTPW1/ ZCOR,Z(100)        
CZZ   COMMON /ZZOPT1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /NAMES / NRD,NRREW,NWRT,NWREW,CREW        
      COMMON /SYSTEM/ SYSBUF,OUTTAP        
      COMMON /GPTA1 / NTYPES,LAST,INCR,NE(1)        
      EQUIVALENCE     (X(1),CORE(1)), (X(7),Y(1))        
C     DATA    DEBUG / .FALSE. /        
      DATA    POPH  , PLMH / 404,4, 304,3 /,  NAME / 4H OPT,3HPR1 /,    
     1        HPOP  / 4H   P,4HOPT  /      ,  NONE / 4H (NO,4HNE) /,    
     2        LTYPE / 90 /  ,NUMTYP / 20  /        
C        
C     NELTYP      = NO. ELEMENT TYPES THAT MAY BE OPTIMIZED        
C     LTYPE       = DIMENSION OF DATDTY AND DTYP        
C     DATTYP/DTYP = ARRAY TO GIVE RELATIVE LOCATIONS OF ELEMENTS IN     
C                   /GPTA1/        
C        
      DATA    DATTYP/        
     1        34, 81, 80, 16, 62, 63, 15, 19, 18, 1,  4,  7,  6,  17,   
C             BR  EB  IS  QM  M1  M2  QP  Q1  Q2  RD  SH  TB  T1  T2    
     2        73,  9,  8,  3, 64, 83,  0 /        
C             T6  TM  TP  TU  Q4  T3        
C        
C     SETUP DATDYP/DTYP IN ALPHABETICAL ORDER AND IN /GPTA1/ SEQUENCE   
C        
      DATA    DATDTY  / 10, 0, 18, 11,  0, 13, 12, 17, 16,  0        
C             ELEMENT   RD  2  TU  SH   5  T1  TB  TP  TM  10        
     1,                 4*0  ,  7,  4, 14,  9,  8,  0        
C             ELEMENT   11-14  QP  QM  T2  Q2  Q1  20        
     2,                 10*0        
C             ELEMENT   21-30        
     3,                 3*0  ,  1,   6*0        
C             ELEMENT   31-33  BR   35-40        
     4,                 10*0        
C             ELEMENT   41-50        
     5,                 10*0        
C             ELEMENT   51-60        
     6,                  0, 5,  6,  19,  6*0        
C             ELEMENT   61 M1  M2   Q4  65-70        
     7,                 2*0,   15,  6*0,   3        
C             ELEMENT   71-72  T6  74-79  D8        
     8,                  2, 0, 20,  7*0 /        
C             ELEMENT   EB 82  T3  84-90        
C        
C     SET UP ELEMENT TYPES        
C        
      NELTYP = NUMTYP        
      DO 1 I = 1,21        
      IF (NTYPES .GT. LTYPE) GO TO 140        
    1 ITYPE(I) = DATTYP(I)        
      DO 2 I = 1,NTYPES        
    2 DTYP(I) = DATDTY(I)        
C        
C        
      ZCOR  = 100        
      MPT   = 101        
      EPT   = 102        
      ECT   = 103        
      DIT   = 104        
      EST   = 105        
      OPTP1 = 201        
      SCRTH1= 301        
C        
C     STEP 1.  INITIALIZE AND CHECK FOR OUTPUT FILE        
C        
      COUNT = 0        
      PRINT = 1        
      CALL FNAME (OPTP1,FNAM)        
      IF (FNAM(1).EQ.NONE(1) .AND. FNAM(2).EQ.NONE(2)) GO TO 120        
C        
      B1P1  = KORSZ(CORE(1)) - SYSBUF        
      B2    = B1P1 - SYSBUF        
      YCOR  = B2 - 7        
      PCOR1 =-1        
      ECOR1 =-1        
      PRCOR1=-1        
      KCOR1 =-1        
      NWDSE = 5        
      NWDSP = 6        
      NPOW  = NELTYP        
      CALL DELSET        
C        
C     STEP 2.  FIND POPT CARD        
C        
      CALL PRELOC (*120,X(B1P1),MPT)        
      CALL LOCATE (*110,X(B1P1),POPH,I)        
      CALL READ (*10,*30,MPT,X,7,1,NWDS)        
C        
C     ILLEGAL NUMBER OF WORDS        
C        
   10 CALL PAGE2 (-2)        
      WRITE  (OUTTAP,20) SFM,NAME,NWDS,HPOP        
   20 FORMAT (A25,' 2288, ',2A4,'READ INCORRECT NUMBER WORDS (',I2,2A4, 
     1        2H).)        
      GO TO 80        
C        
   30 IF (NWDS.NE.6) GO TO 10        
C        
C     STEP 2A.  PROCESS PLIMIT CARDS ON SCRATCH FILE        
C        
      IF (YCOR .LE. 11) GO TO 60        
      NKLW = 0        
      CALL LOCATE (*40,X(B1P1),PLMH,I)        
      CALL GOPEN (SCRTH1,X(B2),NWREW)        
      CALL OPTPX (DTYP)        
      CALL CLOSE (SCRTH1,CREW)        
C     CALL DMPFIL (SCRTH1,Y(1),YCOR)        
   40 CALL CLOSE (MPT,CREW)        
      IF (NKLW    .LT. 0) GO TO 60        
      IF (COUNT+1 .EQ. 0) GO TO 80        
C        
C     STEP 3.  LOAD MATERIAL DATA        
C        
      CALL PREMAT (Y(1),Y(1),X(B1P1),YCOR,MCOR,MPT,DIT)        
      PCOR1 = MCOR  + 1        
      PCOR2 = PCOR1 + NTYPES        
      ECOR1 = PCOR2 + 2*(NPOW+1)        
      YCOR  = YCOR  - ECOR1        
      IF (YCOR .LT. (NWDSE+NWDSP)) GO TO 60        
C        
C     STEP 4.  READ ELEMENTS INTO CORE        
C        
      CALL GOPEN (EST,X(B2),0)        
      CALL OPTP1A (Y(PCOR1),Y(PCOR2),Y(ECOR1),DTYP)        
      CALL CLOSE (EST,CREW)        
C     IF (DEBUG) CALL BUG (NAME(1),4,Y(ECOR1),NELW)        
C     IF (DEBUG) CALL BUG (NAME(2),41,Y(PCOR1),NTYPES)        
      IF (COUNT+1 .EQ. 0) GO TO 80        
      IF (NELW    .LE. 0) GO TO 60        
C        
C     STEP 5.  READ IN PROPERTIES IDS, SET V1.  SECOND BUFFER NOT NEEDED
C        
      PRCOR1 = ECOR1 + NELW        
      YCOR   = YCOR  - NELW + SYSBUF        
      IF (YCOR .LT. NWDSP) GO TO 60        
      FILE = ECT        
      CALL PRELOC (*90,X(B1P1),ECT)        
      CALL OPTP1B (Y(PCOR1),Y(PCOR2),Y(ECOR1),Y(PRCOR1))        
      CALL CLOSE (ECT,CREW)        
C     IF (DEBUG) CALL BUG (NAME(1),50,Y(PCOR2),ECOR1-PCOR2)        
C     IF (DEBUG) CALL BUG (4HPROP,51,Y(PRCOR1),NPRW)        
C     IF (DEBUG) CALL BUG (4HELEM,52,Y(ECOR1),NELW)        
      IF (COUNT+1 .EQ. 0) GO TO 60        
      IF (NPRW    .LE. 0) GO TO 80        
C        
C     STEP 6.  READ PROPERTY DATA INTO CORE        
C        
      KCOR1 = PRCOR1 + NPRW        
      YCOR  = YCOR   - NPRW        
C        
      FILE = EPT        
      CALL PRELOC (*90,X(B1P1),EPT)        
      CALL OPTP1C (Y(PCOR1),Y(PCOR2),Y(PRCOR1))        
      CALL CLOSE (EPT,CREW)        
C     IF (DEBUG) CALL BUG (NAME(2),6,Y(PRCOR1),NPRW)        
      IF (COUNT+1 .EQ.0) GO TO 80        
C        
C     STEP 7.  PROCESS PLIMIT CARDS        
C        
      IF (NKLW .LE. 0) GO TO 50        
      IF (YCOR .LT. 4) GO TO 60        
      CALL GOPEN (SCRTH1,X(B1P1),NRREW)        
      CALL OPTP1D (Y(PCOR2),Y(PRCOR1),Y(KCOR1))        
      CALL CLOSE (SCRTH1,CREW)        
      IF (NKLW    .LT. 0) GO TO 60        
      IF (COUNT+1 .EQ. 0) GO TO 80        
C        
C     STEP 7.  COUNT=0, OUTPUT FILE OPTPR1        
C        
   50 FILE = OPTP1        
      CALL OPEN  (*90,OPTP1,X(B1P1),NWREW)        
      CALL WRITE (OPTP1,FNAM,2,0)        
      CALL WRITE (OPTP1,X(1),6,1)        
C        
      CALL WRITE (OPTP1,Y(PCOR1),NTYPES,0)        
      CALL WRITE (OPTP1,NPOW,1,0)        
      CALL WRITE (OPTP1,Y(PCOR2),2*(NPOW+1),1)        
      CALL WRITE (OPTP1,Y(ECOR1),NELW,1)        
      CALL WRITE (OPTP1,Y(PRCOR1),NPRW,1)        
      CALL WRITE (OPTP1,Y(KCOR1),NKLW,1)        
      CALL EOF   (OPTP1)        
      J      = 0        
      Y(J+1) = OPTP1        
      Y(J+2) = 0        
      Y(J+3) = NELW        
      Y(J+4) = NPRW        
      Y(J+5) = NKLW        
      Y(J+6) = 0        
      Y(J+7) = NTYPES        
      CALL WRTTRL (Y(1))        
      CALL CLOSE (OPTP1,CREW)        
      GO TO 130        
C        
C     ERROR MESSAGES - FILE NOT CREATED        
C        
C     INSUFFICIENT CORE        
C        
   60 CALL PAGE2 (-3)        
      WRITE  (OUTTAP,70) UFM,NAME,B1P1,PCOR1,ECOR1,PRCOR1,KCOR1        
   70 FORMAT (A23,' 2289, ',2A4,'INSUFFICIENT CORE (',I10,2H ), /9X,I9, 
     1       ' = MATERIAL',I9,' = POINTERS',I9,' = ELEMENTS',I9,        
     2       ' = PROPERTIES')        
   80 CALL MESAGE(-61,EPT,NAME)        
C        
C    INPUT FILE PURGED - ILLEGALLY        
C        
   90 CALL MESAGE (-1,FILE,NAME)        
C        
C    OPTPR1 NOT CREATED        
C        
  110 CALL CLOSE (MPT,CREW)        
  120 COUNT = -1        
C        
C     OPTPR1 CREATED        
C        
  130 CONTINUE        
      CALL KLOCK (TSTART)        
      RETURN        
C        
C     ERROR MESSAGE        
C        
  140 WRITE  (OUTTAP,150) SFM        
  150 FORMAT (A25,', DATDTY AND DTYP ARRAYS TOO SMALL')        
      CALL MESAGE (-37,0,NAME)        
      END        
