      SUBROUTINE DETFBS (IY,IOBUF,FILEU,NROW,KCOUNT)        
C        
C     DETFBS IS A SPECIAL VERSION OF THE GFBS ROUTINE AND IS USED BY    
C     THE REAL DETERMINANT METHOD.  IT IS SUITABLE FOR BOTH SINGLE      
C     AND DOUBLE PRECISION OPERATION.        
C        
C        
C     DEFINITION OF PARAMETERS        
C     ------------------------        
C        
C     FILEU  = MATRIX CONTROL BLOCK FOR THE UPPER TRIANGLE        
C     FILEV  = SAME AS FILEU        
C     FILEVT = MATRIX CONTROL BLOCK FOR THE TRANSPOSE OF THE UPPER      
C              TRIANGLE        
C     X, DX  = THE SOLUTION VECTOR        
C     Y, DY  = REGION USED FOR UNPACKING        
C     IY     = POINTER TO Y (DY) RELATIVE TO X (DX)        
C     IOBUF  = THE INPUT BUFFER        
C     NROW   = MATRIX SIZE        
C     KCOUNT = EIGENVALUE COUNTER        
C        
      INTEGER          FILEU(7),PARM(4) ,IOBUF(7),OPTION ,SDET ,FILEV , 
     1                 FILEVT  ,SCR3    ,SCR4    ,SCR6   ,SCR        
      REAL             X(1)    ,Y(1)        
      DOUBLE PRECISION DX(1)   ,DY(1)   ,DXMIN   ,DSDIAG        
CZZ   COMMON /ZZDETX/  CORE(1)        
      COMMON /ZZZZZZ/  CORE(1)        
      COMMON /DETMX /  DUM3(36),IPDETA        
      COMMON /NAMES /  RD      ,RDREW   ,WRT     ,WRTREW  ,REW        
      COMMON /REGEAN/  DUM1(23),SCR3    ,SCR4    ,DUM2(11),SCR6        
      COMMON /REIGKR/  OPTION        
      COMMON /TRNSPX/  FILEV(7),FILEVT(7),LCORE  ,NCR     ,SCR(2)       
      COMMON /UNPAKX/  ITYPEX  , IUNPAK ,JUNPAK  ,INCR        
      EQUIVALENCE      (CORE(1),X(1),DX(1),Y(1),DY(1))    ,        
     1                 (XMIN,DXMIN) ,   (SDIAG,DSDIAG)        
      DATA    SDET  /  4HSDET  /        
      DATA    PARM(3), PARM(4) / 4HDETF, 4HBS   /        
C        
      ITYPEX = FILEU(5)        
      INDEX  = -1        
      INCR   = 1        
      NFILE  = FILEU(1)        
      IF (OPTION .EQ. SDET) GO TO 30        
      INDEX  = 1        
      LCORE  = IPDETA - IY*ITYPEX - 1        
      IF (LCORE .LT. 0) CALL MESAGE (-8,0,PARM(3))        
      NCR = 2        
      SCR(1) = SCR3        
      SCR(2) = SCR4        
      DO 20 I = 1,7        
      FILEV(I)  = FILEU(I)        
      FILEVT(I) = FILEU(I)        
   20 CONTINUE        
   30 FILEVT(1) = SCR6        
      NFILE  = FILEVT(1)        
      IF (ITYPEX .EQ. 1) CALL TRNSP ( Y(IY))        
      IF (ITYPEX .NE. 1) CALL TRNSP (DY(IY))        
      IF (ITYPEX .EQ. 1) GO TO 50        
      ASSIGN 230 TO ISD        
      ASSIGN 260 TO IUS        
   40 PARM(2) = NFILE        
      CALL GOPEN (NFILE,IOBUF,RDREW)        
      GO TO 60        
   50 ASSIGN 240 TO ISD        
      ASSIGN 270 TO IUS        
      GO TO 40        
   60 XMIN = 1.0E20        
      IF (ITYPEX .NE. 1) DXMIN = 1.0D20        
      DO 80 I = 1,NROW        
      IUNPAK = 0        
      IF (ITYPEX .NE. 1) GO TO 70        
      CALL UNPACK (*400,NFILE,X(I))        
      IF (XMIN .GT. ABS(X(I))) XMIN = ABS(X(I))        
      GO TO 80        
   70 CALL UNPACK (*400,NFILE,DX(I))        
      IF (DXMIN .GT. DABS(DX(I))) DXMIN = DABS(DX(I))        
   80 CONTINUE        
      IF (ITYPEX.EQ.1 .AND. XMIN .NE.0.0  ) GO TO 120        
      IF (ITYPEX.NE.1 .AND. DXMIN.NE.0.0D0) GO TO 120        
      XMIN = 1.0E20        
      IF (ITYPEX .NE. 1) DXMIN = 1.0D20        
      DO 100 I = 1,NROW        
      IF (ITYPEX .NE. 1) GO TO 90        
      IF (X(I) .EQ. 0.0) GO TO 100        
      IF (XMIN .GT. ABS(X(I))) XMIN = ABS(X(I))        
      GO TO 100        
   90 IF (DX(I) .EQ. 0.0D0) GO TO 100        
      IF (DXMIN .GT. DABS(DX(I))) DXMIN = DABS(DX(I))        
  100 CONTINUE        
      IF (ITYPEX .NE. 1) GO TO 110        
      IF (XMIN .GT. 1.0E-8) XMIN = 1.0E-8        
      GO TO 120        
  110 IF (DXMIN .GT. 1.0D-8) DXMIN = 1.0D-8        
