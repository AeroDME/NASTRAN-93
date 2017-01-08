      SUBROUTINE QRITER (VAL,O,LOC,QR)        
C        
C     ORTEGA-KAISER QR ITERATION FOR A LARGE TRIDIAGONAL MATRIX        
C        
      INTEGER          LOC(1),QR,SYSBUF,MSG(10)        
      REAL             LFREQ        
      DOUBLE PRECISION VAL(1),O(1),SHIFT,ZERO,ONE,ONES,EPSI,G,R,S,T,U,  
     1                 DLMDAS        
      CHARACTER*5      BELOW,ABOVE,BELABV        
      CHARACTER        UFM*23,UWM*25,UIM*29        
      COMMON /XMSSG /  UFM,UWM,UIM        
      COMMON /SYSTEM/  SYSBUF,NOUT        
      COMMON /GIVN  /  IDUM0(100),N,LFREQ,IDUM3,IDUM4,HFREQ,LAMA,NV,    
     1                 NE,IDUM9,NFOUND,IDUM11,IDUM12,IDUM13,NEVER,MAX   
      COMMON /REIGKR/  IOPTN        
      COMMON /MGIVXX/  DLMDAS        
      DATA    EPSI  ,  ZERO,ONE,MSG/ 1.0D-10, 0.0D+0, 1.0D+0, 53,9*0 /  
      DATA    MGIV  ,  BELOW,ABOVE / 4HMGIV, 'BELOW', 'ABOVE'        /  
