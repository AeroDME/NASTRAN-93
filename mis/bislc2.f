      SUBROUTINE BISLC2 (*,ID,AA,NC,NR,LOC)        
C-----        
C     BINARY SEARCH ROUTINE - LOCATE ID POSTION IN AA        
C     SEARCH BY FIRST 2 WORDS (ROWS) OF ENTRIES.        
C        
C     ID  = TARGET WORD SEARCH, 2 BCD-WORDS        
C     AA  = A (NR X NC) TABLE TO SEARCH FOR ID.        
C     NR  = SIZE   OF ENTRIES (ROW   ) IN THE AA.        
C     NC  = NUMBER OF ENTRIES (COLUMN) IN THE AA.        
C     LOC = POINTER RETURNED, OF NC LOCATION        
C        
C     NONSTANDARD RETURN IN THE EVENT OF NO MATCH.        
C        
      INTEGER  ID(2),AA(NR,NC)        
C        
      KLO = 1        
      KHI = NC        
   10 K   = (KLO+KHI+1)/2        
   20 IF (ID(1) - AA(1,K)) 30,25,40        
   25 IF (ID(2) - AA(2,K)) 30,90,40        
   30 KHI = K        
      GO TO 50        
   40 KLO = K        
   50 IF (KHI-KLO -1) 100,60,10        
   60 IF (K .EQ. KLO)  GO TO 70        
      K   = KLO        
      GO TO 80        
   70 K   = KHI        
   80 KLO = KHI        
      GO TO 20        
   90 LOC = K        
      RETURN        
  100 RETURN 1        
      END        
