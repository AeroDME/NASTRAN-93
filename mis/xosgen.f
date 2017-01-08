      SUBROUTINE XOSGEN        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO GENERATE THE OSCAR ARRAY.       
C        
C          ... DESCRIPTION OF PROGRAM VARIABLES ...        
C     IENDF  = FLAG SIGNALING END OF DMAP SEQUENCE.        
C     LDEF   = SCRATCH USED IN SCANNING LBLTBL TABLE.        
C     LBLTOP = TOP OF LBLTBL ARRAY.        
C     LBLBOT = BOTTOM OF LBLTBL ARRAY.        
C     LSTLBL = POINTER TO LAST LABEL ENTRY MADE IN LBLTBL.        
C     LSTPAR = POINTER TO LAST PARAMETER NAME ENTRY MADE IN LBLTBL.     
C     NAMTBL = NAME CONVERSION TABLE FOR TYPE E NAMES.        
C     IEXFLG = FLAG INDICATING LAST OSCAR ENTRY WAS EXIT.        
C     IOSPNT = POINTER TO NEXT AVAILABLE WORD IN OSCAR ENTRY.        
C     NOSPNT = POINTER TO DATA BLOCK NAME COUNT IN OSCAR ENTRY.        
C     NTYPEE = TABLE CONTAINING TYPE E DMAP NAMES        
C     IPRCFO = POINTER TO LAST TYPE F OR O OSCAR ENTRY.        
C     NDIAG1 = NAME OF THE DIAGNOSTIC O/P PROCESSOR        
C     ITYPE  = TABLE FOR TRANSLATING TYPE CODES TO WORD LENGTH        
C     VARFLG = FLAG INDICATING VARIABLE FOUND IN EQUIV OR PURGE        
C              INSTRUCTION.        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,RSHIFT,ANDF,ORF        
      LOGICAL         SKIP        
      DIMENSION       PRECHK(2),XDMAP(2),DECLAR(3),FPARAM(3),        
     1                DMPCRD(1),NSKIP(5,2),CDCOMP(3),NAMTBL(12),        
     2                ITYPE(6),MED(1),LBLTBL(1),OSCAR(1),OS(5)        
      COMMON /XFIAT / FIAT(3)        
      COMMON /SYSTEM/ BUFSZ,OPTAPE,NOGO,DUM(20),ICFIAT,JUNK(54),        
     1                ISWTCH(3),ICPFLG        
      COMMON /MODDMP/ IFLG(6),NAMOPT(26)        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
     1                NMED,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTYPEE(9),        
     3                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL(1)        
      COMMON /XGPI3 / PVT(2)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /XGPI5 / IAPP,START,ALTER(2),SOL,SUBSET,IFLAG,IESTIM,      
     1                ICFTOP,ICFPNT,LCTLFL,ICTLFL(1)        
      COMMON /XGPI6 / MEDTP,FNMTP,CNMTP,MEDPNT,LMED,IPLUS,DIAG14,DIAG17,
     1                DIAG4,DIAG25,IFIRST,IBUFF(20)        
      COMMON /XGPI7 / FPNT,LFILE,FILE(1)        
      COMMON /XGPID / ICST,IUNST,IMST,IHAPP,IDSAPP,IDMAPP,        
     1                ISAVE,ITAPE,IAPPND,INTGR,LOSGN        
      COMMON /XGPIE / NSCR        
      COMMON /XVPS  / VPS(2)        
      COMMON /XCEITB/ CEITBL(2)        
      COMMON /XOLDPT/ XX(4),SEQNO        
      COMMON /AUTOCM/ PREFLG,NNAMES,PRENAM(100)        
      COMMON /AUTOSM/ NWORDS,SAVNAM(100)        
      COMMON /PASSER/ ISTOPF,MODNAM        
C        
C     EQUIVALENCE     (NTYPEE(1),NTIME ), (NTYPEE(2),NSAVE )        
C    1                (NTYPEE(3),NOUTPT), (NTYPEE(4),NCHKPT)        
C    2                (NTYPEE(5),NPURGE), (NTYPEE(6),NEQUIV)        
C    3                (NTYPEE(7),NCPW  ), (NTYPEE(8),NBPC  )        
C    4                (NTYPEE(9),NWPC  )        
      EQUIVALENCE     (NAMTBL(9),NXPURG)        
      EQUIVALENCE     (OSCAR (1),DMPCRD(1),LBLTBL(1),MED(1),OS(5)),     
     1                (CORE(1),OS(1),LOSCAR), (OS(2),OSPRC),        
     2                (OS(3),OSBOT), (OS(4),OSPNT)        
C        
      DATA    XCHK  / 4HXCHK/        
      DATA    ITYPE / 1,1,2,2,2,4/        
      DATA    IPRCFO/ 0     /, IENDF / 0/        
      DATA    NFILE / 4HFILE/        
      DATA    NVPS  / 4HVPS /        
      DATA    PRECHK/ 4HPREC,  4HHK  /,XDMAP / 4HXDMA, 4HP     /        
      DATA    NCEIT1/ 4HCEIT/, NCEIT2/ 4HBL  /        
      DATA    NLBLT1/ 4HLBLT/, NLBLT2/ 4HBL  /        
      DATA    DECLAR/ 4HBEGI,  4HLABE, 4HFILE/        
      DATA    FPARAM/ 4HTAPE,  4HAPPE, 4HSAVE/        
      DATA    NAMTBL/ 4HXTIM,  4HE   , 4HXSAV, 4HE   , 4HXUOP, 4H    ,  
     1                4HXCHK,  4H    , 4HXPUR, 4HGE  , 4HXEQU, 4HIV  /  
      DATA    NSKIP / 10*0 /, CDCOMP / 4HCOMP, 4HON  , 4HOFF   /        
C        
C     INITIALIZE        
C        
      IFIRST = 0        
      OSBOT  = 1        
      NWORDS = 0        
      LOOKUP = 0        
      PREFLG = 0        
      IVREPT = 0        
      ILEVEL = 0        
      SKIP   =.FALSE.        
      OSPNT  = OSBOT        
      OSCAR(OSBOT  ) = 0        
      OSCAR(OSBOT+1) = 1        
C        
C     FOR RESTART ALLOW CHECKPOINT AND JUMP ENTRIES TO BE INSERTED IN   
C     OSCAR BY XGPI.        
C        
      IF (START .EQ. ICST) GO TO 10        
      OSCAR(OSBOT+1) = 3        
C        
C     ALLOCATE 50 WORDS IN OPEN CORE FOR LBLTBL AND SET LBLTBL        
C     PARAMETERS.        
C        
   10 LBLBOT = LOSCAR        
      LBLTOP = LOSCAR - 50        
      LOSCAR = LBLTOP - 1        
      LSTLBL = LBLTOP - 4        
      LSTPAR = LBLBOT + 1        
C        
C     INITIALIZE DMPCRD ARRAY FOR RIGID FORMAT        
C        
      ICRDTP = LOSCAR        
C        
C     ****************************************        
C     PREPARE TO PROCESS NEXT DMAP INSTRUCTION        
C     ****************************************        
C        
  100 DMPCNT = DMPCNT + 1        
      IF (IAPP .EQ. IDMAPP) GO TO 110        
      MEDPNT = MED(MEDTP+1)*(DMPCNT - 1) + MEDTP + 2        
      IF (MED(MEDTP).LT.DMPCNT .AND. IAPP.NE.IDMAPP) GO TO 2390        
  110 NEWCRD =-1        
      INSERT = 0        
C        
C     SEE IF DMAP INSTRUCTION IS TO BE DELETED OR INSERTED        
C        
      IF (ALTER(1).EQ.0 .OR. ALTER(1).GT.DMPCNT) GO TO 130        
      IF (ALTER(1).LE.DMPCNT .AND. ALTER(2).GE.DMPCNT) GO TO 150        
      IF (ALTER(2) .EQ. 0) GO TO 120        
