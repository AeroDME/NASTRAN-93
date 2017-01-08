      SUBROUTINE OPT2D (IPR,PR)        
C-----        
C   COPY OPTP1 TO OPTP2 DATA FILE.        
C  CHANGE RECORD 3      WORD 1 = IABS (PID).        
C                       WORD 4 = PLST        
C                       WORD 5 = ALPH        
C-----        
      REAL PR(1)        
      INTEGER ZCOR     ,EOR      ,IPR(1)   ,OPTP1    ,OPTP2    ,IZ(1)   
C        
      COMMON /BLANK/ SKP1(9),NWDSP,OPTP1,SKP3(2),OPTP2,SKP4(2),NPRW     
      COMMON /NAMES / NRD,NRREW,NWRT,NWREW,NEXT        
      COMMON /OPTPW2/ ZCOR,Z(1)        
      EQUIVALENCE (IZ(1),Z(1))        
C        
C  . RECORD ZERO - COPY NAME AND 6 PARAMETERS...        
C        
      CALL FREAD (OPTP1,Z(1),8,NEXT)        
      CALL FNAME(OPTP2,Z(1))        
      CALL WRITE (OPTP2,Z(1),8,NEXT)        
C        
C  . RECORD ONE (POINTERS) AND TWO (ELEMENT DATA)...        
C        
      DO 30 I = 1,2        
      N = ZCOR        
   10 EOR = NEXT        
      CALL READ(*20,*20,OPTP1,Z,ZCOR,0,N)        
      EOR = 0        
   20 CALL WRITE (OPTP2,Z(1),N,EOR)        
      IF (EOR.EQ.0) GO TO 10        
   30 CONTINUE        
C        
C  . RECORD THREE - PROPERTY DATA...        
C        
      EOR = 0        
      DO 40 I = 1,NPRW,NWDSP        
      IPR(I) = IABS(IPR(I) )        
      PR(I+4) = -1.0        
      CALL WRITE (OPTP2,IPR(I),NWDSP,EOR)        
   40 CONTINUE        
      CALL WRITE (OPTP2,0,0,NEXT)        
C        
C  . RECORD FOUR - PLIMIT DATA...        
C        
      CALL FREAD (OPTP1,0,0,NEXT)        
      N = ZCOR        
   50 EOR = NEXT        
      CALL READ(*60,*60,OPTP1,Z,ZCOR,0,N)        
      EOR = 0        
   60 CALL WRITE (OPTP2,Z(1),N,EOR)        
      IF (EOR.EQ.0) GO TO 50        
C        
      CALL EOF (OPTP2)        
      IZ(1) = OPTP1        
      CALL RDTRL(IZ(1))        
      IZ(1) = OPTP2        
      CALL WRTTRL (IZ(1))        
      RETURN        
      END        
