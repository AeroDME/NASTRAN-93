      SUBROUTINE PLTMRG        
C        
C     MODULE PLTMRG WRITES GINO DATA BLOCKS WHICH ARE USED AS INPUT TO  
C     THE PLOT MODULE FOR PLOTTING A SUBSTRUCTURE.        
C        
C     APRIL 1974        
C        
      LOGICAL IDENT        
      INTEGER BUF      ,SYSBUF   ,Z(3)     ,CASESS   ,PCDB    ,        
     1        PLTP     ,GPS      ,ELS      ,BGP      ,CASEP   ,        
     2        EQEX     ,SCR1     ,SRD      ,PLTS     ,FILE    ,        
     3        EQSS     ,SUBR(2)  ,CASECC(2),BUF1     ,ELID    ,        
     4        BUF2     ,BUF3     ,BUF4     ,BUF5     ,RC      ,        
     5        BAR      ,QUAD4    ,TRIA3    ,OFFSET        
      REAL    RZ        
      COMMON /BLANK /   NAME(2)  ,NGPTOT   ,LSIL     ,NPSET   ,        
     1                  NM(2)    ,BUF(7)        
      COMMON /SYSTEM/   SYSBUF        
      COMMON /NAMES /   RD       ,RDREW    ,WRT      ,WRTREW  ,        
     1                  REW      ,NOREW        
CZZ   COMMON /ZZPLTM/   RZ(1)        
      COMMON /ZZZZZZ/   RZ(1)        
      EQUIVALENCE       (Z(1),RZ(1))        
      DATA    PLTS  ,   EQSS     ,SUBR               ,CASECC          / 
     1        4HPLTS,   4HEQSS   ,4HPLTM   ,4HRG     ,4HCASE   ,4HCC  / 
      DATA    CASESS,   PCDB     ,PLTP     ,GPS      ,ELS      /        
     1        101   ,   102      ,201      ,202      ,203      /,       
     2        BGP   ,   CASEP    ,EQEX     ,SCR1     ,SRD      /        
     3        204   ,   205      ,206      ,301      ,1        /,       
     4        BAR   ,   QUAD4    ,TRIA3                        /        
     5        2HBR  ,   2HQ4     ,2HT3                         /        
C        
C     INITIALIZE        
C        
      NCORE = KORSZ(Z)        
      BUF1  = NCORE- SYSBUF + 1        
      BUF2  = BUF1 - SYSBUF        
      BUF3  = BUF2 - SYSBUF        
      BUF4  = BUF3 - SYSBUF        
      BUF5  = BUF4 - SYSBUF        
      NCORE = BUF5 - 1        
      NGPTOT= 0        
      LSIL  = 0        
      NPSET =-1        
      IF (NCORE .LE. 0) GO TO 9008        
      CALL SOFOPN (Z(BUF3),Z(BUF4),Z(BUF5))        
C        
C     STRIP SUBSTRUCTURE RECORDS FROM CASESS AND WRITE CASEP (CASECC)   
C        
      FILE = CASESS        
      CALL OPEN (*9001,CASESS,Z(BUF1),RDREW)        
      FILE = CASEP        
      CALL OPEN  (*9001,CASEP,Z(BUF2),WRTREW)        
      CALL FNAME (CASEP,BUF)        
      CALL WRITE (CASEP,BUF,2,1)        
      FILE = CASESS        
   10 CALL READ (*9002,*9003,CASESS,Z,2,1,NWDS)        
      IF (Z(1).NE.CASECC(1) .OR. Z(2).NE.CASECC(2)) GO TO 10        
   20 CALL READ (*40,*30,CASESS,Z,NCORE,1,NWDS)        
      GO TO 9008        
   30 CALL WRITE (CASEP,Z,NWDS,1)        
      GO TO 20        
   40 CALL CLSTAB (CASEP,REW)        
      CALL CLOSE  (CASESS,REW)        
C        
C     BASIC GRID POINT DATA        
C        
      NM(1) = NAME(1)        
      NM(2) = NAME(2)        
      ITEM  = PLTS        
      CALL SFETCH (NAME,PLTS,SRD,RC)        
      IF (RC .NE. 1) GO TO 6100        
C        
C     READ SUBSTRUCTURE NAMES AND TRANSFORMATION DATA INTO OPEN CORE.   
C        
      CALL SUREAD (Z,3,NWDS,RC)        
      IF (RC .NE. 1) GO TO 6106        
      NSS = Z(3)        
      IF (14*NSS .GT. NCORE) GO TO 9008        
      CALL SUREAD (Z,14*NSS,NWDS,RC)        
      IF (RC .NE. 1) GO TO 6106        
      ICORE = 14*NSS + 1        
