      SUBROUTINE PRETRS (CSTMX,NCSTMX)        
C        
C     PRETRS SETS UP EVENTUAL CALLS TO TRANSS.  FOR A MODULE TO USE     
C     TRANSS A CALL TO PRETRS MUST BE INITIATED BY THE MODULE DRIVER    
C     ONCE AND ONLY ONCE.  CSTMX IS ARRAY OF COORDINATE SYSTEM        
C     TRANSFORMATION MATRICES AND MCSTMX IS THE LENGTH OF THIS ARRAY.   
C        
C     THE CSTMX ARRAY MUST BE WITHIN OPEN CORE BOUND, AND THERE IS NO   
C     CHECK ON THIS CONDITION        
C        
C     GIVEN THE ARRAY ECPT OF LENGTH 4, THE FIRST WORD BEING AN INTEGER 
C     COORDINATE SYSTEM IDENTIFICATION NUMBER AND THE NEXT WORDS BEING  
C     THE REAL COORDINATES OF A POINT IN BASIC COORDINATES, THIS ROUTINE
C     COMPUTES THE TRANSFORMATION (DIRECTION COSINE) MATRIX TA WHICH    
C     WILL MAP A VECTOR FROM THE LOCAL SYSTEM LABELED ECPT(1) TO BASIC  
C     COORDINATES.        
C        
C     REVISED  7/92 BY G.CHAN/UNISYS. NEW REFERENCE TO CSTM ARRAY SUCH  
C     THAT THE SOURCE CODE IS UP TO ANSI FORTRAN 77 STANDARD.        
C        
      INTEGER         OFFSET        
      REAL            KE        
      DIMENSION       CSTMX(1),ECPT(4),TA(9),TL(9),KE(9),XN(3)        
CZZ   COMMON /XNSTRN/ CSTM(1)        
      COMMON /ZZZZZZ/ CSTM(1)        
      EQUIVALENCE     (FL1,INT1),(FL2,INT2)        
C        
      NCSTM  = NCSTMX        
      OFFSET = LOCFX(CSTMX(1)) - LOCFX(CSTM(1))        
      IF (OFFSET .LT. 0) CALL ERRTRC ('PRETRS  ',1)        
      ICHECK = 123456789        
      RETURN        
C        
C        
      ENTRY TRANSS (ECPT,TA)        
C     ======================        
C        
      FL1 = ECPT(1)        
      IF (INT1 .EQ. 0) GO TO 90        
      IF (ICHECK .NE. 123456789) CALL ERRTRC ('PRETRS  ',10)        
      DO 10 J = 1,NCSTM,14        
      I   = J + OFFSET        
      FL2 = CSTM(I)        
      IF (INT1 .NE. INT2) GO TO 10        
      KK = I        
      FL2 = CSTM(I+1)        
      GO TO (20,40,40), INT2        
   10 CONTINUE        
C        
C     THE COORDINATE SYSTEM ID. COULD NOT BE FOUND IN THE CSTM.        
C        
      CALL MESAGE (-30,25,INT1)        
C        
C     THE COORDINATE SYSTEM IS RECTANGULAR.        
C        
   20 DO 30 J = 1,9        
      K = KK + 4 + J        
   30 TA(J) = CSTM(K)        
      RETURN        
C        
   40 XN(1) = ECPT(2) - CSTM(KK+2)        
      XN(2) = ECPT(3) - CSTM(KK+3)        
      XN(3) = ECPT(4) - CSTM(KK+4)        
      X = CSTM(KK+5)*XN(1) + CSTM(KK+ 8)*XN(2) + CSTM(KK+11)*XN(3)      
      Y = CSTM(KK+6)*XN(1) + CSTM(KK+ 9)*XN(2) + CSTM(KK+12)*XN(3)      
      Z = CSTM(KK+7)*XN(1) + CSTM(KK+10)*XN(2) + CSTM(KK+13)*XN(3)      
      R = SQRT(X**2 + Y**2)        
      IF (R .EQ. 0.0) GO TO 20        
      DO 50 J = 1,9        
      K = KK + 4 + J        
   50 KE(J) = CSTM(K)        
      GO TO (60,60,70), INT2        
C        
C     THE COORDINATE SYSTEM IS CYLINDRICAL.        
C        
   60 TL(1) = X/R        
      TL(2) =-Y/R        
      TL(3) = 0.0        
      TL(4) =-TL(2)        
      TL(5) = TL(1)        
      TL(6) = 0.0        
      TL(7) = 0.0        
      TL(8) = 0.0        
      TL(9) = 1.0        
      GO TO 80        
C        
C     THE COORDINATE SYSTEM IS SPHERICAL.        
C        
   70 XL = SQRT(X**2 + Y**2 + Z**2)        
      TL(1) = X/XL        
      TL(2) = (X*Z)/(R*XL)        
      TL(3) =-Y/R        
      TL(4) = Y/XL        
      TL(5) = (Y*Z)/(R*XL)        
      TL(6) = X/R        
      TL(7) = Z/XL        
      TL(8) =-R/XL        
      TL(9) = 0.0        
   80 CALL GMMATS (KE(1),3,3,0, TL(1),3,3,0, TA(1))        
      RETURN        
C        
C     THE LOCAL SYSTEM IS BASIC.        
C        
   90 DO 100 I = 1,9        
  100 TA(I) = 0.0        
      TA(1) = 1.0        
      TA(5) = 1.0        
      TA(9) = 1.0        
      RETURN        
      END        
