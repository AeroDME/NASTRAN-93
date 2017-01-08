      SUBROUTINE GP2        
C        
C     GP2 BUILDS THE ELEMENT CONNECTION TABLE (ECT).        
C     STRUCTURAL ELEMENT CONNECTION CARDS ARE ON GEOM2.        
C     EACH EXTERNAL GRID PT. NO. IS CONVERTED TO AN INTERNAL INDEX.     
C     IN ADDITION, GENERAL ELEMENT CARDS ARE READ AND        
C     EXTERNAL GRID NUMBERS ARE CONVERTED TO INTERNAL NUMBERS.        
C        
C        
      INTEGER         ELEM  ,SYSBUF,BUF1  ,BUF2  ,EQEXIN,RD    ,RDREW , 
     1                WRT   ,WRTREW,CLSREW,CLS   ,ECT   ,GEOMP ,B     , 
     2                FILE  ,Z     ,GENEL ,GEOM2 ,RET   ,RET1  ,GP2H  , 
     3                CBAR  ,CBEAM ,BUF3  ,TWO        
      DIMENSION       B(34) ,GP2H(2)      ,MCB(7)       ,GENEL(2)       
      COMMON /BLANK / NOECT        
CZZ   COMMON /ZZGP2X/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /GPTA1 / NELEM ,LAST  ,INCR  ,ELEM(1)        
      COMMON /SYSTEM/ SYSBUF,JUNK(36)     ,IAXIF ,NBPC  ,NBPW        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW,CLS        
      COMMON /SETUP / NFILE(6)        
      COMMON /TWO   / TWO(32)        
      EQUIVALENCE     (GEOMP,GEOM2)        
C        
C     INPUT  DATA FILES        
      DATA   GEOM2,EQEXIN / 101,102 /        
C        
C     OUTPUT DATA FILES        
      DATA   ECT / 201 /        
C        
C     MISC   DATA        
      DATA   GP2H/ 4HGP2 ,4H    /, CBAR / 4HBAR /, CBEAM / 4HBEAM /     
C        
C     GENEL DATA CARDS PROCESSED BY GP2 IN ADDITION TO ELEMENTS.        
      DATA  GENEL / 4301, 43 /        
C        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      CALL DELSET        
      BUF1  = KORSZ(Z) - SYSBUF - 2        
      BUF2  = BUF1 - SYSBUF        
      NOECT = -1        
      BUF3  = BUF2 - SYSBUF        
      MCB(1)= GEOM2        
      CALL RDTRL (MCB)        
C        
C     READ EQEXIN INTO CORE        
C        
      FILE = EQEXIN        
      CALL OPEN (*580,EQEXIN,Z(BUF1),RDREW)        
      CALL FWDREC (*590,EQEXIN)        
      CALL READ (*590,*30,EQEXIN,Z,BUF2,1,N)        
      CALL MESAGE (-8,0,GP2H)        
   30 CALL CLOSE (EQEXIN,CLSREW)        
      KN = N/2        
      N1 = N + 1        
C        
C     OPEN GEOM2. IF PURGED, RETURN.        
C     OTHERWISE, OPEN ECT AND WRITE HEADER RECORD.        
C        
      NOGEO2 = 0        
      CALL PRELOC (*50,Z(BUF1),GEOM2)        
      NOGEO2 = 1        
      GO TO 60        
   50 RETURN        
C        
   60 NOECT = 1        
      NOGO  = 0        
      FILE  = ECT        
      CALL OPEN (*580,ECT,Z(BUF2),WRTREW)        
      CALL FNAME (ECT,B)        
      CALL WRITE (ECT,B,2,1)        
C        
C     READ 3-WORD ID FROM GEOM2. SEARCH ELEMENT TABLE FOR MATCH.        
C     IF FOUND, BRANCH TO ELEMENT CODE. IF NOT FOUND, SEARCH GENEL      
C     TABLE  FOR MATCH. IF FOUND BRANCH TO APPROPRIATE CODE. IF NOT     
C     FOUND, SKIP RECORD AND CONTINUE.        
C        
   70 CALL READ (*460,*600,GEOM2,B,3,0,FLAG)        
      DO 80 I = 1,LAST,INCR        
      IF (ELEM(I+3) .EQ. B(1)) GO TO 120        
   80 CONTINUE        
      IF (GENEL(1) .EQ. B(1)) GO TO 110        
      CALL FWDREC (*460,GEOM2)        
      GO TO 70        
  110 K = (I+1)/2        
      GO TO 280        
C        
C     WRITE 3-WORD ID ON ECT. READ ALL CARDS FOR ELEMENT AND        
C     CONVERT EXTERNAL GRID NOS. TO INTERNAL NOS.  WRITE ENTRIES ON ECT 
C     DIRECTLY AFTER CONVERSION.        
C        
  120 ASSIGN 170 TO RET        
      ASSIGN 630 TO RET1        
      CALL WRITE (ECT,B,3,0)        
      M  = ELEM(I+5)        
      LX = ELEM(I+12)        
      MM = LX + ELEM(I+9)        
      NAME = ELEM(I)        
      II   = N1        
      FILE = GEOM2        
  150 CALL READ (*590,*270,FILE,B,M,0,FLAG)        