C        
C     READ THE BASIC GRID POINT DATA FROM THE PLTS ITEM OF EACH BASIC   
C     SUBSTRUCTURE COMPRISING THE PSEUDOSTRUCTURE TO BE PLOTTED.        
C     TRANSFORM THE COORDINATES TO THE BASIC COORDINATE SYSTEM OF THE   
C     PSEUDOSTRUCTURE AND WRITE THEM ON BGP (BGPDT).        
C        
      FILE = BGP        
      CALL OPEN (*9001,BGP,Z(BUF1),WRTREW)        
      CALL FNAME (BGP,BUF)        
      CALL WRITE (BGP,BUF,2,1)        
      J = 1        
  120 NM(1) = Z(J  )        
      NM(2) = Z(J+1)        
      NGP = 0        
      CALL SFETCH (NM,PLTS,SRD,RC)        
      IF (RC .EQ. 1) GO TO 130        
      CALL SMSG (RC-2,PLTS,NM)        
      GO TO 170        
  130 I = 1        
      CALL SJUMP (I)        
      IDENT = .FALSE.        
      DO 140 I = 1,3        
      IF (Z(J+I+1) .NE. 0) GO TO 150        
      IF (Z(J+I+5) .NE. 0) GO TO 150        
      IF (Z(J+I+9) .NE. 0) GO TO 150        
      IF (ABS(RZ(J+4*I+1)-1.0) .GT. 1.0E-4) GO TO 150        
  140 CONTINUE        
      IDENT = .TRUE.        
  150 CALL SUREAD (BUF,4,NWDS,RC)        
      IF (RC .EQ. 2) GO TO 170        
      NGP = NGP + 1        
      IF (IDENT .OR. BUF(1).LT.0) GO TO 160        
      BUF(5) = Z(J+2)        
      BUF(6) = Z(J+3)        
      BUF(7) = Z(J+4)        
      CALL GMMATS (Z(J+5),3,3,-2,BUF(2),3,1,0,BUF(5))        
      CALL WRITE (BGP,BUF,1,0)        
      CALL WRITE (BGP,BUF(5),3,0)        
      GO TO 150        
  160 CALL WRITE (BGP,BUF,4,0)        
      GO TO 150        
  170 NGPTOT = NGPTOT+NGP        
      Z(J+2) = NGP        
      J = J + 14        
      IF (J .LT. ICORE) GO TO 120        
      CALL WRITE (BGP,0,0,1)        
      CALL CLOSE (BGP,REW)        
      BUF(1) = BGP        
      BUF(2) = NGPTOT        
      DO 180 I = 3,7        
  180 BUF(I) = 0        
      CALL WRTTRL (BUF)        
C        
C     ALLOCATE 5 WORDS PER COMPONENT BASIC SUBSTRUCTURE AT THE TOP OF   
C     OPEN CORE.  THIS ARRAY IS HEREINAFTER REFERRED TO AS *SDATA*      
C        
C     SAVE THE BASIC SUBSTRUCTURE NAMES AND THE NUMBER OF STRUCTURAL    
C     GRID POINTS IN EACH IN SDATA.  DO NOT SAVE SUBSTRUCTURES FOR      
C     WHICH NO PLTS ITEM WAS FOUND.        
C        
      J = 1        
      DO 190 I = 1,NSS        
      IF (Z(14*I-11) .EQ. 0) GO TO 190        
      Z(J  ) = Z(14*I-13)        
      Z(J+1) = Z(14*I-12)        
      Z(J+2) = Z(14*I-11)        
      J = J + 5        
  190 CONTINUE        
      IF (J .LE. 1) GO TO 9200        
      NSS = J/5        
      ISX = NSS*5        
      ICORE = J        
      LCORE = NCORE - J + 1        
