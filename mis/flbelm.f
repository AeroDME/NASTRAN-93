      SUBROUTINE FLBELM        
C        
C     READS CFLSTR AND CFREE BULK DATA AND BUILDS INCORE TABLES TO      
C     DESCRIBE THE CONNECTIVITY BETWEEN THE STRUCTURE AND FLUID        
C        
      LOGICAL         ERROR        
      INTEGER         GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT      ,
     1                GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF    ,
     2                USETS    ,AF       ,DKGG     ,FBELM    ,FRELM    ,
     3                CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT   ,
     4                Z        ,FILE     ,NAME(2)  ,MCB(7)   ,CFLSTR(2),
     5                CARD(10) ,ID(3)    ,GRID(4)  ,CFREE(2) ,ELM2D(7,3)
     6,               ELMFL(4,3)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /FLBFIL/ GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT      ,
     1                GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF    ,
     2                USETS    ,AF       ,DKGG     ,FBELM    ,FRELM    ,
     3                CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT    
      COMMON /FLBPTR/ ERROR    ,ICORE    ,LCORE    ,IBGPDT   ,NBGPDT   ,
     1                ISIL     ,NSIL     ,IGRAV    ,NGRAV    ,IGRID    ,
     2                NGRID    ,IBUF1    ,IBUF2    ,IBUF3    ,IBUF4    ,
     3                IBUF5        
CZZ   COMMON /ZZFLB1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF   ,NOUT        
      COMMON /BLANK / NOGRAV   ,NOFREE        
      DATA    CFLSTR/ 7610,76/ ,CFREE / 4810,48 /  ,MCB / 7*0 /        
      DATA    NAME  / 4HFLBE , 4HLM   /        
C        
C     TWO DIMENSIONAL STRUCTURAL ELEMENTS DESCRIPTIONS        
C        
      DATA    N2D   / 7 /        
      DATA    ELM2D /        
C        
C                     TRIA1  TRIA2   TRMEM  QUAD1  QUAD2  QDMEM  SHEAR  
C     1  IFP CARD NUMBERS        
C     2  NUMBER OF GRIDS        
C     3  NUMBER OF WORDS IN ECT RECORD        
C        
     1                52    ,53     ,56    ,57    ,58    ,60    ,61   , 
     2                3     ,3      ,3      ,4     ,4     ,4     ,4   , 
     3                6     ,6      ,6      ,7      ,7    ,7      ,6  / 
C        
C     FLUID ELEMENT DESCRIPTIONS        
C        
      DATA    NFL   / 4 /        
      DATA    ELMFL /        
C        
C                     FHEX1     FHEX2     FTETRA    FWEDGE        
C    1  IFP CARD NUMBERS        
C    2  NUMBER OF GRIDS        
C    3  NUMBER OF WORDS IN ECT RECORD        
C        
     1                333      ,334      ,335      ,336     ,        
     2                8        ,8        ,4        ,6       ,        
     3                10       ,10       ,6        ,8       /        
C        
C        
C     READ BGPDT INTO OPEN CORE        
C        
      IBGPDT = 1        
      FILE   = BGPDT        
      CALL GOPEN (BGPDT,Z(IBUF1),0)        
      NZ = IBUF3 - 1        
      CALL READ (*1002,*10,BGPDT,Z(IBGPDT),NZ,1,NBGPDT)        
      GO TO 1008        
   10 ICORE = IBGPDT + NBGPDT        
      NGRDT = NBGPDT/4        
      CALL CLOSE (BGPDT,1)        
C        
C     LOCATE CFLSTR CARDS ON GEOM2 AND READ THEM INTO ELEMENT TABLE     
C     IN CORE.   ONE ELEMENT TABLE RECORD WILL LOOK AS FOLLOWS -        
C        
C                  WORD      DESCRIPTION        
C        
C                  1         STRUCTURE ELEMENT ID        
C                  2         FLUID ELEMENT ID        
C                  3-6       ZERO        
C                  7         GRAV LOAD ID        
C        
      FILE = GEOM2        
      CALL PRELOC (*1001,Z(IBUF1),GEOM2)        
      CALL LOCATE (*1200,Z(IBUF1),CFLSTR,ID)        
      IELMT = ICORE        
   20 CALL READ (*1002,*40,GEOM2,ID,2,0,N)        
   30 CALL READ (*1002,*1003,GEOM2,IDS,1,0,N)        
      IF (IDS .LT. 0) GO TO 20        
      IF (ICORE+7 .GE. IBUF3) GO TO 1008        
      Z(ICORE  ) = IDS        
      Z(ICORE+1) = ID(1)        
      Z(ICORE+2) = 0        
      Z(ICORE+3) = 0        
      Z(ICORE+4) = 0        
      Z(ICORE+5) = 0        
      Z(ICORE+6) = ID(2)        
      ICORE = ICORE + 7        
      GO TO 30        
