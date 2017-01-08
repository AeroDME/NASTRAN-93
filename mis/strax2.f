      SUBROUTINE STRAX2 (SORC,TI)        
C        
C     THIS ROUTINE IS PHASE II OF STRESS DATA FOR THE TRIANGULAR        
C     CROSS SECTION RING        
C        
C     OUTPUTS FROM PHASE I ARE THE FOLLOWING -        
C     IDEL IGP(3) TZ SEL(54) TS(4) AK(81) PHI(14)        
C     AKUPH(27) AKPH2(9) SELP1(18) SELP2(27) SELP3(9)        
C        
C     ANY GROUP OF STATEMENTS PREFACED BY AN IF STATEMENT CONTAINING    
C     ...KSYS78 OR LSYS78 ...  INDICATES CODING NECESSARY FOR THIS      
C     ELEMENT*S PIEZOELECTRIC CAPABILITY        
C        
C     KSYS78 = 0   ELASTIC, NON-PIEZOELECTRIC MATERIAL        
C     KSYS78 = 1   ELECTRICAL-ELASTIC COUPLED, PIEZOELETRIC MATERIAL    
C     KSYS78 = 2   ELASTIC ONLY, PIEZOELECTRIC MATERIAL        
C     LSYS78 = .TRUE. IF KSYS78 = 0, OR 2        
C        
      LOGICAL         ZERO,ZERON,LSYS78        
      INTEGER         SORC,IBLOCK(22,14),ISTRES(100),IFORCE(25),ELEMID, 
     1                ICLOCK(22,14)        
      REAL            NPHI        
      DIMENSION       TI(3),DUM3(225),STRES(100),FORCE(25),AKUPH(27),   
     1                AKPH2(9),SELP1(18),SELP2(27),SELP3(9),D3(3),D6(6),
     2                D9(9),DISPP(3),ECHRG(3),EFLUX(3)        
C        
C     SDR2 VARIABLE CORE        
C        
CZZ   COMMON /ZZSDR2/ ZZ(1)        
      COMMON /ZZZZZZ/ ZZ(1)        
C        
C     SDR2 BLOCK FOR POINTERS AND LOADING  TEMPERATURES        
C        
      COMMON /SDR2X4/ DUM1(33),ICSTM,NCSTM,IVEC,IVECN,TEMPLD,ELDEFM,    
     1                DUM4(12),KTYPE        
C        
C     SCRATCH BLOCK        
C        
      COMMON /SDR2X8/ DISP(9),EFORC(9),ESTRES(9),HARM,N,SINPHI,CONPHI,  
     1                NPHI,NANGLE,ELEMID,UNU(123),NELHAR        
C        
C     SDR2 INPUT AND OUTPUT BLOCK        
C        
      COMMON /SDR2X7/ IDEL,IGP(3),TZ,SEL(54),TS(6),AK(81),PHI(14),      
     1                DUM2(90),BLOCK(22,14),CLOCK(22,14)        
C        
      COMMON /SDR2DE/ DUM5(33), IPART        
      COMMON /CONDAS/ CONSTS(5)        
      COMMON /SYSTEM/ KSYSTM(77),KSYS78        
      EQUIVALENCE     (IBLOCK(1,1),BLOCK(1,1)),(ICLOCK(1,1),CLOCK(1,1)),
     1                (DUM3(1),IDEL),(LDTEMP,TEMPLD),        
     2                (DUM3(109),STRES(9),ISTRES(9),EFLUX(1)),        
     3                (DUM3(201),FORCE(1),IFORCE(1)),        
     4                (DUM2(1),SELP1(1)),(DUM2(19),AKPH2(1)),        
     5                (DUM2(28),AKUPH(1)),(DUM2(55),SELP2(1)),        
     6                (DUM2(82),SELP3(1)),(CONSTS(4),DEGRAD),        
     7                (UNU(1),D3(1)),(UNU(4),D6(1)),(UNU(10),D9(1))     
      DATA    ZERON / .FALSE. /        
      DATA    IOSORC/ 0       /        
C        
      LSYS78 = .FALSE.        
      IF (KSYS78.EQ.0 .OR. KSYS78.EQ.2) LSYS78 = .TRUE.        
C        
      ELEMID = IDEL/1000        
      NELHAR = IDEL - ELEMID*1000        
C        
C     SET BLOCK = 0 IF HARMONIC = 0        
C        
      N = NELHAR - 1        
      IF (N .NE. 0) GO TO 21        
      IF (N.EQ.0 .AND. ZERON .AND. IOSORC .NE. SORC) GO TO 14        
      ZERON  = .TRUE.        
      IOSORC = SORC        
      DO 15 I = 2,22        
      DO 15 J = 1,14        
      IF (KTYPE.NE.2 .OR. IPART.NE.2) BLOCK(I,J) = 0.0        
      CLOCK(I,J) = 0.0        
   15 CONTINUE        
