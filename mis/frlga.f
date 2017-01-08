      SUBROUTINE FRLGA (DLT,FRL,CASECC,DIT,PP,LUSETD,NFREQ,NLOAD,       
     1                  FRQSET,FOL,NOTRD)        
C        
C     THIS ROUTINE GENERATES LOADS INCORE AT EACH FREQUENCY        
C        
C     WITH ENTRY POINTS - GUST1A AND FRRD1A        
C                         ======     ======        
C        
      INTEGER         SYSBUF,DLT,FRL,CASECC,DIT,PP,FRQSET,ICORE(14),    
     1                FILE,MCB(7),IHEAD(8),ITLIST(13),NAME(6),FOL       
      REAL            FX(2)        
      COMPLEX         POW,EB,R2,R1        
      DIMENSION       HEAD(8)        
      COMMON /SYSTEM/ KSYSTM(55)        
      COMMON /BLANK / XX        
      COMMON /PACKX / IT1,IT2,II,JJ,INCR        
CZZ   COMMON /ZZFRA1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /CONDAS/ PI,TWOPHI,RADEG,DEGRA,S4PISQ        
      COMMON /FRRDST/ OVR(152),ITL(3)        
      EQUIVALENCE     (CORE(1),ICORE(1)), (HEAD(1),IHEAD(1),ISIL),      
     1                (HEAD(2),A), (HEAD(3),TAU), (HEAD(4),THETA),      
     1                (KSYSTM(1),SYSBUF), (KSYSTM(55),IPREC)        
      DATA    ITLIST/ 4,1105,11,1,1205,12,2,1305,13,3,1405,14,4 /       
      DATA    NAME  / 4HDLT ,4HFRLG,4HA   ,4HGUST,4H1A  ,4HFRRD /       
      DATA    IFRL  / 4HFRL /        
C        
C     IDENTIFICATION OF VARIABLES        
C        
C     NFREQ  = NUMBER OF FREQ IN SELECTED FREQ SET        
C     NDONE  =  NUMBER OF FREQUENCIES CURRENTLY BUILT FOR CUR LOAD      
C     LLIST  = POINTER TO START OF LOAD TABLE        
C     ITABL  = POINTER TO START OF LIST OF TABLES NEEDED FOR CURRENT    
C              LOAD        
C     ILOAD  = POINTER TO BEGINNING OF LOADS IN CORE        
C     IFL    = POINTER TO VALUES OF FREQ  FUNCTIONS        
C     NBUILD = NUMBER OF FREQUENCIES WHICH CAN BE BUILT AT ONCE        
C     NLOAD  = NUMBER OF LOADS FOUND IN CASE CONTROL        
C     LCORE  = AMOUNT OF CORE AVAILABLE TO HOLD  LOADS + F(F)-S        
C     FRQSET = SELECT FREQUENCY SET ID        
C     LOADN  = SELECTED DYNAMIC LOAD        
C     NDLOAD = NUMBER OF DLOAD CARDS        
C     NSIMPL = NUMBER OF SIMPLE LOADS        
C     NSUBL  = NUMBEL OF  SIMPLE LOADS COMPOSING PRESENT LOAD        
C     NTABL  = NUBER OF TABLE ID-S IN PRESENT LOAD        
C     ICDTY  = CARD TYPE CODE  1=RLOAD1,  2=RLOAD2        
C        
C        
      GO TO 2        
C        
C        
      ENTRY GUST1A (DLT,FRL,CASECC,DIT,PP,LUSETD,NFREQ,NLOAD,        
     1              FRQSET,FOL,NOTRD)        
C     =======================================================        
C        
      NAME(2) = NAME(4)        
      NAME(3) = NAME(5)        
      GO TO 2        
C        
C        
      ENTRY FRRD1A (DLT,FRL,CASECC,DIT,PP,LUSETD,NFREQ,NLOAD,        
     1              FRQSET,FOL,NOTRD)        
