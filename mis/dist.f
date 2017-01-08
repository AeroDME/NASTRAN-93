      SUBROUTINE DIST (IDEG,HIST,MEDIAN,MODD)        
C        
C     COMPUTE THE DISTRIBUTION OF NODAL DEGREES WITH MEDIAN AND MODE    
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
      INTEGER         IDEG(1),  HIST(1)        
      COMMON /SYSTEM/ ISYS,     NOUT        
      COMMON /BANDS / NN,       MM        
C        
C     IDEG(I) = DEGREE OF NODE I        
C     HIST(I) = NUMBER OF NODES OF DEGREE I        
C        
C     COMPUTE HISTOGRAM.        
C        
      MM1 = MM + 1        
      DO 10 I = 1,MM1        
   10 HIST(I) = 0        
      DO 20 I = 1,NN        
      K = IDEG(I) + 1        
   20 HIST(K) = HIST(K) + 1        
C        
C     COMPUTE MODE (MODD).        
C        
      MODD = 0        
      MAX  = 0        
      DO 30 I = 1,MM1        
      K = HIST(I)        
      IF (K .LE. MAX) GO TO 30        
      MAX  = K        
      MODD = I - 1        
   30 CONTINUE        
C        
C     COMPUTE CUMULATIVE DISTRIBUTION, AND MEDIAN.        
C        
      DO 40 I = 2,MM1        
   40 HIST(I) = HIST(I) + HIST(I-1)        
      NN2 = NN/2        
      DO 50 I = 1,MM1        
      IF (HIST(I) .GT. NN2) GO TO 60        
   50 CONTINUE        
   60 MEDIAN = I - 1        
      RETURN        
      END        