C        
C     SET ANGLES CONTROL FOR SUMMATION        
C        
      ZERO = .FALSE.        
      J = 0        
      DO 16 I = 1,14        
      IF (PHI(I)) 17,18,17        
   18 IF (ZERO) GO TO 16        
      ZERO = .TRUE.        
   17 J = J + 1        
      BLOCK(1,J) = PHI(I)        
      CLOCK(1,J) = PHI(I)        
   16 CONTINUE        
      J = J + 1        
      IF (J .GT. 14) GO TO 21        
      IBLOCK(1,J) = 1        
      ICLOCK(1,J) = 1        
      GO TO 21        
   14 ZERON = .FALSE.        
   21 HARM  = N        
C        
C     INITIALIZE LOCAT VARIABLES        
C        
      NDOF  = 3        
      NUMPT = 3        
      N     = NDOF*NUMPT        
      NSP   = 1        
      NCOMP = 6        
      NS    = NSP*NCOMP        
C        
C     FIND GRID POINTS DISPLACEMENTS        
C        
      K = 0        
      DO 100 I = 1,NUMPT        
      ILOC = IVEC + IGP(I) - 2        
C        
      IF (LSYS78) GO TO 90        
      ILOCP = ILOC + 4        
      DISPP(I) = ZZ(ILOCP)        
   90 CONTINUE        
      DO 100 J = 1,NDOF        
      ILOC = ILOC + 1        
      K    = K + 1        
      DISP(K) = ZZ(ILOC)        
  100 CONTINUE        
C        
C     COMPUTE THE GRID POINT FORCES        
C        
      CALL GMMATS (AK(1),N,N,0, DISP(1),N,1,0, EFORC(1))        
C        
      DO 109 I = 1,3        
  109 ECHRG(I) = 0.0        
C        
      IF (LSYS78) GO TO 125        
      CALL GMMATS (AKUPH(1),N,NUMPT,0, DISPP(1),NUMPT,1,0, D9(1))       
      DO 110 I = 1,9        
  110 EFORC(I) = EFORC(I) + D9(I)        
C        
      CALL GMMATS (AKUPH(1),N,NUMPT,1, DISP(1),N,1,0, D3(1))        
      CALL GMMATS (AKPH2(1),NUMPT,NUMPT,0, DISPP(1),NUMPT,1,0, ECHRG(1))
      DO 120 I = 1,3        
  120 ECHRG(I) = ECHRG(I) + D3(I)        
C        
C     COMPUTE THE STRESSES        
C        
  125 CALL GMMATS (SEL(1),NS,N,0, DISP(1),N,1,0, ESTRES(1))        
C        
      DO 129 I = 1,3        
  129 EFLUX(I) = 0.0        
C        
      IF (LSYS78) GO TO 145        
      CALL GMMATS (SELP1(1),NS,NUMPT,0, DISPP(1),NUMPT,1,0, D6(1))      
      DO 130 I = 1,6        
  130 ESTRES(I) = ESTRES(I) + D6(I)        
C        
      CALL GMMATS (SELP2(1),NUMPT,N,0, DISP(1),N,1,0, EFLUX(1))        
      CALL GMMATS (SELP3(1),NUMPT,NUMPT,0, DISPP(1),NUMPT,1,0, D3(1))   
C        
      DO 140 I = 1,3        
  140 EFLUX(I) = EFLUX(I) + D3(I)        
C        
C     COMPUTE THERMAL STRESS IF IT IS EXISTS        
C        
  145 IF (LDTEMP .EQ. -1) GO TO 300        
      DT = TZ        
      IF (HARM .GT. 0.0) DT = 0.0        
      DT = (TI(1)+TI(2)+TI(3))/3.0 - DT        
      DO 200 I = 1,NS        
      ESTRES(I) = ESTRES(I) - DT*TS(I)        
  200 CONTINUE        
C        
C     BRANCH TO INSERT HARMONIC STRESSES AND FORCES INTO BLOCK OR CLOCK 
C        
C     KTYPE = 1 - REAL OUTPUT, STORED IN BLOCK, NOTHING IN CLOCK        
C     KTYPE = 2 - COMPLEX OUTPUT        
C     IPART = 1 - IMAGINARY PART OF COMPLEX OUTPUT, STORED IN BLOCK     
C     IPART = 2 - REAL PART OF COMPLEX OUTPUT, STORED IN CLOCK        
C        
  300 IF (KTYPE.EQ.2 .AND. IPART.EQ.2) GO TO 505        
