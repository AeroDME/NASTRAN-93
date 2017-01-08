      SUBROUTINE BITPAT (ICODE,IBITS)        
C        
C     THE PURPOSE OF THIS ROUTINE IS TO TRANSFORM THE DOF WORD INTO ITS 
C     NASTRAN DIGITAL REPRESENTATION.        
C        
      EXTERNAL        ORF        
      INTEGER         LIST(32),IBITS(2),ORF,INT(9)        
      COMMON /SYSTEM/ JUNK(38),NBPC,NBPW        
      DATA    IBLANK/ 4H    /        
      DATA    INT   / 1H1,1H2,1H3,1H4,1H5,1H6,1H7,1H8,1H9 /        
C        
      IBITS(1) = IBLANK        
      IBITS(2) = IBLANK        
C        
      CALL DECODE (ICODE,LIST,N)        
      IF (N .EQ. 0) RETURN        
C        
C     DO 10 I = 1,N        
C     LIST(I) = LIST(I) + 1        
C  10 CONTINUE        
C        
      J = 1        
      NBITS = -NBPC        
      DO 20 I = 1,N        
      NBITS = NBITS + NBPC        
C     IA = LIST(I)        
      IA = LIST(I)  + 1        
      K  = NBPW - NBITS        
      IBITS(J) = KLSHFT(KRSHFT(IBITS(J),K/NBPC),K/NBPC)        
      IBITS(J) = ORF(IBITS(J),KRSHFT(INT(IA),NBITS/NBPC))        
      IF (I .NE. 4) GO TO 20        
      J = 2        
      NBITS = -NBPC        
   20 CONTINUE        
      RETURN        
      END        
