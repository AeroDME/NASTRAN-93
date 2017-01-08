      SUBROUTINE PARTN (IRP,ICP,CORE)        
C        
      EXTERNAL         RSHIFT,ANDF        
      INTEGER          ANDF,TWO1,CORE,SYSBUF,RSHIFT        
      DIMENSION        ICP(1),IRP(1)        
      DIMENSION        CORE(1),IAS(7,4),HEAD(2),BLOCK1(40),NAME(2)      
      COMMON /PARMEG/  NAMEA,NCOLA,NROWA,IFORMA,ITYPA,IA(2),        
     1                 IA11(7),IA21(7),IA12(7),IA22(7),LCARE,RULE       
      COMMON /SYSTEM/  SYSBUF        
      COMMON /TWO   /  TWO1(32)        
      COMMON /ZNTPKX/  A11(4),II,IEOL,IEOR        
      EQUIVALENCE     (IAS(1,1),IA11(1))        
      DATA    ILN   /  20 /, NAME / 4HPART,4HN   /        
C        
C     ZERO 6 AND 7 OF OUTPUT BLOCKS        
C        
      IOTP  = ITYPA        
      IOPEN = 0        
      DO 40 I = 1,4        
      DO 10 J = 6,7        
   10 IAS(J,I) = 0        
      IF (IAS(1,I)) 20,40,20        
   20 IF (IAS(5,I) .NE. ITYPA) IOTP = 4        
      IOPEN = IOPEN + 1        
      DO 30 J = 2,5        
      IF (IAS(J,I)) 340,340,30        
   30 CONTINUE        
      IAS(2,I) = 0        
   40 CONTINUE        
      LCORE  = LCARE        
      IBUF   = LCORE- SYSBUF + 1        
      IBUFCP = IBUF - NROWA        
      IBUFRP = IBUFCP - (NCOLA+31)/32        
      IF (IBUFRP) 300,300,50        
   50 LCORE = IBUFRP - 1        
      INORP = 0        
      CALL RULER (RULE,ICP,ZCPCT,OCPCT,CORE(IBUFCP),NROWA,CORE(IBUF),1) 
      IF (IRP(1).EQ.ICP(1) .AND. IRP(1).NE.0 .AND. NROWA.EQ.NCOLA)      
     1    GO TO 60        
      CALL RULER (RULE,IRP,ZRPCT,ORPCT,CORE(IBUFRP),NCOLA,CORE(IBUF),0) 
      GO TO 70        
   60 INORP = 1        
      LCORE = IBUFCP - 1        
C        
C     OPEN OUTPUT MATRICES        
C        
   70 IF (IOPEN*SYSBUF .GT. LCORE) GO TO 300        
      DO 100 I = 1,4        
      IF (IAS(1,I)) 80,100,80        
   80 LCORE = LCORE - SYSBUF        
      CALL OPEN  (*90,IAS(1,I),CORE(LCORE+1),1)        
      CALL FNAME (IAS(1,I),HEAD)        
      CALL WRITE (IAS(1,I),HEAD,2,1)        
      GO TO 100        
   90 IAS(1,I) = 0        
  100 CONTINUE        
C        
C     OPEN INPUT MATRIX        
C        
      CALL GOPEN (NAMEA,CORE(IBUF),0)        
C        
C     LOOP FOR EACH COLUMN        
C        
      KM = 0        
      DO 270 LOOP = 1,NCOLA        
      IF (INORP .NE. 0) GO TO 110        
C        
C     COLUMN PARTITION A SEQ. OF ZEROS AND ONES        
C        
      KM = KM + 1        
      IF (KM .GT. 32) KM = 1        
      L = IBUFRP + (LOOP-1)/32        
      ITEMP = ANDF(CORE(L),TWO1(KM))        
      IF (KM .EQ. 1) ITEMP = RSHIFT(ANDF(CORE(L),TWO1(KM)),1)        
      IF (ITEMP) 120,130,120        
  110 L  = IBUFCP + LOOP - 1        
      IF (CORE(L)) 130,120,120        
  120 L1 = 2        
      GO TO 140        
  130 L1 = 0        
C        
C     BEGIN BLDPK ON TWO SUBS        
C        
  140 J = 0        
      DO 160 L = 1,2        
      K = L1 + L        
      M = ILN*(L-1) + 1        
      IF (IAS(1,K)) 150,160,150        
  150 CALL BLDPK (IOTP,IAS(5,K),IAS(1,K),BLOCK1(M),1)        
      J = J + 1        
  160 CONTINUE        
      IF (J) 170,260,170        
C        
C     SEARCH COLUMN FOR NON-ZERO ELEMENTS        
C        
  170 CALL INTPK (*230,NAMEA,0,IOTP,0)        
C        
C     LOOP FOR ROWS WITHIN COLUMN        
C        
  180 IF (IEOL) 230,190,230        
  190 CALL ZNTPKI        
C        
C     COMPUTE ROW POSITION AND OUTPUT MATRIX        
C        
      L = IBUFCP + II - 1        
      IPOS = IABS(CORE(L))        
      IF (CORE(L)) 200,210,210        
  200 M1 = L1 + 1        
      M  = 1        
      GO TO 220        
  210 M1 = L1 + 2        
      M  = ILN+ 1        
  220 IF (IAS(1,M1) .EQ. 0) GO TO 180        
      CALL BLDPKI (A11(1),IPOS,IAS(1,M1),BLOCK1(M))        
      GO TO 180        
  230 DO 250 L = 1,2        
      K = L + L1        
      M = ILN*(L-1) + 1        
      IF (IAS(1,K)) 240,250,240        
  240 CALL BLDPKN (IAS(1,K),BLOCK1(M),IAS(1,K))        
  250 CONTINUE        
      GO TO 270        
  260 CALL SKPREC (NAMEA,1)        
  270 CONTINUE        
C        
C     ALL DONE - CLOSE OPEN MATRICES        
C        
      CALL CLOSE (NAMEA,1)        
      DO 290 I = 1,4        
      IF (IAS(1,I)) 280,290,280        
  280 CALL CLOSE (IAS(1,I),1)        
  290 CONTINUE        
      RETURN        
C        
  300 IPM1 =-8        
  310 CALL MESAGE (IPM1,IPM2,NAME)        
  340 IPM1 =-7        
      GO TO 310        
      END        
