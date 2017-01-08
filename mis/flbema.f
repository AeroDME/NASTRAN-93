      SUBROUTINE FLBEMA (TYPE)        
C        
C     ASSEMBLES THE AF OR DKGG MATRIX UTITLIZING THE ELEMENT        
C     MATRICES GENERATED IN FLBEMG        
C        
C     TYPE = 1  AFF MATRIX        
C     TYPE = 2  DKGG MATRIX        
C        
      LOGICAL         ERROR    ,SKIP        
      INTEGER         GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT      ,
     1                GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF    ,
     2                USETS    ,AF       ,DKGG     ,FBELM    ,FRELM    ,
     3                CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT   ,
     4                TYPE     ,OUTMAT   ,XMAT     ,XDICT    ,Z        ,
     5                FILE     ,NAME(2)  ,MCB(7)   ,ALLOC(3) ,DICT(2)  ,
     6                TYPIN    ,TYPOUT   ,ROWSIL(4),COLSIL(12)         ,
     7                OPTC     ,OPTW     ,RD       ,RDREW    ,WRT      ,
     8                WRTREW   ,REW      ,NOREW    ,TERMS(288)        
      CHARACTER       UFM*23   ,UWM*25   ,UIM*29   ,SFM*25        
      COMMON /XMSSG / UFM      ,UWM      ,UIM      ,SFM        
      COMMON /FLBFIL/ GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT      ,
     1                GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF    ,
     2                USETS    ,AF       ,DKGG     ,FBELM    ,FRELM    ,
     3                CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT    
CZZ   COMMON /ZZFLB2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /FLBPTR/ ERROR    ,ICORE    ,LCORE    ,IBGPDT   ,NBGPDT   ,
     1                ISIL     ,NSIL     ,IGRAV    ,NGRAV    ,IGRID    ,
     2                NGRID    ,IBUF1    ,IBUF2    ,IBUF3    ,IBUF4    ,
     3                IBUF5        
      COMMON /SYSTEM/ SYSBUF   ,NOUT        
      COMMON /NAMES / RD       ,RDREW    ,WRT      ,WRTREW   ,REW      ,
     1                NOREW        
      DATA    NAME  / 4HFLBE,4HMA   /        
C        
C        
C     ASSIGN FILES DEPENDING ON TYPE        
C        
      GO TO (2,4), TYPE        
C        
C     AF MATRIX        
C        
    2 OUTMAT = AF        
      XMAT   = AFMAT        
      XDICT  = AFDICT        
      GO TO 6        
C        
C     DKGG MATRIX        
C        
    4 OUTMAT = DKGG        
      XMAT   = KGMAT        
      XDICT  = KGDICT        
C        
C     ALLOCATE COLUMN POINTER VECTOR IN TOP OF CORE        
C        
    6 MCB(1) = USET        
      CALL RDTRL(MCB)        
      LUSET = MCB(3)        
      ICOL  = 1        
      NCOL  = LUSET        
      DO 10 I = 1,NCOL        
   10 Z(I) = 0        
C        
C     INITILIZE OPEN AND CLOSE OPTIONS        
C        
      OPTW = WRTREW        
      OPTC = NOREW        
C        
C     POSITION CONNECT FILE TO PROPER RECORD        
C        
      FILE = CONECT        
      CALL OPEN (*1001,CONECT,Z(IBUF1),RDREW)        
      IF (TYPE .EQ. 2) CALL SKPFIL (CONECT,1)        
      CALL FWDREC (*1002,CONECT)        
      CALL CLOSE (CONECT,NOREW)        
C        
C     INITIALIZE PACK - UNPACK DATA        
C        
      TYPIN  = 2        
      TYPOUT = 2        
      MCB(1) = OUTMAT        
      MCB(2) = 0        
      MCB(3) = LUSET        
      MCB(4) = 3 - TYPE        
      MCB(5) = TYPOUT        
      MCB(6) = 0        
      MCB(7) = 0        
C        
C     SET UP CORE POINTERS        
C        
      ICORE = NCOL  + 1        
      LCORE = IBUF2 - 1        
      NCORE = LCORE - ICORE        
      IF (NCORE .LT. 200) GO TO 1008        
C        
      SKIP  = .FALSE.        
      ILCOL = 0        
C        
C        
C     ALLOCATE ALL AVALABLE CORE FOR THIS PASS BY USE OF CONECT FILE    
C        
   30 IFCOL = ILCOL + 1        
      JCORE = ICORE        
      FILE  = CONECT        
C        
      CALL GOPEN (CONECT,Z(IBUF1),RD)        
C        
      IF (SKIP) GO TO 60        
   50 CALL READ (*70,*1008,CONECT,ALLOC,3,1,N)        
C        
   60 ISIL     = ALLOC(1)        
      Z(ISIL)  = JCORE        
      Z(JCORE) = JCORE + 1        
      JCORE    = JCORE + 1 + ALLOC(2) + 2*ALLOC(3)        
      IF(JCORE .GT. LCORE ) GO TO 80        
      ILCOL = ISIL        
      GO TO 50        
C        
C     END OF RECORD ON CONECT - ALL COLUMNS ALLOCATED        
C        
   70 ILCOL = LUSET        
      OPTC  = REW        
      GO TO 90        
C        
C     INSUFFICIENT CORE FOR NEXT COLUMN - SET FLAG TO SAVE CURRENT      
C     CONECT ALLOCATION RECORD        
C        
   80 SKIP = .TRUE.        
