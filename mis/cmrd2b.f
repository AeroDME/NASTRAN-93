      SUBROUTINE CMRD2B (KODE)        
C        
C     THIS SUBROUTINE PROCESSES THE OLDMODES OPTION FLAG FOR THE CMRED2 
C     MODULE.        
C        
C     INPUT  DATA        
C     GINO - LAMAMR - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED   
C            PHISSR - RIGHT HAND EIGENVECTOR MATRIX FOR SUBSTRUCTURE    
C                     BEING REDUCED        
C            PHISSL - LEFT HAND EIGENVECTOR MATRIX FOR SUBSTRUCTURE     
C                     BEING REDUCED        
C     SOF  - LAMS   - EIGENVALUE TABLE FOR ORIGINAL SUBSTRUCTURE        
C            PHIS   - RIGHT HAND EIGENVECTOR TABLE FOR ORIGINAL        
C                     SUBSTRUCTURE        
C            PHIL   - LEFT HAND EIGENVECTOR TABLE FOR ORIGINAL        
C                     SUBSTRUCTURE        
C        
C     OUTPUT DATA        
C     GINO - LAMAMR - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED   
C            PHISS  - EIGENVECTOR MATRIX FOR SUBSTRUCTURE BEING REDUCED 
C     SOF  - LAMS   - EIGENVALUE TABLE FOR ORIGINAL SUBSTRUCTURE        
C            PHIS   - EIGENVECTOR MATRIX FOR ORIGINAL SUBSTRUCTURE      
C        
C     PARAMETERS        
C     INPUT- GBUF   - GINO BUFFER        
C            INFILE - INPUT FILE NUMBERS        
C            ISCR   - SCRATCH FILE NUMBERS        
C            KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C            OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C            MODES  - OLDMODES OPTION FLAG        
C            NFOUND - NUMBER OF MODAL POINTS USED        
C            LAMAAP - BEGINNING ADDRESS OF LAMS RECORD TO BE APPENDED   
C            MODLEN - LENGTH OF MODE USE ARRAY        
C     OTHERS-LAMAMR - LAMAMR INPUT FILE NUMBER        
C            PHIS   - PHIS INPUT FILE NUMBER        
C            LAMS   - LAMS INPUT FILE NUMBER        
C            PHISS  - PHISS INPUT FILE NUMBER        
C        
      LOGICAL         MODES        
      INTEGER         DRY,GBUF1,OLDNAM,Z,PHISSR,PHISSL,PHISL,RGDFMT     
      DIMENSION       RZ(1),MODNAM(2),ITMLST(3)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / IDUM1,DRY,IDUM7,GBUF1,IDUM2(5),INFILE(11),        
     1                IDUM3(6),ISCR(11),KORLEN,KORBGN,OLDNAM(2),        
     2                IDUM5(7),MODES,IDUM6,LAMAAP,NFOUND,MODLEN        
CZZ   COMMON /ZZCMRD/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ IDUM4,IPRNTR        
      EQUIVALENCE     (RZ(1),Z(1)),(LAMAMR,INFILE(2)),        
     1                (PHISSR,INFILE(3)),(PHISSL,INFILE(4)),        
     2                (LAMS,ISCR(5)),(PHISL,ISCR(6))        
      DATA    MODNAM/ 4HCMRD,4H2B  /        
      DATA    ITMLST/ 4HPHIS,4HPHIL,4HLAMS/        
      DATA    RGDFMT/ 3 /        
C        
C     TEST OPERATION FLAG        
C        
      IF (DRY .EQ. -2) RETURN        
      IF (KODE .EQ. 3) GO TO 20        
C        
C     TEST OLDMODES OPTION FLAG        
C        
      IF (MODES) GO TO 10        
C        
C     STORE GINO PHISS(R,L) AS PHI(S,L) ON SOF        
C        
      IFILE = PHISSR        
      IF (KODE .EQ. 2) IFILE = PHISSL        
      ITEM = ITMLST(KODE)        
      CALL MTRXO (IFILE,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 3) GO TO 120        
      RETURN        
