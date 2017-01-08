      SUBROUTINE EMGCNG        
C        
C     THIS ROUTINE OF THE -EMG- MODULE READS -CNGRNT- CARD        
C     IMAGES, IF ANY, FROM GEOM2 AND BUILDS A PAIRED LIST.        
C        
C     ON EACH -CNGRNT- DATA CARD THE  FIRST ID (NEED NOT BE THE SMALLEST
C     ID) BECOMES THE PRIMARY ID.  THIS ID WILL BE PAIRED WITH A ZERO   
C     NOW AND A NEGATIVE DICTIONARY-TABLE  ADDRESS LATER.  AS SOME OF   
C     THE ID-S APPEARING ON THE -CNGRNT- DATA CARD MAY NOT EVEN BE IN   
C     THE PROBLEM, THE FIRST ID OF A CONGRUENT GROUP REFERENCED WILL    
C     RESULT IN THE ELEMENT COMPUTATIONS AND THE SETTING OF A DICTIONARY
C     FILE TABLE ADDRESS WITH THE PRIMARY ID.        
C        
      LOGICAL         ANYCON, ERROR, HEAT        
      INTEGER         Z, GEOM2, SYSBUF, BUF, SUBR(2), CNGRNT(2), EST,   
     1                CSTM, DIT, DICTN, RD, WRT, WRTREW, RDREW, CLS,    
     2                CLSREW, PRECIS, FLAG, FLAGS        
      CHARACTER       UFM*23, UWM*25        
      COMMON /XMSSG / UFM, UWM        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /NAMES / RD, RDREW, WRT, WRTREW, CLSREW, CLS        
      COMMON /EMGFIL/ EST, CSTM, MPT, DIT, GEOM2, MATS(3), DICTN(3)     
      COMMON /EMGPRM/ ICORE, JCORE, NCORE, ICSTM, NCSTM, IMAT, NMAT,    
     1                IHMAT, NHMAT, IDIT, NDIT, ICONG, NCONG, LCONG,    
     2                ANYCON, FLAGS(3), PRECIS, ERROR, HEAT,        
     3                ICMBAR, LCSTM, LMAT, LHMAT        
CZZ   COMMON /ZZEMGX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (KSYSTM(1), SYSBUF), (KSYSTM(2), NOUT)        
      DATA    SUBR  / 4HEMGC,  4HNG  /, NOEOR / 0 /, CNGRNT / 5008,50 / 
C        
      BUF = NCORE - SYSBUF - 2        
      IF (BUF .LE. JCORE) CALL MESAGE (-8,JCORE-BUF,SUBR)        
      ANYCON= .FALSE.        
      ICONG = JCORE        
      NCONG = JCORE - 1        
      LCONG = 0        
C        
C     LOCATE -CNGRNT- BULK DATA CARDS IF ANY.        
C        
      CALL PRELOC (*90,Z(BUF),GEOM2)        
      CALL LOCATE (*80,Z(BUF),CNGRNT,FLAG)        
C        
C     PROCESS ONE DATA CARD        
C        
   10 IF (NCONG+2 .GE. BUF) GO TO 35        
      CALL READ (*40,*40,GEOM2,Z(NCONG+1),1,NOEOR,IWORDS)        
      Z(NCONG+2) = 0        
      IDPRIM = Z(NCONG+1)        
      NCONG  = NCONG + 2        
C        
C     READ ANY SECONDARY IDS.        
C        
   20 IF (NCONG+2 .GE. BUF) GO TO 35        
      CALL READ (*40,*40,GEOM2,Z(NCONG+1),1,NOEOR,IWORDS)        
C        
C     CHECK FOR THE FOLLOWING CONDITION        
C        
C     CONDITION 1        
C     ------------        
C        
C     A SECONDARY ID ON THIS CARD IS THE SAME AS THE PRIMARY ID        
C     ON THIS CARD.  THE SECONDARY ID IS IGNORED AND THE CONDITION      
C     IS INDICATED BY A USER INFORMATION MESSAGE.        
C        
      IF (Z(NCONG+1).NE.IDPRIM) GO TO 25        
C        
C     THE ABOVE CONDITION EXISTS        
C        
      CALL PAGE2 (3)        
      WRITE (NOUT,2010) UWM,IDPRIM        
      GO TO 20        
C        
   25 IF (Z(NCONG+1)) 10,20,30        
   30 Z(NCONG+2) = IDPRIM        
      NCONG = NCONG + 2        
      GO TO 20        
C        
C     INSUFFICIENT CORE TO PROCESS ALL -CNGRNT- CARDS        
C        
   35 ICRQ = NCONG + 2 - BUF        
      CALL PAGE2 (2)        
      WRITE (NOUT,2050) UWM,ICRQ        
C        
C     NO MORE -CNGRNT- CARDS        
C        
   40 LCONG = NCONG - ICONG + 1        
      IF (LCONG .LE. 0) GO TO 80        
      CALL SORT (0,0,2,1,Z(ICONG),LCONG)        
