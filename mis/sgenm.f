      SUBROUTINE SGENM (NTYPE,IFILE,SFILE,OFILE,ICODE,OCODE,CTYPES,     
     1                  CTYPEO)        
C        
C     THIS SUBROUTINE MERGES CONVERTED SUBSTRUCTURING DATA WITH EXISTING
C     NASTRAN DATA        
C        
C     INPUTS        
C     NTYPE  - NUMBER OF DIFFERENT SUBSTRUCTURING CARDS        
C     IFILE  - INPUT FILE NAME        
C     SFILE  - SCRATCH FILE NAME        
C     OFILE  - OUTPUT FILE NAME        
C     ICODE  - LOCATE CODES FOR INPUT CARD TYPES        
C     OCODE  - LOCATE CODES FOR OUTPUT CARD TYPES        
C     CTYPES - BCD NAMES OF SUBSTRUCTURING CARDS        
C     CTYPEO - BCD NAMES OF CORRESPONDING NASTRAN CARDS        
C        
      INTEGER         SFILE,OFILE,ICODE(4,1),OCODE(4,1),CTYPES(2,8),    
     1                CTYPEO(2,8),BUF1,BUF2,BUF3,Z,SYSBUF,OUTT,CARD(3), 
     2                N65535(3),SUBNAM(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / IDRY,NAME(2)        
      COMMON /SGENCM/ NONO,NSS,IPTR,BUF1,BUF2,BUF3,NZ        
CZZ   COMMON /ZZSGEN/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,OUTT        
      DATA    N65535/ 3*65535 /        
      DATA    SUBNAM/ 4HSGEN,4HM    /        
C        
C     OPEN FILES        
C        
      CALL GOPEN (IFILE,Z(BUF1),0)        
      CALL GOPEN (SFILE,Z(BUF2),0)        
      CALL GOPEN (OFILE,Z(BUF3),1)        
C        
C     READ HEADER FROM IFILE - DETERMINE IF SUBSTRUCTURING OR NASTRAN   
C     CARD        
C        
      FILE = IFILE        
   10 CALL READ (*1002,*1003,IFILE,CARD,3,0,IDX)        
      IF (CARD(1) .EQ. N65535(1)) GO TO 70        
      DO 20 I = 1,NTYPE        
      IF (ICODE(1,I).NE.CARD(1) .OR. ICODE(2,I).NE.CARD(2)) GO TO 20    
C        
C     SKIP RECORD IF SUBSTRUCTURING CARD        
C        
      CALL FWDREC (*70,IFILE)        
      GO TO 10        
   20 CONTINUE        
      DO 30 I = 1,NTYPE        
      IF (OCODE(1,I).NE.CARD(1) .OR. OCODE(2,I).NE.CARD(2)) GO TO 30    
C        
C     FATAL ERROR IF BOTH SUBSTRUCTURING AND NASTRAN CARDS        
C        
      IF (ICODE(4,I) .EQ. 0) GO TO 40        
      NONO = 1        
      J = OCODE(4,I)        
      WRITE (OUTT,6330) UFM,NAME,(CTYPES(K,J),K=1,2),(CTYPEO(K,J),K=1,2)
      CALL FWDREC (*70,IFILE)        
      GO TO 10        
   30 CONTINUE        
C        
C     COPY RECORD FROM IFILE TO OUTPUT        
C        
   40 CALL WRITE (OFILE,CARD,3,0)        
   50 CALL READ  (*1002,*60,IFILE,Z,NZ,0,NWDS)        
      CALL WRITE (OFILE,Z,NZ,0)        
      GO TO 50        
   60 CALL WRITE (OFILE,Z,NWDS,1)        
      GO TO 10        
C        
C     COPY RECORD FROM SFILE TO OUTPUT        
C        
   70 I1 = 1        
   80 DO 90 I = I1,NTYPE        
      IF (ICODE(4,I) .EQ. 1) GO TO 100        
   90 CONTINUE        
      GO TO 150        
  100 CALL FREAD (SFILE,CARD,3,0)        
      CALL WRITE (OFILE,OCODE(1,I),3,0)        
      FILE = SFILE        
  110 CALL READ  (*1002,*120,SFILE,Z,NZ,0,NWDS)        
      CALL WRITE (OFILE,Z,NZ,0)        
      GO TO 110        
  120 CALL WRITE (OFILE,Z,NWDS,1)        
      I1 = I + 1        
      GO TO 80        
C        
C     CLOSE FILES        
C        
  150 CALL WRITE (OFILE,N65535,3,1)        
      CALL CLOSE (IFILE,1)        
      CALL CLOSE (SFILE,1)        
      CALL CLOSE (OFILE,1)        
      RETURN        
C        
C     ERRORS        
C        
 1002 M = -2        
      GO TO 2000        
 1003 M = -3        
 2000 CALL MESAGE (M,FILE,SUBNAM)        
      RETURN        
C        
 6330 FORMAT (A23,' 6330, SOLUTION SUBSTRUCTURE ',2A4,3H - ,2A4,' AND ',
     1       2A4,' CARDS CANNOT BE USED TOGETHER.', /30X,        
     2       'USE EITHER ONE, BUT NOT BOTH.')        
      END        