C        
C     JUST FINISHED DELETING, SET INSERT AND ALTER FOR INSERTING        
C        
      ALTER(1) = ALTER(2)        
      ALTER(2) = 0        
  120 IF (ALTER(1) .NE. DMPCNT-1) GO TO 130        
      INSERT = 1        
      DMPCNT = DMPCNT - 1        
      GO TO 160        
C        
C     GET NEXT DMAP INSTRUCTION        
C     FOR RIGID FORMAT SEE IF OSCAR ENTRY IS PART OF SUBSET        
C        
  130 IF (IAPP .EQ. IDMAPP) GO TO 160        
      I = MED(MEDTP+1)        
      DO 140 J = 1,I        
      K = MEDPNT + J -1        
      IF (MED(K) .NE. 0) GO TO 160        
  140 CONTINUE        
C        
C     SET INSERT FLAG TO NO PRINT        
C        
  150 INSERT = -2        
      GO TO 310        
C        
C     CHECK FOR CONDITIONAL COMPILATION END        
C        
  160 IF (ILEVEL .LE. 0) GO TO 190        
      DO 170 I = 1,ILEVEL        
      IF (IABS(NSKIP(I,1)) .LT. 99999) NSKIP(I,1) = NSKIP(I,1) - 1      
  170 CONTINUE        
      IF (NSKIP(ILEVEL,1) .EQ. -1) GO TO 180        
      IF (SKIP) INSERT = INSERT - 2        
      GO TO 190        
  180 SKIP   =.FALSE.        
      ILEVEL = ILEVEL - 1        
C        
  190 IF (LOOKUP.NE.1 .OR. PREFLG.EQ.0) GO TO 200        
      PREFLG = -PREFLG        
      CALL AUTOCK (OSPNT)        
  200 MODNAM = 1        
      LOOKUP = 0        
      CALL XSCNDM        
      MODNAM = 0        
      GO TO (2120,210,2120,100,2060), IRTURN        
  210 IF (.NOT.SKIP) GO TO 220        
C        
C     CHECK LABELS EVEN IF CONDITIONAL COMPILATION        
C        
      IF (DMAP(DMPPNT) .EQ. DECLAR(2)) GO TO 1270        
      GO TO 310        
C        
C     FIND MPL ENTRY AND BRANCH ON TYPE        
C        
  220 MPLPNT = 1        
      MODIDX = 1        
      IF (DMAP(DMPPNT).EQ.PRECHK(1) .AND. DMAP(DMPPNT+1).EQ.PRECHK(2))  
     1    GO TO 1490        
      IF (DMAP(DMPPNT).EQ.XDMAP(1)  .AND. DMAP(DMPPNT+1).EQ.XDMAP(2))   
     1    GO TO 1570        
      IF (DMAP(DMPPNT).EQ.CDCOMP(1) .AND. (DMAP(DMPPNT+1).EQ.CDCOMP(2)  
     1    .OR. DMAP(DMPPNT+1).EQ.CDCOMP(3))) GO TO 1740        
  230 IF (MPL(MPLPNT+1).EQ.DMAP(DMPPNT) .AND. MPL(MPLPNT+2).EQ.        
     1    DMAP(DMPPNT+1)) GO TO 240        
C        
C     CHECK FOR ERROR IN MPL TABLE        
C        
      IF (MPL(MPLPNT).LT.1 .OR. MPL(MPLPNT).GT.LMPL) GO TO 2140        
      MPLPNT = MPL(MPLPNT) + MPLPNT        
      MODIDX = 1 + MODIDX        
      IF (MPLPNT-LMPL) 230,2130,2130        
C        
C     GET FORMAT TYPE FROM MPL AND BRANCH        
C        
  240 I = MPL(MPLPNT + 3)        
      IF (I.LT.1 .OR. I.GT.5) GO TO 2140        
      GO TO (400,400,500,800,1200), I        
C        
C     *****************************************************        
C     RETURN HERE AFTER DMAP INSTRUCTION HAS BEEN PROCESSED        
C     *****************************************************        
C        
C     CHECK FOR FATAL ERROR        
C        
  300 IF (NOGO .EQ. 2) GO TO 2060        
C        
C     CHECK FOR END OF DMAP SEQUENCE.        
C        
      IF (IENDF .NE. 0) GO TO 1900        
C        
C     CHECK FOR $ ENTRY IN DMAP AND GET NEXT DMAP INSTRUCTION        
C        
  310 CALL XSCNDM        
      GO TO (320,320,320,100,2060), IRTURN        
  320 IF (NOGO.EQ.0 .AND. INSERT.GE.0) GO TO 2160        
      GO TO 310        
C        
C     ********************************************        
C     GENERATE OSCAR ENTRY WITH TYPE F OR O FORMAT        
C     ********************************************        
C        
C     GENERATE LINK HEADER SECTION        
C        
  400 CALL XLNKHD        
      IPRCFO = OSPNT        
C        
C     GENERATE I/P FILE SECTION        
C        
      CALL XIPFL        
      GO TO (410,2100), IRTURN        
C        
C     SAVE POINTER TO O/P FILE SECTION        
C        
  410 J = OSPNT + OSCAR(OSPNT)        
C        
C     GENERATE O/P FILE SECTION        
C        
      CALL XOPFL        
      GO TO (420,2110), IRTURN        
C        
C     NUMBER OF SCRATCH FILES TO OSCAR        
C        
  420 I = OSPNT + OSCAR(OSPNT)        
      OSCAR(I) = MPL(MPLPNT)        
C        
C     INCREMENT OSCAR WORD COUNT AND MPLPNT        
C        
      OSCAR(OSPNT) = 1 + OSCAR(OSPNT)        
      MPLPNT = 1 + MPLPNT        
C        
C     GENERATE PARAMETER SECTION        
C        
      CALL XPARAM        
      GO TO (430,2060), IRTURN        
C        
C     CONTINUE COMPILATION        
C     ZERO INTERNAL CHECKPOINT FLAG IN OSCAR ENTRY FOR TYPE F ENTRY     
C        
  430 IF (ANDF(OSCAR(OSPNT+2),MASKHI) .EQ. 2) GO TO 440        
      I = OSPNT + OSCAR(OSPNT)        
      OSCAR(I) = 0        
      OSCAR(OSPNT) = 1 + OSCAR(OSPNT)        
  440 CONTINUE        
      IF (NWORDS .EQ. 0) GO TO 450        
      CALL AUTOSV        
      NWORDS = 0        
  450 IF (PREFLG.EQ.0 .OR. ISTOPF.EQ.0) GO TO 460        
      CALL AUTOCK (ISTOPF)        
  460 CONTINUE        
      GO TO 300        
C        
C     ***************************************        
C     GENERATE OSCAR ENTRY WITH TYPE C FORMAT        
C     ***************************************        
C        
C     GENERATE LINK HEADER SECTION        
C        
  500 CALL XLNKHD        
C        
C     UPDATE OSCAR ENTRY WORD COUNT TO INCLUDE VALUE SECTION.        
C        
      OSCAR(OSPNT) = 7        
C        
C     CHECK FOR END CARD        
C        
      IF (OSCAR(OSPNT+3) .NE. NEND) GO TO 510        
      OSCAR(OSPNT+3) = NEXIT        
      IENDF = 1        
C        
C     SET EXECUTE FLAG IN OSCAR FOR END        
C        
      OSCAR(OSPNT+5) = ORF(ISGNON,OSCAR(OSPNT+5))        
C        
C     GET NEXT ENTRY IN DMAP        
C        
  510 CALL XSCNDM        
      GO TO (2160,520,630,630,2060), IRTURN        