C     =======================================================        
C        
      NAME(2) = NAME(6)        
      NAME(3) = NAME(5)        
C        
C        
C     INITALIZE        
C        
    2 IT1   = 3        
      IT2   = 2 + IPREC        
      II    = 1        
      JJ    = LUSETD        
      INCR  = 1        
      NOTRD =-1        
      LCORE = KORSZ(CORE(1))        
C        
C     PICK UP AND STORE FREQUENCY SET        
C        
      IBUF  = LCORE - SYSBUF + 1        
      NZ1   = IBUF  - 1        
      LCORE = LCORE - 2*SYSBUF        
      NZ    = LCORE        
      IGUST = 0        
      IF (CASECC .GT. 0) GO TO 5        
      CASECC = IABS(CASECC)        
      IGUST  = 1        
    5 CONTINUE        
      FILE   = CASECC        
      CALL OPEN (*510,CASECC,CORE(IBUF),0)        
      CALL FWDREC (*530,CASECC)        
      CALL FREAD  (CASECC,CORE,149,0)        
      FRQSET = ICORE(14)        
      NLOAD  = 0        
      LOADN  = ICORE(13)        
      CALL CLOSE (CASECC,1)        
      ITL(1) = 2        
      I149   = 149        
      ITL(2) = ICORE(I149)        
      ITL(3) = ITL(2) + 1        
      ITLD   = 1        
C        
C     BRING IN AND SAVE FREQ LIST -- CONVERT  W-S TO F    F = TWOPHI* W 
C        
      FILE  = FRL        
      CALL OPEN (*510,FRL,CORE(IBUF),0)        
      CALL READ (*530,*10,FRL,CORE(1),NZ1,0,IFLAG)        
      GO TO 540        
   10 DO 20 I = 3,IFLAG        
      IF (ICORE(I) .EQ. FRQSET) GO TO 30        
   20 CONTINUE        
      NAME(1) = IFRL        
      CALL MESAGE (-31,FRQSET,NAME)        
   30 K = I-3        
      IF (K .EQ. 0) GO TO 50        
      DO 40 I = 1,K        
      CALL FWDREC (*530,FRL)        
   40 CONTINUE        
C        
C     READ IN  FREQ LIST        
C        
   50 CALL READ (*530,*60,FRL,CORE(1),NZ1,0,NFREQ)        
      GO TO 540        
   60 CALL CLOSE (FRL,1)        
      LCORE = LCORE - NFREQ        
      NZ1   = NZ1   - NFREQ        
      FRQSET= K + 1        
      LLIST = NFREQ + 1        
C        
C     CONVERT TO F        
C        
      DO 70 I = 1,NFREQ        
      CORE(I) = CORE(I)/TWOPHI        
   70 CONTINUE        
C        
C     PUT HEADER ON LOAD FILE        
C        
      FILE = PP        
      NZ   = IBUF - SYSBUF        
      NZ1  = NZ1  - SYSBUF        
      CALL OPEN (*510,PP,CORE(NZ),1)        
      CALL FNAME (PP,MCB(1))        
      CALL WRITE (PP,MCB(1),2,0)        
      CALL WRITE (PP,CORE(1),NFREQ,1)        
      FILE = FOL        
      CALL OPEN (*71,FOL,CORE(IBUF),1)        
      CALL FNAME (FOL,MCB)        
      CALL WRITE (FOL,MCB,2,0)        
      CALL WRITE (FOL,CORE,NFREQ,1)        
      CALL CLOSE (FOL,1)        
      MCB(1) = FOL        
      MCB(2) = NFREQ        
      MCB(3) = FRQSET        
      CALL WRTTRL (MCB)        
   71 CONTINUE        
C        
C     SET UP MCB FOR PP        
C        
      MCB(1) = PP        
      MCB(2) = 0        
      MCB(3) = LUSETD        
      MCB(4) = 2        
      MCB(5) = 2 + IPREC        
      MCB(6) = 0        
      MCB(7) = 0        