C        
   40 NELMT = ICORE - IELMT        
      NELM  = NELMT/7        
C        
C     SORT ELEMENT TABLE BY STRUCTUREAL ELEMENT ID        
C        
      CALL SORT (0,0,7,1,Z(IELMT),NELMT)        
C        
C     READ ECT AND PROCESS 2D STRUCTURAL ELEMENTS        
C        
      FILE = ECT        
      CALL GOPEN (ECT,Z(IBUF2),0)        
   50 CALL READ (*100,*1002,ECT,CARD,3,0,N)        
      DO 60 I = 1,N2D        
      IF (CARD(3) .EQ. ELM2D(I,1)) GO TO 70        
   60 CONTINUE        
C        
C     SKIP RECORD BECAUSE NOT ACCEPTABLE 2D ELEMENT TYPE        
C        
      CALL FWDREC (*1001,ECT)        
      GO TO 50        
C        
C     PROCESS THE 2D ELEMENT        
C        
   70 NGRDS = ELM2D(I,2)        
      NWDS  = ELM2D(I,3)        
C        
C     READ DATA FOR ONE 2D ELEMENT        
C        
   80 CALL READ (*1001,*50,ECT,CARD,NWDS,0,N)        
C        
C     CHECK IF STRUCTURAL ELEMENT IS CONNECTED TO ANY FLUID ELEMENT     
C     MAKE SURE BISLOC FINDS FIRST OF SEVERAL POSSIBLE ENTRIES        
C        
      CALL BISLOC (*80,CARD(1),Z(IELMT),7,NELM,JLOC)        
   82 IF (JLOC.EQ.1 .OR. Z(IELMT+JLOC-8).NE.CARD(1)) GO TO 84        
      JLOC = JLOC - 7        
      GO TO 82        
C        
C     INSERT ELEMENT GRID POINTS INTO ELEMENT TABLE WORDS 3-6        
C        
   84 DO 90 I = 1,NGRDS        
   90 Z(IELMT+JLOC+I) = CARD(I+2)        
      IF (NGRDS .EQ. 3) Z(IELMT+JLOC+4) = -1        
C        
C     CHECK IF NEXT ENTRY IS FOR THE SAME STRUCTURAL ELEMENT        
C        
      IF (JLOC+7.GE.NELMT .OR. Z(IELMT+JLOC+6).NE.CARD(1)) GO TO 80     
      JLOC = JLOC + 7        
      GO TO 84        
C        
  100 CONTINUE        
C        
C     PASS THROUGH ELEMENT TABLE AND CHECK THAT EACH ENTRY HAS GRIDS.   
C     ALSO SWITCH THE STRUCTURE AND FLUID ELEMENTS IN THE TABLE FOR     
C     FUTURE WORD WITH FLUID ID.        
C        
      LELMT = IELMT + NELMT - 1        
      DO 110 I = IELMT,LELMT,7        
      IDS  = Z(I  )        
      Z(I) = Z(I+1)        
      IF (Z(I+2) .NE. 0) GO TO 110        
      ERROR = .TRUE.        
      WRITE (NOUT,8002) UFM,IDS        
      IDS  = 0        
  110 Z(I+1) = IDS        
C        
C     ALLOCATE AND ZERO THE GRID POINT CONNECTIVE TABLE AT THE BOTTOM   
C     OF CORE        
C        
C     TABLE ENTRIES WILL BE AS FOLLOWS        
C        
C     POSITIVE LESS THEN 1,000,000  - NUMBER OF STRUCTURAL POINTS       
C                                     CONNECTED TO THIS FLUID POINT     
C     MULTIPLES OF 1,000,000        - NUMBER OF FREE SURFACE POINTS     
C                                     CONNECTED TO THIS FLUID POINT     
C     NEGATIVE                      - NUMBER OF STRUCTURAL POINTS       
C                                     CONNECTED TO THIS STRUCTURAL      
C                                     POINT        
C        
      IGRID = IBUF3 - NGRDT - 1        
      IF (IGRID .LT. ICORE) GO TO 1008        
      NGRID = NGRDT        
      LGRID = IBUF3 - 1        
      DO 115 I = IGRID,LGRID        
  115 Z(I) = 0        
C        
C     LOCATE CFREE CARDS ON GEOM2 AND ADD THEM TO THE ELEMENT TABLE.    
C     THESE ELEMENT RECORDS WILL APPEAR AS FOLLOWS        
C        
C                  WORD      DESCRIPTION        
C        
C                  1         FLUID ELEMENT ID        
C                  2         -1        
C                  3         FACE ID        
C                  4-6       ZERO        
C                  7         GRAV ID        
C        
      FILE = GEOM2        
      CALL LOCATE (*124,Z(IBUF1),CFREE,ID)        
      NOFREE = 1        
  120 CALL READ (*1002,*130,GEOM2,ID,3,0,N)        
      IF (ICORE+7 .GE. IGRID) GO TO 1008        
      Z(ICORE  ) = ID(1)        
      Z(ICORE+1) = -1        
      Z(ICORE+2) = ID(3)        
      Z(ICORE+3) = 0        
      Z(ICORE+4) = 0        
      Z(ICORE+5) = 0        
      Z(ICORE+6) = ID(2)        
      ICORE = ICORE + 7        
      GO TO 120        