C        
C     IF NEXT DMAP ENTRY IS BCD IT SHOULD BE LABEL NAME FOR BRANCH      
C     DMAP INSTRUCTION.        
C        
  520 IF (OSCAR(OSPNT+3) .EQ. NEXIT) GO TO 2160        
C        
C     SEARCH LABEL TABLE FOR LABEL NAME        
C        
      IF (LSTLBL .LT. LBLTOP) GO TO 540        
      DO 530 J = LBLTOP,LSTLBL,4        
      IF (DMAP(DMPPNT).EQ.LBLTBL(J) .AND. DMAP(DMPPNT+1).EQ.LBLTBL(J+1))
     1    GO TO 550        
  530 CONTINUE        
C        
C     NAME NOT FOUND IN TABLE        
C        
  540 LDEF = 0        
      GO TO 560        
C        
C     NOW SEE IF LABEL HAS BEEN REFERENCED        
C        
  550 IF (LBLTBL(J+3) .EQ. 0) GO TO 580        
      LDEF = LBLTBL(J+2)        
C        
C     MAKE NEW ENTRY IN LABEL TABLE, CHECK FOR TABLE OVERFLOW        
C        
  560 ASSIGN 570 TO IRTURN        
      IF (LSTLBL+8 .GE. LSTPAR) GO TO 2220        
  570 LSTLBL = LSTLBL + 4        
      J = LSTLBL        
      LBLTBL(J  ) = DMAP(DMPPNT  )        
      LBLTBL(J+1) = DMAP(DMPPNT+1)        
      LBLTBL(J+2) = LDEF        
  580 LBLTBL(J+3) = OSPNT        
C        
C     GET NEXT ENTRY FROM DMAP, ENTRY IS $ FOR JUMP,NAME FOR COND,      
C     VALUE FOR REPT.        
C        
      CALL XSCNDM        
      GO TO (2160,600,720,590,2060), IRTURN        
C        
C     DMAP INSTRUCTION IS JUMP        
C        
  590 OSCAR(OSPNT+6) = 0        
      IF (OSCAR(OSPNT+3) .EQ. NJUMP) GO TO 300        
      GO TO 2160        
C        
C     COND DMAP INSTRUCTION, ENTER PARAMETER NAME IN LABEL TABLE.       
C        
  600 IF (OSCAR(OSPNT+3) .NE. NREPT) GO TO 610        
      IVREPT =  1        
      GO TO 640        
  610 IF (OSCAR(OSPNT+3) .NE. NCOND) GO TO 2160        
      ASSIGN 620 TO IRTURN        
      IF (LSTPAR-8 .LE. LSTLBL) GO TO 2220        
  620 LSTPAR = LSTPAR - 4        
      LBLTBL(LSTPAR  ) = DMAP(DMPPNT  )        
      LBLTBL(LSTPAR+1) = DMAP(DMPPNT+1)        
      LBLTBL(LSTPAR+2) = OSPNT + 6        
      LBLTBL(LSTPAR+3) = OSPNT        
      GO TO 300        
C        
C     EXIT DMAP INSTRUCTION, SET EXECUTE FLAG AND OSCAR VALUE SECTION.  
C        
  630 IF (OSCAR(OSPNT+3) .NE. NEXIT) GO TO 2160        
      IF (DMAP(DMPPNT) .NE. INTGR) DMAP(DMPPNT+1) = 0        
      DMAP(DMPPNT  ) = INTGR        
      DMAP(DMPPNT+2) = RSHIFT(IALLON,1)        
C        
C     ENTER LOOP COUNT IN CEITBL FOR REPT AND EXIT INSTRUCTIONS        
C        
  640 CEITBL(2) = CEITBL(2) + 4        
      IF (CEITBL(2) .GT. CEITBL(1)) GO TO 2280        
C        
C     I = POINTER TO LOOP COUNT IN CEITBL ENTRY        
C        
      I = CEITBL(2) - 2        
      IF (IVREPT .EQ. 0) GO TO 700        
C        
C     PROCESS VARIABLE REPT INSTRUCTION - FIND PARAM IN VPS        
C        
      KDH = 3        
  650 IF (DMAP(DMPPNT).EQ.VPS(KDH) .AND. DMAP(DMPPNT+1).EQ.VPS(KDH+1))  
     1    GO TO 660        
      KDH = KDH + ANDF(VPS(KDH+2),MASKHI) + 3        
      IF (KDH - VPS(2)) 650,670,670        
C        
C     PARAMETER FOUND        
C        
  660 IF (ANDF(RSHIFT(VPS(KDH+2),16),15) .NE. 1) GO TO 2210        
      CEITBL(I) = LSHIFT(KDH,16)        
      CEITBL(I) = ORF(CEITBL(I),ISGNON)        
      GO TO 710        
C        
C     CHECK PVT FOR PARAMETER        
C        
  670 KDH = 3        
  680 LENGTH = ANDF(PVT(KDH+2),NOSGN)        
      LENGTH = ITYPE(LENGTH)        
      IF (DMAP(DMPPNT).EQ.PVT(KDH) .AND. DMAP(DMPPNT+1).EQ.PVT(KDH+1))  
     1    GO TO 690        
      KDH = KDH + LENGTH + 3        
      IF (KDH - PVT(2)) 680,2200,2200        
  690 IF (LENGTH .NE. ITYPE(1)) GO TO 2210        
      CEITBL(I) = LSHIFT(PVT(KDH+3),16)        
      GO TO 710        
  700 CEITBL(I) = LSHIFT(DMAP(DMPPNT+1),16)        
C        
C     FIRST WORD OF CEITBL ENTRY CONTAINS OSCAR RECORD NUMBERS OF       
C     BEGINNING AND END OF LOOP        
C        
  710 CEITBL(I-1) = ISEQN        
      IVREPT = 0        
C        
C     OSCAR VALUE SECTION CONTAINS POINTER TO LOOP COUNT IN CEITBL ENTRY
C        
      OSCAR(OSPNT+6) = I        
      GO TO 300        
C        
C     REPT DMAP INSTRUCTION, COUNT TO VALUE SECTION.        
C        
  720 IF (OSCAR(OSPNT+3) .EQ. NREPT) GO TO 640        
      GO TO 2160        
C        
C     ***************************************        
C     GENERATE OSCAR ENTRY WITH TYPE E FORMAT        
C     ***************************************        
C        
C     PREFIX MODULE NAME WITH AN X        
C        
  800 DO 810 I = 1,6        
      IF (NTYPEE(I) .EQ. DMAP(DMPPNT)) GO TO 820        
  810 CONTINUE        
  820 I = 2*I - 1        
      DMAP(DMPPNT  ) = NAMTBL(I  )        
      DMAP(DMPPNT+1) = NAMTBL(I+1)        
C        
C     GENERATE LINK HEADER FOR OSCAR        
C        
      IF (I.EQ.9 .OR. I.EQ.11) LOOKUP = 1        
      OS2B4 = OSPRC        
      CALL XLNKHD        
C        
C     BRANCH ON DMAP NAME AND GENERATE VALUE/OUTPUT SECTION OF OSCAR    
C        
      I = (I+1)/2        
      GO TO (830,860,990,990,990,990), I        
C        
C     EXTIME ENTRY, CHECK ESTIM IN CONTROL FILE        
C        
  830 OSCAR(OSPNT+5) = ANDF(OSCAR(OSPNT+5),NOSGN)        
      IF (IESTIM .EQ. 0) GO TO 300        
