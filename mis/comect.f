      SUBROUTINE COMECT (ELE,MAX)        
C        
C     REVISED  10/1990 BY G.CHAN/UNISYS        
C              TO INCLUDE OFFSET DATA FOR CBAR, CTRIA3 AND CQUAD4 IN    
C              THE ECT2 DATA BLOCK        
C              (6 COORDINATE VALUES FOR THE BAR, AND 1 OFFSET VALUE     
C              FOR EACH OF THE TWO PLATES, ARE ADDED AFTER THE GRID     
C              DATA)        
C        
      INTEGER         IDREC(3),ELE(1),ELID(2),TYPE,IHX2(20),IHX3(32),   
     1                ECT1,ECT2,BUFSIZ,B1,B2,GP(32),OUTREW,REW,M1(18),  
     2                NAME(2),ERR(5),EPT,PID,IX(1),PCOMP(12)        
      REAL            OFFSET(1)        
      COMMON /BLANK / SKP1(12),ECT1,SKP2(7),MERR,SKP3(10),ECT2        
      COMMON /SYSTEM/ BUFSIZ        
CZZ   COMMON /ZZPSET/ X(1)        
      COMMON /ZZZZZZ/ X(1)        
      COMMON /GPTA1 / NEL,LAST,INCR,NE(1)        
      EQUIVALENCE     (OFFSET(1),GP(1)), (IX(1),X(1))        
      DATA    NAME  / 4H COM,4HECT /,  OUTREW,REW,INREW / 1, 1, 0 /     
      DATA    PCOMP / 5502,25,2, 5602,14,2, 5702,13,2, 5802,17,17 /     
C                     PCOMP      PCOMP1     PCOMP2     PSHELL        
      DATA    NM1   / 18    /,        
     1        M1    / 4H(33X, 4H,2A4, 4H,18H, 4HIGNO, 4HRING, 4H ELE,   
     2                4HMENT, 4H (2A, 4H4,32, 4HH) W, 4HITH , 4HMORE,   
     3                4H THA, 4HN 32, 4H CON, 4HNECT, 4HIONS, 4H.)  /,  
     4        ILXX  / 2HXX /        
      DATA    IHX2  / 1,1,3,3,5,5,7,7,1,3,5,7,13,13,15,15,17,17,19,19/  
      DATA    IHX3  / 1,1,4,4,4,7,7,7,10,10,10,1,1,4,7,10,21,24,27,30,  
     1                21,21,24,24,24,27,27,27,30,30,30,21            /  
C        
      B1 = KORSZ(X) - (3*BUFSIZ+2)        
      B2 = B1 + BUFSIZ + 3        
      ERR(1) = 4        
      ERR(2) = NAME(1)        
      ERR(3) = NAME(2)        
C        
C     IF EPT FILE IS PRESENT, AND ANY OF THE PSHELL, PCOMP, PCOMP1 AND  
C     PCOMP2 CARDS IS ALSO PRESENT, CREATE A TABLE OF PROPERTY ID AND   
C     OFFSET DATA, TO BE USE LATER BY CTRIA3 OR CQURD4 ELEMENTS        
C        
      JCOMP = B1        
      EPT = 104        
      CALL OPEN (*40,EPT,X(B1),INREW)        
      CALL READ (*30,*30,EPT,IX,2,1,M)        
      CALL CLOSE (EPT,REW)        
      CALL PRELOC (*40,X(B1),EPT)        
      N = 1        
      DO 20 I = 1,12,3        
      IDREC(1) = PCOMP(I)        
      IDREC(2) = IDREC(1)/100        
      CALL LOCATE (*20,X(B1),IDREC,J)        
      K = PCOMP(I+1)        
      J = PCOMP(I+2)        
   10 CALL READ (*20,*20,EPT,X,K,0,M)        
      IF (X(J) .EQ. 0.0) GO TO 10        
      JCOMP = JCOMP - 2        
      IX(JCOMP ) = IX(1)        
      X(JCOMP+1) =  X(J)        
      GO TO 10        
   20 N = N + 1        
   30 CALL CLOSE (EPT,REW)        
      KCOMP = B1 - 1        
C        
C     CONSTRUCT A LIST OF INDICES IN THE ECT FOR USE WITH GPECT IN THE  
C     PLOT MODULE BY CONTOUR PLOTTING        
C        
   40 CALL GOPEN (ECT1,X(B1),INREW)        
      DO 50 J = 1,MAX        
   50 ELE(J) = 0        
      I = 1        
   60 CALL READ (*130,*80,ECT1,IDREC,3,0,M)        
      DO 70 J = 1,NEL        
      IDX = (J-1)*INCR        
      IF (NE(IDX+4) .EQ. IDREC(1)) GO TO 100        
   70 CONTINUE        
      CALL SKPREC (ECT1,1)        
      GO TO 60        
   80 CALL MESAGE (-3,ECT1,NAME)        
   90 CALL MESAGE (-2,ECT1,NAME)        
  100 LECT = NE(IDX+6) - 1        
  110 CALL READ (*90,*60,ECT1,ELE(I),1,0,M)        
      CALL FREAD (ECT1,0,-LECT,0)        
      I = I + 1        
      IF (I .GT. MAX) CALL MESAGE (-8,0,NAME)        
      GO TO 110        
C        
  120 CALL MESAGE (-1,ECT1,NAME)        
C        
  130 LELE = I - 1        
      CALL CLOSE (ECT1,REW)        
C        
      CALL PRELOC (*120,X(B1),ECT1)        
      CALL GOPEN (ECT2,X(B2),OUTREW)        
      DO 290 N = 1,NEL        
      IDX = (N-1)*INCR        
