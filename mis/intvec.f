      SUBROUTINE INTVEC (VECTOR)        
C        
      INTEGER         VECTOR,XYZR(4),CHAR,VEC(4),VECWRD        
      COMMON /SYSTEM/ SKIP(40), NCPW        
      DATA    XYZR  / 1HX,1HY,1HZ,1HR /        
      DATA    N     / 1HN/        
C        
      NSHAPE = 0        
      VECWRD = VECTOR        
      IF (VECWRD .EQ. 0) GO TO 125        
      DO 101 I = 1,4        
      VEC(I) = 0        
  101 CONTINUE        
C        
C     SEPARATE THE FOUR CHARACTERS IN -VECWRD- (ANY COMBINATION OF THE  
C     CHARACTERS X, Y, Z, AND R.        
C        
      DO 120 K = 1,4        
      CHAR = KLSHFT(VECWRD,(K-1))        
      CHAR = KRSHFT(CHAR,(NCPW-1))        
      DO 111 I = 1,4        
      IF (CHAR .EQ. KRSHFT(XYZR(I),(NCPW-1))) GO TO 115        
  111 CONTINUE        
      IF(CHAR .EQ. KRSHFT(N,(NCPW-1))) NSHAPE = 1        
      GO TO 120        
  115 VEC(I) = 1        
  120 CONTINUE        
C        
      VECTOR = VEC(1) + 2*VEC(2) + 4*VEC(3) + 8*VEC(4)        
      IF (VECTOR .EQ. 8) VECTOR = 15        
      IF (NSHAPE .EQ. 1) VECTOR =-VECTOR        
  125 RETURN        
      END        
