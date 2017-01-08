      SUBROUTINE T3BGBS (NG,NB,GMAT,BMAT,KMAT)        
C        
C     WITH ENTRY T3BGBD (NG,NB,GMAD,BMAD,KMAD)        
C        
C     ROUTINE FOR EFFICIENT TRIPLE-MULTPLICATION OF [B] AND [G] MATRICES
C     TO EVALUATE THE CONTRIBUTION TO THE ELEMENT STIFFNESS MATRIX FROM 
C     THE CURRENT INTEGRATION POINT        
C        
C        
C     INPUT :        
C           NG          - NUMBER OF ROWS AND COLUMNS OF GMAT        
C           NB          - NUMBER OF COLUMNS OF BMAT        
C           GMAT/GMAD   - [G], FORCE-STRAIN RELATIONSHIP        
C           BMAT/BMAD   - [B], STRAIN-DISPLACEMENT RELATIONSHIP        
C     OUTPUT:        
C           KMAT/KMAD   - CONTRIBUTION TO THE ELEMENT STIFFNESS MATRIX  
C                         FROM THE CURRENT INTEGRATION POINT        
C        
C     ALGORITHM:        
C           MATRICES ARE MULTIPLIED IN FULL WHEN MEMBRANE-BENDING       
C           COUPLING IN PRESENT, OTHERWISE PARTIAL MULTIPLICATION       
C           IS PERFORMED.        
C           IN EACH TRIPLE MULTIPLY, THE RESULT IS ADDED TO KMAT.       
C        
C        
      LOGICAL          MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      REAL             GMAT(9,1),BMAT(1),KMAT(1),G1(3,3),GBMAT(162)     
      DOUBLE PRECISION GMAD(9,1),BMAD(1),KMAD(1),G2(3,3),GBMAD(162)     
      COMMON /TERMS /  MEMBRN,BENDNG,SHRFLX,MBCOUP,NORPTH        
      EQUIVALENCE      (G1(1,1),G2(1,1)),(GBMAT(1),GBMAD(1))        
C        
C        
C     SINGLE PRECISION        
C        
      ND3 = NB*3        
      ND6 = NB*6        
C        
C     IF [G] IS FULLY POPULATED, PERFORM STRAIGHT MULTIPLICATION AND    
C     RETURN.        
C        
      IF (.NOT.MBCOUP) GO TO 10        
      CALL GMMATS (GMAT,NG,NG,0,  BMAT,NG,NB,0,  GBMAT)        
      CALL GMMATS (BMAT,NG,NB,-1, GBMAT,NG,NB,0, KMAT )        
      GO TO 60        
C        
C     MULTIPLY MEMBRANE TERMS WHEN PRESENT        
C        
   10 IF (.NOT.MEMBRN) GO TO 30        
      DO 20 I = 1,3        
      DO 20 J = 1,3        
      G1(I,J) = GMAT(I,J)        
   20 CONTINUE        
      CALL GMMATS (G1,3,3,0, BMAT(1),3,NB,0, GBMAT)        
      CALL GMMATS (BMAT(1),3,NB,-1, GBMAT,3,NB,0, KMAT)        
C        
C     MULTIPLY BENDING TERMS WHEN PRESENT        
C        
   30 IF (.NOT.BENDNG) GO TO 60        
      DO 40 I = 1,3        
      II = I + 3        
      DO 40 J = 1,3        
      JJ = J + 3        
      G1(I,J) = GMAT(II,JJ)        
   40 CONTINUE        
      CALL GMMATS (G1,3,3,0, BMAT(ND3+1),3,NB,0, GBMAT)        
      CALL GMMATS (BMAT(ND3+1),3,NB,-1, GBMAT,3,NB,0, KMAT)        
C        
      DO 50 I = 1,3        
      II = I + 6        
      DO 50 J = 1,3        
      JJ = J + 6        
      G1(I,J) = GMAT(II,JJ)        
   50 CONTINUE        
      CALL GMMATS (G1,3,3,0, BMAT(ND6+1),3,NB,0, GBMAT)        
      CALL GMMATS (BMAT(ND6+1),3,NB,-1, GBMAT,3,NB,0, KMAT)        
   60 RETURN        
C        
C        
      ENTRY T3BGBD (NG,NB,GMAD,BMAD,KMAD)        
C     ===================================        
C        
C     DOUBLE PRECISION        
C        
      ND3 = NB*3        
      ND6 = NB*6        
C        
C     IF [G] IS FULLY POPULATED, PERFORM STRAIGHT MULTIPLICATION AND    
C     RETURN.        
C        
      IF (.NOT.MBCOUP) GO TO 100        
      CALL GMMATD (GMAD,NG,NG,0,  BMAD,NG,NB,0,  GBMAD)        
      CALL GMMATD (BMAD,NG,NB,-1, GBMAD,NG,NB,0, KMAD )        
      GO TO 150        
C        
C     MULTIPLY MEMBRANE TERMS WHEN PRESENT        
C        
  100 IF (.NOT.MEMBRN) GO TO 120        
      DO 110 I = 1,3        
      DO 110 J = 1,3        
      G2(I,J) = GMAD(I,J)        
  110 CONTINUE        
      CALL GMMATD (G2,3,3,0, BMAD(1),3,NB,0, GBMAD)        
      CALL GMMATD (BMAD(1),3,NB,-1, GBMAD,3,NB,0, KMAD)        
C        
C     MULTIPLY BENDING TERMS WHEN PRESENT        
C        
  120 IF (.NOT.BENDNG) GO TO 150        
      DO 130 I = 1,3        
      II = I + 3        
      DO 130 J = 1,3        
      JJ = J + 3        
      G2(I,J) = GMAD(II,JJ)        
  130 CONTINUE        
      CALL GMMATD (G2,3,3,0, BMAD(ND3+1),3,NB,0, GBMAD)        
      CALL GMMATD (BMAD(ND3+1),3,NB,-1, GBMAD,3,NB,0, KMAD)        
C        
      DO 140 I = 1,3        
      II = I + 6        
      DO 140 J = 1,3        
      JJ = J + 6        
      G2(I,J) = GMAD(II,JJ)        
  140 CONTINUE        
      CALL GMMATD (G2,3,3,0, BMAD(ND6+1),3,NB,0, GBMAD)        
      CALL GMMATD (BMAD(ND6+1),3,NB,-1, GBMAD,3,NB,0, KMAD)        
C        
  150 RETURN        
C        
      END        