C        
C     GET TIME SEGMENT NAME        
C        
      CALL XSCNDM        
      GO TO (2370,840,2370,2370,2060), IRTURN        
  840 I = IESTIM + ICTLFL(IESTIM) - 1        
      J = IESTIM + 1        
      DO 850 K = J,I,2        
      IF (DMAP(DMPPNT).EQ.ICTLFL(K) .AND. DMAP(DMPPNT+1).EQ.ICTLFL(K+1))
     1    OSCAR(OSPNT+5) = ORF(OSCAR(OSPNT+5),ISGNON)        
  850 CONTINUE        
      GO TO 300        
C        
C     XSAVE ENTRY, ENTER POINTERS IN VALUE SECTION OF OSCAR.        
C        
  860 I = OSPNT + OSCAR(OSPNT)        
      OSCAR(I) = 0        
      K = I - 1        
C        
C     GET PARAMETER NAME FROM DMAP.        
C        
  870 CALL XSCNDM        
      GO TO (2260,880,2260,930,2060), IRTURN        
C        
C     FIND PARAMETER IN VPS AND ENTER POINTER TO VALUE IN OSCAR.        
C        
  880 K = K + 2        
      OSCAR(I  ) = OSCAR(I) + 1        
      OSCAR(K  ) = 0        
      OSCAR(K+1) = 0        
      J = 3        
  890 IF (VPS(J).EQ.DMAP(DMPPNT) .AND. VPS(J+1).EQ.DMAP(DMPPNT+1))      
     1    GO TO 900        
      L = ANDF(VPS(J+2),MASKHI)        
      J = J + L + 3        
      IF (J .LT. VPS(2)) GO TO 890        
C        
C     PARAMETER NOT IN VPS - ERROR        
C        
      GO TO 2270        
C        
C     PARAMETER FOUND IN VPS        
C        
  900 OSCAR(K) = J + 3        
C        
C     SEE IF PARAMETER WAS ALREADY SAVED        
C        
      J  = I + 1        
      J1 = K - 2        
      IF (J1 .LT. J) GO TO 870        
      DO 910 L = J,J1,2        
      IF (OSCAR(L) .EQ. OSCAR(K)) GO TO 920        
  910 CONTINUE        
      GO TO 870        
C        
C     PARAMETER DUPLICATED        
C        
  920 K = K - 2        
      OSCAR(I) = OSCAR(I) - 1        
      GO TO 2150        
C        
C        
C     END OF SAVE PARAMETER NAME LIST, INCREMENT OSCAR WORD COUNT.      
C        
  930 OSCAR(OSPNT) = OSCAR(OSPNT) + 2*OSCAR(I) + 1        
C        
C     GET PARAMETER VALUE DISPLACEMENT IN COMMON FROM PRECEDING        
C     OSCAR ENTRY.        
C        
      IOSDAV = OSPRC        
      IF (OSCAR(OSPRC+3) .EQ. XCHK) OSPRC = OS2B4        
      IF (ANDF(OSCAR(OSPRC+2),MASKHI) .GT. 2) GO TO 2420        
C        
C     J = OSCAR POINTER TO BEGINNING OF PARAMETER SECTION.        
C        
      J = OSPRC + 6 + 3*OSCAR(OSPRC+6) + 1        
      IF (ANDF(OSCAR(OSPRC+2),MASKHI) .EQ. 1) J = J + 1 + 3*OSCAR(J)    
      J = J + 1        
C        
C     N1 = PARAMETER COUNT,N2=PARAMETER DISPLACEMENT IN COMMON,        
C     N3 = OSCAR POINTER TO PARAMETER ENTRIES IN PRECEDING OSCAR ENTRY. 
C        
      N3 = J + 1        
      N1 = OSCAR(J)        
      N2 = 1        
C        
C     SCAN PARAMETER LIST OF PRECEDING OSCAR ENTRY        
C        
      DO 980 M = 1,N1        
      L = ANDF(OSCAR(N3),NOSGN)        
      IF (OSCAR(N3) .GT. 0) GO TO 970        
      N3 = N3 + 1        
C        
C     VARIABLE PARAMETER, COMPARE VPS POINTER WITH XSAVE VPS POINTERS.  
C        
      I1 = I + 1        
      DO 940 K1 = I1,K,2        
      IF (OSCAR(K1) .EQ. L) GO TO 950        
  940 CONTINUE        
      GO TO 960        
  950 OSCAR(K1+1) = N2        
  960 L = ANDF(VPS(L-1),MASKHI)        
      GO TO 980        
C        
C     CONSTANT PARAMETER, INCREMENT N2, N3        
C        
  970 N3 = N3 + L + 1        
  980 N2 = N2 + L        
C        
C     PARAMETER SECTION SCANNED, CHECK EXSAVE PARAMETER LIST FOR        
C     PARAMETERS NOT FOUND IN PRECEDING OSCAR.        
C        
      GO TO 2290        
C        
C     XUOP,XCHK,XPURGE,OR XEQUIV OSCAR ENTRY - GENERATE FILE NAME LIST. 
C        
  990 NOSPNT = OSPNT + OSCAR(OSPNT)        
      IPRIME = 1        
      IOSPNT = NOSPNT + 1        
      OSCAR(NOSPNT) = 0        
C        
C     GET NEXT ENTRY FROM DMAP CARD        
C        
 1000 CALL XSCNDM        
      GO TO (1040,1010,2160,1080,2060), IRTURN        
C        
C     DMAP ENTRY IS DATA BLOCK NAME, STORE IN OSCAR        
C        
 1010 OSCAR(IOSPNT  ) = DMAP(DMPPNT  )        
      OSCAR(IOSPNT+1) = DMAP(DMPPNT+1)        
C        
C     MAKE SURE FILE IS NOT BLANK        
C        
      IF (OSCAR(IOSPNT) .EQ. NBLANK) GO TO 1000        
C        
C     FOR CHKPNT - MAKE SURE FILE IS NOT OUTPUT BY USER I/P PROCESSOR   
C        
      IF (OSCAR(OSPNT+3) .NE. NAMTBL(7)) GO TO 1030        
      M = FIAT(3)*ICFIAT - 2        
      DO 1020 J = 4,M,ICFIAT        
      IF (OSCAR(IOSPNT).EQ.FIAT(J+1) .AND. OSCAR(IOSPNT+1).EQ.FIAT(J+2))
     1    GO TO 2400        
 1020 CONTINUE        
 1030 IOSPNT = IOSPNT + 2        
      OSCAR(NOSPNT) = 1 + OSCAR(NOSPNT)        
C        
C     INSERT EXTRA WORD INTO OSCAR FOR EACH PRIMARY DATA BLOCK IN       
C     EQUIV STATEMENT        
C        
      IF (OSCAR(OSPNT+3).NE.NAMTBL(11) .OR. OSCAR(OSPNT+4).NE.NAMTBL(12)
     1   ) GO TO 1000        
      IF (IPRIME .EQ. 0) GO TO 1000        
      OSCAR(IOSPNT) = 0        
      IOSPNT = IOSPNT + 1        
      IPRIME = 0        
      GO TO 1000        
C        
C     DMAP ENTRY IS OPERATOR, CHECK FOR / OPERATOR        
C        
 1040 IF ((DMAP(DMPPNT+1).NE.ISLSH) .OR. (OSCAR(OSPNT+3).NE.NXEQUI .AND.
     1     OSCAR(OSPNT+3).NE.NXPURG)) GO TO 2160        
C        
C     OSCAR ENTRY IS XEQUIV OR XPURGE        
C        
      VARFLG = 0        
      IF (OSCAR(OSPNT+3) .EQ. NXPURG) GO TO 1050        
      IF (OSCAR(NOSPNT)  .LT. 2     ) GO TO 2160        
