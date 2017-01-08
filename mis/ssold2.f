      SUBROUTINE SSOLD2 (ITYPE,FTEMP)        
C        
C     PHASE TWO STRESS DATA RECOVERY FOR THE SOLID ELEMENTS        
C        
C     ITYPE = 1,2,3,OR4 CORRESPONDING TO THE TETRA,WEDGE,HEXA1,ORHEXA2  
C             ELEMENTS        
C        
C     PHIOUT CONTAINS THE FOLLOWING WHERE N IS THE NUMBER OF CORNERS    
C        
C             ELEMENT ID        
C             N SILS        
C             T SUB 0        
C             6 THERMAL STRESS COEFFICIENTS        
C             N VOLUME RATIO COEFFICIENTS        
C             N 6 BY 3 MATRICES RELATING STRESS TO DISPLACEMENTS        
C        
C  $MIXED_FORMATS        
C        
      INTEGER         NPHI(1),EJECT,ISHD(7),TYP(8),ISTYP(2)        
      REAL            FTEMP(8),FRLAST(2)        
      COMMON /SYSTEM/ IBFSZ,NOUT,IDM(9),LINE        
CZZ   COMMON /ZZSDR2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SDR2X4/ DUMMY(35),IVEC,IVECN,LDTEMP,DEFORM        
      COMMON /SDR2X7/ PHIOUT(100),STRES(100),FORVEC(25)        
      COMMON /SDR2X8/ TEMP(6),FACTOR,NPTS,NPOINT,KS,KBETA,SIGMA(9),     
     1                CTMP(6),CSIG(7)        
      COMMON /SDR2X9/ NCHK,ISUB,ILD,FRTMEI(2),TWOTOP,FNCHK        
      EQUIVALENCE     (NPHI(1),PHIOUT(1)),(ISHD(1),LSUB),        
     1                (ISHD(2),LLD),(ISHD(6),FRLAST(1))        
      DATA    TYP   / 4HTETR,1HA, 4HWEDG,1HE, 4HHEXA,1H1, 4HHEXA,1H2  / 
      DATA    LLD   , LSUB,FRLAST / 2*-1, -1.0E30, -1.0E30  /        
C        
      GO TO (100,110,120,120), ITYPE        
  100 NPTS = 4        
      GO TO 130        
  110 NPTS = 6        
      GO TO 130        
  120 NPTS = 8        
C        
C        
  130 DO 140 I = 1,9        
      CSIG(I)  = 0.0        
  140 SIGMA(I) = 0.0        
C        
C     LOOP ON GRID POINTS, DISPLACEMENT EFFECTS        
C        
      DO 1000 N = 1,NPTS        
      NPOINT = IVEC + NPHI(N+1) - 1        
      KS =  18*N + 2*NPTS - 9        
      CALL SMMATS (PHIOUT(KS),6,3,0, Z(NPOINT),3,1,0, TEMP,CTMP)        
      DO 200 I = 1,6        
      CSIG (I+1) =  CSIG(I+1) + CTMP(I)        
  200 SIGMA(I+1) = SIGMA(I+1) + TEMP(I)        
C        
C     TEMPERATURE EFFECTS        
C        
      IF (LDTEMP .EQ. -1) GO TO 1000        
      KBETA  = NPTS + N + 8        
      FACTOR = (FTEMP(N) - PHIOUT(NPTS+2))*PHIOUT(KBETA)        
C        
      DO 300 I = 1,6        
      KBETA = NPTS + I + 2        
  300 SIGMA(I+1) = SIGMA(I+1) - PHIOUT(KBETA)*FACTOR        
 1000 CONTINUE        
      SIGMA(1) = PHIOUT(1)        
      DO 1100 I = 1,7        
 1100 STRES(I) = SIGMA(I)        
C        
C     OCTAHEDRAL STRESS AND HYDROSTATIC PRESSURE        
C        
      STRES(8) = SQRT(SIGMA(2)*(SIGMA(2) - SIGMA(3) - SIGMA(4))*2.0 +   
     1           2.0*SIGMA(3)*(SIGMA(3) - SIGMA(4)) + 2.0* SIGMA(4)**2 +
     2           6.0*(SIGMA(5)**2 + SIGMA(6)**2 + SIGMA(7)**2))/3.0     
      STRES(9) = -(SIGMA(2) + SIGMA(3) + SIGMA(4))/3.0        
      IF (NCHK .LE. 0) GO TO 450        
C        
C   . CHECK PRECISION        
C        
      CSIG(1) = PHIOUT(1)        
      K = 0        
C        
C   . STRESSES        
C        
      CALL SDRCHK (SIGMA(2),CSIG(2),6,K)        
      IF (K .EQ. 0) GO TO 450        
C        
C   . LIMITS EXCEEDED        
C        
      J = 2*ITYPE        
      ISTYP(1) = TYP(J-1)        
      ISTYP(2) = TYP(J  )        
      J = 0        
C        
      IF (LSUB.EQ.ISUB .AND. FRLAST(1).EQ.FRTMEI(1) .AND.        
     1    LLD .EQ.ILD  .AND. FRLAST(2).EQ.FRTMEI(2)) GO TO 420        
      LSUB = ISUB        
      LLD  = ILD        
      FRLAST(1) = FRTMEI(1)        
      FRLAST(2) = FRTMEI(2)        
      J = 2        
      CALL PAGE1        
  400 CALL SD2RHD (ISHD,J)        
      LINE = LINE + 1        
      WRITE  (NOUT,410)        
  410 FORMAT (7X,4HTYPE,5X,3HEID,5X,2HSX,5X,2HSY,5X,2HSZ,4X,3HTYZ,4X,   
     1        3HTXZ,4X,3HTXY)        
      GO TO 430        
  420 IF (EJECT(2) .NE. 0) GO TO 400        
  430 WRITE  (NOUT,440,ERR=450) ISTYP,CSIG        
  440 FORMAT (1H0,6X,A4,A1,I7,6F7.1)        
C        
  450 CONTINUE        
      RETURN        
      END        
