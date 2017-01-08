      SUBROUTINE JACOB2 (ELID,SHP,DSHP,GPTH,BGPDT,GPNORM,JACOB)        
C        
C     THIS ROUTINE WAS CALLED JACOBD BEFORE, AND WAS THE ONLY ROUTINE   
C     THAT ENDED WITH 'DB' AND WAS NOT A BLOCK DATA SUBROUTINE.        
C        
C     THIS SUBROUTINE CALCULATES JACOBIAN AT EACH GIVEN INTEGRATION     
C     POINT FOR QUAD4 POTVIN TYPE ELEMENTS.        
C        
C     DOUBLE PRECISION VERSION        
C        
      LOGICAL          BADJ        
      INTEGER          INDEX(3,3),ELID,NOGO,NOUT        
      REAL             BGPDT(4,1),GPNORM(4,1)        
      DOUBLE PRECISION SHP(1),DSHP(1),GPTH(1),PSITRN(9),JACOB(3,3),     
     1                 TGRID(3,8),SK(3),TK(3),ENK(3),V1(3),V2(3),V3(3), 
     2                 VAL,HZTA,THICK,DETJ,DUM(3),EPS        
      COMMON /Q4DT  /  DETJ,HZTA,PSITRN,NNODE,BADJ,N1        
      COMMON /SYSTEM/  IBUF,NOUT,NOGO        
C        
      EQUIVALENCE     (PSITRN(1),V1(1))        
      EQUIVALENCE     (PSITRN(4),V2(1))        
      EQUIVALENCE     (PSITRN(7),V3(1))        
C        
      DATA EPS / 1.0D-15 /        
C        
C     INITIALIZE BADJ LOGICAL        
C        
      BADJ=.FALSE.        
C        
C     COMPUTE THE JACOBIAN AT THIS GAUSS POINT,        
C     ITS INVERSE AND ITS DETERMINANT.        
C        
      DO 150 I=1,NNODE        
      THICK=GPTH(I)        
      TGRID(1,I)=BGPDT(2,I)+HZTA*THICK*GPNORM(2,I)        
      TGRID(2,I)=BGPDT(3,I)+HZTA*THICK*GPNORM(3,I)        
  150 TGRID(3,I)=BGPDT(4,I)+HZTA*THICK*GPNORM(4,I)        
      DO 200 I=1,2        
      IPOINT=N1*(I-1)        
      DO 200 J=1,3        
      JACOB(I,J)=0.0D0        
      DO 200 K=1,NNODE        
      JACOB(I,J)=JACOB(I,J)+DSHP(K+IPOINT)*TGRID(J,K)        
  200 CONTINUE        
      DO 250 J=1,3        
      JACOB(3,J)=0.0D0        
      DO 250 K=1,NNODE        
      JTEMP=J+1        
      JACOB(3,J)=JACOB(3,J)+0.5D0*GPTH(K)*GPNORM(JTEMP,K)*SHP(K)        
  250 CONTINUE        
C        
C     SAVE THE S, T, AND N VECTORS FOR CALCULATING PSI LATER.        
C        
      DO 300 I=1,3        
      IF (DABS(JACOB(1,I)) .LE. EPS) JACOB(1,I)=0.0D0        
      SK(I)=JACOB(1,I)        
      IF (DABS(JACOB(2,I)) .LE. EPS) JACOB(2,I)=0.0D0        
      TK(I)=JACOB(2,I)        
      IF (DABS(JACOB(3,I)) .LE. EPS) JACOB(3,I)=0.0D0        
      ENK(I)=JACOB(3,I)        
  300 CONTINUE        
C        
C     THE INVERSE OF THE JACOBIAN WILL BE STORED IN        
C     JACOB AFTER THE SUBROUTINE INVERD HAS EXECUTED.        
C        
      CALL INVERD (3,JACOB,3,DUM,0,DETJ,ISING,INDEX)        
      IF (ISING.EQ.1 .AND. DETJ.GT.0.0D0) GO TO 350        
      WRITE (NOUT,550) ELID        
      NOGO=1        
      BADJ=.TRUE.        
      GO TO 500        
  350 CALL DAXB (SK,TK,V3)        
      VAL=DSQRT(V3(1)*V3(1)+V3(2)*V3(2)+V3(3)*V3(3))        
      V3(1)=V3(1)/VAL        
      V3(2)=V3(2)/VAL        
      V3(3)=V3(3)/VAL        
C        
C     CROSS ELEMENT Y DIRECTION WITH UNIT VECTOR V3 IN ORDER        
C     TO BE CONSISTENT WITH THE ELEMENT COORDINATE SYSTEM.        
C        
C     NOTE - THIS IS IMPORTANT FOR THE DIRECTIONAL REDUCED        
C            INTEGRATION CASES.        
C        
C        
C        
      V2(1)=0.0D0        
      V2(2)=1.0D0        
      V2(3)=0.0D0        
C        
      CALL DAXB (V2,V3,V1)        
      VAL=DSQRT(V1(1)*V1(1)+V1(2)*V1(2)+V1(3)*V1(3))        
      V1(1)=V1(1)/VAL        
      V1(2)=V1(2)/VAL        
      V1(3)=V1(3)/VAL        
      CALL DAXB (V3,V1,V2)        
C        
C     REMEMBER THAT V1(1) IS EQUIVALENCED TO PSITRN(1), AND SO ON.      
C        
C     ELIMINATE SMALL NUMBERS        
C        
      DO 400 I = 1,3        
      IF (DABS(V1(I)) .LE. EPS) V1(I)=0.0D0        
      IF (DABS(V2(I)) .LE. EPS) V2(I)=0.0D0        
      IF (DABS(V3(I)) .LE. EPS) V3(I)=0.0D0        
  400 CONTINUE        
C        
  500 CONTINUE        
      RETURN        
C        
  550 FORMAT ('0*** USER FATAL ERROR, ELEMENT ID =',I10,        
     1       '  HAS BAD OR REVERSE GEOMETRY')        
      END        
