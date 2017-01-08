      SUBROUTINE XYFIND (*,*,*,MAJID,IDZ)        
C        
      LOGICAL         RANDOM    ,RETRY        
      INTEGER         MAJID(11) ,FILE      ,VECTOR    ,VECID   ,        
     1                Z         ,EOR       ,FLAG      ,SUBC        
CZZ   COMMON /ZZXYTR/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /XYWORK/ FILE      ,TCURVE(32),NTOPS     ,PRINT   ,        
     1                IFILE     ,XAXIS(32) ,NBOTS     ,PLOT    ,        
     2                VECTOR    ,YAXIS(32) ,VECID(5)  ,PUNCH   ,        
     3                MAJOR     ,YTAXIS(32),SUBC(5)   ,CENTER  ,        
     4                RANDOM    ,YBAXIS(32),IDIN(153) ,BUF(100),        
     5                IVALUE(60),IAT       ,IDOUT(300),OUTOPN  ,        
     6                STEPS     ,NAT       ,PAPLOT    ,KNT        
      DATA    EOR   / 1 /        
C        
C     THIS SUBROUTINE LOCATES THE ID RECORD FOR A PARTICULAR ELEMENT OR 
C     POINT ID AND IF THIS IS A RANDOM PLOT IT CONSIDERS THE COMPONENT  
C        
      K = 1        
      RETRY = .FALSE.        
      ITEMP = IDZ        
      IF (SUBC(FILE)) 15,1,1        
    1 CONTINUE        
      IF (KNT) 3,15,7        
    3 CONTINUE        
      ISAV = IDIN(4)        
    5 CALL READ (*80,*110,IFILE,IDIN(1),146,1,FLAG)        
      IF (ISAV .EQ. IDIN(4)) GO TO 21        
      CALL FWDREC (*100,IFILE)        
      GO TO 5        
    7 CONTINUE        
      ISAV = IDIN(4)        
      GO TO 11        
    9 CALL FWDREC (*100,IFILE)        
   11 CALL READ (*80,*110,IFILE,IDIN(1),146,1,FLAG)        
      IF (IDIN(4) .EQ. ISAV) GO TO 9        
      GO TO 21        
   15 CALL REWIND (IFILE)        
      CALL FWDREC (*100,IFILE)        
      VECID(FILE) = 0        
   20 CALL READ (*80,*110,IFILE,IDIN(1),146,EOR,FLAG)        
   21 CONTINUE        
      IF (MAJOR .NE. IDIN(2)) GO TO 25        
      IF (SUBC(FILE) .EQ.  0) GO TO 30        
      IF (SUBC(FILE) .EQ. IDIN(4)) GO TO 30        
   25 CONTINUE        
      CALL FWDREC (*100,IFILE)        
      K = K + 1        
      GO TO 20        
C        
C     MATCH ON MAJOR ID MADE        
C        
   30 VECID(FILE) = VECTOR        
   40 IF (IDIN(5)/10 .EQ. Z(IDZ)) GO TO 90        
      ITEMP = -1        
   50 CALL FWDREC (*100,IFILE)        
      CALL READ (*80,*110,IFILE,IDIN(1),146,EOR,FLAG)        
      IF (MAJOR .EQ. IDIN(2)) GO TO 40        
C        
C     ELEMENT DATA ARE NOT IN ASCENDING SORT LIKE GRID DATA, BUT ARE    
C     SORTED BY ELEMENT NAME, THEN BY ELEMENT NUMBER.        
C     SINCE IT IS POSSIBLE FOR THE DESIRED ELEMENT TO BE AHEAD OF THE   
C     CURRENT POSITION OF FILE, REWIND AND TRY AGAIN TO FIND MISSING    
C     ELEMENT DATA FOR FORCES AND STRESSES.        
C        
   80 IF (KNT.EQ.0 .OR. RETRY .OR. SUBC(FILE).EQ.0) GO TO 82        
      RETRY = .TRUE.        
      GO TO 15        
   82 IF (SUBC(FILE) .NE. 0) GO TO 85        
      SUBC(FILE) = -1        
      RETURN        
C        
   85 CONTINUE        
      VECID(FILE) = 0        
      IDZ = ITEMP        
      CALL REWIND (IFILE)        
      CALL FWDREC (*100,IFILE)        
      RETURN 3        
C        
C     IF RANDOM CHECK COMPONENT FOR MATCH        
C        
   90 IF (Z(IDZ+1).NE.IDIN(6) .AND. RANDOM) GO TO 50        
      IF (SUBC(FILE) .EQ. 0) RETURN        
      IF (SUBC(FILE) .NE. IDIN(4)) GO TO 50        
      RETURN        
C        
C     EOF HIT WHEN AN EOF SHOULD NOT HAVE BEEN HIT        
C        
  100 RETURN 1        
C        
C     EOR HIT WHEN AN EOR SHOULD NOT HAVE BEEN HIT        
C        
  110 RETURN 2        
C        
      END        
