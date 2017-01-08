      SUBROUTINE DEGREE (IG,IDEG,JG)        
C        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     SET UP THE IDEG ARRAY CONTAINING THE DEGREE OF EACH NODE STORED        
C     IN THE IG ARRAY.        
C     IDEG(I)=DEGREE OF NODE I        
C        
C     INTEGER          BUNPK        
      DIMENSION        IG(1),    JG(1),   IDEG(1)        
      COMMON /BANDS /  NN,       MM        
C        
      DO 100 I=1,NN        
      IDEG(I)=0        
      CALL BUNPAK(IG,I,MM,JG)        
      DO 80 J=1,MM        
C     IF (BUNPK(IG,I,J)) 100,100,50        
      IF (JG(J)) 100,100,50        
   50 IDEG(I)=IDEG(I)+1        
   80 CONTINUE        
  100 CONTINUE        
      RETURN        
      END        