C        
C     CHECK LATER TO SEE IF RESTRICTION APPLIES TO AXIF PROBLEMS        
C        
      IF (IAXIF .NE. 0) GO TO 155        
      IF (NBPW.LE.32 .AND. B(1).GT.16777215) GO TO 670        
C                                  16777215 = 2**24 - 1        
  155 L = LX        
  160 IF (B(L) .NE. 0) GO TO 470        
  170 L= L + 1        
      IF (L    .LT.    MM) GO TO 160        
      IF (NAME .EQ. CBEAM) GO TO 180        
      IF (NAME .NE.  CBAR) GO TO 200        
C        
C     SPECIAL PROCESSING FOR BAR AND BEAM ELEMENTS        
C        
      IF (B(8) .EQ. 1) GO TO 200        
      ASSIGN 190 TO RET        
      L = 5        
      GO TO 470        
  180 IF (B(8) .EQ. 0) GO TO 200        
      ASSIGN 190 TO RET        
      L = 8        
      GO TO 470        
  190 ASSIGN 170 TO RET        
C        
  200 CALL WRITE (ECT,B,M,0)        
      GO TO 150        
C        
C     CURRENT ELEMENT IS COMPLETE        
C        
  270 CALL WRITE (ECT,0,0,1)        
      GO TO 70        
C        
C     GENERAL ELEMENTS-- WRITE 3-WORD ID ON ECT. READ ALL GENELS,       
C     CONVERT EXTERNAL GRID NOS. TO INTERNAL NOS. AND WRITE THEM ON ECT.
C        
  280 CALL WRITE (ECT,B,3,0)        
      FILE = GEOM2        
      L = 2        
      ASSIGN 310 TO RET        
      ASSIGN 640 TO RET1        
  290 IJK = 0        
      CALL READ (*590,*360,GEOM2,B,1,0,FLAG)        
      CALL WRITE (ECT,B,1,0)        
  300 CALL READ (*590,*600,GEOM2,B(2),2,0,FLAG)        
      IF (B(2) .EQ. -1) GO TO 320        
      GO TO 470        
  310 CALL WRITE (ECT,B(2),2,0)        
      GO TO 300        
  320 NUD = B(3)        
      IF (IJK .NE. 0) GO TO 330        
      NUI = B(3)        
      IJK = 1        
      GO TO 310        
  330 CALL WRITE (ECT,B(2),2,0)        
      CALL READ (*590,*600,GEOM2,IJK1,1,0,FLAG)        
      CALL WRITE (ECT,IJK1,1,0)        
      NCORE = BUF2 - N1        
      NZ = (NUI*(NUI+1))/2        
      NREAD = 0        
  340 N= MIN0(NCORE,NZ-NREAD)        
      CALL READ (*590,*600,GEOM2,Z(N1),N,0,FLAG)        
      CALL WRITE (ECT,Z(N1),N,0)        
      NREAD = NREAD + N        
      IF (NREAD .LT. NZ) GO TO 340        
      CALL READ (*590,*600,GEOM2,IJK,1,0,FLAG)        
      CALL WRITE (ECT,IJK,1,0)        
      IF (IJK .EQ. 0) GO TO 290        
      NS = NUI*NUD        
      NREAD = 0        
  350 N= MIN0(NCORE,NS-NREAD)        
      CALL READ (*590,*600,GEOM2,Z(N1),N,0,FLAG)        
      CALL WRITE (ECT,Z(N1),N,0)        
      NREAD = NREAD + N        
      IF (NREAD .LT. NS) GO TO 350        
      GO TO 290        
  360 CALL WRITE (ECT,0,0,1)        
      GO TO 70        
C        
C     CLOSE FILES, WRITE TRAILER AND RETURN.        
C        
  460 CALL CLOSE (GEOM2,CLSREW)        
      CALL CLOSE (ECT  ,CLSREW)        
      MCB(1) = GEOM2        
      CALL RDTRL (MCB)        
      MCB(1) = ECT        
      CALL WRTTRL (MCB)        
      IF (NOGO .NE. 0) CALL MESAGE (-61,0,0)        
      RETURN        
C        
C        
C     INTERNAL BINARY SEARCH ROUTINE        
C     ==============================        
C        
  470 KLO = 1        
      KHI = KN        
      IGRID = B(L)        
  480 K = (KLO+KHI+1)/2        
  490 IF (IGRID-Z(2*K-1)) 500,560,510        
  500 KHI = K        
      GO TO 520        
  510 KLO = K        
  520 IF (KHI-KLO-1) 570,530,480        
  530 IF (K .EQ. KLO) GO TO 540        
      K = KLO        
      GO TO 550        
  540 K = KHI        
  550 KLO = KHI        
      GO TO 490        
  560 B(L) = Z(2*K)        
      GO TO RET,  (170,310,190)        
  570 GO TO RET1, (630,640)        
C        
C        
C     FATAL ERROR MESSAGES        
C        
  580 J = -1        
      GO TO 610        
  590 J = -2        
      GO TO 610        
  600 J = -3        
  610 CALL MESAGE (J,FILE,GP2H)        
  630 K = 7        
      GO TO 660        
  640 K = 61        
  660 B(2) = IGRID        
      CALL MESAGE (30,K,B)        
      NOGO = 1        
      GO TO RET, (170,310)        
  670 NOGO = 1        
      CALL MESAGE (30,138,B)        
      GO TO 155        
      END        