C        
C     INSERT HARMONIC STRESSES AND FORCES INTO BLOCK        
C        
      DO 380 I = 1,14        
      IF (IBLOCK(1,I) .EQ. 1) GO TO 390        
      IF (HARM .NE. 0.0) GO TO 330        
      DO 310 IWA = 1,6        
      BLOCK(IWA+1,I) = ESTRES(IWA)        
      BLOCK(IWA+7,I) = EFORC (IWA)        
  310 CONTINUE        
      BLOCK(14,I) = EFORC(7)        
      BLOCK(15,I) = EFORC(8)        
      BLOCK(16,I) = EFORC(9)        
C        
      IF (LSYS78) GO TO 320        
      BLOCK(17,I) = EFLUX(1)        
      BLOCK(18,I) = EFLUX(2)        
      BLOCK(19,I) = EFLUX(3)        
      BLOCK(20,I) = ECHRG(1)        
      BLOCK(21,I) = ECHRG(2)        
      BLOCK(22,I) = ECHRG(3)        
  320 CONTINUE        
      GO TO 380        
  330 CONTINUE        
      NPHI   = HARM*BLOCK(1,I)*DEGRAD        
      SINPHI = SIN(NPHI)        
      CONPHI = COS(NPHI)        
C        
      GO TO (360,340), SORC        
C        
  340 BLOCK( 2,I) = BLOCK( 2,I) + CONPHI*ESTRES(1)        
      BLOCK( 3,I) = BLOCK( 3,I) + CONPHI*ESTRES(2)        
      BLOCK( 4,I) = BLOCK( 4,I) + CONPHI*ESTRES(3)        
      BLOCK( 5,I) = BLOCK( 5,I) + CONPHI*ESTRES(4)        
      BLOCK( 6,I) = BLOCK( 6,I) + SINPHI*ESTRES(5)        
      BLOCK( 7,I) = BLOCK( 7,I) + SINPHI*ESTRES(6)        
      BLOCK( 8,I) = BLOCK( 8,I) + CONPHI*EFORC(1)        
      BLOCK( 9,I) = BLOCK( 9,I) + SINPHI*EFORC(2)        
      BLOCK(10,I) = BLOCK(10,I) + CONPHI*EFORC(3)        
      BLOCK(11,I) = BLOCK(11,I) + CONPHI*EFORC(4)        
      BLOCK(12,I) = BLOCK(12,I) + SINPHI*EFORC(5)        
      BLOCK(13,I) = BLOCK(13,I) + CONPHI*EFORC(6)        
      BLOCK(14,I) = BLOCK(14,I) + CONPHI*EFORC(7)        
      BLOCK(15,I) = BLOCK(15,I) + SINPHI*EFORC(8)        
      BLOCK(16,I) = BLOCK(16,I) + CONPHI*EFORC(9)        
      IF (LSYS78) GO TO 350        
      BLOCK(17,I) = BLOCK(17,I) + CONPHI*EFLUX(1)        
      BLOCK(18,I) = BLOCK(18,I) + CONPHI*EFLUX(2)        
      BLOCK(19,I) = BLOCK(19,I) + SINPHI*EFLUX(3)        
      BLOCK(20,I) = BLOCK(20,I) + CONPHI*ECHRG(1)        
      BLOCK(21,I) = BLOCK(21,I) + CONPHI*ECHRG(2)        
      BLOCK(22,I) = BLOCK(22,I) + CONPHI*ECHRG(3)        
  350 CONTINUE        
      GO TO 380        
  360 BLOCK( 2,I) = BLOCK( 2,I) + SINPHI*ESTRES(1)        
      BLOCK( 3,I) = BLOCK( 3,I) + SINPHI*ESTRES(2)        
      BLOCK( 4,I) = BLOCK( 4,I) + SINPHI*ESTRES(3)        
      BLOCK( 5,I) = BLOCK( 5,I) + SINPHI*ESTRES(4)        
      BLOCK( 6,I) = BLOCK( 6,I) - CONPHI*ESTRES(5)        
      BLOCK( 7,I) = BLOCK( 7,I) - CONPHI*ESTRES(6)        
      BLOCK( 8,I) = BLOCK( 8,I) + SINPHI*EFORC(1)        
      BLOCK( 9,I) = BLOCK( 9,I) - CONPHI*EFORC(2)        
      BLOCK(10,I) = BLOCK(10,I) + SINPHI*EFORC(3)        
      BLOCK(11,I) = BLOCK(11,I) + SINPHI*EFORC(4)        
      BLOCK(12,I) = BLOCK(12,I) - CONPHI*EFORC(5)        
      BLOCK(13,I) = BLOCK(13,I) + SINPHI*EFORC(6)        
      BLOCK(14,I) = BLOCK(14,I) + SINPHI*EFORC(7)        
      BLOCK(15,I) = BLOCK(15,I) - CONPHI*EFORC(8)        
      BLOCK(16,I) = BLOCK(16,I) - SINPHI*EFORC(9)        
      IF (LSYS78) GO TO 370        
      BLOCK(17,I) = BLOCK(17,I) + SINPHI*EFLUX(1)        
      BLOCK(18,I) = BLOCK(18,I) + SINPHI*EFLUX(2)        
      BLOCK(19,I) = BLOCK(19,I) - CONPHI*EFLUX(3)        
      BLOCK(20,I) = BLOCK(20,I) + SINPHI*ECHRG(1)        
      BLOCK(21,I) = BLOCK(21,I) + SINPHI*ECHRG(2)        
      BLOCK(22,I) = BLOCK(22,I) + SINPHI*ECHRG(3)        
  370 CONTINUE        
  380 CONTINUE        