C        
C     VAL    = DIAGONAL TERMS OF THE TRIDIAGONAL.        
C              REORDERED EIGENVALUES UPON RETURN.        
C     O      = SQUARE OF THE OFF-DIAGIONAL TERMS OF THE TRIDIAGONAL.    
C     LOC    = ORIGINAL LOCATIONS OF THE REORDERED EIGENVALUES.        
C     QR     = 1 MEANS  VAL= EIGENVALUES--JUST REORDER THEM        
C     N      = ORDER OF THE PROBLEM = ALSO NO. OF FREQ. EXTRACTED       
C     MAX    = MAXIMUM NUMBER OF ITERATIONS        
C     SHIFT  = SHIFT FACTOR (SMALLEST DIAGONAL TERM        
C     LFREQ  , HFREQ = FREQ. RANGE OF INTEREST IF NV IS ZERO        
C     NV     = NUMBER OF EIGENVECTORS TO BE COMPUTED, SAVED AND OUTPUT. 
C              IF NV IS ZERO (INPUT), AND LFREQ-HFREQ ARE PRESENT, NV IS
C              SET TO BE NO. OF MODES WITHIN THE FREQ. RANGE (OUTPUT)   
C     NE     = NO. OF EIGENVALUES (INCLUDING RIGID MODES) TO BE PRINTED.
C              ALL, IF NE IS NOT SPECIFIED.        
C              IF NE .LT. NV, NE IS SET EQUAL TO NV        
C        
      MAX = 100*N        
      IF (NV .GT.  N) NV = N        
      IF (NE .EQ.  0) NE = N        
      IF (NE .LT. NV) NE = NV        
C        
C     IS THIS AN ORDERING ONLY CALL        
C        
      NEVER = 0        
      IF (QR .NE. 0) GO TO 150        
C        
C     SEARCH FOR A DECOUPLED SUBMATRIX.        
C        
      M2 = N        
  100 M2M1 = M2 - 1        
      DO 101 K = 1,M2M1        
      M1 = M2 - K        
      IF (O(M1) .NE. ZERO) GO TO 102        
  101 CONTINUE        
C        
C     ALL OFF-DIAGONAL TERMS ARE ZEROS, JOB DONE. GO TO 150        
C     THE DIAGONALS CONTAIN THE EIGENVALUES.        
C        
      GO TO 150        
C        
C     DECOUPLED SUBMATRIX        
C        
  102 M2M1 = M1        
      M2   = M1 + 1        
      IF (M2M1 .EQ. 1) GO TO 105        
      DO 103 K = 2,M2M1        
      M1 = M2 - K        
      IF (O(M1) .EQ. ZERO) GO TO 104        
  103 CONTINUE        
      GO TO 105        
  104 M1 = M1 + 1        
  105 MM = M1        
C        
C     Q-R ITERATION FOR THE DECOUPLED SUBMATRIX        
C        
  110 DO 135 ITER = 1,MAX        
      IF (DABS(VAL(M2))+O(M2M1) .EQ. DABS(VAL(M2))) GO TO 140        
      DO 111 K = M1,M2M1        
      IF (VAL(K) .NE. VAL(K+1)) GO TO 115        
  111 CONTINUE        
      SHIFT = ZERO        
      GO TO 120        
C        
C     FIND THE SMALLEST DIAGONAL TERM = SHIFT        
C        
  115 SHIFT = VAL(M2)        
      DO 116 I = M1,M2M1        
      IF (DABS(VAL(I)) .LT. DABS(SHIFT)) SHIFT = VAL(I)        
  116 CONTINUE        
C        
C     REDUCE ALL TERMS BY SHIFT        
C        
      DO 117  I = M1,M2        
      VAL(I) = VAL(I) - SHIFT        
  117 CONTINUE        
C        
C     Q-R ITERATION        
C        
  120 R = VAL(M1)**2        
      S = O(M1)/(R+O(M1))        
      T = ZERO        
      U = S*(VAL(M1) + VAL(M1+1))        
      VAL(M1) = VAL(M1) + U        
      IF (M1 .EQ. M2M1) GO TO 125        
      M1P1 = M1 + 1        
      DO 123 I = M1P1,M2M1        
      G = VAL(I) - U        
      R = (ONE-T)*O(I-1)        
      ONES = ONE - S        
      IF (DABS(ONES) .GT. EPSI) R = G*G/ONES        
      R = R + O(I)        
      O(I-1) = S*R        
      IF (O(I-1) .EQ. ZERO) MM = I        
      T = S        
C        
C     IBM MAY FLAG AN EXPONENT UNDERFLOW ON NEXT LINE.        
C     IT IS PERFECTLY OK SINCE O(I) SHOULD BE APPROACHING ZERO.        
C        
      S = O(I)/R        
      U = S*(G + VAL(I+1))        
      VAL(I) = U + G        
  123 CONTINUE        
C        
  125 VAL(M2) = VAL(M2) - U        
      R = (ONE-T)*O(M2M1)        
      ONES = ONE - S        
      IF (DABS(ONES) .GT. EPSI) R = VAL(M2)**2/ONES        
      O(M2M1) = S*R        
C        
C     SHIFT BACK        
C        
      IF (SHIFT .EQ. ZERO) GO TO 133        
      DO 130 I = M1,M2        
      VAL(I) = VAL(I) + SHIFT        
  130 CONTINUE        
  133 M1 = MM        
  135 CONTINUE        
C        
C     TOO MANY ITERATIONS        
C        
C        
C     THE ACCURACY OF EIGENVALUE  XXXXX  IS IN DOUBT--QRITER FAILED TO  
C     CONVERGE IN  XX  ITERATIONS        
C        
      NEVER = NEVER + 1        
      CALL MESAGE (MSG(1),VAL(M2),MAX)        
C        
C     CONVERGENCE ACHIEVED        
C        
  140 IF (M1 .EQ. M2M1) GO TO 145        
      M2   = M2M1        
      M2M1 = M2 -1        
      GO TO 110        
  145 IF (M1 .LE. 2) GO TO 150        
      M2 = M1 - 1        
      GO TO 100        
  150 IF (N .EQ. 1) GO TO 205        
C        
C     REORDER EIGENVALUES ALGEBRAICALLY IN ASCENDING ORDER        
C        
      IF (IOPTN .NE. MGIV) GO TO 155        
C        
C     FOR MGIV METHOD, RECOMPUTE LAMBDA        
C        
      DO 153 K = 1,N        
      VAL(K) = (1.0D0/VAL(K)) - DLMDAS        
  153 CONTINUE        
  155 CONTINUE        
      DO 190 K = 1,N        
      DO 160 M = 1,N        
      IF (VAL(M) .NE. -10000.0D0) GO TO 170        
  160 CONTINUE        
  170 IF (M .EQ. N) GO TO 185        
      MP1 = M + 1        
      DO 180 I = MP1,N        
      IF (VAL(I) .EQ. -10000.0D0) GO TO 180        
      IF (VAL(M) .GT. VAL(I)) M = I        
  180 CONTINUE        
  185 O(K)   = VAL(M)        
      VAL(M) =-10000.0D0        
      LOC(K) = M        
  190 CONTINUE        
      DO 195 I = 1,N        
      VAL(I) = O(I)        
  195 CONTINUE        
C        
C     IF RIGID MODES WERE FOUND BEFORE, REPLACE RIGID FREQ. BY ZERO     
C        
      IF (NFOUND .EQ. 0) GO TO 205        
      DO 200 I = 1,NFOUND        
      VAL(I) = ZERO        
  200 CONTINUE        
C        
C     OUTPUT OPTION CHECK - BY FREQ. RANGE OR BY NO. OF FREQ.        
C     REQUESTED        
C        
  205 IB    = 1        
      IF (NV .NE. 0) GO TO 225        
      IF (LFREQ .LE. 0.0) GO TO 225        
C        
C     LOCATE PONTER THAT POINTS TO EIGENVALUE ABOVE OR EQUAL THE        
C     LOWEST LFREQ. AS REQUESTED.        
C        
      DO 215 I = 1,N        
      IF (VAL(I) .GE. LFREQ) GO TO 220        
  215 CONTINUE        
      I  = 0        
  220 IB = I        
C        
C     OPEN LAMA FOR OUTPUT        
C     PUT EIGENVALUES ON LAMA FOLLOWED BY ORDER FOUND        
C        
  225 IBUF1 = (KORSZ(O)-SYSBUF+1)/2        
      CALL GOPEN (LAMA,O(IBUF1),1)        
      NN = 0        
      IF (IB .EQ. 0) GO TO 240        
      DO 230 I = IB,N        
      VALX = VAL(I)        
      IF (NV.NE.0 .AND.    I.GT.   NE) GO TO 240        
      IF (NV.EQ.0 .AND. VALX.GT.HFREQ) GO TO 240        
      CALL WRITE (LAMA,VALX,1,0)        
      NN = NN + 1        
  230 CONTINUE        
C        
  240 CONTINUE        
C     WRITE  (NOUT,245) IB,NV,NN,NFOUND,LFREQ,HFREQ        
C 245 FORMAT ('  QRITER/@245  IB,NV,NN,NFOUND,LFREQ,HFREQ=',4I5,2E9.3)  
C        
C     IF FREQ. RANGE IS REQUESTED, AND ALL FREQ. FOUND ARE OUTSIDE THE  
C     RANGE, OUTPUT AT LEAST ONE FREQ.        
C        
      IF (NN .GT. 0) GO TO 260        
      IF (IB .EQ. 0) BELABV = BELOW        
      IF (IB .NE. 0) BELABV = ABOVE        
      WRITE (NOUT,250) UIM,BELABV        
  250 FORMAT (A29,', ALL ROOTS FOUND WERE ',A5,' FREQ. RANGE SPECIFIED',
     1       /5X,'HOWEVER, ONE EIGENVALUE OUTSIDE THIS FREQ. RANGE WAS',
     2       ' SAVED AND PRINTED')        
      NN = 1        
      IF (IB .NE. 0) IB = N        
      IF (IB .EQ. 0) IB = 1        
      CALL WRITE (LAMA,VAL(IB),1,0)        
  260 CALL WRITE (LAMA,0,0,1)        
      CALL WRITE (LAMA,LOC(IB),NN,1)        
      CALL CLOSE (LAMA,1)        
      MSG(2) = LAMA        
      MSG(3) = NN        
      CALL WRTTRL (MSG(2))        
C        
C     IF FREQ. DOES NOT START FROM FIRST FUNDAMENTAL MODE, ADJUST VAL   
C     AND LOC TABLES SO THAT WILVEC WILL PICK UP FREQUENCIES CORRECTLY  
C        
      IF (IB .LE. 1) GO TO 280        
      J = 1        
      DO 270 I = IB,N        
      VAL(J) = VAL(I)        
      LOC(J) = LOC(I)        
  270 J = J + 1        
C        
  280 IF (NV.EQ.0 .AND. IB.GT.1 .AND. NN.LT.NFOUND .AND. VAL(1).LE.ZERO)
     1    NFOUND = 0        
      IF (NV .EQ. 0) NV = NN        
      RETURN        
      END        
