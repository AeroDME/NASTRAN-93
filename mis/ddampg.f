      SUBROUTINE DDAMPG        
C        
C     DDAMPG  MP,PVW/PG/V,N,NMODES/V,N,NDIR $        
C        
C     MP IS MGG*PHIG, PVW IS (PF)*SSDV*OMEGA, PARTICIPATION FACTORS X   
C     SHOCK SPECTRUM DESIGN VALUES X RADIAN FREQUENCIES.        
C     MP IS (NXM).  IF PVW IS A VECTOR (MX1), WE WANT TO MULTIPLY THE   
C     ITH. TERM INTO THE ITH. COLUMN OF MP.  PG IS THEN NXM.        
C     IF PVW IS A MATRIX (MXL), WE REPEAT THE PREVIOUS COMPUTATION FOR  
C     EACH OF THE L VECTORS, MAKING PG (NX(MXL)).        
C     NMODES IS NUMBER OF MODES. NDIR IS NUMBER OF SHOCK DIRECTIONS     
C        
      INTEGER         MP,PVW,PG,BUF1,BUF2,BUF3,FILE        
      DIMENSION       NAM(2),MCB(7)        
      COMMON /UNPAKX/ JOUT,III,NNN,JNCR        
      COMMON /PACKX / IIN,IOUT,II,NN,INCR        
      COMMON /SYSTEM/ IBUF(80)        
      COMMON /BLANK / NMODES,NDIR        
CZZ   COMMON /ZZDDMG/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      DATA    MP,PVW, PG /101,102,201/        
      DATA    NAM   / 4HDDAM,4HPG    /        
C        
C     SET UP OPEN CORE AND BUFFERS        
C        
      LCORE = KORSZ(Z)        
      BUF1  = LCORE - IBUF(1) + 1        
      BUF2  = BUF1 - IBUF(1)        
      BUF3  = BUF2 - IBUF(1)        
      LCORE = BUF3 - 1        
      IF (LCORE .LE. 0) GO TO 1008        
C        
C     PICK UP ROW AND COLUMN STATISTICS AND SET PACK/UNPACK PARAMETERS  
C        
      MCB(1) = MP        
      CALL RDTRL (MCB)        
      NCOLMP = MCB(2)        
      NMODES = NCOLMP        
      NROWMP = MCB(3)        
      MCB(1) = PVW        
      CALL RDTRL (MCB)        
      NCOLPV = MCB(2)        
      NDIR   = NCOLPV        
      NROWPV = MCB(3)        
      MCB4   = MCB(4)        
      MCB5   = MCB(5)        
C        
C        
      IF (LCORE .LT. NROWPV+NROWMP) GO TO 1008        
      IF (NCOLMP .NE. NROWPV) GO TO 1007        
      MCB(1) = PG        
      MCB(2) = 0        
      MCB(3) = NROWMP        
      MCB(4) = MCB4        
      MCB(5) = MCB5        
      MCB(6) = 0        
      MCB(7) = 0        
C        
      JOUT = 1        
      IIN  = 1        
      IOUT = 1        
      II   = 1        
      III  = 1        
      NN   = NROWMP        
      INCR = 1        
      JNCR = 1        
C        
      CALL GOPEN (MP,Z(BUF1),0)        
      CALL GOPEN (PVW,Z(BUF2),0)        
      CALL GOPEN (PG,Z(BUF3),1)        
C        
      DO 130 IJK = 1,NCOLPV        
      NNN = NROWPV        
      CALL UNPACK (*20,PVW,Z(1))        
      GO TO 60        
C        
C     NULL COLUMN FOR PVW-WRITE OUT NCOLMP ZERO COLUMNS OF LENGTH NROWMP
C        
   20 DO 30 K = 1,NROWMP        
   30 Z(K) = 0.        
      DO 56 K = 1,NCOLMP        
      CALL PACK (Z,PG,MCB)        
   56 CONTINUE        
      GO TO 125        
C        
   60 DO 120 J = 1,NCOLMP        
      NNN = NROWMP        
      CALL UNPACK (*80,MP,Z(NROWPV+1))        
      GO TO 100        
C        
   80 DO 90 K = 1,NROWMP        
      Z(NROWPV+K) = 0.        
   90 CONTINUE        
      GO TO 115        
C        
  100 DO 110 K = 1,NROWMP        
      ISUB = NROWPV + K        
      Z(ISUB) = Z(ISUB)*Z(J)        
  110 CONTINUE        
  115 CALL PACK (Z(NROWPV+1),PG,MCB)        
  120 CONTINUE        
  125 CALL REWIND (MP)        
      FILE = MP        
      CALL FWDREC (*1002,MP)        
  130 CONTINUE        
C        
      CALL WRTTRL (MCB)        
      CALL CLOSE (MP,1)        
      CALL CLOSE (PVW,1)        
      CALL CLOSE (PG,1)        
C        
      RETURN        
C        
C     FATAL ERRORS        
C        
 1002 N = -2        
      GO TO 1010        
 1007 N = -7        
      GO TO 1010        
 1008 N = -8        
      FILE = 0        
 1010 CALL MESAGE (N,FILE,NAM)        
      RETURN        
      END        
