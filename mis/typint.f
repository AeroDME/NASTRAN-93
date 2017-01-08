      SUBROUTINE TYPINT (X,Y,XYD,NUM,FIELD,OPT)        
C        
C     (X,Y) = STARTING OR ENDING POINT OF THE NUMBER TO BE TYPED (ALWAYS
C             LEFT-TO-RIGHT OR TOP-TO-BOTTOM).        
C     XYD   = NO ACTION IF OPT IS ZERO        
C           = (+/-)1 IF X = STARTING OR ENDING POINT OF THE NUMBER.     
C           = (+/-)2 IF Y = STARTING OR ENDING POINT OF THE NUMBER.     
C     NUM   = INTEGER NUMBER TO BE TYPED (AT MOST 10 DIGITS).        
C     FIELD = NO ACTION IF OPT IS ZERO        
C           = 1 IF THE NUMBER IS TO BE CENTERED AT (X,Y). IF XYD=1 OR 2,
C             THE NUMBER WILL BE TYPED IN THE X OR Y DIRECTION.        
C           = 0 OR -1 IF THE NUMBER IS TO BE TYPED STARTING OR ENDING AT
C             (X,Y). IF FIELD = -1, FIELD WILL BE SET TO THE NUMBER OF  
C             DIGITS PRINTED.        
C     OPT   =-1 TO INITIATE  THE TYPING MODE.        
C           =+1 TO TERMINATE THE TYPING MODE.        
C           = 0 TO TYPE A LINE.        
C        
      INTEGER         XYD,FIELD,OPT,PLOTER,ASTER,DIR,D(11)        
      COMMON /PLTDAT/ MODEL,PLOTER,SKPPLT(18),SKPA(3),CNTX,CNTY        
      DATA    ASTER , MINUS / 41,40 /        
C        
      IF (OPT .EQ. 0) GO TO 100        
      CALL TIPE (0,0,0,0,0,OPT)        
      GO TO 200        
C        
C     SEPARATE THE DIGITS OF THE NUMBER (MAXIMUM OF 10).        
C        
  100 ND = -1        
      IF (NUM .GE. 0) GO TO 110        
      ND = 0        
      D(1) = MINUS        
  110 N = IABS(NUM)        
      DO 111 I = 1,10        
      J = N/10**(10-I)        
      IF (J.EQ.0 .AND. ND.LE.0) GO TO 111        
      IF (J  .GT. 9) J  = ASTER - 1        
      IF (ND .LE. 0) ND = ND + 1        
      ND = ND + 1        
      D(ND) = J + 1        
      N = N - J*10**(10-I)        
  111 CONTINUE        
      IF (ND .GT. 0) GO TO 112        
      ND   = 1        
      D(1) = 1        
C        
  112 XX = X        
      YY = Y        
      IF (FIELD.GT.0 .AND. ND.GT.1) GO TO 120        
C        
C     THE TYPED NUMBER IS NOT TO BE CENTERED AT (X,Y).        
C        
      DIR = XYD        
      IF (FIELD .LT. 0) FIELD = ND        
      GO TO 150        
C        
C     THE TYPED NUMBER MUST BE CENTERED AT (X,Y).        
C        
  120 XY = ND/2        
      IF (ND/2 .EQ. (ND+1)/2) XY = XY - .5        
      DIR = MAX0(IABS(XYD),1)        
      IF (DIR.EQ.1) XX = X - XY*CNTX        
      IF (DIR.EQ.2) YY = Y - XY*CNTY        
C        
C     TYPE THE NUMBER.        
C        
  150 CALL TYPE10 (XX,YY,DIR,D,ND,0)        
      GO TO 200        
C        
  200 RETURN        
      END        
