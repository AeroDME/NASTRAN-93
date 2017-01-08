      SUBROUTINE CMTRCE (IERTAB,IWDS,ITOMNY)        
C        
C     THIS ROUTINE TRACES BACK IMPROPER CONNECTIONS FINDING        
C     GIRD POINT IDS FOR INTERNAL POINT  NUMBERS        
C        
      INTEGER COMBO,IERTAB(1),Z,OF,IOUT(6),NAM(2)        
C        
      COMMON /CMB003/ COMBO(7,5)        
CZZ   COMMON /ZZCOMB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ JUNK,OF,IJUNK(6),NLPP,IJ2(2),LINE        
      DATA    NHEQSS/ 4HEQSS /        
C        
      CALL SORT(0,0,4,2,IERTAB(1),IWDS)        
      IB = 1        
      CALL PAGE1        
      WRITE(OF,2000)        
      WRITE(OF,2100)        
      NLINE = NLINE + 5        
C        
   50 IPS = IERTAB(IB+1)        
      NAM(1) = COMBO(IPS,1)        
      NAM(2) = COMBO(IPS,2)        
      CALL SFETCH(NAM,NHEQSS,1,ITEST)        
      CALL SUREAD(Z(1),-1,NOUT,ITEST)        
      IPT = NOUT        
C        
C     READ EQSS FOR EACH COMPONENT        
C        
      NCOMP = 3        
      NCOMP = Z(NCOMP)        
      IST = IPT + NCOMP + 2        
      Z(IPT+1) = IST        
      DO 100 I=1,NCOMP        
      CALL SUREAD(Z(IST),-1,NOUT,ITEST)        
      Z(IPT+1+I) = NOUT + IST        
      CALL SORT(0,0,3,2,Z(IST),NOUT)        
      IST = IST + NOUT        
  100 CONTINUE        
      DO 300 I=IB,IWDS,4        
      IF( IERTAB(I+1) .NE. IPS ) GO TO 1000        
      DO 220 J=1,2        
      IP = IERTAB(I+1+J)        
      DO 210 JJ=1,NCOMP        
      II = Z(IPT+JJ)        
      NWDS = Z(IPT+JJ+1) - Z(IPT+JJ)        
      CALL BISLOC(*210,IP,Z(II+1),3,NWDS/3,ILOC)        
      IOUT(3*J) = Z(II+ILOC-1)        
      IOUT(3*J-2) = Z(2*JJ+3)        
      IOUT(3*J-1) = Z(2*JJ+4)        
      GO TO 220        
  210 CONTINUE        
  220 CONTINUE        
      LINE = LINE + 1        
      IF( LINE .LE. NLPP ) GO TO 230        
      CALL PAGE1        
      WRITE(OF,2100)        
      LINE = LINE + 2        
  230 CONTINUE        
      WRITE(OF,2200) IERTAB(I),IOUT        
  300 CONTINUE        
      GO TO 1100        
C        
C     GET NEXT PSEUDOSTRUCUTRE        
C        
 1000 IB = I        
      GO TO 50        
 1100 IF( ITOMNY .EQ. 0 ) RETURN        
      WRITE(OF,2300)        
      RETURN        
 2000 FORMAT(/1X,        
     1 61HTHE FOLLOWING CONNECTIONS HAVE BEEN FOUND TO BE INCONSISTANT.,
     2 /1X,57HATTEMPTS HAVE BEEN MADE TO CONNECT INTERNAL POINTS WITHIN,
     3 /1X,57HTHE SAME PSEUDOSTRUCTURE DUE TO SPLIT DEGREES OF FREEDOM.,
     4 /1X,79HTHESE ERRORS MUST BE RESOLVED BY THE USER VIA RELES DATA O
     5R MANUAL CONNECTIONS. /)        
 2100 FORMAT(5X,3HDOF,5X,12HSUBSTRUCTURE,5X,8H GRID ID,5X,        
     1   12HSUBSTRUCTURE,5X,8H GRID ID   /)        
 2200 FORMAT(6X,I1,10X,2A4,5X,I8,9X,2A4,5X,I8)        
 2300 FORMAT(/5X,93HTHE NUMBER OF FATAL MESSAGES EXCEEDED THE AVAILABLE 
     1STORAGE. SOME MESSAGES HAVE BEEN DELETED. )        
      END        
