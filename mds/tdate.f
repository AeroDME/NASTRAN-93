      SUBROUTINE TDATE (DATE)        
C        
C     VAX VERSION        
C     ===========        
C     (ALSO SiliconGraphics, DEC/ultrix, and SUN.        
C      CRAY AND HP DO NOT HAVE IDATE)        
C        
C     THIS ROUTINE OBTAINS THE MONTH, DAY AND YEAR, IN INTEGER FORMAT   
C        
CDE   D. Everhart
CDE   07 JAN 2017
CDE   Changes how IDATE intrinsic is called.  This switches month and
CDE   day (indicies 1 & 2).  Also, Date(3) is expected to be a 2 digit
CDE   value.
CDE   INTEGER DATE(3)        
C        
CDE   CALL IDATE (DATE(1),DATE(2),DATE(3))        
C                 MONTH   DAY     YEAR        
CDE   CALL ID
      INTEGER DATE(3), TMP
      CALL IDATE(DATE)
      TMP = DATE(1)
      DATE(1) = DATE(2)
      DATE(2) = TMP
      DATE(3)=MOD(DATE(3),100)
      RETURN        
      END        
