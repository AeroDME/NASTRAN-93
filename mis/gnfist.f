      SUBROUTINE GNFIST (FILENM,FISTNM,MODNO)        
C        
      EXTERNAL        ANDF        
      INTEGER         ANDF,FIAT,FILENM(2),FIST,FISTNM,FISTX,OSCAR       
      COMMON /XFIST / FIST(2)        
      COMMON /XFIAT / FIAT(3)        
      COMMON /XDPL  / IDPL(3)        
      COMMON /OSCENT/ OSCAR(7)        
      COMMON /IPURGE/ IPVAL(5)        
      COMMON /ISOSGN/ ISVAL(34)        
      COMMON /IXSFA / IXVAL(5)        
      COMMON /SYSTEM/ SKIP(23),ICFIAT        
      DATA    MASK1 / 65535 /,  MASK  / 32767 /        
C             MASK1 = O177777   MASK  = O77777        
C        
      DO 1 K = 1,5        
      IPVAL(K) = 0        
      IXVAL(K) = 0        
    1 CONTINUE        
      DO 2 K = 5,34        
      ISVAL(K) = 0        
    2 CONTINUE        
C        
      ISVAL(1) = 3        
      ISVAL(2) = 3        
      ISVAL(3) = 1        
      ISVAL(4) = 2        
C        
      IXVAL(3) = 10        
C        
      IF (FILENM(1).EQ.0 .AND. FILENM(2).EQ.0) RETURN        
C        
C     SEARCH FIAT FOR MATCHING FILE        
C        
      LFIAT = FIAT(3)        
      K = 5        
      DO 10 J = 1,LFIAT        
      IF (FILENM(1).EQ.FIAT(K) .AND. FILENM(2).EQ.FIAT(K+1)) GO TO 30   
   10 K = K + ICFIAT        
C        
C     FILE NOT IN FIAT - IF INPUT FILE ASSUME PURGED        
C        
      IF (FISTNM.GT.100 .AND. FISTNM.LT.200) GO TO 40        
C        
C     MUST CALL IN FILE ALLOCATOR        
C        
   20 CALL XSFA (MODNO)        
      MODNO = -MODNO        
      RETURN        
C        
C     IF FILE POINTER = 77777 NO ENTRY IS MADE IN FIST        
C        
   30 IF (ANDF(FIAT(K-1),MASK) .EQ. MASK) RETURN        
      IF (FISTNM.LE.100 .OR. FISTNM.GE.300) GO TO 170        
      IF (FISTNM .GE. 200) GO TO 120        
C        
C        
C     INPUT FILE        
C     ==========        
C        
C     SEE IF IT EXISTS        
C        
      IF (FIAT(K+2).NE.0 .OR. FIAT(K+3).NE.0 .OR. FIAT(K+4).NE.0)       
     1    GO TO 170        
      IF (ICFIAT.EQ.11 .AND. (FIAT(K+7).NE.0 .OR. FIAT(K+8).NE.0 .OR.   
     1    FIAT(K+9).NE.0)) GO TO 170        
C        
C     INPUT FILE NOT GENERATED ACCORDING TO FIAT - CHECK DPL        
C        
   40 I1 = OSCAR(7)*3 + 5        
      J1 = IDPL(3) *3 + 1        
      L  = FIAT(3) *ICFIAT - 2        
      DO 50 J = 4,J1,3        
      IF (IDPL(J).EQ.FILENM(1) .AND. IDPL(J+1).EQ.FILENM(2)) GO TO 60   
   50 CONTINUE        
      RETURN        
C        
C     FILE IN DPL - ZERO FIAT ENTRY SO FILE ALLOCATOR WILL UNPOOL IT.   
C     DO THIS FOR OTHER LIKE I/P FILES IN OSCAR ENTRY.        
C        
   60 DO 110 I = 8,I1,3        
      IF (OSCAR(I) .EQ. 0) GO TO 110        
C        
C     SEARCH FIAT        
C        
      DO 70 K = 4,L,ICFIAT        
      IF (OSCAR(I).EQ.FIAT(K+1) .AND. OSCAR(I+1).EQ.FIAT(K+2)) GO TO 80 
   70 CONTINUE        