C        
C     COPY STRESSES AND FORCES INTO OUTPUT BLOCKS        
C     FLUXES ARE EQUIVALENCED INTO STRES(J)        
C     CHARGES ARE WRITTEN INTO FORCE(J)        
C        
  390 J = 2        
      ISTRES (1) = ELEMID        
      ISTRES (2) = NELHAR        
      DO 400 I = 1,NCOMP        
      J = J + 1        
      STRES(J) = ESTRES(I)        
  400 CONTINUE        
      K = 0        
      J = 2        
      IFORCE(1) = ELEMID        
      IFORCE(2) = NELHAR        
      DO 500 I  = 1,NUMPT        
      DO 500 KK = 1,NDOF        
      J = J + 1        
      K = K + 1        
      FORCE(J) = EFORC(K)        
C        
      IF (K.NE.3 .AND. K.NE.6 .AND. K.NE.9) GO TO 500        
      J  = J + 1        
      K3 = K/3        
      FORCE(J) = ECHRG(K3)        
  500 CONTINUE        
C        
      IF (KTYPE.EQ.1 .OR. (KTYPE.EQ.2 .AND. IPART.EQ.1)) GO TO 1000     
C        
C     INSERT HARMONIC STRESSES AND FORCES INTO CLOCK        
C        
  505 DO 580 I = 1,14        
      IF (ICLOCK(1,I) .EQ. 1) GO TO 600        
      IF (HARM .NE. 0.0) GO TO 530        
      DO 510 IWA = 1,6        
      CLOCK(IWA+1,I) = ESTRES(IWA)        
      CLOCK(IWA+7,I) = EFORC (IWA)        
  510 CONTINUE        
      CLOCK(14,I) = EFORC(7)        
      CLOCK(15,I) = EFORC(8)        
      CLOCK(16,I) = EFORC(9)        
C        
      IF (LSYS78) GO TO 520        
      CLOCK(17,I) = EFLUX(1)        
      CLOCK(18,I) = EFLUX(2)        
      CLOCK(19,I) = EFLUX(3)        
      CLOCK(20,I) = ECHRG(1)        
      CLOCK(21,I) = ECHRG(2)        
      CLOCK(22,I) = ECHRG(3)        
  520 CONTINUE        
      GO TO 580        
  530 CONTINUE        
      NPHI   = HARM*CLOCK(1,I)*DEGRAD        
      SINPHI = SIN(NPHI)        
      CONPHI = COS(NPHI)        
C        
      GO TO (560,540), SORC        
C        
  540 CLOCK( 2,I) = CLOCK( 2,I) + CONPHI*ESTRES(1)        
      CLOCK( 3,I) = CLOCK( 3,I) + CONPHI*ESTRES(2)        
      CLOCK( 4,I) = CLOCK( 4,I) + CONPHI*ESTRES(3)        
      CLOCK( 5,I) = CLOCK( 5,I) + CONPHI*ESTRES(4)        
      CLOCK( 6,I) = CLOCK( 6,I) + SINPHI*ESTRES(5)        
      CLOCK( 7,I) = CLOCK( 7,I) + SINPHI*ESTRES(6)        
      CLOCK( 8,I) = CLOCK( 8,I) + CONPHI*EFORC(1)        
      CLOCK( 9,I) = CLOCK( 9,I) + SINPHI*EFORC(2)        
      CLOCK(10,I) = CLOCK(10,I) + CONPHI*EFORC(3)        
      CLOCK(11,I) = CLOCK(11,I) + CONPHI*EFORC(4)        
      CLOCK(12,I) = CLOCK(12,I) + SINPHI*EFORC(5)        
      CLOCK(13,I) = CLOCK(13,I) + CONPHI*EFORC(6)        
      CLOCK(14,I) = CLOCK(14,I) + CONPHI*EFORC(7)        
      CLOCK(15,I) = CLOCK(15,I) + SINPHI*EFORC(8)        
      CLOCK(16,I) = CLOCK(16,I) + CONPHI*EFORC(9)        