C        
C     GET PARAMETER NAME AND ENTER INTO LBLTBL        
C        
 1050 CALL XSCNDM        
      GO TO (1110,1060,2160,2160,2060), IRTURN        
 1060 VARFLG = 1        
      IF (DMAP(DMPPNT) .EQ. NBLANK) GO TO 1100        
      ASSIGN 1070 TO IRTURN        
      IF (LSTPAR-8 .LE. LSTLBL) GO TO 2220        
 1070 LSTPAR = LSTPAR - 4        
      LBLTBL(LSTPAR  ) = DMAP(DMPPNT  )        
      LBLTBL(LSTPAR+1) = DMAP(DMPPNT+1)        
      LBLTBL(LSTPAR+2) = IOSPNT        
      LBLTBL(LSTPAR+3) = OSPNT        
      IDLHSS = 2*OSCAR(NOSPNT)+OSCAR(OSPNT) + 2        
      IF (OSCAR(OSPNT+3) .EQ. NAMTBL(11)) IDLHSS = IDLHSS + 1        
      OSCAR(OSPNT) = IDLHSS        
C        
C     CHECK FOR POSSIBILITY OF ANOTHER DATA BLOCK NAME LIST.        
C        
      CALL XSCNDM        
      GO TO (990,2160,2160,300,2060), IRTURN        
C        
C     END OF DMAP INSTRUCTION, INCREMENT OSCAR WORD COUNT IF NOT XEQUIV 
C     OR XPURGE.        
C        
 1080 IF (OSCAR(OSPNT+3).NE.NXEQUI .AND. OSCAR(OSPNT+3).NE.NXPURG)      
     1    GO TO 1090        
      OSCAR(IOSPNT) = -1        
      IDLHSS = 2*OSCAR(NOSPNT) + OSCAR(OSPNT) + 2        
      IF (OSCAR(OSPNT+3) .EQ. NAMTBL(11)) IDLHSS = IDLHSS + 1        
      OSCAR(OSPNT) = IDLHSS        
      GO TO 300        
 1090 OSCAR(OSPNT) = 2*OSCAR(NOSPNT) + OSCAR(OSPNT) + 1        
C        
C     ELIMINATE ENTRY IF NOTHING CHECKPOINTED.        
C        
      IF (OSCAR(NOSPNT) .EQ. 0) OSBOT = OSPRC        
      GO TO 300        
 1100 CALL XSCNDM        
      GO TO (1110,2160,2160,2160,2060), IRTURN        
 1110 IF ((DMAP(DMPPNT+1).NE.ISLSH) .OR. (OSCAR(OSPNT+3).NE.NXEQUI .AND.
     1     OSCAR(OSPNT+3).NE.NXPURG)) GO TO 2160        
      OSCAR(IOSPNT) = -1        
      IDLHSS = 2*OSCAR(NOSPNT) + OSCAR(OSPNT) + 2        
      IF (OSCAR(OSPNT+3) .EQ. NAMTBL(11)) IDLHSS = IDLHSS + 1        
      OSCAR(OSPNT) = IDLHSS        
      GO TO 990        
C        
C     *******************************        
C     DMAP INSTRUCTION IS DECLARATIVE        
C     *******************************        
C        
C     PUT DUMMY ENTRY IN OSCAR FOR DIAGNOSTIC USE.        
C        
 1200 J = OSBOT  + OSCAR(OSBOT)        
      OSCAR(J+3) = DMAP(DMPPNT)        
      OSCAR(J+4) = DMAP(DMPPNT+1)        
      OSCAR(J+5) = DMPCNT        
      CALL XLNKHD        
C        
C     NOW PROCESS INSTRUCTION        
C        
      DO 1210 J = 1,3        
      IF (DMAP(DMPPNT) .EQ. DECLAR(J)) GO TO (1220,1270,1350), J        
 1210 CONTINUE        
C        
C     BEGIN DECLARATIVE - PREPARE TO PROCESS NEXT DMAP INSTRUCTION      
C        
 1220 INDEX = 1        
 1230 IF (IFIRST .GT. 0) GO TO 1250        
      IF (DIAG14.EQ.0 .AND. DIAG17.EQ.0) GO TO 1250        
      IFIRST = 1        
      CALL XGPIMW (5,18,DMPCNT,IBUFF)        
 1240 IF (START .NE. ICST) CALL XGPIMW (10,0,0,0)        
 1250 IF (INDEX .GT.    1) GO TO 300        
 1260 CALL XSCNDM        
      GO TO (1260,1260,1260,300,2060), IRTURN        
C        
C     LABEL DECLARATIVE - GET LABEL NAME        
C        
 1270 CALL XSCNDM        
      GO TO (2170,1280,2170,2170,2060), IRTURN        
C        
C     CHECK IF LABEL IS FOR CONDITIONAL COMPILATION        
C        
 1280 CONTINUE        
      IF (DMAP(DMPPNT).NE.NSKIP(ILEVEL,1) .OR. DMAP(DMPPNT+1).NE.       
     1    NSKIP(ILEVEL,2)) GO TO 1290        
      ILEVEL = ILEVEL - 1        
      SKIP   = .FALSE.        
      GO TO 300        
 1290 IF (SKIP) GO TO 300        
C        
C     SCAN LABEL TABLE FOR LABEL NAME        
C        
      IF (LSTLBL .LT. LBLTOP) GO TO 1310        
      DO 1300 J = LBLTOP,LSTLBL,4        
      IF (DMAP(DMPPNT).EQ.LBLTBL(J) .AND. DMAP(DMPPNT+1).EQ.LBLTBL(J+1))
     1    GO TO 1340        
 1300 CONTINUE        
C        
C     NAME NOT IN LABEL TABLE, MAKE NEW ENTRY        
C        
 1310 ASSIGN 1320 TO IRTURN        
      IF (LSTLBL+8 .GE. LSTPAR) GO TO 2220        
 1320 LSTLBL = LSTLBL + 4        
      J = LSTLBL        
      LBLTBL(J  ) = DMAP(DMPPNT  )        
      LBLTBL(J+1) = DMAP(DMPPNT+1)        
      LBLTBL(J+3) = 0        
 1330 LBLTBL(J+2) = ISEQN + 1        
      GO TO 300        
C        
C     LABEL NAME FOUND IN LABEL TABLE, DEF ENTRY SHOULD BE ZERO        
C        
 1340 IF (LBLTBL(J+2)) 2250,1330,2250        
C        
C     FILE DECLARATIVE        
C     SET FILE NAME FLAG        
C     DO NOT PROCESS FILE DECLARATION WHEN EXECUTE FLAG IS OFF ON       
C     MODIFIED RESTART.        
C        
 1350 IF (START.EQ.IMST .AND. OSCAR(OSPNT+5).GE.0) GO TO 1260        
 1360 I = 1        
 1370 CALL XSCNDM        
      GO TO (1380,1410,2170,300,2060), IRTURN        
C        
C     DELIMITER ENCOUNTERED        
C        
 1380 IF (DMAP(DMPPNT+1) .EQ. ISLSH) GO TO 1390        
      IF (DMAP(DMPPNT+1) .EQ. IEQUL) GO TO 1400        
      GO TO 2170        
C        
C     DELIMITER IS /, TEST FILE NAME FLAG        
C        
 1390 IF (I .NE. 0) GO TO 2170        
      GO TO 1360        
C        
C     DELIMITER IS =, TURN OFF FILE NAME FLAG        
C        
 1400 I = 0        
      GO TO 1370        
C        
C     NAME ENCOUNTERED - TEST FILE NAME FLAG        
C        
 1410 IF (I .EQ. 0) GO TO 1430        
C        
C     FILE NAME - ENTER IN FILE TABLE        
C        
      FPNT = FPNT + 3        
      IF (FPNT .GT. LFILE-2) GO TO 2410        
      FILE(FPNT  ) = DMAP(DMPPNT  )        
      FILE(FPNT+1) = DMAP(DMPPNT+1)        