C        
C     READ SOF PHI(S,L) ONTO GINO PHI(S,L) SCRATCH FILES        
C        
   10 ITEM = ITMLST(KODE)        
      CALL MTRXI (PHISL,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 120        
C        
C     READ SOF LAMS ONTO GINO LAMS SCRATCH FILE        
C        
      CALL SFETCH (OLDNAM,ITMLST(3),1,ITEST)        
      ITEM = ITMLST(3)        
      IF (ITEST .GT. 1) GO TO 120        
      CALL GOPEN  (LAMS,Z(GBUF1),1)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      CALL WRITE  (LAMS,Z(KORBGN),NWDSRD,1)        
      CALL SUREAD (Z(KORBGN),-1,NWDSRD,ITEST)        
      CALL WRITE  (LAMS,Z(KORBGN),NWDSRD,1)        
      CALL CLOSE  (LAMS,1)        
C        
C     SWITCH FILE NUMBERS        
C        
      IF (KODE .EQ. 1) PHISSR = PHISL        
      IF (KODE .EQ. 2) PHISSL = PHISL        
      LAMAMR = LAMS        
      RETURN        
C        
C     STORE LAMAMR (TABLE) AS LAMS ON SOF        
C        
   20 IF (MODES) GO TO 60        
      ITEM = ITMLST(3)        
      CALL DELETE (OLDNAM,ITEM,ITEST)        
      IF (ITEST.EQ.2 .OR. ITEST.GT.3) GO TO 120        
      IFILE = LAMAMR        
      CALL GOPEN  (LAMAMR,Z(GBUF1),0)        
      CALL FWDREC (*100,LAMAMR)        
      ITEST = 3        
      CALL SFETCH (OLDNAM,ITMLST(3),2,ITEST)        
      IF (ITEST .NE. 3) GO TO 120        
      DO 30 I = 1, 2        
   30 Z(KORBGN+I-1) = OLDNAM(I)        
      Z(KORBGN+2) = RGDFMT        
      Z(KORBGN+3) = MODLEN        
      CALL SUWRT (Z(KORBGN),4,2)        
      LAMWDS = MODLEN - 1        
      RZ(KORBGN+6) = 0.0        
      DO 50 I = 1,LAMWDS        
      CALL READ  (*90,*100,LAMAMR,Z(KORBGN),6,0,NWDS)        
   50 CALL SUWRT (Z(KORBGN),7,1)        
      CALL READ  (*90,*100,LAMAMR,Z(KORBGN),6,0,NWDS)        
      CALL CLOSE (LAMAMR,1)        
      CALL SUWRT (Z(KORBGN),7,2)        
      CALL SUWRT (Z(LAMAAP),MODLEN,2)        
      CALL SUWRT (Z(LAMAAP),0,3)        
   60 CONTINUE        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
   90 IMSG = -2        
      GO TO 110        
  100 IMSG = -3        
  110 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  120 GO TO (130,135,140,150,160,180), ITEST        
  130 WRITE (IPRNTR,900) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
  135 WRITE (IPRNTR,902) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
  140 IMSG = -1        
      GO TO 170        
  150 IMSG = -2        
      GO TO 170        
  160 IMSG = -3        
  170 CALL SMSG (IMSG,ITEM,OLDNAM)        
      RETURN        
C        
  180 WRITE (IPRNTR,901) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
  900 FORMAT (A23,' 6211, MODULE ',2A4,' - ITEM ',A4,        
     1       ' OF SUBSTRUCTURE ',2A4,' HAS ALREADY BEEN WRITTEN.')      
  901 FORMAT (A23,' 6632, MODULE ',2A4,' - NASTRAN MATRIX FILE FOR I/O',
     1       ' OF SOF ITEM ',A4,', SUBSTRUCTURE ',2A4,', IS PURBED.')   
  902 FORMAT (A23,' 6215, MODULE ',2A4,' - ITEM ',A4,        
     1       ' OF SUBSTRUCTURE ',2A4,' PSEUDO-EXISTS ONLY.')        
C        
      END        