C        
      IF (LSYS78) GO TO 550        
      CLOCK(17,I) = CLOCK(17,I) + CONPHI*EFLUX(1)        
      CLOCK(18,I) = CLOCK(18,I) + CONPHI*EFLUX(2)        
      CLOCK(19,I) = CLOCK(19,I) + SINPHI*EFLUX(3)        
      CLOCK(20,I) = CLOCK(20,I) + CONPHI*ECHRG(1)        
      CLOCK(21,I) = CLOCK(21,I) + CONPHI*ECHRG(2)        
      CLOCK(22,I) = CLOCK(22,I) + CONPHI*ECHRG(3)        
  550 CONTINUE        
      GO TO 580        
C        
  560 CLOCK( 2,I) = CLOCK( 2,I) + SINPHI*ESTRES(1)        
      CLOCK( 3,I) = CLOCK( 3,I) + SINPHI*ESTRES(2)        
      CLOCK( 4,I) = CLOCK( 4,I) + SINPHI*ESTRES(3)        
      CLOCK( 5,I) = CLOCK( 5,I) + SINPHI*ESTRES(4)        
      CLOCK( 6,I) = CLOCK( 6,I) - CONPHI*ESTRES(5)        
      CLOCK( 7,I) = CLOCK( 7,I) - CONPHI*ESTRES(6)        
      CLOCK( 8,I) = CLOCK( 8,I) + SINPHI*EFORC(1)        
      CLOCK( 9,I) = CLOCK( 9,I) - CONPHI*EFORC(2)        
      CLOCK(10,I) = CLOCK(10,I) + SINPHI*EFORC(3)        
      CLOCK(11,I) = CLOCK(11,I) + SINPHI*EFORC(4)        
      CLOCK(12,I) = CLOCK(12,I) - CONPHI*EFORC(5)        
      CLOCK(13,I) = CLOCK(13,I) + SINPHI*EFORC(6)        
      CLOCK(14,I) = CLOCK(14,I) + SINPHI*EFORC(7)        
      CLOCK(15,I) = CLOCK(15,I) - CONPHI*EFORC(8)        
      CLOCK(16,I) = CLOCK(16,I) + SINPHI*EFORC(9)        
      IF (LSYS78) GO TO 570        
      CLOCK(17,I) = CLOCK(17,I) + SINPHI*EFLUX(1)        
      CLOCK(18,I) = CLOCK(18,I) + SINPHI*EFLUX(2)        
      CLOCK(19,I) = CLOCK(19,I) - CONPHI*EFLUX(3)        
      CLOCK(20,I) = CLOCK(20,I) + SINPHI*ECHRG(1)        
      CLOCK(21,I) = CLOCK(21,I) + SINPHI*ECHRG(2)        
      CLOCK(22,I) = CLOCK(22,I) + SINPHI*ECHRG(3)        
  570 CONTINUE        
  580 CONTINUE        
C        
C     COPY STRESSES AND FORCES INTO OUTPUT BLOCKS        
C     FLUXES ARE EQUIVALENCED INTO STRES(J)        
C     CHARGES ARE WRITTEN INTO FORCE(J)        
C        
  600 J = 2        
      ISTRES (1) = ELEMID        
      ISTRES (2) = NELHAR        
      DO 700 I = 1,NCOMP        
      J = J + 1        
      STRES(J) = ESTRES(I)        
  700 CONTINUE        
      K = 0        
      J = 2        
      IFORCE(1) = ELEMID        
      IFORCE(2) = NELHAR        
      DO 800 I  = 1,NUMPT        
      DO 800 KK = 1,NDOF        
      J = J + 1        
      K = K + 1        
      FORCE(J) = EFORC(K)        
C        
      IF (K.NE.3 .AND. K.NE.6 .AND. K.NE.9) GO TO 800        
      J  = J + 1        
      K3 = K/3        
      FORCE(J) = ECHRG(K3)        
  800 CONTINUE        
C        
 1000 RETURN        
      END        