C        
C     COMPUTE EQEX (EQEXIN)        
C        
C        
C     READ THE EQEXIN DATA FROM THE PLTS ITEM OF EACH BASIC SUBSTRUCTURE
C     USE THREE WORDS IN OPEN CORE FOR EACH GRID POINT   (1) EXTERNAL   
C     ID, (2) INTERNAL ID, (3) SUBSTRUCTURE SEQUENCE NUMBER IN SDATA.   
C     INCREMENT THE INTERNAL IDS BY THE NUMBER OF GRID POINTS ON THE    
C     PRECEDING SUBSTRUCTURES.        
C        
      K   = ICORE        
      NGP = 0        
      DO 210 I = 1,NSS        
      NM(1) = Z(5*I-4)        
      NM(2) = Z(5*I-3)        
      CALL SFETCH (NM,PLTS,SRD,RC)        
      N = 2        
      CALL SJUMP (N)        
      RC = 3        
      IF (N .LT. 0) GO TO 6106        
      N = Z(5*I-2)        
      DO 200 J = 1,N        
      CALL SUREAD (Z(K),2,NWDS,RC)        
      IF (RC .NE. 1) GO TO 6106        
      Z(K+1) = Z(K+1) + NGP        
      Z(K+2) = I        
      K = K + 3        
      IF (K+2 .GT. NCORE) GO TO 9008        
  200 CONTINUE        
      NGP = NGP + N        
  210 CONTINUE        
C        
C     SORT ON EXTERNAL IDS AND WRITE RECORD 1 OF EQEX.        
C        
      CALL SORT (0,0,3,1,Z(ICORE),3*NGP)        
      FILE = EQEX        
      CALL OPEN (*9001,EQEX,Z(BUF1),WRTREW)        
      CALL FNAME (EQEX,BUF)        
      CALL WRITE (EQEX,BUF,2,1)        
      DO 220 I = 1,NGP        
  220 CALL WRITE (EQEX,Z(ICORE+3*I-3),2,0)        
      CALL WRITE (EQEX,0,0,1)        
C        
C     SAVE THE TABLE IN OPEN CORE ON SCR1 TO USE IN COMPUTING RECORD 2  
C     OF EQEX        
C        
      FILE = SCR1        
      CALL OPEN  (*9001,SCR1,Z(BUF2),WRTREW)        
      CALL WRITE (SCR1,Z(ICORE),3*NGP,1)        
      CALL CLOSE (SCR1,REW)        
      CALL OPEN  (*9001,SCR1,Z(BUF2),RDREW)        
C        
C     READ GROUP 0 OF THE EQSS ITEM OF THE SUBSTRUCTURE TO BE PLOTTED   
C     INTO OPEN CORE AT ICORE.  READ THE EXTERNAL AND INTERNAL IDS FOR  
C     EACH CONTRIBUTING BASIC SUBSTRUCTURE INTO OPEN CORE FOLLOWING     
C     GROUP 0.  SAVE THE CORE POINTERS FOR EACH GROUP IN SDATA.        
C        
      NM(1) = NAME(1)        
      NM(2) = NAME(2)        
      ITEM  = EQSS        
      CALL SFETCH (NAME,EQSS,SRD,RC)        
      IF (RC .NE. 1) GO TO 6100        
      CALL SUREAD (Z(ICORE),LCORE,NWDS,RC)        
      IF (RC .NE. 2) GO TO 9008        
      K   = ICORE + NWDS        
      N   = Z(ICORE+2)        
      ISS = 1        
      DO 250 I = 1,N        
      IF (ISS .GT. ISX) GO TO 240        
      IF (Z(ICORE+2*I+2).NE.Z(ISS) .OR. Z(ICORE+2*I+3).NE.Z(ISS+1))     
     1    GO TO 240        
      Z(ISS+3) = K        
  230 IF (K+2 .GT. NCORE) GO TO 9008        
      CALL SUREAD (Z(K),3,NWDS,RC)        
      K = K + 2        
      IF (RC .EQ. 1) GO TO 230        
      Z(ISS+4) = (K-Z(ISS+3))/2        
      ISS = ISS + 5        
      GO TO 250        
  240 J = 1        
      CALL SJUMP (J)        
  250 CONTINUE        
C        
C     READ SIL NUMBERS INTO OPEN CORE.        
C        
      KSIL = K - 1        
      N = Z(ICORE+3)        
      IF (KSIL+N+1 .GT. NCORE) GO TO 9008        
      DO 260 I = 1,N        
      CALL SUREAD (Z(KSIL+I),2,NWDS,RC)        
      IF (RC .NE. 1) GO TO 6106        
  260 CONTINUE        
      LSIL = Z(KSIL+N)        