C        
C     NO CFREE CARDS - THIS IMPLIES THAT THERE WILL BE NO FREE SURFACE  
C        
  124 NOFREE = -1        
C        
C     COMPLETE CORE ALLOCATION FOR THIS PHASE        
C        
  130 NELMT = ICORE - IELMT        
      NELM  = NELMT/7        
      CALL CLOSE (GEOM2,1)        
C        
C     SORT ELEMENT TABLE BY FLUID ID        
C        
      CALL SORT (0,0,7,1,Z(IELMT),NELMT)        
C        
C     OPEN FBELM AND FRELM SCRATCH FILES        
C        
      CALL GOPEN (FBELM,Z(IBUF1),1)        
      CALL GOPEN (FRELM,Z(IBUF3),1)        
C        
C     READ ECT AND PROCESS FLUID ELEMENTS        
C        
      FILE = ECT        
      CALL REWIND (ECT)        
      CALL FWDREC (*1002,ECT)        
  140 CALL READ (*220,*1003,ECT,CARD,3,0,N)        
      DO 150 I = 1,NFL        
      IF (CARD(3) .EQ. ELMFL(I,1)) GO TO 160        
  150 CONTINUE        
C        
C     SKIP RECORD BECAUSE NOT FLUID ELEMENT TYPE        
C        
      CALL FWDREC (*1001,ECT)        
      GO TO 140        
C        
C     PRECESS FLUID ELEMENT        
C        
  160 NTYPE = ELMFL(I,1)        
      NWDS  = ELMFL(I,3)        
C        
C     READ DATA FOR ONE FLUID ELEMENT        
C        
  170 CALL READ (*1001,*140,ECT,CARD,NWDS,0,N)        
C        
C     FIND IF FLUID ELEMENT IS ON FREE SURFACE OR STRUCTURAL BOUNDARY.  
C     MAKE SURE BISLOC FINDS THE FIRST OF SEVERAL POSSIBLE ENTRIES.     
C        
      CALL BISLOC (*170,CARD(1),Z(IELMT),7,NELM,JLOC)        
  175 IF (JLOC.EQ.1 .OR. Z(IELMT+JLOC-8).NE.CARD(1)) GO TO 180        
      JLOC = JLOC - 7        
      GO TO 175        
C        
C     DETERMINE IF ENTRY IS EITHER A BOUNDARY OR FREE SURFACE        
C     DESCRIPTION - IGNORE ENTRY IF IT WAS IN ERROR DURING STRUCTURAL   
C     ELEMENT PROCESSING        
C        
  180 IF (Z(IELMT+JLOC) .GT.  0) GO TO 190        
      IF (Z(IELMT+JLOC) .EQ. -1) GO TO 200        
      GO TO 210        
C        
C     THIS ENTRY DESCRIBES THE FLUID / STRUCTURE BOUNDARY - FIND THE    
C     FLUID GRID POINTS WHICH COINCIDE WITH THE STRUCTURAL POINTS       
C        
  190 CALL FLFACE (NTYPE,CARD,Z(IELMT+JLOC-1),GRID)        
      IF (ERROR) GO TO 210        
C        
C     INCLUDE CONNECTIONS IN GRID POINT CONNECTIVITY TABLE        
C        1) NUMBER OF STRUCTURE GRID POINTS CONNECTED TO EACH FLUID     
C        2) NUMBER OF STRUCTURAL GRID POINTS CONNECTED TO EACH        
C           STRUCTURE POINT        
C        
      NGRDF = 4        
      IF (GRID(4) .LT. 0) NGRDF = 3        
      NGRDS = 4        
      IF (Z(IELMT+JLOC+4) .LT. 0) NGRDS = 3        
      DO 192 I = 1,NGRDF        
      J = GRID(I) - 1        
  192 Z(IGRID+J) = Z(IGRID+J) + NGRDS        
      DO 194 I = 1,NGRDS        
      J = Z(IELMT+JLOC+I) - 1        
  194 Z(IGRID+J) = Z(IGRID+J) - NGRDS        