C        
C     IF SCALAR CONNECTION POSSIBLE FOR ELEMENT THEN SKIP IT        
C        
      IF (NE(IDX+11) .NE. 0) GO TO 290        
C        
C     SKIP DUMMY ELEMENTS AND POINT ELEMENTS        
C        
      IF (NE(IDX+10)-1  .LE. 0) GO TO 290        
      IF (NE(IDX+16) .EQ. ILXX) GO TO 290        
      CALL LOCATE (*290,X(B1),NE(IDX+4),I)        
      NGPEL = NE(IDX+10)        
      IF (NGPEL .GT. 32) GO TO 270        
C        
      CALL WRITE (ECT2,N,1,0)        
      CALL WRITE (ECT2,NGPEL,1,0)        
  140 CALL READ (*280,*280,ECT1,ELID,1,0,I)        
C        
C     FIND THIS ELEMENTS POINTER IN THE ECT        
C        
      DO 150 I = 1,LELE        
      IF (ELE(I) .EQ. ELID(1)) GO TO 160        
  150 CONTINUE        
      CALL MESAGE (-37,0,NAME)        
  160 ELID(2) = I        
C        
C     DETERMINE NUMBER ENTRIES FOR SKIPPING TO GRID ENTRIES        
C        
      I = NE(IDX+13) - 2        
      IF (N .EQ. 52) GO TO 190        
C              CHBDY        
C        
      IF (N.EQ.64 .OR. N.EQ.83) GO TO 240        
C           CQUAD4        CTRIA3        
      IF (I) 120,180,170        
C        
  170 CALL FREAD (ECT1,0,-I,0)        
  180 CALL FREAD (ECT1,GP,NGPEL,0)        
      IF (N .EQ. 34) GO TO 230        
C               CBAR        
C        
      CALL FREAD (ECT1,0,-(NE(IDX+6)-NGPEL-I-1),0)        
      GO TO 200        
C        
C     SPECIAL HANDLING FOR CHBDY        
C     IF TYPE IS NEGATIVE, SAVE TYPE FLAG AFTER GRIDS.        
C        
  190 CALL FREAD (ECT1,0,-1,0)        
      CALL FREAD (ECT1,TYPE,1,0)        
      CALL FREAD (ECT1,GP,8,0)        
      CALL FREAD (ECT1,0,-(NE(IDX+6)-NGPEL-I-1),0)        
      IF (TYPE .LT. 0) GO TO 140        
      IF (TYPE .EQ. 6) TYPE = 3        
      GP(9) = TYPE        
      GO TO 220        
C        
C     SPCIAL HANDLING OF IHEX2 AND IHEX3 WITH ZERO GRIDS        
C        
  200 IF (N.NE.66 .AND. N.NE.67) GO TO 220        
      DO 210 J = 1,NGPEL        
      IF (GP(J) .NE. 0) GO TO 210        
      K = IHX3(J)        
      IF (N .EQ. 66) K = IHX2(J)        
      GP(J) = GP(K)        
  210 CONTINUE        
C        
  220 CALL WRITE (ECT2,ELID,2,0)        
      CALL WRITE (ECT2,GP,NGPEL,0)        
      GO TO 140        
C        
C     SPECIAL HANDLING OF THOSE ELEMENTS HAVING GRID OFFSET.        
C     ADD THESE OFFSET DATA AFTER THE GRID POINTS        
C        
C     (1) CBAR ELEMENT, 2 OFFSET VECTORS (6 VALUES)        
C        
  230 CALL WRITE (ECT2,ELID,2,0)        
      CALL WRITE (ECT2,GP,NGPEL,0)        
      CALL FREAD (ECT1,0,-6,0)        
      CALL FREAD (ECT1,OFFSET,6,0)        
      CALL WRITE (ECT2,OFFSET,6,0)        
      GO TO 140        
C        
C     (2) CTRIA3 AND CQUAD4 ELEMENTS, ONE OFFSET DATA NORMAL TO PLATE.  
C         OFFSET DATA COULD BE ON ELEMENT CARD OR ON PSHELL OR PCOMPI   
C         CARDS        
C        
  240 CALL FREAD (ECT1,PID,1,0)        
      CALL FREAD (ECT1,GP,NGPEL,0)        
      CALL WRITE (ECT2,ELID,2,0)        
      CALL WRITE (ECT2,GP,NGPEL,0)        
      J = 5        
      IF (N .EQ. 64) J = 6        
      CALL FREAD (ECT1,0,-J,0)        
      CALL FREAD (ECT1,OFFSET,1,0)        
      IF (OFFSET(1) .NE. 0.0) GO TO 260        
      IF (JCOMP     .EQ.  B1) GO TO 260        
      DO 250 I = JCOMP,KCOMP,2        
      IF (IX(I) .NE. PID) GO TO 250        
      OFFSET(1) = X(I+1)        
      GO TO 260        
  250 CONTINUE        
  260 CALL WRITE (ECT2,OFFSET,1,0)        
      GO TO 140        
C        
C     ELEMENT TYPE WITH MORE THAN 32 CONNECTIONS        
C        
  270 ERR(4) = NE(IDX+1)        
      ERR(5) = NE(IDX+2)        
      CALL WRTPRT (MERR,ERR,M1,NM1)        
      CALL SKPREC (ECT1,1)        
      GO TO 290        
C        
  280 CALL WRITE (ECT2,0,0,1)        
  290 CONTINUE        
C        
      CALL CLSTAB (ECT2,REW)        
      CALL CLOSE  (ECT1,REW)        
      RETURN        
      END        
