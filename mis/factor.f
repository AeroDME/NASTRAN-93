      SUBROUTINE FACTOR (INPUT,LOWER,SCR1,SCR2,SCR3,SCR4)        
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER          BCD(2)        
      DOUBLE PRECISION DET        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /SFACT /  FILEA(7),FILEL(7),FILEU(7),SCR1FL,SCR2FL,NZ    , 
     1                 DET(2)  ,P       ,SCR3FL  ,XX3   ,XX4   ,CHL     
CZZ   COMMON /ZZFACT/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      EQUIVALENCE      (KSYSTM(55),IPREC)        
      DATA    LOWTRI/  4 /        
      DATA    BCD   /  4HFACT,4HOR   /        
C        
C     INITIALIZE MATRIX CONTROL BLOCKS AND SFACT COMMON        
C        
      NZ = KORSZ(Z)        
      FILEA(1) = INPUT        
      CALL RDTRL (FILEA)        
      CALL MAKMCB (FILEL,LOWER,FILEA(3),LOWTRI,IPREC)        
      FILEU(1) = IABS(SCR1)        
      SCR1FL = SCR2        
      SCR2FL = SCR3        
      SCR3FL = SCR4        
      CHL = 0        
      IF (SCR1 .LT. 0) CHL = 1        
C        
C     DECOMPOSE INPUT MATRIX INTO LOWER TRIANGULAR FACTOR.        
C        
      CALL SDCOMP (*40,Z,Z,Z)        
C        
C     WRITE TRAILER FOR LOWER TRIANGULAR FACTOR.        
C        
      CALL WRTTRL (FILEL)        
      RETURN        
C        
C     FATAL ERROR MESSAGE FOR SINGULAR INPUT MATRIX        
C        
   40 CALL MESAGE (-5,INPUT,BCD)        
      RETURN        
      END        
