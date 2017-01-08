      SUBROUTINE OFPCC2 (IX, L1, L2, L3, L4, L5, IPOINT)
C*****
C     SETS HEADER LINE FORMATS FOR COMPLEX ELEMENT STRESSES IN
C     MATERIAL COORDINATE SYSTEM  --  SORT 2 OUTPUT
C*****
      DIMENSION IDATA(48)
C
      DATA IDATA/4003,108, 139, 125, 0, 433, 4031,108, 139, 126, 0, 433,
     *           4003,108, 140, 125, 0, 433, 4031,108, 140, 126, 0, 433,
     *           4003,108, 135, 125, 0, 433, 4031,108, 135, 126, 0, 433,
     *           4003,108, 134, 125, 0, 433, 4031,108, 134, 126, 0, 433/
C                                                                       
      IX = IDATA(IPOINT  )
      L1 = IDATA(IPOINT+1)
      L2 = IDATA(IPOINT+2)
      L3 = IDATA(IPOINT+3)
      L4 = IDATA(IPOINT+4)
      L5 = IDATA(IPOINT+5)
C
      RETURN
      END