C        
C     PUT FILE NAME INTO LABEL TABLE FOR DMAP XREF        
C        
      ASSIGN 1420 TO IRTURN        
      IF (LSTLBL+8 .GE. LSTPAR) GO TO 2220        
 1420 LSTLBL = LSTLBL + 4        
      LBLTBL(LSTLBL  ) = FILE(FPNT  )        
      LBLTBL(LSTLBL+1) = FILE(FPNT+1)        
      LBLTBL(LSTLBL+2) = ISEQN        
      LBLTBL(LSTLBL+3) = -1        
      GO TO 1370        
C        
C     FILE PARAMETER FOUND - ENTER APPROPRIATE CODE IN FILE TABLE       
C        
 1430 DO 1440 J = 1,3        
      IF (DMAP(DMPPNT) .EQ. FPARAM(J)) GO TO (1450,1460,1470), J        
 1440 CONTINUE        
      GO TO 2160        
C        
C     TAPE PARAM        
C        
 1450 FCODE = ITAPE        
      GO TO 1480        
C        
C     APPEND PARAM        
C        
 1460 FCODE = IAPPND        
      GO TO 1480        
C        
C     SAVE PARAM        
C        
 1470 FCODE = ISAVE        
C        
C     PUT CODE IN FILE TABLE        
C        
 1480 FILE(FPNT+2) = ORF(FILE(FPNT+2),FCODE)        
      GO TO 1370        
C        
C     PROCESS PRECHK CARD        
C        
 1490 INDEX = 3        
      CALL XSCNDM        
      GO TO (2160,1500,2160,2160,2160), IRTURN        
C        
C     TEST FOR  ALL  OPTION OR BLANK        
C        
 1500 IF (DMAP(DMPPNT) .EQ. NBLANK) GO TO 1490        
      PREFLG = 1        
      NNAMES = 0        
      IF (DMAP(DMPPNT) .EQ. NAMOPT(23)) GO TO 1520        
      IF (DMAP(DMPPNT) .EQ.      NEND ) GO TO 1550        
C        
C     LIST HAS BEEN FOUND, STORE IN /AUTOCM/        
C        
 1510 NNAMES = NNAMES + 1        
      IF (NNAMES .GT. 50) GO TO 2180        
      PRENAM(2*NNAMES-1) = DMAP(DMPPNT  )        
      PRENAM(2*NNAMES  ) = DMAP(DMPPNT+1)        
      CALL XSCNDM        
      GO TO (2160,1510,2160,1560,2060), IRTURN        
C        
C     ALL  OPTION FOUND, LOOK FOR  EXCEPT        
C        
 1520 CALL XSCNDM        
      GO TO (2160,1530,2160,1530,2060), IRTURN        
 1530 IF (DMAP(DMPPNT).EQ.NAMOPT(25) .AND. DMAP(DMPPNT+1).EQ.NAMOPT(26))
     1    GO TO 1540        
      PREFLG = 2        
      GO TO 1560        
 1540 PREFLG = 3        
      CALL XSCNDM        
      GO TO (2160,1510,2160,1560,2060), IRTURN        
 1550 PREFLG = 0        
 1560 IF (ICPFLG .NE. 0) GO TO 1240        
      PREFLG = 0        
      GO TO 300        
C        
C     PROCESS XDMAP INSTRUCTION        
C        
 1570 IOLD = DIAG14        
 1580 CALL XSCNDM        
      GO TO (2160,1610,2160,1590,2060), IRTURN        
 1590 INDEX = 2        
      IF (IOLD.EQ.0 .OR. IFIRST.EQ.0) GO TO 1230        
      IF (START .NE. ICST) WRITE (OPTAPE,1600) IPLUS,IPLUS        
 1600 FORMAT (A1,2X,A1)        
      GO TO 300        
 1610 IF (DMAP(DMPPNT) .EQ. NBLANK) GO TO 1580        
C        
C     HAVE LOCATED AN XDMAP OPTION        
C        
      DO 1620 K = 1,22,2        
      IF (DMAP(DMPPNT).EQ.NAMOPT(K) .AND. DMAP(DMPPNT+1).EQ.NAMOPT(K+1))
     1    GO TO 1630        
 1620 CONTINUE        
      GO TO 2190        
 1630 KK = K/2 + 1        
      GO TO (1580,1640,1710,1660,1650,1680,1690,1700,1580,1670,1580), KK
 1640 IFLG(1) = 0        
      GO TO 1580        
 1650 IF (DIAG14 .EQ. 1) GO TO 1580        
      IFLG(3) = 0        
      DIAG14  = 0        
      GO TO 1580        
 1660 IF (DIAG14 .EQ. 1) GO TO 1580        
      IFLG(3) = 1        
      DIAG14  = 2        
      GO TO 1580        
 1670 IF (DIAG4 .EQ. 1) GO TO 1580        
      IFLG(6) = 1        
      DIAG4   = 1        
      GO TO 1580        
 1680 IF (DIAG17 .EQ. 1) GO TO 1580        
      IFLG(4) = 1        
      DIAG17  = 2        
      GO TO 1580        
 1690 IF (DIAG17 .EQ. 1) GO TO 1580        
      IFLG(4) = 0        
      DIAG17  = 0        
      GO TO 1580        
 1700 IF (DIAG25 .EQ. 1) GO TO 1580        
      IFLG(5) = 1        
      DIAG25  = 1        
      GO TO 1580        
C        
C     CODE TO PROCESS  ERR  OPTION        
C        
 1710 CALL XSCNDM        
      GO TO (1720,2160,2160,2160,2060), IRTURN        
 1720 IF (DMAP(DMPPNT+1) .NE. IEQUL) GO TO 2160        
      CALL XSCNDM        
      GO TO (2160,2160,1730,2160,2060), IRTURN        
 1730 IFLG(2) = DMAP(DMPPNT+1)        
      IF (IFLG(2).LT.0 .OR. IFLG(2).GT.2) GO TO 2190        
      GO TO 1580        
C        
C     PROCESS CONDCOMP INSTRUCTION        
C        
 1740 IF (ILEVEL .GE. 5) GO TO 2160        
      ION = 0        
      IF (DMAP(DMPPNT+1) .EQ. CDCOMP(2)) ION = 1        
      CALL XSCNDM        
      GO TO (2160,1750,1760,2160,2060), IRTURN        
C        
C     LABEL SPECIFIED FOR END        
C        
 1750 NSKIP(ILEVEL+1,1) = DMAP(DMPPNT  )        
      NSKIP(ILEVEL+1,2) = DMAP(DMPPNT+1)        
      GO TO 1770        
C        
C     INSTRUCTION COUNT GIVEN FOR END        
C        
 1760 CONTINUE        
      IF (DMAP(DMPPNT+1) .LT. 0) GO TO 2160        
      NSKIP(ILEVEL+1,1) = DMAP(DMPPNT+1)        
C        
C     GET LABEL AND LOOK FOR IT IN PVT        
C        
 1770 CALL XSCNDM        
      GO TO (2160,1780,2160,2160,2060), IRTURN        
 1780 ILEVEL = ILEVEL + 1        
      KDH = 3        
 1790 LENGTH = ANDF(PVT(KDH+2),NOSGN)        
      LENGTH = ITYPE(LENGTH)        
      IF (DMAP(DMPPNT).EQ.PVT(KDH) .AND. DMAP(DMPPNT+1).EQ.PVT(KDH+1))  
     1    GO TO 1810        
      KDH = KDH + LENGTH + 3        
      IF (KDH - PVT(2)) 1790,1800,1800        
C        
C     PARAMETER NOT FOUND - ASSUME FALSE VALUE        
C        
 1800 IF (ION .EQ. 0) GO TO 300        
      GO TO 1820        