C        
C     READ THE TABLE OF EXTERNAL ID (GP), INTERNAL ID (IP), AND SUB-    
C     STRUCTURE NUMBER (SSN) FROM SCR1 ONE ENTRY AT A TIME.  LOCATE     
C     THE GP IN THE EQSS DATA INDICATED BY SSN AND LOOK UP THE SIL      
C     NUMBER.  WRITE GP AND SIL ON EQEX.  IF GP NOT FOUND, THEN SIL=-1. 
C        
  270 CALL READ (*9002,*290,SCR1,BUF,3,0,N)        
      I  = BUF(3)        
      J  = Z(5*I-1)        
      I5 = 5*I        
      CALL BISLOC (*280,BUF(1),Z(J),2,Z(I5),K)        
      I = Z(J+K) + KSIL        
      BUF(2) = 10*Z(I) + 1        
      CALL WRITE (EQEX,BUF,2,0)        
      GO TO 270        
  280 BUF(2) = -1        
      CALL WRITE (EQEX,BUF,2,0)        
      GO TO 270        
  290 CALL WRITE (EQEX,0,0,1)        
      CALL CLOSE (EQEX,REW)        
      CALL CLOSE (SCR1,REW)        
      BUF(1) = EQEX        
      BUF(2) = NGPTOT        
      DO 300 I = 3,7        
  300 BUF(I) = 0        
      CALL WRTTRL (BUF)        
C        
C     INTERPRET PLOT SETS AND GENERATE PLTP (PLTPAR)        
C        
C        
C     AT PRESENT, ONLY ONE PLOT SET (DEFINED IN PHASE 1) IS ALLOWED.    
C        
C     PHASE 2 PLOT SET DEFINITIONS ARE IGNORED.        
C        
C     COPY PCDB TO PLTP        
C        
      FILE = PCDB        
      CALL OPEN (*9001,PCDB,Z(BUF1),RDREW)        
      CALL FWDREC (*9002,PCDB)        
      FILE = PLTP        
      CALL OPEN  (*9001,PLTP,Z(BUF2),WRTREW)        
      CALL FNAME (PLTP,BUF)        
      CALL WRITE (PLTP,BUF,2,1)        
  310 CALL READ  (*330,*320,PCDB,Z(ICORE),LCORE,1,NWDS)        
      GO TO 9008        
  320 CALL WRITE (PLTP,Z(ICORE),NWDS,1)        
      GO TO 310        
  330 CALL CLOSE (PCDB,REW)        
      CALL CLOSE (PLTP,REW)        
      BUF(1) = PCDB        
      CALL RDTRL (BUF)        
      BUF(1) = PLTP        
      CALL WRTTRL (BUF)        
      DO 340 I = 1,NSS        
      Z(5*I-1) = 0        
      Z(5*I  ) = 1        
  340 CONTINUE        
      NPSET = 1        
C        
C     GPSETS        
C        
C        
C     LOCATE THE GPSETS DATA OF THE PLTS ITEM OF EACH BASIC SUBSTRUCTURE
C     AND READ THE NUMBER OF GRID POINTS IN THE ELEMENT SET.  STORE THIS
C     AS THE FOURTH ENTRY IN SDATA        
C        
      N = 3        
      NGPSET = 0        
      ITEM   = PLTS        
      DO 1010 I = 1,NSS        
      NM(1) = Z(5*I-4)        
      NM(2) = Z(5*I-3)        
      CALL SFETCH (NM,PLTS,SRD,RC)        
      CALL SJUMP (N)        
      RC = 3        
      IF (N .LT. 0) GO TO 6106        
      CALL SUREAD (Z(5*I-1),1,NWDS,RC)        
      IF (RC .NE. 1) GO TO 6106        
      NGPSET = NGPSET + Z(5*I-1)        
 1010 CONTINUE        
C        
C     WRITE RECORDS 0 AND 1 OF GPS AND FIRST WORD OF RECORD 2.        
C        
      FILE = GPS        
      CALL OPEN  (*9001,GPS,Z(BUF1),WRTREW)        
      CALL FNAME (GPS,BUF)        
      CALL WRITE (GPS,BUF,2,1)        
      CALL WRITE (GPS,1,1,1)        
      CALL WRITE (GPS,NGPSET,1,0)        
C        
C     READ GPSETS DATA FROM THE PLTS ITEM OF EACH BASIC SUBSTRUCTURE.   
C     INCREMENT THE ABSOLUTE VALUE OF THE POINTERS IN IT BY THE NUMBER  
C     OF GRID POINTS IN THE ELEMENT SETS OF THE PRECEDING BASIC        
C     SUBSTRUCTURES.  WRITE THE RESULT ON GPS (GPSETS).        
C        
      N = 3        
      NGPSET = 0        
      DO 1050 I = 1,NSS        
      CALL SFETCH (Z(5*I-4),PLTS,SRD,RC)        
      CALL SJUMP (N)        
      CALL SUREAD (Z(ICORE),LCORE,NWDS,RC)        
      IF (RC .NE. 2) GO TO 9008        
      NWDS = NWDS - 1        
      DO 1040 J = 1,NWDS        
      IF (Z(ICORE+J)) 1020,1040,1030        
 1020 Z(ICORE+J) = Z(ICORE+J) - NGPSET        
      GO TO 1040        
 1030 Z(ICORE+J) = Z(ICORE+J) + NGPSET        
 1040 CONTINUE        
      CALL WRITE (GPS,Z(ICORE+1),NWDS,0)        
      NGPSET = NGPSET + Z(5*I-1)        
 1050 CONTINUE        
      CALL CLSTAB (GPS,REW)        
