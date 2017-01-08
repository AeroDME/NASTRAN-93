      SUBROUTINE APDB1 (IBUF1,IBUF2,NEXT,LEFT,NSTNS,NLINES,XSIGN,       
     1                  LCSTM,ACSTM,NODEX,NODEI,ISILC,XYZB)        
C        
C     GENERATE GTKA TRANSFORMATION MATRIX        
C        
      EXTERNAL        ANDF        
      LOGICAL         MULTI,OMIT,SINGLE,DEBUG        
      INTEGER         GM,GO,GTKA,SCR1,SCR2,CORE,        
     1                UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG,USET1,IDATA(7),
     2                GTKG,GKNB,GKM,GKAB,GKF,GKS,GKO,GKN,GSIZE,        
     3                ANDF,RD,RDREW,WRT,WRTREW,CLSREW,TGKG(7)        
      DIMENSION       ITRL(7),XYZB(4,NSTNS),IZ(1),Z(1),RDATA(7),TA(3,3),
     1                TBL(3),TBLA(3),ACSTM(1),NODEX(1),NODEI(1),ISILC(1)
      COMMON /SYSTEM/ KSYSTM(54),IPREC        
      COMMON /TWO   / ITWO(32)        
CZZ   COMMON /ZZSSA2/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /ZBLPKX/ AP(4),II        
      COMMON /BITPOS/ UM,UO,UR,USG,USB,UL,UA,UF,US,UN,UG        
      COMMON /PATX  / LC,N,NO,NY,USET1,IBC(7)        
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW        
      COMMON /APDBUG/ DEBUG        
CZZ   COMMON /ZZAPDB/ Z        
      EQUIVALENCE     (Z(1),CORE(1))        
      EQUIVALENCE     (Z(1),IZ(1)), (IDATA(1),RDATA(1))        
      DATA    SINGLE, MULTI,OMIT /.TRUE.,.TRUE.,.TRUE./        
C        
      USET = 102        
      GM   = 106        
      GO   = 107        
      GTKA = 204        
      SCR1 = 301        
      SCR2 = 302        
      GKNB = 303        
      GKM  = 304        
      GKAB = 305        
      ITRL(1) = USET        
      CALL RDTRL(ITRL)        
      GSIZE = ITRL(3)        
      IF (ANDF(ITRL(5),ITWO(UM)) .EQ. 0) MULTI = .FALSE.        
      IF (ANDF(ITRL(5),ITWO(US)) .EQ. 0) SINGLE= .FALSE.        
      IF (ANDF(ITRL(5),ITWO(UO)) .EQ. 0) OMIT  = .FALSE.        
      IF (.NOT.(MULTI .OR. SINGLE .OR. OMIT)) SCR2 = GTKA        
      GTKG = SCR2        
C        
C     OPEN SCR1 TO READ BLADE NODE DATA        
C        
C                         T        
C     OPEN SCR2 TO WRITE G   MATRIX OF ORDER (GSIZE X KSIZE)        
C                         KG        
C        
      CALL GOPEN (SCR1,Z(IBUF1),RDREW)        
      CALL GOPEN (GTKG,Z(IBUF2),WRTREW)        
      TGKG(1) = GTKG        
      TGKG(2) = 0        
      TGKG(3) = GSIZE        
      TGKG(4) = 2        
      TGKG(5) = 1        
      TGKG(6) = 0        
      TGKG(7) = 0        
C        
C     SET-UP CALL TO TRANSS VIA PRETRS        
C        
      IF (LCSTM .GT. 0) CALL PRETRS (ACSTM,LCSTM)        
C        
C     LOOP ON STREAMLINES        
C        
      DO 50  NLINE = 1,NLINES        
C        
C     READ STREAMLINE NODE DATA FROM SCR1        
C        
      DO 10 NST = 1,NSTNS        
      CALL FREAD (SCR1,IDATA,7,0)        
      IF (DEBUG) CALL BUG1 ('SCR1 IDATA',10,IDATA,7)        
      NODEX(NST) = IDATA(1)        
      NODEI(NST) = IDATA(2)        
      ISILC(NST) = IDATA(3)        
      XYZB(1,NST)= RDATA(4)        
      XYZB(2,NST)= RDATA(5)        
      XYZB(3,NST)= RDATA(6)        
      XYZB(4,NST)= RDATA(7)        
   10 CONTINUE        
