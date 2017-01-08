      SUBROUTINE CURVIT (INDEP,NI,DEP,ND,IFILE,Z,IZ,LZ,MCLOSE,TOLER,    
     1                   MCSID,XSCALE,YSCALE)        
C        
C     PERFORMS LOCAL INTERPOLATION        
C        
C     INDEP  = X,Y COORDINATES OF INDEPENDENT ELEMENT CENTERS (2 X NI)  
C     DEP    = X,Y COORDINATES OF DEPENDENT GRID POINTS  (2 X ND)       
C     IFILE  = FILE TO WRITE SPECIAL FORM ROWS OF G-MATRIX        
C     Z      = REAL AREA OF CORE, LENGTH = LZ.        
C     IZ     = EQUIVALENT INTEGER AREA OF CORE, LENGTH = LZ.        
C     MCLOSE = NUMBER OF CLOSEST INDEPENDENT POINTS TO USE        
C     TOLER  = PERCENT OF DISTANCE FROM A DEPENDENT POINT TO        
C              INDEPENDENT POINT NUMBER -NCLOSE- POINTS FURTHER OUT ARE 
C              ALLOWED TO BE SUCH AS TO BE INCLUDED IN A LOCAL        
C              INTERPOLATION.        
C        
      INTEGER         SYSBUF, IZ(1), SUBR(2), ITEMP(2), RD, RDREW, WRT, 
     1                WRTREW, CLSREW, CLS, EOR        
      REAL            Z(1), DEP(2,1), INDEP(2,1)        
      CHARACTER       UFM*23, UWM*25        
      COMMON /XMSSG / UFM, UWM        
      COMMON /SYSTEM/ SYSBUF, IOUTPT        
      COMMON /NAMES / RD, RDREW, WRT, WRTREW, CLSREW, CLS        
      DATA    SUBR  / 4HCURV ,4HIT  /, EOR, NOEOR / 1, 0 /        
C        
      NCLOSE = MIN0(MCLOSE,NI)        
      IF (NCLOSE .LE. 2) NCLOSE = NI        
C        
C     COMPUTE TOLERANCE MULTIPLIER WITH RESPECT TO SQUARES.        
C     TOLERANCE IS IN PERCENT OF DISTANCE TO POINT NUMBER -NCLOSE- IN   
C     FINAL LIST        
C        
      TOL = (1.0 + TOLER/100.0)**2        
C        
C     THUS IF DISTANCE FROM THE DEPENDENT POINT TO INDEPENDENT POINT    
C     NUMBER -NCLOSE- = LSQ, ADDITIONAL INDEPENDENT POINTS WILL BE      
C     INCLUDED IF THE SQUARE OF THEIR DISTANCE TO THE DEPENDENT POINT   
C     IS .LE. TOL TIMES LSQ.        
C        
C        
C     ALLOCATE BUFFER FOR -IFILE- AND OPEN -IFILE-.        
C        
      IBUF = LZ - SYSBUF        
      JZ   = IBUF - 1        
      ICRQ = -JZ        
      IF (JZ .LE. 0) GO TO 900        
      CALL GOPEN (IFILE,IZ(IBUF),1)        
C        
C     EACH ROW OF G-MATRIX WILL BE WRITTEN AS A LOGICAL RECORD        
C     WITH PAIRS OF        
C                 1- INDEPENDENT POINT INDEX        
C                 2- G VALUE        
C        
C        
C     SHORT CUT WILL BE TAKEN IF ALL INDEPENDENT POINTS ARE TO BE USED  
C     FOR INTERPOLATION AT EACH DEPENDENT POINT.        
C        
      IF (NCLOSE .EQ. NI) GO TO 550        
C        
C     MASTER LOOP ON DEPENDENT POINTS. EACH DEPENDENT POINT RESULTS IN  
C     A VARIABLE LENGTH ROW OF G-MATRIX DEPENDING ON HOW MANY        
C     INDEPENDENT POINTS ARE SELECTED FOR USE. (AT LEAST 3 MUST BE USED)
C        
   80 DO 500 I = 1,ND        