C        
C     BEGIN LOOP ON LOADS SELECTED        
C        
   80 IF (NLOAD .EQ. 0) GO TO 100        
      FILE = CASECC        
      CALL OPEN (*510,CASECC,CORE(IBUF),0)        
      L = NLOAD + 1        
      DO 90 I = 1,L        
      CALL FWDREC (*530,CASECC)        
   90 CONTINUE        
      CALL READ (*500,*540,CASECC,CORE(LLIST),16,1,IFLAG)        
      LOADN = ICORE(LLIST+12)        
      CALL CLOSE (CASECC,1)        
  100 NLOAD = NLOAD + 1        
      IF (LOADN .EQ. 0) GO TO 491        
      NDONE = 0        
      LCORE = NZ1        
C        
C     FIND SELECTED LOAD IN DLT        
C        
      FILE = DLT        
      CALL OPEN (*510,DLT,CORE(IBUF),0)        
      CALL READ (*530,*110,DLT,CORE(LLIST),NZ1,0,IFLAG)        
C        
C     IS IT A DLOAD SET        
C        
  110 NDLOAD = ICORE(LLIST+2)        
      NSIMPL = IFLAG - 3 - NDLOAD        
      IF (NSIMPL .EQ. 0) CALL MESAGE (-31,LOADN,NAME)        
      IF (NDLOAD .EQ. 0) GO TO 300        
      K = LLIST + 2        
      DO 120 I = 1,NDLOAD        
      K = K + 1        
      IF (ICORE(K) .EQ. LOADN) GO TO 130        
  120 CONTINUE        
      GO TO 300        
C        
C     PROCESS DLOAD SET        
C        
C     FORMAT OF DLOAD CARD = SET ID, SCALE,SCALE,ID, SCALE, ID, ...,0,-1
C        
  130 NZ1 = NZ1 - IFLAG        
C        
C     BRING IN ALL DLOADS        
C        
      L = LLIST + IFLAG        
      CALL READ (*530,*140,DLT,CORE(L),NZ1,0,I)        
      GO TO 540        
C        
C     FIND SELECTED ID        
C        
  140 ISEL  = L        
  150 IF (ICORE(ISEL) .EQ. LOADN) GO TO 170        
  160 ISEL = ISEL + 2        
      IF (ICORE(ISEL+1) .NE. -1) GO TO 160        
      ISEL = ISEL + 2        
      GO TO 150        
C        
C     FOUND LOAD SET  SELECTED        
C        
  170 SCALE  = CORE(ISEL+1)        
C        
C     CONVERT  SCALE FACTORS TO OVERALL  SCALE +ID-S TO RECORD NUMBERS-1
C        
      L = ISEL + 2        
      NSUBL = 0        
  180 CORE(L) = CORE(L)*SCALE        
      K = LLIST + 2 + NDLOAD        
      DO 190 I = 1,NSIMPL        
      K = K + 1        
      IF (ICORE(L+1) .EQ. ICORE(K)) GO TO 200        
  190 CONTINUE        
      CALL MESAGE (-31,ICORE(L),NAME)        
C        
C     FOUND SIMPLE ID        
C        
  200 ICORE(L+1) = I + 1        
      NSUBL = NSUBL + 1        
      L = L + 2        
      IF (ICORE(L+1) .GE. 0) GO TO 180        
C        
C     MOVE TO LOAD LIST AREA        
C        
      L = ISEL + 2        
      K = LLIST        
      DO 210 I = 1,NSUBL        
      ICORE(K)  = ICORE(L+1)        
      CORE(K+1) = CORE(L)        
      L = L + 2        
      K = K + 2        
  210 CONTINUE        