C        
C     WRITE 12 WORD RECORD FOR THIS ENTRY ON FBELM        
C        
C                  WORD      DESCRIPTION        
C        
C                  1         FLUID ELEMENT ID        
C                  2         STRUCTURAL ELEMENT ID        
C                  3-6       STRUCTURE GRID POINTS        
C                  7         GRAVITY LOAD ID        
C                  8         MATERIAL ID        
C                  9-12      FLUID GRID POINTS        
C        
      CALL WRITE (FBELM,Z(IELMT+JLOC-1),7,0)        
      CALL WRITE (FBELM,CARD(2),1,0)        
      CALL WRITE (FBELM,GRID,4,0)        
      GO TO 210        
C        
C     THIS ENTRY DESCRIBES THE FREE SURFACE - FIND THE FLUIDS GRID      
C     POINTS WHICH DEFINE THE FACE ID GIVEN        
C        
  200 CALL FLFACE (NTYPE,CARD,Z(IELMT+JLOC-1),GRID)        
      IF (ERROR) GO TO 210        
C        
C     INCLUDE CONNECTIONS IN GRID POINT CONNECTIVITY TABLE        
C        1) NUMBER OF FREE SURFACE POINTS CONNECTED TO THIS FREE        
C           SURFACE POINT        
C        
      NGRDF = 4        
      IF (GRID(4) .LT. 0) NGRDF = 3        
      DO 202 I = 1,NGRDF        
      J = GRID(I) - 1        
  202 Z(IGRID+J) = Z(IGRID+J) + NGRDF*1000000        
C        
C     WRITE 7 WORD RECORD ON FRELM FILE        
C        
C                  WORD      DESCRIPTION        
C        
C                  1         FLUID ELEMENT ID        
C                  2         MATERIAL FLAG        
C                  3-6       FLUID GRID POINTS        
C                  7         GRAVITY LOAD ID        
C        
      Z(IELMT+JLOC) = CARD(2)        
      CALL WRITE (FRELM,Z(IELMT+JLOC-1),2,0)        
      CALL WRITE (FRELM,GRID,4,0)        
      CALL WRITE (FRELM,Z(IELMT+JLOC+5),1,0)        
C        
C     FLAG THE ELEMENT TABLE ENTRY AS BEEN PROCESSED AND CHECK IF       
C     THE NEXT ENTRY IS FOR THE SAME FLUID ELEMENT        
C        
  210 Z(IELMT+JLOC) = -2        
      IF (JLOC+7.GE.NELMT .OR. Z(IELMT+JLOC+6).NE.CARD(1)) GO TO 170    
      JLOC = JLOC + 7        
      GO TO 180        
C        
  220 CALL CLOSE (ECT,1)        
      CALL CLOSE (FBELM,1)        
      CALL CLOSE (FRELM,1)        
      MCB(1) = FBELM        
      MCB(2) = NGRDT        
      MCB(3) = NELM        
      CALL WRTTRL (MCB)        
      MCB(1) = FRELM        
      CALL WRTTRL (MCB)        
C        
C     MAKE ONE FINAL PASS THROUGH ELEMENT TABLE AND VERIFY THAT        
C     EVERY FLUID ELEMENT WAS PROCESSED        
C        
      LELMT = IELMT + NELMT - 1        
      DO 240 I = IELMT,LELMT,7        
      IF (Z(I+1) .EQ. -2) GO TO 240        
      IF (Z(I+1) .EQ. -1) GO TO 230        
      ERROR = .TRUE.        
      WRITE (NOUT,8003) UFM,Z(I)        
      GO TO 240        
C        
  230 ERROR = .TRUE.        
      WRITE (NOUT,8004) UFM,Z(I)        
C        
  240 CONTINUE        
C        
C     ELEMENT TABLE IS NO LONGER NEEDED SO DELETE IT AND RETURN        
C        
      ICORE = IELMT        
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
 1100 CALL MESAGE (N,FILE,NAME)        
C        
C     NO FLUID / STRUCTURE BOUNDARY DEFINED.  FATAL ERROR BECAUSE DMAP  
C     CANNOT HANDLE THIS CONDITION        
C        
 1200 ERROR = .TRUE.        
      WRITE (NOUT,8001) UFM        
      RETURN        
C        
C     ERROR FORMATS        
C        
 8001 FORMAT (A23,' 8001. THERE MUST BE A FLUID/STRUCTURE BOUNDARY IN ',
     1       'HYDROELASTIC ANALYSIS.')        
 8002 FORMAT (A23,' 8002, ELEMENT ID',I9,' ON A CFLSTR CARD DOES NOT ', 
     1       'REFERENCE A VALID 2D STRUCTURAL ELEMENT.')        
 8003 FORMAT (A23,' 8003. ELEMENT ID',I9,' ON A CFLSTR CARD DOES NOT ', 
     1       'REFERENCE A VALID FLUID ELEMENT.')        
 8004 FORMAT (A23,' 8004. ELEMENT ID',I9,' ON A CFFREE CARD DOES NOT ', 
     1       'REFERENCE A VALID FLUID ELEMENT.')        
      END        