C        
C     LIST OF DISTANCE SQUARES OF ALL INDEPENDENT POINTS TO        
C     CURRENT DEPENDENT POINT IS FORMED.        
C        
C     SELECTION OF THE -NCLOSE- SMALLEST VALUES IS THEN MADE.        
C        
C     THEN ANY OTHER INDEPENDENT POINTS WITHIN TOLERANCE RANGE OF       
C     POINT NUMBER -NCLOSE- IN LIST ARE ADDED.        
C        
      FMAX = 0.0        
      X    = DEP(1,I)        
      Y    = DEP(2,I)        
      ICRQ = NI - JZ        
      IF (NI .GT. JZ) GO TO 900        
      DO 100 J = 1,NI        
      Z(J) = (XSCALE*(INDEP(1,J)-X))**2 + (YSCALE*(INDEP(2,J)-Y))**2    
      IF (Z(J) .LE. FMAX) GO TO 100        
      FMAX = Z(J)        
  100 CONTINUE        
      FMAX = 2.0*FMAX + 1.0        
C        
C     ALLOCATE FOR LIST OF INDEXES TO THE MINIMUMS.        
C        
      ILIST = NI + 1        
      NLIST = NI        
C        
C     FIND -NCLOSE- SMALLEST VALUES.        
C        
      DO 170 J = 1,NCLOSE        
      FMIN = FMAX        
C        
      DO 160 K = 1,NI        
      IF (FMIN-Z(K)) 160,160,150        
  150 FMIN = Z(K)        
      IDX  = K        
  160 CONTINUE        
C        
C     ADD INDEX TO THIS MINIMUM TO THE LIST        
C        
      ICRQ = NLIST + 1 - JZ        
      IF (ICRQ .GT. 0) GO TO 900        
      IZ(NLIST+1) = IDX        
      NLIST = NLIST + 1        
C        
C     RESET THIS VALUE SO IT CAN NOT BE USED AGAIN        
C        
      Z(IDX) = FMAX        
  170 CONTINUE        
C        
C     ADD ANY ADDITIONAL INDEPENDENT POINTS WITHIN TOLERANCE RANGE OF   
C     LAST ONE SELECTED ABOVE.        
C        
      FMAX = TOL*FMIN        
      DO 190 J = 1,NI        
      IF (Z(J) .GT. FMAX) GO TO 190        
      ICRQ = NLIST + 1 - JZ        
      IF (ICRQ .GT. 0) GO TO 900        
      IZ(NLIST+1) = J        
      NLIST = NLIST + 1        
  190 CONTINUE        
C        
C     LIST IS COMPLETE THUS MOVE IT TO THE BEGINNING OF THE CORE BLOCK. 
C        
      J = 0        
      DO 210 K = ILIST,NLIST        
      J = J + 1        
      IZ(J) = IZ(K)        
  210 CONTINUE        
      ILIST = 1        
      NLIST = J        
      IPTS  = J        
C        
C     HERE AND IZ(ILIST) TO IZ(NLIST) CONTAINS LIST OF        
C     POSITION INDEXES OF INDEPENDENT POINT COORDINATES TO BE USED.     
C        
C     NOW SET UP LIST OF XY-CCORDINATES OF THESE INDEPENDENT POINTS     
C     FOR THE SSPLIN CALL.        
C        
      IXY  = NLIST + 1        
      NXY  = NLIST + 2*IPTS        
      ICRQ = NXY - JZ        
      IF (NXY .GT. JZ) GO TO 900        
      JXY  = NLIST        
      DO 270 J = ILIST,NLIST        
      K    = IZ(J)        
      Z(JXY+1) = INDEP(1,K)        
      Z(JXY+2) = INDEP(2,K)        
      JXY  = JXY + 2        
  270 CONTINUE        