C        
C     ELSETS        
C        
C        
C     READ THE ELSETS DATA FROM THE PLTS ITEM OF EACH BASIC SUBSTRUCTURE
C     INCREMENT ALL NON-ZERO GRID POINT CONNECTION INDICES BY THE NUMBER
C     OF STRUCTURAL GRID POINTS OF THE PRECEDING SUBSTRUCTURES.  WRITE  
C     THE RESULT ON ELS (ELSETS).        
C        
C     NOTE   THE ELEMENT TYPES WILL BE SCRAMBLED.  LIKE ELEMENT TYPES   
C            FROM THE CONTRIBUTING BASIC SUBSTRUCTURES WILL NOT BE      
C            GROUPED TOGETHER.        
C        
C     NOTE   THE BAR HAS ADDITIONALLY 6 OFFSET DATA VALUES. QUAD4 AND   
C            TRIA3 HAS 1 OFFSET DATA EACH        
C        
      FILE = ELS        
      CALL OPEN  (*9001,ELS,Z(BUF1),WRTREW)        
      CALL FNAME (ELS,BUF)        
      CALL WRITE (ELS,BUF,2,1)        
      NGP = 0        
C        
C     LOOP OVER BASIC SUBSTRUCTURES        
C        
      DO 2050 I = 1,NSS        
      NM(1) = Z(5*I-4)        
      NM(2) = Z(5*I-3)        
      CALL SFETCH (NM,PLTS,SRD,RC)        
      N  = 4        
      CALL SJUMP (N)        
      RC = 3        
      IF (N .LT. 0) GO TO 6106        
C        
C     LOOP OVER ELEMENT TYPES        
C        
 2010 CALL SUREAD (BUF,2,N,RC)        
      IF (RC .EQ. 2) GO TO 2040        
      IF (RC .NE. 1) GO TO 6106        
      CALL WRITE (ELS,BUF,2,0)        
      NGPEL  = BUF(2)        
      OFFSET = 0        
      IF (BUF(1) .EQ. BAR) OFFSET = 6        
      IF (BUF(1).EQ.QUAD4 .OR. BUF(1).EQ.TRIA3) OFFSET = 1        
C        
C     LOOP OVER ELEMENTS        
C        
 2020 CALL SUREAD (ELID,1,N,RC)        
      IF (RC .NE. 1) GO TO 6106        
      CALL WRITE (ELS,ELID,1,0)        
      IF (ELID .LE. 0) GO TO 2010        
      CALL SUREAD (INDX,1,N,RC)        
      CALL WRITE (ELS,INDX,1,0)        
      CALL SUREAD (Z(ICORE),NGPEL+OFFSET,N,RC)        
      IF (RC .NE. 1) GO TO 6106        
C        
C     LOOP OVER CONNECTIONS        
C        
      K = ICORE        
      DO 2030 J = 1,NGPEL        
      IF (Z(K) .NE. 0) Z(K) = Z(K) + NGP        
 2030 K = K + 1        
      CALL WRITE (ELS,Z(ICORE),NGPEL+OFFSET,0)        
      GO TO 2020        
 2040 NGP = NGP + Z(5*I-2)        
 2050 CONTINUE        
C        
      CALL WRITE  (ELS,0,0,1)        
      CALL CLSTAB (ELS,REW)        
C        
C     NORMAL MODULE COMPLETION        
C        
      CALL SOFCLS        
      RETURN        
C        
C     ABNORMAL MODULE COMPLETION        
C        
 6100 IF (RC .EQ. 2) RC = 3        
      CALL SMSG (RC-2,ITEM,NM)        
      GO TO 9200        
 6106 CALL SMSG (RC+4,ITEM,NM)        
      GO TO 9200        
 9001 N = 1        
      GO TO 9100        
 9002 N = 2        
      GO TO 9100        
 9003 N = 3        
      GO TO 9100        
 9008 N = 8        
 9100 CALL MESAGE (N,FILE,SUBR)        
      CALL CLOSE  (FILE,REW)        
 9200 CALL SOFCLS        
      NPSET = -1        
      RETURN        
      END        
