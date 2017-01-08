      SUBROUTINE CONMSG (MESAGE, NWORDS, IDUMMY)        
C        
C     THIS ROUTINE IS THE CONSOLE MESSAGE WRITER FOR        
C     THE VAX VERSION OF NASTRAN        
C        
CDE   D. Everhart
CDE   07 JAN 2017
CDE   ITIME gfortran intrinsic replaces TIME call.  This intrinsic
CDE   expects a DIMENSION(3) array. CHanged ITIME dimension from (2)
CDE   to (3).  Changed TIME call to ITIME, and changed WRITE
CDE   statement accordingly.  Also renamed ITIME variable to TIME.
C        
      INTEGER CPUTIM, CPUSTR        
      INTEGER WALLTM, WALSTR        
      INTEGER TIME
C        
      DIMENSION MESAGE(1), TIME(3)        
C        
      COMMON /SYSTEM/ ISYSTM(100)        
C        
      EQUIVALENCE (ISYSTM( 2), NOUT  ),        
     *            (ISYSTM(18), CPUSTR),        
     *            (ISYSTM(32), WALSTR)        
C        
C        
C     GET THE CURRENT TIME        
C        
      CALL ITIME (TIME)        
C        
C     GET THE WALL CLOCK TIME ELAPSED SINCE THE START OF JOB        
C        
      CALL WALTIM (WALLTM)        
      WALSEC = WALLTM - WALSTR        
      IF (WALSEC.LT.0.0) WALSEC = WALSEC + 86400.0        
C        
C     GET THE CPU TIME TAKEN SINCE THE START OF JOB        
C        
      CALL KLOCK (CPUTIM)        
      CPUSEC = CPUTIM - CPUSTR        
C        
      MWORDS = MIN0 (NWORDS, 15)        
      WRITE (4, 2000) TIME(1),TIME(2), WALSEC, CPUSEC,
     &                (MESAGE(I),I = 1, MWORDS) 
      RETURN        
 2000 FORMAT (1X, 2A4, F9.1, 12H ELAPSED SEC, F10.1, 8H CPU SEC,        
     1        3X, A4,  2X, 2A4, 2X, 12A4)        
      END        