C        
C     NOW READY FOR SSPLIN ROUTINE CALL.        
C        
      CALL SSPLIN (IPTS,Z(IXY),1,DEP(1,I),0,0,0,1,0,Z(JXY+1),JZ-JXY,    
     1             ISING)        
      IF (ISING .NE. 2) GO TO 300        
C        
C     ILL-CONDITION FOR THIS DEPENDENT POINT - NO SOLUTION POSSIBLE.    
C        
      CALL PAGE2 (4)        
      WRITE  (IOUTPT,250) UWM,I,MCSID        
  250 FORMAT (A25,' 2252. (CURVIT-1) LOCAL INTERPOLATION USING INDE',   
     1       'PENDENT VALUES WITHIN RANGE OF THE', /5X,I7,'-TH SORTED ',
     2       'ORDER GRID ID INVOLVED WITH RESPECT TO MATERIAL COORDIN', 
     3       'ATE SYSTEM ID',I9, /5X,'CAN NOT BE COMPLETED.  ILL-CONDI',
     4       'TION MAY HAVE RESULTED FROM ALIGNMENT OF INDEPENDENT ',   
     5       'VALUE COORDINATES.', /5X,        
     6       'OUTPUT FOR THE GRID ID IN QUESTION WILL NOT APPEAR.')     
      IPTS = 0        
      GO TO 340        
C        
C     REPLACE INDEPENDENT POINT XY PAIRS WITH SPECIAL FORM DEPENDENT    
C     POINT G-MATRIX OUTPUT ROW.        
C        
  300 K1 = ILIST        
      K2 = JXY + 1        
      DO 320 J = IXY,NXY,2        
      IZ(J ) = IZ(K1)        
      Z(J+1) = Z(K2)        
      K1 = K1 + 1        
      K2 = K2 + 1        
  320 CONTINUE        
C        
  340 CALL WRITE (IFILE,IZ(IXY),2*IPTS,EOR)        
C        
C  GO PROCESS NEXT DEPENDENT POINT.        
C        
  500 CONTINUE        
      GO TO 800        
C        
C     CHECK FOR SUFFICIENT CORE FOR SHORT CUT.        
C        
  550 N = NI + 3        
      N = N**2 + 3*N + NI*ND + N*ND        
      IF (N .GT. JZ) GO TO 80        
C        
C     CALL SSPLIN AND GET G-MATRIX STORED BY ROWS.        
C        
      CALL SSPLIN (NI,INDEP(1,1),ND,DEP(1,1),0,0,0,1,0,Z(1),JZ,ISING)   
      IF (ISING .NE. 2) GO TO 650        
      N = 0        
      WRITE (IOUTPT,250) UWM,N,MCSID        
C        
C     OUTPUT NULL ROW FOR EACH DEPENDENT POINT.        
C        
      DO 600 I = 1,ND        
      CALL WRITE (IFILE,0,0,EOR)        
  600 CONTINUE        
      GO TO 800        
C        
C     OUTPUT ROWS OF G-MATRIX WITH INDEXES.        
C        
  650 K = 0        
      DO 680 I = 1,ND        
      DO 670 J = 1,NI        
      K = K + 1        
      ITEMP(1) = J        
      ITEMP(2) = IZ(K)        
      CALL WRITE (IFILE,ITEMP(1),2,NOEOR)        
  670 CONTINUE        
      CALL WRITE (IFILE,0,0,EOR)        
  680 CONTINUE        
C        
C     ALL G-MATRIX ROWS COMPLETE. (ROWS SINGULAR ARE EMPTY LOGICAL      
C     RECORDS IN -IFILE- )        
C        
  800 CALL CLOSE (IFILE,CLSREW)        
      RETURN        
C        
  900 CALL MESAGE (-8,ICRQ,SUBR)        
      RETURN        
      END        