C        
C     BUILD LOAD VECTOR FOR BACKWARD PASS        
C        
  120 SDIAG = 1.0        
      IF (ITYPEX .NE. 1) DSDIAG = 1.0D0        
      DO 160 I = 1,NROW        
      ANUM = (-1)**(I*KCOUNT)        
      AI   = I        
      ADEN = 1.0 + (1.0 - AI/NROW)*KCOUNT        
      AVALUE = ANUM/ADEN        
      IF (ITYPEX .NE.    1) GO TO 140        
      IF (OPTION .NE. SDET) GO TO 130        
      SDIAG = X(I)        
      IF (X(I).GE.0.0 .AND. ABS(X(I)).LT.XMIN) SDIAG = XMIN        
      IF (X(I).LT.0.0 .AND. ABS(X(I)).LT.XMIN) SDIAG =-XMIN        
  130 X(I) = XMIN*AVALUE/SDIAG        
      GO TO 160        
  140 IF (OPTION .NE. SDET) GO TO 150        
      DSDIAG = DX(I)        
      IF (DX(I).GE.0.0 .AND. DABS(DX(I)).LT.DXMIN) DSDIAG = DXMIN       
      IF (DX(I).LT.0.0 .AND. DABS(DX(I)).LT.DXMIN) DSDIAG =-DXMIN       
  150 DX(I) = DXMIN*AVALUE/DSDIAG        
  160 CONTINUE        
C        
C        
C     BEGIN BACKWARD PASS        
C        
      DO 300 I = 1,NROW        
      IUNPAK = 0        
      J = NROW - I + 1        
      CALL BCKREC (NFILE)        
      IF (ITYPEX .EQ. 1) CALL UNPACK (*400,NFILE,Y(IY))        
      IF (ITYPEX .NE. 1) CALL UNPACK (*400,NFILE,DY(IY))        
      CALL BCKREC (NFILE)        
      ISING = 0        
      K = JUNPAK - IUNPAK + IY        
      GO TO ISD, (230,240)        
C        
C     DIVIDE BY THE DIAGONAL TERM        
C        
  200 IF (OPTION .EQ. SDET) GO TO 300        
      IF (DY(K).GE.0.0D0 .AND. DABS(DY(K)).LT.DXMIN) DY(K) = DXMIN      
      IF (DY(K).LT.0.0D0 .AND. DABS(DY(K)).LT.DXMIN) DY(K) =-DXMIN      
      DX(J) = DX(J)/DY(K)        
      GO TO 300        
  210 IF (OPTION .EQ. SDET) GO TO 300        
      IF (Y(K).GE.0.0 .AND. ABS(Y(K)).LT.XMIN) Y(K) = XMIN        
      IF (Y(K).LT.0.0 .AND. ABS(Y(K)).LT.XMIN) Y(K) =-XMIN        
      X(J) = X(J)/Y(K)        
      GO TO 300        
  220 K = K - 1        
      JUNPAK = JUNPAK - 1        
      IF (K .LT. IY) GO TO 280        
      GO TO ISD, (230,240)        
  230 IF (DY(K) .EQ. 0.0D0) GO TO 220        
      IF (JUNPAK - J) 280,200,250        
  240 IF (Y(K) .EQ. 0.0) GO TO 220        
      IF (JUNPAK - J) 280,210,250        
  250 GO TO IUS, (260,270)        
  260 DX(J) = DX(J) - INDEX*DX(JUNPAK)*DY(K)        
      GO TO 220        
  270 X(J) = X(J) - INDEX*X(JUNPAK)*Y(K)        
      GO TO 220        
  280 IF (ISING .EQ. 0) GO TO 400        
  300 CONTINUE        
C        
      IF (OPTION .EQ. SDET) GO TO 340        
      IF (ITYPEX .EQ.    1) GO TO 320        
      DO 310 I = 1,NROW        
      DX(I) = -DX(I)        
  310 CONTINUE        
      GO TO 340        
  320 DO 330 I = 1,NROW        
      X(I) = -X(I)        
  330 CONTINUE        
  340 CALL CLOSE (NFILE,REW)        
      RETURN        
C        
C     ATTEMPT TO OPERATE ON SINGULAR MATRIX        
C        
  400 PARM(1) = -5        
      CALL MESAGE (PARM(1),PARM(2),PARM(3))        
      RETURN        
      END        
