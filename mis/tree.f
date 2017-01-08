      SUBROUTINE TREE (IROOT,NDSTK,LVL,IWK,NDEG,LVLWTH,LVLBOT,LVLN,        
     1                 MAXLW,IBORT,JWK)        
C        
C     TREE DROPS A TREE IN NDSTK FROM IROOT        
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE        
C        
C     LVL-      ARRAY INDICATING AVAILABLE NODES IN NDSTK WITH ZERO        
C               ENTRIES. TREE ENTERS LEVEL NUMBERS ASSIGNED        
C               DURING EXECUTION OF OF THIS PROCEDURE        
C     IWK-      ON OUTPUT CONTAINS NODE NUMBERS USED IN TREE        
C               ARRANGED BY LEVELS (IWK(LVLN) CONTAINS IROOT        
C               AND IWK(LVLBOT+LVLWTH-1) CONTAINS LAST NODE ENTERED)        
C     JWK-      ON ONTPUT CONTAINS A ROW OF UNPACKED GRID NOS.        
C               CURRENTLY, JWK AND RENUM SHARE SAME CORE SPACE        
C     LVLWTH-   ON OUTPUT CONTAINS WIDTH OF LAST LEVEL        
C     LVLBOT-   ON OUTPUT CONTAINS INDEX INTO IWK OF FIRST        
C               NODE IN LAST LEVEL        
C     MAXLW-    ON OUTPUT CONTAINS THE MAXIMUM LEVEL WIDTH        
C     LVLN-     ON INPUT THE FIRST AVAILABLE LOCATION IN IWK        
C               USUALLY ONE BUT IF IWK IS USED TO STORE PREVIOUS        
C               CONNECTED COMPONENTS, LVLN IS NEXT AVAILABLE LOCATION.        
C               ON OUTPUT THE TOTAL NUMBER OF LEVELS + 1        
C     IBORT-    INPUT PARAM WHICH TRIGGERS EARLY RETURN IF        
C               MAXLW BECOMES .GE. IBORT        
C        
C     INTEGER          BUNPK        
      DIMENSION        LVL(1),   IWK(1),   NDEG(1),  NDSTK(1),  JWK(1)        
C        
      MAXLW =0        
      ITOP  =LVLN        
      INOW  =LVLN        
      LVLBOT=LVLN        
      LVLTOP=LVLN+1        
      LVLN  =1        
      LVL(IROOT)=1        
      IWK(ITOP) =IROOT        
   30 LVLN  =LVLN+1        
   35 IWKNOW=IWK(INOW)        
      NDROW =NDEG(IWKNOW)        
      CALL BUNPAK(NDSTK,IWKNOW,NDROW,JWK)        
      DO 40 J=1,NDROW        
C     ITEST=BUNPK(NDSTK,IWKNOW,J)        
      ITEST=JWK(J)        
      IF (LVL(ITEST).NE.0) GO TO 40        
      LVL(ITEST)=LVLN        
      ITOP=ITOP+1        
      IWK(ITOP)=ITEST        
   40 CONTINUE        
      INOW=INOW+1        
      IF (INOW.LT.LVLTOP) GO TO 35        
      LVLWTH=LVLTOP-LVLBOT        
      IF (MAXLW.LT.LVLWTH) MAXLW=LVLWTH        
      IF (MAXLW.GE.IBORT .OR. ITOP.LT.LVLTOP) RETURN        
      LVLBOT=INOW        
      LVLTOP=ITOP+1        
      GO TO 30        
      END        