C        
C     BUILD LIST OF UNIQUE TABLES NEEDED FOR NSUBL LOADS        
C        
      IPOS  = 2        
  230 NTABL = 0        
      ITABL = LLIST + 2*NSUBL        
      DO 290 I = 1,NSUBL        
      K = LLIST + (I-1)*2        
      J = ICORE(K)        
      L = J - IPOS        
      IF (L .EQ. 0) GO TO 250        
      DO 240 K = 1,L        
      CALL FWDREC (*530,DLT)        
  240 CONTINUE        
C        
C     READ IN DESCRIPTOR WORDS        
C        
  250 IPOS = J + 1        
      CALL READ (*530,*550,DLT,HEAD(1),8,1,IFLAG)        
      ICDTY = IHEAD(1)        
      NT    = 4        
      GO TO (251,251,252,291), ICDTY        
C        
C     TLOAD 1 CARD        
C        
  252 NT    = 3        
      ITLD  = 2        
      NOTRD = 1        
  251 CONTINUE        
      DO 280 M = 3,NT        
      IF (IHEAD(M) .EQ. 0) GO TO 280        
      IF( NTABL    .EQ. 0) GO TO 270        
      DO 260 K = 1,NTABL        
      L  = ITABL+K        
      IF (ICORE(L) .EQ. IHEAD(M)) GO TO 280        
  260 CONTINUE        
C        
C     STORE NEW TABLE ID        
C        
  270 NTABL = NTABL + 1        
      K = ITABL + NTABL        
      ICORE(K) = IHEAD(M)        
  280 CONTINUE        
      GO TO 290        
C        
C     TLOAD2 CARD        
C        
  291 CONTINUE        
      NOTRD = 1        
  290 CONTINUE        
      CALL REWIND (DLT)        
      LCORE = LCORE - NTABL - 1        
      ILOAD = ITABL + NTABL + 1        
      ICORE(ITABL)  = NTABL        
      GO TO 330        
C        
C     PROCESS SIMPLE LOAD REQUEST        
C        
  300 NSUBL = 1        
      CORE(LLIST+1) = 1.0        
      L = LLIST + 2 + NDLOAD        
      DO 310 I = 1,NSIMPL        
      L = L + 1        
      IF (ICORE(L) .EQ. LOADN) GO TO 320        
  310 CONTINUE        
      CALL MESAGE (-31,LOADN,NAME)        
C        
C     FOUND SIMPLE LOAD  STORE RECORD NUMBER        
C        
  320 IF (NDLOAD .NE. 0) I = I + 1        
      ICORE(LLIST) = I        
      IPOS  = 1        
      LCORE = LCORE - 2        
      GO TO 230        
C        
C     ALLOCATE CORE        
C        
  330 LVECT  = 2*LUSETD        
      NBUILD = LCORE/(LVECT+NTABL*ITLD)        
      NBUILD = MIN0(NBUILD,NFREQ)        
      IF (NBUILD .EQ. 0) GO TO 540        
      KK  = NTABL*NBUILD        
      IFL = NZ - NTABL*NBUILD*ITLD        
C        
C     LOOP HERE FOR FREQUENCY SPILL        
C        
      LCORE = LCORE - NTABL*NBUILD        
      NBUF  = LCORE - SYSBUF        
      IF (NTABL .EQ. 0) GO TO 361        
  340 CALL PRETAB (DIT,CORE(ILOAD),CORE(ILOAD),CORE(NBUF),NBUF,L,       
     1             CORE(ITABL),ITLIST(1))        
      DO 360 J = 1,NTABL        
      L = ITABL + J        
      DO 350 I = 1,NBUILD        
      M = NDONE + I        
      K = IFL + NBUILD*(J-1) + I - 1        
      IF (ITLD .EQ. 2) GO TO 341        
C        
C                 TAB      X       F(X)        
      CALL TAB (CORE(L),CORE(M),CORE(K))        
      GO TO 350        