C        
C     CHECK IF VALUE IS FALSE        
C        
 1810 PVT(KDH+2) = ORF(PVT(KDH+2),ISGNON)        
      IF (ANDF(PVT(KDH+2),NOSGN) .NE.  1) GO TO 2160        
      IF (PVT(KDH+3).LT.0 .AND. ION.EQ.1) GO TO 300        
      IF (PVT(KDH+3).GE.0 .AND. ION.EQ.0) GO TO 300        
 1820 SKIP = .TRUE.        
      GO TO 300        
C        
C     ***********************************************************       
C     DMAP INSTRUCTIONS ALL PROCESSED - PREPARE OSCAR FOR PHASE 2       
C     ***********************************************************       
C        
C     CHECK FOR DISCREPENCY BETWEEN RIGID FORMAT AND MED TABLE.        
C        
 1900 IF (MED(MEDTP).NE.DMPCNT .AND. IAPP.NE.IDMAPP) GO TO 2390        
C        
C     USE LBLTBL PARAMETER NAMES TO UPDATE VALUE SECTIONS OF TYPE C AND 
C     E OSCAR ENTRIES.        
C        
 1910 IF (LSTPAR .GE. LBLBOT) GO TO 1990        
C        
C     FIND PARAMETER NAME IN VPS        
C        
      K = 3        
 1920 IF (LBLTBL(LSTPAR).EQ.VPS(K) .AND. LBLTBL(LSTPAR+1).EQ.VPS(K+1))  
     1    GO TO 1930        
      K = K + ANDF(VPS(K+2),MASKHI) + 3        
      IF (K - VPS(2)) 1920,1950,1950        
C        
C     NAME FOUND IN VPS, VPS POINTER TO OSCAR VALUE SECTION.        
C        
 1930 I = LBLTBL(LSTPAR+2)        
      OSCAR(I) = K + 3        
C        
C     GET NEXT ENTRY FROM LBLTBL        
C        
 1940 LSTPAR = LSTPAR + 4        
      GO TO 1910        
C        
C     SEARCH PVT TABLE FOR PARAMETER. IF FOUND ENTER PARAMETER IN VPS.  
C        
 1950 K1 = 3        
 1960 LENGTH = ANDF(PVT(K1+2),NOSGN)        
      LENGTH = ITYPE(LENGTH)        
      IF (LBLTBL(LSTPAR).EQ.PVT(K1) .AND. LBLTBL(LSTPAR+1).EQ.PVT(K1+1))
     1    GO TO 1970        
      K1 = K1 + LENGTH + 3        
      IF (K1-PVT(2)) 1960,2310,2310        
 1970 K = VPS(2) + 1        
      PVT(K1+2) = ORF(PVT(K1+2),ISGNON)        
      VPS(2) = K + 2 + LENGTH        
      IF (VPS(2) .GE. VPS(1)) GO TO 2380        
      K2 = LENGTH + 3        
      DO 1980 M = 1,K2        
      J  = K  + M - 1        
      J1 = K1 + M - 1        
 1980 VPS(J) = PVT(J1)        
      GO TO 1930        
C        
C     USE LBLTBL ENTRIES TO LOAD SEQUENCE NOS. INTO VALUE SECTION OF    
C     TYPE C OSCAR ENTRIES.        
C        
 1990 LBLERR = 0        
      LSTLSV = LSTLBL        
 2000 IF (LSTLBL .LT. LBLTOP) GO TO 2050        
      IF (LBLTBL(LSTLBL+2) .EQ. 0) GO TO 2330        
C        
C     IGNORE FILE NAMES IN LBLTBL USED FOR XREF        
C        
 2010 IF (LBLTBL(LSTLBL+3)) 2040,2360,2020        
 2020 I = LBLTBL(LSTLBL+3) + 6        
      IF (OSCAR(I-3).EQ.NCOND .OR. OSCAR(I-3).EQ.NJUMP) GO TO 2030      
      J = OSCAR(I)        
C        
C     LABEL NAME TO WORDS 3 AND 4 OF CEITBL ENTRY        
C        
      CEITBL(J+1) = LBLTBL(LSTLBL  )        
      CEITBL(J+2) = LBLTBL(LSTLBL+1)        
C        
C     OSCAR RECORD NO. OF BEGIN LOOP TO FIRST WORD OF CEITBL ENTRY      
C        
      CEITBL(J-1) = ORF(LSHIFT(LBLTBL(LSTLBL+2),16),CEITBL(J-1))        
 2030 OSCAR(I)    = ORF(LSHIFT(LBLTBL(LSTLBL+2),16),OSCAR(I))        
C        
C     GET NEXT LBLTBL ENTRY.        
C        
 2040 LSTLBL = LSTLBL - 4        
      GO TO 2000        
C        
C     NORMAL RETURN -     DUMP LBLTBL ONTO SCRATCH FOR DMAP XREF        
C                         THEN DELETE LBLTBL AND DMPCRD ARRARYS        
C                         FROM OPEN CORE        
C        
 2050 LSTLBL = LSTLSV        
 2060 LOSCAR = LBLBOT        
      IDPBUF = KORSZ(OSCAR) - 2*BUFSZ        
      CALL CLOSE (NSCR,1)        
      LSTLBL = LSTLBL - LBLTOP + 4        
      IF (LSTLBL .LT. 0) LSTLBL = 0        
      RETURN        
C        
C     DIAGNOSTIC MESSAGES -        
C        
C     DMAP INPUT FILE ERROR        
C        
 2100 CALL XGPIDG (-10,OSPNT,0,0)        
      GO TO 410        
C        
C     DMAP OUTPUT FILE ERROR        
C        
 2110 CALL XGPIDG (-11,OSPNT,0,0)        
      GO TO 420        
C        
C     NO MACRO INSTRUCTION NAME ON DMAP CARD.        
C        
 2120 CALL XGPIDG (12,0,DMPCNT,0)        
      GO TO 300        
C        
C     NO MPL ENTRY FOR THIS DMAP MACRO INSTRUCTION        
C        
 2130 CALL XGPIDG (13,0,DMPPNT,DMPCNT)        
      GO TO 300        
C        
C     MPL TABLE INCORRECT        
C        
 2140 CALL XGPIDG (49,0,0,0)        
      GO TO 2500        
C        
C     DUPLICATE PARAMETER NAMES (WARNING)        
C        
 2150 CALL XGPIDG (-2,OSPNT,DMAP(DMPPNT),DMAP(DMPPNT+1))        
      GO TO 870        
C        
C     DMAP FORMAT ERROR        
C        
 2160 CALL XGPIDG (16,OSPNT,0,0)        
      GO TO 300        
 2170 J = OSBOT + OSCAR(OSBOT) + 6        
      CALL XGPIDG (16,J,0,0)        
      GO TO 300        
C        
C     PRECHK NAME LIST OVERFLOW        
C        
 2180 CALL XGPIDG (55,0,0,0)        
      GO TO 2500        
C        
C     ILLEGAL OPTION ON XDMAP CARD        
C        
 2190 CALL XGPIDG (56,0,0,0)        
      GO TO 300        
C        
C     VARIABLE REPT INSTRUCTION ERRORS        
C        
 2200 CALL XGPIDG (58,0,0,0)        
      GO TO 300        
 2210 CALL XGPIDG (57,0,0,0)        
      GO TO 300        
C        
C     LBLTBL OVERFLOWED - ALLOCATE 50 MORE WORDS FOR IT.        
C        
 2220 ICRDTP = ICRDTP - 50        
      IF (ICRDTP .LT. OSCAR(OSBOT)+OSBOT) GO TO 2240        
      LOSCAR = LOSCAR - 50        