C        
   90 CALL CLOSE (CONECT,OPTC)        
C        
C     OPEN DICTIONARY AND MATRIX FILES AND PREPARE TO MAKE PASS        
C        
      CALL GOPEN (XDICT,Z(IBUF1),RDREW)        
      CALL GOPEN (XMAT,Z(IBUF2),RDREW)        
      ICPOS = 0        
C        
C     READ XDICT ENTRY AND DETERMINE IF COLUMN IS IN CORE FOR THIS      
C     PASS        
C        
  100 FILE = XDICT        
      CALL READ (*1002,*200,XDICT,DICT,2,0,N)        
      ISIL = DICT(1)        
      IF (ISIL.LT.IFCOL .OR. ISIL.GT.ILCOL) GO TO 100        
C        
C     THE COLUMN IS IN CORE - OBTAIN MATRIX DATA FROM XMAT FILE IF      
C     WE DO NOT ALREADY HAVE IT        
C        
      IF (DICT(2) .EQ. ICPOS) GO TO 150        
      ICPOS = DICT(2)        
      FILE  = XMAT        
      CALL FILPOS (XMAT,ICPOS)        
      CALL READ (*1002,*1003,XMAT,ROWSIL,4,0,N)        
      CALL READ (*1002,*1003,XMAT,COLSIL,4,0,N)        
      NROW  = 4        
      IF (ROWSIL(4) .LT. 0) NROW = 3        
      NCOL  = 4        
      IF (COLSIL(4) .LT. 0) NCOL = 3        
      CALL READ (*1002,*110,XMAT,TERMS,289,0,NWDS)        
      ICODE = 1        
      GO TO 8010        
C        
C     EXPAND COLSIL TO INCLUDE ALL SILS        
C        
  110 IF(NWDS .LT. 162) GO TO 130        
      DO 120 I = 1,4        
      J = 4 - I        
      COLSIL(3*J+1) = COLSIL(J+1)        
      COLSIL(3*J+2) = COLSIL(J+1) + 1        
  120 COLSIL(3*J+3) = COLSIL(J+1) + 2        
      NCOL   = NCOL * 3        
  130 NTPERS = 2        
      IF(NWDS .LT. 54) GO TO 150        
      NTPERS = 6        
C        
C     LOCATE POSITION OF MATRIX TERMS FOR DESIRED SIL        
C        
  150 DO 160 KCOL = 1,NCOL        
      IF (COLSIL(KCOL) .EQ. ISIL) GO TO 170        
  160 CONTINUE        
      ICODE = 2        
      GO TO 8010        
C        
  170 ILOC = (KCOL-1)*NROW*NTPERS + 1        
C        
C     EXTRACT MATRIX TERMS AND STORE THEM IN CORE        
C        
      ICODE = 3        
      JCORE = Z(ISIL)        
      IF (JCORE .EQ. 0) GO TO 8010        
      KCORE = Z(JCORE)        
      DO 190 I = 1,NROW        
      Z(KCORE) = ROWSIL(I)        
      IF (NTPERS .EQ. 2) Z(KCORE) = -ROWSIL(I)        
      KCORE = KCORE + 1        
      DO 180 J = 1,NTPERS        
      Z(KCORE) = TERMS(ILOC)        
      ILOC  = ILOC  + 1        
  180 KCORE = KCORE + 1        
  190 CONTINUE        
      Z(JCORE) = KCORE        
C        
      GO TO 100        
C        
C     END OF FILE ON XDICT - PREPARE TO PACK OUT COLUMNS IN CORE        
C        
  200 CALL CLOSE (XDICT,OPTC)        
      CALL CLOSE (XMAT,OPTC)        
      CALL GOPEN (OUTMAT,Z(IBUF1),OPTW)        
C        
C     PACK OUT COLUMNS        
C        
      DO 210 I = IFCOL,ILCOL        
      CALL BLDPK (TYPIN,TYPOUT,OUTMAT,0,0)        
      IF (Z(I) .EQ. 0) GO TO 210        
C        
      ILOC = Z(I) + 1        
      NLOC = Z(ILOC-1) - ILOC        
      CALL PAKCOL (Z(ILOC),NLOC)        
C        
  210 CALL BLDPKN (OUTMAT,0,MCB)        
C        
      CALL CLOSE (OUTMAT,OPTC)        
C        
C     RETURN FOR ADDITIONAL PASS IF MORE NONZERO COLUMNS REMAIN        
C        
      OPTW = WRT        
      IF (ILCOL .LT. LUSET) GO TO 30        
C        
C     ALL COLUMNS PROCESSED - WRITE TRAILER AND RETURN        
C        
      CALL WRTTRL (MCB)        
      RETURN        
C        
C     ERROR CONDITIONS        
C        
 1001 N = -1        
      GO TO 1100        
 1002 N = -2        
      GO TO 1100        
 1003 N = -3        
      GO TO 1100        
 1008 N = -8        
      GO TO 1100        
C        
 1100 CALL MESAGE (N,FILE,NAME)        
C        
 8010 WRITE  (NOUT,9010) SFM,ICODE        
 9010 FORMAT (A25,' 8010, LOGIC ERROR IN SUBROUTINE FLBEMA - CODE',I3/) 
      N = -61        
      GO TO 1100        
      END        