C        
C     TRANSFOR LOOK UP FOR TLOAD 1 CARDS        
C        
  341 CONTINUE        
      CALL TAB1 (CORE(L),CORE(M),FX(1))        
      CORE(K   ) = FX(1)        
      CORE(K+KK) = FX(2)        
      GO TO 350        
  350 CONTINUE        
  360 CONTINUE        
  361 CONTINUE        
C        
C     READY CORE FOR BUILDING LOADS        
C        
      K = ILOAD - 1        
      DO 380 I = 1,NBUILD        
      DO 370 L = 1,LVECT        
      K = K + 1        
      CORE(K) = 0.0        
  370 CONTINUE        
  380 CONTINUE        
C        
C     POSITION TO LOAD IN DLT        
C        
      IPOS = 0        
      DO 480 I = 1,NSUBL        
      K = LLIST + 2*I - 2        
      L = ICORE(K) - IPOS        
      SCALE = CORE(K+1)        
      IF (L  .EQ. 0) GO TO 400        
      DO 390 J = 1,L        
      CALL FWDREC (*530,DLT)        
  390 CONTINUE        
C        
C     READ IN 8 WORD LOAD ID        
C        
  400 IPOS  = L + 1 + IPOS        
      CALL READ (*530,*540,DLT,HEAD(1),8,0,IFLAG)        
      ICDTY = IHEAD(1)        
      TK1   = HEAD(3)        
      TK2   = HEAD(4)        
      NT    = 4        
      GO TO (404,404,403,435), ICDTY        
  403 NT    = 3        
C        
C     FIND COEFFICIENTS IN TABLE LIST        
C        
  404 DO 430 K = 3,NT        
      IF (IHEAD(K) .NE. 0) GO TO 405        
      IHEAD(K+3) = -1        
      GO TO 430        
  405 DO 410 L = 1,NTABL        
      M = ITABL + L        
      IF (ICORE(M) .EQ. IHEAD(K)) GO TO 420        
  410 CONTINUE        
      GO TO 550        
C        
C     COMPUTE POINTER INTO COEF TABLE        
C        
  420 IHEAD(K+3) = IFL + (L-1)*NBUILD        
      IF (ICDTY .EQ. 3) IHEAD(K+4) = IFL + (L-1)*NBUILD + NTABL*NBUILD  
  430 CONTINUE        
C        
C     REPEATLY READ IN  4  WORDS --SIL,A,TAU,THETA        
C        
  435 IGUST1 = 0        
  440 CONTINUE        
      IF (IGUST  .EQ. 0) GO TO 442        
      IF (IGUST1 .EQ. 1) GO TO 480        
      IGUST1 = 1        
  442 CONTINUE        
      CALL READ (*530,*480,DLT,IHEAD(1),4,0,IFLAG)        
      IF (IGUST .EQ. 0) GO TO 443        
      ISIL  = 1        
      A     = 1.0        
      TAU   = 0.0        
      THETA = 0.0        
  443 CONTINUE        
      A     = A*SCALE        
      THETA = THETA*DEGRA        
      DO 470 J = 1,NBUILD        
      IF (ICDTY .EQ. 4) GO TO 448        
C        
C     COMPUTE COEFFICIENTS        
C        
      C1 = 0.0        
      IF (IHEAD(6) .LT. 0) GO TO 445        
      K  = IHEAD(6) + J - 1        
      C1 = CORE(K)        
  445 C2 = 0.0        
      IF (IHEAD(7) .LT. 0) GO TO 448        
      K  = IHEAD(7) + J - 1        
      C2 = CORE(K)        
  448 L  = NDONE + J        
      M  = (J-1)*LVECT + 2*ISIL - 2 + ILOAD        
      GO TO (450,460,450,471), ICDTY        
C        
C     RLOAD 1 CARDS OF TLOAD1 CARDS        
C        
  450 XLAMA = THETA - CORE(L)*TAU*TWOPHI        
      SINXL = SIN(XLAMA)        
      COSXL = COS(XLAMA)        
      CORE(M  ) = A*(C1*COSXL - C2*SINXL) + CORE(M  )        
      CORE(M+1) = A*(C1*SINXL + C2*COSXL) + CORE(M+1)        
      GO TO 470        