C        
C     FILE NOT IN FIAT - CHECK NEXT INPUT FILE        
C        
      GO TO 110        
C        
C     FILE IN FIAT - CHECK DPL IF FIAT TRAILER IS ZERO        
C        
   80 IF (FIAT(K+3).NE.0 .OR. FIAT(K+4).NE.0 .OR. FIAT(K+5).NE.0 .OR.   
     1    ANDF(MASK,FIAT(K)).EQ.MASK) GO TO 110        
      IF (ICFIAT.EQ.11 .AND. (FIAT(K+8).NE.0 .OR. FIAT(K+9).NE.0 .OR.   
     1    FIAT(K+10).NE.0)) GO TO 110        
      DO 90 J = 4,J1,3        
      IF (IDPL(J).EQ.FIAT(K+1) .AND. IDPL(J+1).EQ.FIAT(K+2)) GO TO 100  
   90 CONTINUE        
      GO TO 110        
C        
C     FILE IS IN DPL - ZERO OUT FIAT ENTRY        
C        
  100 FIAT(K) = ANDF(MASK1,FIAT(K))        
      IF (ANDF(MASK,FIAT(K)) .EQ. MASK) FIAT(K) = 0        
      FIAT(K+1) = 0        
      FIAT(K+2) = 0        
  110 CONTINUE        
C        
C     CALL FILE ALLOCATOR AND UNPOOL FILES        
C        
      GO TO 20        
C        
C        
C     OUTPUT FILE        
C     ===========        
C        
C     SEARCH DPL FOR FILE NAME        
C        
  120 J1 = IDPL(3)*3 + 1        
      DO 130 M = 4,J1,3        
      IF (IDPL(M).EQ.FILENM(1) .AND. IDPL(M+1).EQ.FILENM(2)) GO TO 140  
  130 CONTINUE        
      GO TO 170        
C        
C     FILE NAME IS IN DPL - PURGE IT AND ALL EQUIV FILE FROM DPL        
C        
  140 IDPL(M  ) = 0        
      IDPL(M+1) = 0        
      L = IDPL(M+2)        
      DO 150 J = 4,J1,3        
      IF (J.EQ.M .OR. L.NE.IDPL(J+2)) GO TO 150        
      IDPL(J  ) = 0        
      IDPL(J+1) = 0        
      IDPL(J+2) = 0        
  150 CONTINUE        
C        
C     IF THIS IS LAST FILE ON POOL TAPE, DECREASE FILE COUNT IN DPL     
C        
      IF (ANDF(L,MASK) .NE. IDPL(1)-1) GO TO 160        
      IDPL(  1) = IDPL(1) - 1        
      IDPL(M+2) = 0        
C        
C     IF DELETED FILES ARE AT END OF DPL, DECREMENT ENTRY COUNT        
C        
  160 IF (IDPL(J1).NE.0 .OR. IDPL(J1+1).NE.0 .OR. IDPL(J1+2).NE.0)      
     1    GO TO 170        
      IDPL(3) = IDPL(3) - 1        
      J1 = IDPL(3)*3 + 1        
      GO TO 160        
C        
C     CHECK FOR FIST TABLE OVERFLOW        
C        
  170 IF (FIST(1) .LE. FIST(2)) CALL MESAGE (-20,IABS(MODNO),FILENM)    
      FIST(2) = FIST(2)   + 1        
      FISTX   = FIST(2)*2 + 1        
      FIST(FISTX  ) = FISTNM        
      FIST(FISTX+1) = K - 2        
      IF (FISTNM .LT. 300) RETURN        
C        
C     ZERO TRAILER FOR SCRATCH FILE        
C        
      FIAT(K+2) = 0        
      FIAT(K+3) = 0        
      FIAT(K+4) = 0        
      IF (ICFIAT .EQ. 8) GO TO 180        
      FIAT(K+7) = 0        
      FIAT(K+8) = 0        
      FIAT(K+9) = 0        
  180 RETURN        
      END        
