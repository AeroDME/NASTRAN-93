      SUBROUTINE SDCIN (BLOCK,AC,N,VECS,VECD)        
C        
C     SDCIN USES GETSTR/ENDGET TO READ A ROW OF A MATRIX AND ADD THE    
C     TERMS OF THE ROW INTO A VECTOR        
C        
C     BLOCK = A 15-WORD ARRAY IN WHICH BLOCK (1) = GINO NAME        
C     AC    = A VECTOR OF N COLUMN POSITIONS (COL NBRS MAY BE .LT. 0)   
C     N     = NUMBER OF WORDS IN AC AND NUMBER OF TERMS IN VECS        
C     VECS  = A VECTOR OF N TERMS. THE POS OF EACH TERM IS DEFINED BY   
C     THE NUMBER STORED IN THE CORRESPONDING POSITION IN AC        
C     VECD  = SAME VECTOR AS VECS        
C        
      INTEGER          AC(1)    ,PRC     ,WORDS    ,RLCMPX   ,TYPE   ,  
     1                 RC       ,PREC    ,BLOCK(15)        
      REAL             VECS(1)  ,XNS(1)        
      DOUBLE PRECISION XND(1)   ,VECD(1)        
      COMMON /TYPE  /  PRC(2)   ,WORDS(4) ,RLCMPX(4)        
      COMMON /SYSTEM/  SYSBUF   ,NOUT        
CZZ   COMMON /XNSTRN/  XND        
      COMMON /ZZZZZZ/  XND        
      EQUIVALENCE      (XND(1),XNS(1))        
C        
C     PERFORM GENERAL INITIALIZATION        
C        
      TYPE = BLOCK(2)        
      PREC = PRC(TYPE)        
      RC   = RLCMPX(TYPE)        
      I    = 1        
C        
C     LOCATE POSITION IN VECTOR CORRESPONDING TO STRING        
C        
   10 IF (I .GT. N) GO TO 92        
      DO 11 J = I,N        
      IF (IABS(AC(J)) .EQ. BLOCK(4)) GO TO 12        
   11 CONTINUE        
      GO TO 90        
   12 I = J + BLOCK(6)        
      NN = BLOCK(4) + BLOCK(6) - 1        
      IF (IABS(AC(I-1)) .NE. NN) GO TO 91        
C        
C     ADD TERMS FROM STRING INTO VECTOR        
C        
      II = RC*(J-1)        
      JSTR = BLOCK(5)        
      NSTR = JSTR + RC*BLOCK(6) - 1        
      IF (PREC .EQ. 2) GO TO 24        
C        
      DO 22 JJ = JSTR,NSTR        
      II = II + 1        
      VECS(II) = VECS(II) + XNS(JJ)        
   22 CONTINUE        
      GO TO 30        
C        
   24 DO 26 JJ = JSTR,NSTR        
      II = II + 1        
      VECD(II) = VECD(II) + XND(JJ)        
   26 CONTINUE        
C        
C     CLOSE CURRENT STRING AND GET NEXT STRING        
C        
   30 CALL ENDGET (BLOCK)        
      CALL GETSTR (*99,BLOCK)        
      GO TO 10        
C        
C     LOGIC ERRORS        
C        
   90 KERR = 1        
      GO TO 97        
   91 KERR = 2        
      GO TO 97        
   92 KERR = 3        
      GO TO 97        
   97 WRITE  (NOUT,98) KERR        
   98 FORMAT (22H0*** SDCIN FATAL ERROR ,I2)        
      CALL MESAGE (-61,0,0)        
   99 RETURN        
      END        