C        
C     RLOAD2  CARDS        
C        
  460 XLAMA = THETA - CORE(L)*TAU*TWOPHI + C2*DEGRA        
      CORE(M  ) = A*C1*COS(XLAMA) + CORE(M  )        
      CORE(M+1) = A*C1*SIN(XLAMA) + CORE(M+1)        
      GO TO 470        
C        
C     TLOAD 2 CARDS        
C        
  471 CONTINUE        
      F   = HEAD(5)        
      P   = HEAD(6)*DEGRA        
      C   = HEAD(7)        
      IB  = HEAD(8)  +.5        
      DT  = TK2 - TK1        
      RZ  =-C*DT        
      CZ  =-DT*(F-CORE(L))*TWOPHI        
C        
C     COMPUTE  E(B+1) (ZR2)        
C        
      CALL FRR1A1 (RZ,CZ,IB+1,REB,CEB)        
      EB = CMPLX(REB,CEB)        
      RP =-RZ        
      CP = P - CORE(L)*TWOPHI*TK2 + TWOPHI*F*DT        
      POW= CMPLX(RP,CP)        
      R2 = CEXP(POW)*EB        
C        
C     COMPUTE  R1        
C        
      CZ = -DT*(-F -CORE(L))*TWOPHI        
C        
C     COMPUTE  E(B+1)ZR1        
C        
      CALL FRR1A1 (RZ,CZ,IB+1,REB,CEB)        
      EB  = CMPLX(REB,CEB)        
      CP  =-P - CORE(L)*TWOPHI*TK2 - TWOPHI*F*DT        
      POW = CMPLX(RP,CP)        
      R1  = R2 + CEXP(POW)*EB        
C        
C     COMPUTE   P(W)        
      R2  = CMPLX(0.,-CORE(L)*TAU*TWOPHI)        
      POW = R1*CEXP(R2)        
      CP  = (DT**(IB+1))/(2.0 *(HEAD(8)+1.))        
      RZ  = REAL(POW)*A*CP        
      CZ  = AIMAG (POW)*A*CP        
      CORE(M  ) = CORE(M  ) + RZ        
      CORE(M+1) = CORE(M+1) + CZ        
      GO TO 470        
  470 CONTINUE        
      GO TO 440        
C        
C     END OF STUFF IN DLT TABLE        
C        
  480 CONTINUE        
C        
C     PACK OUT LOADS BUILT        
C        
      DO 490 I = 1,NBUILD        
      M = (I-1)*LVECT + ILOAD        
      CALL PACK (CORE(M),PP,MCB(1))        
  490 CONTINUE        
      NDONE  = NDONE  + NBUILD        
      NBUILD = MIN0(NBUILD,NFREQ-NDONE)        
      CALL REWIND (DLT)        
      IF (NBUILD .NE. 0) GO TO 340        
      CALL CLOSE (DLT,1)        
      GO TO 80        
C        
C     BUILD ZERO LOAD        
C        
  491 DO 492 I = 1,NFREQ        
      CALL BLDPK (3,3,PP,0,0)        
      CALL BLDPKN (PP,0,MCB)        
  492 CONTINUE        
      GO TO 80        
C        
C     EOF  ON CASECC  END OF ROUTINE        
C        
  500 CALL CLOSE (CASECC,1)        
      CALL WRTTRL (MCB(1))        
      CALL CLOSE (PP,1)        
      RETURN        
C        
C     ERROR MESAGES        
C        
  510 IP1 = -1        
  520 CALL MESAGE (IP1,FILE,NAME(2))        
  530 IP1 = -2        
      GO TO 520        
  540 IP1 = -8        
      GO TO 520        
  550 IP1 = -7        
      GO TO 520        
      END        