C        
C     CHECK FOR THE FOLLOWING ADDITIONAL CONDITIONS        
C        
C     CONDITION 2        
C     -----------        
C        
C     A PRIMARY ID ON A CNGRNT CARD IS ALSO USED AS A SECONDARY        
C     ID ON ANOTHER CNGRNT CARD.  THIS RESULTS IN A USER FATAL        
C     MESSAGE.        
C        
C     CONDITION 3        
C     -----------        
C        
C     A SECONDARY ID IS SPECIFIED AS CONGRUENT TO MORE THAN ONE        
C     PRIMARY ID.  THIS ALSO RESULTS IN A USER FATAL MESSAGE.        
C        
C     CONDITION 4        
C     -----------        
C        
C     A SECONDARY ID IS REDUNDANTLY SPECIFIED.  THE REDUNDANCIES ARE    
C     IGNORED AND THE CONDITION IS INDICATED BY A USER INFORMATION      
C     MESSAGE.        
C        
      NOGO   = 0        
      NCONG1 = NCONG - 2        
      DO 440 I = ICONG,NCONG1,2        
      IF (Z(I  ) .NE. Z(I+2)) GO TO 440        
      IF (Z(I+1) .EQ. Z(I+3)) GO TO 440        
      NOGO = 1        
      IF (Z(I+1).NE.0 .AND. Z(I+3).NE.0) GO TO 420        
C        
C     THIS IS CONDITION 2 DESCRIBED ABOVE        
C        
      WRITE (NOUT,2020) UFM,Z(I)        
      GO TO 440        
C        
C     THIS IS CONDITION 3 DESCRIBED ABOVE        
C        
  420 WRITE (NOUT,2030) UFM,Z(I)        
C        
  440 CONTINUE        
      IF (NOGO .EQ. 1) CALL MESAGE (-37,0,SUBR)        
      NCONG2 = NCONG1        
      DO 480 I = ICONG,NCONG1,2        
      IF (Z(I) .LT.      0) GO TO 480        
      IF (Z(I) .NE. Z(I+2)) GO TO 480        
      J = I + 2        
  450 DO 460 K = J,NCONG2,2        
      Z(K  ) = Z(K+2)        
      Z(K+1) = Z(K+3)        
  460 CONTINUE        
      LCONG = LCONG - 2        
      NCONG = NCONG - 2        
      Z(NCONG2-1) = -1        
      NCONG2 = NCONG2 - 2        
      IF (Z(J) .EQ. Z(I)) GO TO 450        
      IF (Z(I+1) .EQ.  0) GO TO 480        
C        
C     THIS IS CONDITION 4 DESCRIBED ABOVE        
C        
      CALL PAGE2 (2)        
      WRITE (NOUT,2040) UWM,Z(I)        
C        
  480 CONTINUE        
C        
C     REPLACE PRIMARY ID ASSOCIATED WITH EACH SECONDARY ID        
C     WITH LOCATION OF PRIMARY ID IN TABLE.        
C        
      LNUM   = LCONG / 2        
      ICONGZ = ICONG - 1        
      DO 60 I = ICONG,NCONG,2        
      IF (Z(I+1)) 50,60,50        
   50 KID = Z(I+1)        
      CALL BISLOC (*60,KID,Z(ICONG),2,LNUM,J)        
      Z(I+1) = ICONGZ + J        
   60 CONTINUE        
C        
C     TABLE IS COMPLETE        
C        
   80 CALL CLOSE (GEOM2,CLSREW)        
      IF (NCONG .GT. ICONG) ANYCON = .TRUE.        
      JCORE = NCONG + 1        
   90 RETURN        
C        
C        
 2010 FORMAT (A25,' 3169, PRIMARY ID',I9,' ON A CNGRNT CARD ALSO USED ',
     1       'AS A SECONDARY ID ON THE SAME CARD.', /5X,        
     3       'SECONDARY ID IGNORED.')        
 2020 FORMAT (A23,' 3170, PRIMARY ID',I9,' ON A CNGRNT CARD ALSO USED ',
     1       'AS A SECONDARY ID ON ANOTHER CNGRNT CARD.')        
 2030 FORMAT (A23,' 3171, SECONDARY ID',I9,        
     1       ' SPECIFIED AS CONGRUENT TO MORE THAN ONE PRIMARY ID.')    
 2040 FORMAT (A25,' 3172, SECONDARY ID',I9,' REDUNDANTLY SPECIFIED ON ',
     1       'CNGRNT CARDS.  REDUNDANCY IGNORED.')        
 2050 FORMAT (A25,' 3182, INSUFFICIENT CORE TO PROCESS ALL CNGRNT ',    
     1       'CARDS.  ADDITIONAL CORE NEEDED =',I8,7H WORDS.)        
C        
      END        