C        
C     GENERATE BASIC TO LOCAL TRANSFORMATION MATRIX FOR THIS STREAMLINE 
C        
      XBMXA = XYZB(2,NSTNS) - XYZB(2,1)        
      YBMYA = XYZB(3,NSTNS) - XYZB(3,1)        
      ZBMZA = XYZB(4,NSTNS) - XYZB(4,1)        
      RL1 = SQRT(XBMXA*XBMXA + YBMYA*YBMYA + ZBMZA*ZBMZA)        
      RL2 = SQRT(RL1*RL1 - ZBMZA*ZBMZA)        
      TBL(1) = -XSIGN*(YBMYA/RL2)        
      TBL(2) =  XSIGN*(XBMXA/RL2)        
      TBL(3) =  0.0        
      IF (DEBUG) CALL BUG1 ('MAT-TBL   ',15,TBL,3)        
C        
C     LOOP ON COMPUTING STATIONS        
C        
      DO 40  NCS = 1,NSTNS        
C        
C     LOCATE GLOBAL TO BASIC TRANSFORMATION MATRIX        
C        
      RDATA(1) = XYZB(1,NCS)        
      IF (LCSTM.EQ.0 .OR. IDATA(1).EQ.0) GO TO 20        
      CALL TRANSS (XYZB(1,NCS),TA)        
C     TBLA = TBL*TA        
      CALL GMMATS (TBL,1,3,0, TA,3,3,0, TBLA)        
      GO TO 25        
   20 TBLA(1) = TBL(1)        
      TBLA(2) = TBL(2)        
      TBLA(3) = TBL(3)        
   25 CONTINUE        
      IF (DEBUG) CALL BUG1 ('MAT-TBLA  ',25,TBLA,3)        
C        
C     COMPUTE LOCATION IN G-SET USING SIL        
C     KODE = 1 FOR GRID POINT        
C     KODE = 2 FOR SCALAR POINT (NOT ALLOWED, CHECK WAS MADE BY APDB)   
C        
      ISIL = ISILC(NCS)/10        
      CALL BLDPK (1,1,GTKG,0,0)        
C        
C     OUTPUT GKG(TRANSPOSE) = GTKG        
C     II IS ROW POSITION        
C        
      DO 30 ICOL = 1,3        
      II = ISIL        
      AP(1) = TBLA(ICOL)        
      IF (DEBUG) CALL BUG1 ('ISIL      ',28,ISIL,1)        
      IF (DEBUG) CALL BUG1 ('MAT-AP    ',29,AP,1)        
      CALL ZBLPKI        
      ISIL = ISIL + 1        
   30 CONTINUE        
      CALL BLDPKN (GTKG,0,TGKG)        
   40 CONTINUE        
   50 CONTINUE        
      CALL CLOSE (SCR1,CLSREW)        
      CALL CLOSE (GTKG,CLSREW)        
      CALL WRTTRL (TGKG)        
C        
C     CREATE GTKA MATRIX        
C        
      IF (MULTI .OR. SINGLE .OR. OMIT) GO TO 60        
      GO TO 100        
   60 CONTINUE        
      LC  = KORSZ(CORE)        
      GKF = GKNB        
      GKS = GKM        
      GKO = GKS        
      USET1 = USET        
C        
C     REDUCE TO N-SET IF MULTI POINT CONSTRAINTS        
C        
      GKN = GTKG        
      IF (.NOT.MULTI) GO TO 70        
      IF (.NOT.SINGLE .AND. .NOT.OMIT) GKN = GTKA        
      CALL CALCV (SCR1,UG,UN,UM,CORE)        
      CALL SSG2A (GTKG,GKNB,GKM,SCR1)        
      CALL SSG2B (GM,GKM,GKNB,GKN,1,IPREC,1,SCR1)        
C        
C     PARTITION INTO F-SET IF SINGLE POINT CONSTRAINTS        
C        
   70 IF (.NOT.SINGLE) GO TO 80        
      IF (.NOT.OMIT  ) GKF = GTKA        
      CALL CALCV (SCR1,UN,UF,US,CORE)        
      CALL SSG2A (GKN,GKF,0,SCR1)        
      GO TO 90        
C        
C     REDUCE TO A-SET IF OMITS        
C        
   80 GKF = GKN        
   90 IF (.NOT.OMIT) GO TO 100        
      CALL CALCV (SCR1,UF,UA,UO,CORE)        
      CALL SSG2A (GKF,GKAB,GKO,SCR1)        
      CALL SSG2B (GO,GKO,GKAB,GTKA,1,IPREC,1,SCR1)        
  100 RETURN        
      END        