C        
C     MOVE LABEL NAME PORTION OF LBLTBL        
C        
      JX = LSTLBL + 3        
      DO 2230 IX = LBLTOP,JX        
      IY = IX - 50        
 2230 LBLTBL(IY) = LBLTBL(IX)        
      LBLTOP = LBLTOP - 50        
      LSTLBL = LSTLBL - 50        
      GO TO IRTURN, (570,620,1070,1320,1420)        
C        
C     LABEL TABLE OVERFLOW, DISCONTINUE COMPILATION        
C        
 2240 CALL XGPIDG (14,NLBLT1,NLBLT2,DMPCNT)        
      GO TO 2500        
C        
C     LABEL IS MULTIPLY DEFINED        
C        
 2250 CALL XGPIDG (19,DMPCNT,DMPPNT,0)        
      GO TO 300        
C        
C     ILLEGAL CHARACTERS IN DMAP SAVE PARAMETER NAME LIST        
C        
 2260 CALL XGPIDG (20,OSPNT,OSCAR(I)+1,0)        
      GO TO 870        
C        
C     XSAVE PARAMETER NAME NOT ON PRECEDING DMAP CARD        
C        
 2270 CALL XGPIDG (21,OSPNT,DMAP(DMPPNT),DMAP(DMPPNT+1))        
      GO TO 870        
C        
C     CEITBL OVERFLOW, DISCONTINUE COMPILATION        
C        
 2280 CALL XGPIDG (14,NCEIT1,NCEIT2,DMPCNT)        
      GO TO 2500        
C        
C     CHECK FOR XSAVE PARAMETERS NOT ON PRECEDING DMAP CARD        
C        
 2290 I1 = I + 2        
      K  = K + 1        
      DO 2300 K1 = I1,K,2        
      IF (OSCAR(K1).GT.0 .OR. OSCAR(K1-1).EQ.0) GO TO 2300        
      J = OSCAR(K1-1)        
      CALL XGPIDG (21,OSPNT,VPS(J-3),VPS(J-2))        
 2300 CONTINUE        
      GO TO 300        
C        
C     PARAMETER NOT DEFINED FOR USE IN COND, PURGE OR EQUIV INSTRUCTIONS
C        
 2310 CALL XGPIDG (25,LBLTBL(LSTPAR+3),LBLTBL(LSTPAR),LBLTBL(LSTPAR+1)) 
      GO TO 1940        
C        
C     LABEL NOT DEFINED        
C        
 2320 CALL XGPIDG (26,LBLTBL(LSTLBL+3),LBLTBL(LSTLBL),LBLTBL(LSTLBL+1)) 
      NOGO = 1        
      GO TO 2040        
C        
C     CHECK FOR LABEL DEFINED        
C        
 2330 DO 2340 J = LBLTOP,LSTLBL,4        
      IF (LBLTBL(J).EQ.LBLTBL(LSTLBL) .AND. LBLTBL(J+1).EQ.        
     1    LBLTBL(LSTLBL+1) .AND. LBLTBL(J+2).GT.0) GO TO 2350        
 2340 CONTINUE        
      GO TO 2320        
 2350 LBLTBL(LSTLBL+2) = LBLTBL(J+2)        
      GO TO 2010        
C        
C     LABEL NOT REFERENCED - WARNING ONLY        
C        
 2360 CALL XGPIDG (-27,LBLTBL(LSTLBL+2),LBLTBL(LSTLBL),LBLTBL(LSTLBL+1))
      GO TO 2040        
C        
C     TIME SEGMENT NAME INCORRECT - WARNING ONLY        
C        
 2370 CALL XGPIDG (-17,OSPNT,0,0)        
      GO TO 300        
C        
C     VPS TABLE OVERFLOWED        
C        
 2380 CALL XGPIDG (14,NVPS,NBLANK,0)        
      GO TO 2500        
C        
C     DMAP SEQUENCE DOES NOT CORRESPOND TO MED TABLE        
C        
 2390 CALL XGPIDG (39,0,0,0)        
      GO TO 2500        
C        
C     WARNING - CANNOT CHECKPOINT USER INPUT        
C        
 2400 CALL XGPIDG (-48,OSPNT,OSCAR(IOSPNT),OSCAR(IOSPNT+1))        
      GO TO 1030        
C        
C     OVERFLOWED FILE TABLE        
C        
 2410 CALL XGPIDG (14,NFILE,NBLANK,0)        
      GO TO 2500        
C        
C     SAVE OUT OF POSITION        
C        
 2420 CALL XGPIDG (61,OSPNT,0,0)        
      OSPNT = IOSDAV        
      OSPRC = OS2B4        
      GO TO 300        
C        
C     RETURN WHEN XGPI HAS BEEN DISASTERED.        
C        
 2500 NOGO = 2        
      RETURN        
      END        
C        
C              TABLE OF OLD(90) vs. NEW(91) STATEMENT NUMBERS        
C        
C     OLD NO.    NEW NO.      OLD NO.    NEW NO.      OLD NO.    NEW NO.
C    --------------------    --------------------    -------------------
C         30         10          564        960         3516       1690 
C         35        100          570        970         3517       1700 
C        351        110          576        980         3518       1710 
C         36        120          580        990         3520       1720 
C         40        130          582       1000         3525       1730 
C         41        140          584       1010         3600       1740 
C         43        150          585       1020         3610       1750 
C         42        160          587       1030         3620       1760 
C         49        170          588       1040         3630       1770 
C         46        180          594       1050         3640       1780 
C         47        190          595       1060         3650       1790 
C         37        200          596       1070         3660       1800 
C         45        210          598       1080         3670       1810 
C         48        220          599       1090         3680       1820 
C         50        230          593       1100          630       1900 
C         55        240          597       1110          633       1910 
C         60        300          600       1200          635       1920 
C         80        310         6000       1210          640       1930 
C         85        320         6005       1220          645       1940 
C        200        400         6010       1230          646       1950 
C        205        410         6013       1240         6460       1960 
C        210        420         6015       1250         6465       1970 
C        220        430          601       1260         6468       1980 
C        221        440          602       1270          650       1990 
C        225        450          605       1280          655       2000 
C        226        460          606       1290          665       2010 
C        400        500          610       1300          666       2020 
C        405        510          612       1310          670       2030 
C        410        520          613       1320          660       2040 
C        415        530          620       1330          798       2050 
C        416        540          625       1340          800       2060 
C        420        550          603       1350          100       2100 
C        430        560         6930       1360          105       2110 
C        431        570         6030       1370          110       2120 
C        435        580         6031       1380          115       2130 
C        440        590         6032       1390          117       2140 
C        450        600         6132       1400          120       2150 
C        451        610         6033       1410          125       2160 
C        454        620         6133       1420          126       2170 
C        460        630         6034       1430          127       2180 
C        465        640         6035       1440          128       2190 
C        467        650         6036       1450          151       2200 
C        468        660         6037       1460          152       2210 
C        480        670         6038       1470          129       2220 
C        482        680         6039       1480          133       2230 
C        481        690         3000       1490          130       2240 
C        466        700         3001       1500          135       2250 
C        469        710         3003       1510          140       2260 
C        470        720         3002       1520          145       2270 
C        500        800         3004       1530          150       2280 
C        503        810         3005       1540          155       2290 
C        505        820         3006       1550          158       2300 
C        510        830         3010       1560          160       2310 
C        515        840         3400       1570          165       2320 
C        520        850         3500       1580          167       2330 
C        540        860         3501       1590          168       2340 
C        545        870        35015       1600          169       2350 
C        550        880         3502       1610          170       2360 
C        552        890         3503       1620          175       2370 
C        554        900         3504       1630          180       2380 
C        553        910         3511       1640          185       2390 
C        551        920         3512       1650          190       2400 
C        555        930         3513       1660          195       2410 
C        560        940         3514       1670          196       2420 
C        562        950         3515       1680          790       2500 
